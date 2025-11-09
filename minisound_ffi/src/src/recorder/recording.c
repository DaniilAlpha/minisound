#include "../../include/recorder/recording.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../external/milo/milo.h"

#define RECORDING_MIN_CAP (8192)
#define RECORDING_FADE_MS (64)

/*************
 ** private **
 *************/

struct Recording {
    uint8_t *buf;
    size_t off;
    size_t size, cap;

    ma_encoder encoder;
};

static inline size_t grow_cap(size_t const old_cap) { return old_cap << 1; }

static ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *const add_data,
    size_t const add_data_size,
    size_t *const out_written_data_size
) {
    Recording *const self = encoder->pUserData;

    size_t const min_target_size = self->off + add_data_size;

    size_t new_cap = self->cap;
    while (new_cap < min_target_size) new_cap = grow_cap(new_cap);
    if (new_cap != self->cap) {
        uint8_t *const new_buf = realloc(self->buf, new_cap);
        if (new_buf == NULL) return MA_OUT_OF_MEMORY;

        self->buf = new_buf, self->cap = new_cap;
    }

    memcpy(self->buf + self->off, add_data, add_data_size);
    self->off += add_data_size;
    if (self->size < min_target_size) self->size = min_target_size;

    return *out_written_data_size = add_data_size, MA_SUCCESS;
}
static ma_result encoder_on_seek(
    ma_encoder *const encoder,
    long long const off_from_origin,
    ma_seek_origin const origin
) {
    Recording *const self = encoder->pUserData;

    size_t off = 0;
    switch (origin) {
    case MA_SEEK_SET: off = off_from_origin; break;
    case MA_SEEK_CUR: off = self->off + off_from_origin; break;
    case MA_SEEK_END: off = self->size - 1 - off_from_origin; break;
    }
    if (off >= self->size) return MA_OUT_OF_RANGE;

    self->off = off;

    return MA_SUCCESS;
}

/************
 ** public **
 ************/

Recording *recording_alloc(void) { return malloc0(sizeof(Recording)); }
Result recording_init(
    Recording *const self,
    RecordingEncoding const encoding,
    RecordingFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    ma_result r;

    self->buf = malloc(RECORDING_MIN_CAP);
    if (self->buf == NULL) return OutOfMemErr;

    self->off = 0;
    self->size = 0, self->cap = RECORDING_MIN_CAP;

    ma_encoder_config const config = ma_encoder_config_init(
        (ma_encoding_format)encoding,
        (ma_format)format,
        channel_count,
        sample_rate
    );
    if ((r = ma_encoder_init(
             encoder_on_write,
             encoder_on_seek,
             self,
             &config,
             &self->encoder
         )) != MA_SUCCESS)
        return free(self->buf),
               error("miniaudio encoder initialization error (code: %i)!", r),
               UnknownErr;

    return info("recording initialized."), Ok;
}
void recording_uninit(Recording *const self) {
    ma_encoder_uninit(&self->encoder);

    free(self->buf), self->buf = NULL;
    self->off = 0;
    self->cap = self->size = 0;
}

EXPORT uint8_t const *recording_get_buf(Recording const *const self) {
    return self->buf;
}
EXPORT size_t recording_get_size(Recording const *const self) {
    return self->size;
}

Result recording_write(
    Recording *const self,
    uint8_t const *const data,
    size_t const data_len_frames
) {
    ma_result r;

    if ((r = ma_encoder_write_pcm_frames(
             &self->encoder,
             data,
             data_len_frames,
             NULL
         )) != MA_SUCCESS)
        return error("miniaudio encoder writing error (code: %i)!", r),
               UnknownErr;

    return trace("wrote data into the recording."), Ok;
}

Result recording_fit(Recording *const self) {
    uint8_t *const new_buf = realloc(self->buf, self->size);
    if (new_buf == NULL) return OutOfMemErr;

    self->buf = new_buf;

    return Ok;
}

// clang-format off

// this ensures safe casting between `RecorderEncoding` and `ma_encoder_format`
static_assert((int)RECORDING_ENCODING_WAV == (int)ma_encoding_format_wav, "`RECORDING_ENCODING_WAV` should match `ma_encoding_format_wav`.");
// static_assert((int)RECORDING_ENCODING_FLAC == (int)ma_encoding_format_flac, "`RECORDING_ENCODING_FLAC` should match `ma_encoding_format_flac`.");
// static_assert((int)RECORDING_ENCODING_MP3 == (int)ma_encoding_format_mp3, "`RECORDING_ENCODING_MP3` should match `ma_encoding_format_mp3`.");

// this ensures safe casting between `RecorderFormat` and `ma_format`
static_assert((int)RECORDING_FORMAT_U8 == (int)ma_format_u8, "`RECORDING_FORMAT_U8` should match `ma_format_u8`.");
static_assert((int)RECORDING_FORMAT_S16 == (int)ma_format_s16, "`RECORDING_FORMAT_S16` should match `ma_format_s16`.");
static_assert((int)RECORDING_FORMAT_S24 == (int)ma_format_s24, "`RECORDING_FORMAT_S24` should match `ma_format_s24`.");
static_assert((int)RECORDING_FORMAT_S32 == (int)ma_format_s32, "`RECORDING_FORMAT_S32` should match `ma_format_s32`.");
static_assert((int)RECORDING_FORMAT_F32 == (int)ma_format_f32, "`RECORDING_FORMAT_F32` should match `ma_format_f32`.");

// clang-format on
