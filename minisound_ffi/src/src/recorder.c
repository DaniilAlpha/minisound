#include "../include/recorder.h"

#include <stdlib.h>
#include <string.h>

#include "../external/miniaudio/include/miniaudio.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** private **
 *************/

struct Recorder {
    bool is_recording;

    ma_device device;
    ma_encoder encoder;

    uint8_t *buf;
    size_t buf_len;
};

ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *buf,
    size_t const buf_len,
    size_t *const out_written_len
) {
    Recorder *const self = encoder->pUserData;

    uint8_t *const new_buf = realloc(self->buf, self->buf_len + buf_len);
    if (new_buf == NULL) return MA_OUT_OF_MEMORY;

    memcpy(new_buf + self->buf_len, buf, buf_len);

    self->buf = new_buf;
    self->buf_len += buf_len;

    if (out_written_len != NULL) *out_written_len = buf_len;

    return MA_SUCCESS;
}

ma_result encoder_on_seek(
    ma_encoder *const self,
    ma_int64 const offset,
    ma_seek_origin const origin
) {
    return MA_SUCCESS;
}

static void data_callback(
    ma_device *const device,
    void *const _,
    void const *const in_buf,
    size_t in_buf_len
) {
    (void)_;

    Recorder *const self = device->pUserData;

    // size_t const floatsToWrite = in_buf_len * self->channels;

    // // Write raw PCM data directly to the circular buffer
    // circular_buffer_write(
    //     &self->circular_buffer,
    //     (float const *)pInput,
    //     floatsToWrite
    // );

    ma_encoder_write_pcm_frames(&self->encoder, in_buf, in_buf_len, NULL);
}

/************
 ** public **
 ************/

Recorder *recorder_alloc() { return malloc(sizeof(Recorder)); }
Result recorder_init(
    Recorder *const self,
    RecorderEncoding const encoding,
    RecorderFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    self->is_recording = false;
    self->buf = NULL, self->buf_len = 0;

    ma_encoder_config const config = ma_encoder_config_init(
        (ma_encoding_format)encoding,
        (ma_format)format,
        channel_count,
        sample_rate
    );
    ma_result r = ma_encoder_init(
        encoder_on_write,
        encoder_on_seek,
        self,
        &config,
        &self->encoder
    );
    if (r != MA_SUCCESS)
        return error(
                   "miniaudio encoder initialization error! Error code: %d",
                   r
               ),
               UnknownErr;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.capture.format = (ma_format)format;
    device_config.capture.channels = channel_count;
    device_config.sampleRate = sample_rate;
    // device_config.dataCallback = data_callback;
    // device_config.pUserData = self;
    r = ma_device_init(NULL, &device_config, &self->device);
    if (r != MA_SUCCESS) {
        ma_encoder_uninit(&self->encoder);
        return error(
                   "minisudio device initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    return Ok;
}
void recorder_uninit(Recorder *const self) {
    ma_encoder_uninit(&self->encoder);
    ma_device_uninit(&self->device);
}

bool recorder_get_is_recording(Recorder const *recorder) {
    return recorder->is_recording;
}

Result recorder_start(Recorder *const self) {
    if (self->is_recording) return Ok;

    if (ma_device_start(&self->device) != MA_SUCCESS)
        return error("miniaudio device starting error!"), UnknownErr;

    self->is_recording = true;

    return Ok;
}
Recording recorder_stop(Recorder *const self) {
    ma_device_stop(&self->device);

    self->is_recording = false;

    // TODO? maybe copy in its own buffer?
    return (Recording){.buf = self->buf, .buf_len = self->buf_len};
}
