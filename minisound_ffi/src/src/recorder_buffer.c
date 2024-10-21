#include "../include/recorder_buffer.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"
#include "../external/miniaudio/include/miniaudio.h"

#define RECORDING_MIN_CAP   (65536)
#define RECORDING_FADEIN_MS (32)

/*************
 ** private **
 *************/

struct RecorderBuffer {
    uint8_t *buf;
    size_t size, cap;
    size_t off;

    ma_encoder encoder;
};

static inline size_t grow_cap(size_t const old_cap) { return old_cap << 1; }

static ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *const data,
    size_t const data_size,
    size_t *const out_written_data_size
) {
    RecorderBuffer *const self = encoder->pUserData;

    size_t const min_target_size = self->off + data_size;
    size_t new_cap = self->cap;
    while (new_cap < min_target_size) new_cap = grow_cap(new_cap);

    if (new_cap != self->cap) {
        uint8_t *const new_buf = realloc(self->buf, new_cap);
        if (new_buf == NULL) return MA_ERROR;

        self->buf = new_buf;
        self->cap = new_cap;
    }

    memcpy(self->buf + self->off, data, data_size);
    if (self->size < min_target_size) self->size = min_target_size;
    self->off += data_size;

    size_t const frame_size = ma_get_bytes_per_frame(
        self->encoder.config.format,
        self->encoder.config.channels
    );
    size_t fade_size = RECORDING_FADEIN_MS * self->encoder.config.sampleRate /
                       1000 * frame_size;
    size_t max_size = data_size - self->off;
    if (fade_size > self->off && max_size > self->off) {
        fade_size -= self->off;
        max_size -= self->off;

        size_t const min_size = fade_size > max_size ? max_size : fade_size;

        // TODO fade in several first frames to prevent hit at start

        ma_result r = MA_SUCCESS;
        ma_fader fader;
        ma_fader_config const config = ma_fader_config_init(
            self->encoder.config.format,
            self->encoder.config.channels,
            self->encoder.config.sampleRate
        );
        if ((r = ma_fader_init(&config, &fader)) != MA_SUCCESS) return r;

        static float old_volume = 0;
        float const target_volume = (float)min_size / fade_size;
        ma_fader_set_fade(&fader, old_volume, target_volume, min_size);
        old_volume = target_volume;

        if ((r = ma_fader_process_pcm_frames(
                 &fader,
                 self->buf,
                 self->buf,
                 min_size
             )) != MA_SUCCESS)
            return r;
    }

    return *out_written_data_size = data_size, MA_SUCCESS;
}

static ma_result encoder_on_seek(
    ma_encoder *const encoder,
    long long const off_from_origin,
    ma_seek_origin const origin
) {
    RecorderBuffer *const self = encoder->pUserData;

    size_t off = 0;
    switch (origin) {
    case ma_seek_origin_start: off = off_from_origin; break;
    case ma_seek_origin_current: off = self->off + off_from_origin; break;
    case ma_seek_origin_end: off = self->size - 1 - off_from_origin; break;
    }
    if (off >= self->size) return MA_OUT_OF_RANGE;

    self->off = off;

    return MA_SUCCESS;
}

/************
 ** public **
 ************/

RecorderBuffer *recorder_buffer_alloc(void) {
    return malloc(sizeof(RecorderBuffer));
}
Result recorder_buffer_init(
    RecorderBuffer *const self,
    RecordingEncoding const encoding,
    void *const v_device
) {
    ma_device const *const device = v_device;

    self->buf = malloc(RECORDING_MIN_CAP);
    if (self->buf == NULL) return OutOfMemErr;

    self->off = self->off = 0;
    self->size = 0, self->cap = RECORDING_MIN_CAP;

    ma_encoder_config const config = ma_encoder_config_init(
        (ma_encoding_format)encoding,
        device->capture.format,
        device->capture.channels,
        device->sampleRate
    );
    ma_result const r = ma_encoder_init(
        encoder_on_write,
        encoder_on_seek,
        self,
        &config,
        &self->encoder
    );
    if (r != MA_SUCCESS) {
        free(self->buf);
        return error(
                   "miniaudio encoder initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    return info("recording initialized"), Ok;
}
void recorder_buffer_uninit(RecorderBuffer *const self) {
    ma_encoder_uninit(&self->encoder);

    free(self->buf), self->buf = NULL;
    self->cap = self->size = self->off = self->off = 0;
}

Result recorder_buffer_write(
    RecorderBuffer *const self,
    uint8_t const *const data,
    size_t const data_size
) {
    if (ma_encoder_write_pcm_frames(&self->encoder, data, data_size, NULL) !=
        MA_SUCCESS)
        return error("error writing frames to the encoder!"), UnknownErr;

    return trace("wrote to recording"), Ok;
}

Recording recorder_buffer_consume(RecorderBuffer *const self) {
    ma_encoder_uninit(&self->encoder);

    uint8_t *const new_buf = realloc(self->buf, self->size);

    Recording const recording = {
        .buf = new_buf == NULL ? self->buf : new_buf,
        .size = self->size
    };

    self->buf = NULL;
    self->cap = self->size = self->off = self->off = 0;

    return recording;
}
