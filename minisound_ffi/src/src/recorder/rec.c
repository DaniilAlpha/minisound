#include "../../include/recorder/rec.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../external/milo/milo.h"

#define RECORDING_RB_ITER_LIMIT (16)
// #define RECORDING_FADE_MS (64)

/*************
 ** private **
 *************/

struct Rec {
    ma_encoder encoder;
    ma_rb rb;

    size_t data_availability_threshold;
    RecOnDataFn *on_data_available;
    RecSeekDataFn *seek_data;
};

static ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *const add_data,
    size_t const add_data_size,
    size_t *const out_written_data_size
) {
    Rec *const self = encoder->pUserData;

    size_t const avail_size = ma_rb_available_write(&self->rb);
    size_t const insufficient_size =
        avail_size < add_data_size ? (add_data_size - avail_size) : 0;
    if (insufficient_size) {
        ma_rb_seek_read(&self->rb, insufficient_size);
        warn(
            "recording dropped %zu bytes of data because of insufficient buffer! this may cause recording data corruption or just minor glitches depending on the data format and whether this happened at the beginning, middle or the end.",
            insufficient_size
        );
    }

    size_t rem_data_size = add_data_size;
    uint8_t const *rem_data = add_data;
    for (unsigned i = 0; rem_data_size && i < RECORDING_RB_ITER_LIMIT; i++) {
        void *buf = NULL;
        size_t written_size = rem_data_size;
        if (ma_rb_acquire_write(&self->rb, &written_size, &buf) != MA_SUCCESS)
            continue;

        memcpy(buf, rem_data, written_size);
        rem_data_size -= written_size;
        rem_data += written_size;

        if (ma_rb_commit_write(&self->rb, written_size) != MA_SUCCESS) continue;
    }
    if (rem_data_size)
        error(
            "could not write the remaining %zu bytes for some reason! expect severe glitches and recording data corruption!",
            rem_data_size
        );

    if (ma_rb_available_read(&self->rb) >= self->data_availability_threshold)
        if (self->on_data_available) self->on_data_available(self);

    return trace("wrote %zu bytes into the recording.", add_data_size),
         *out_written_data_size = add_data_size, MA_SUCCESS;
}
static ma_result encoder_on_seek(
    ma_encoder *const encoder,
    long long const off,
    ma_seek_origin const origin
) {
    Rec *const self = encoder->pUserData;

    self->seek_data(self, off, origin);
    return trace("seek data to %lli;%i.", off, origin), MA_SUCCESS;
}

/************
 ** public **
 ************/

Rec *rec_alloc(void) { return malloc0(sizeof(Rec)); }
Result rec_init(
    Rec *const self,
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    size_t const buf_size_frames,
    size_t const data_availability_threshold_frames,
    RecOnDataFn *const on_data_available,
    RecSeekDataFn *const seek_data
) {
    ma_result r;

    size_t const single_frame_size =
        ma_get_bytes_per_frame((ma_format)format, channel_count);
    if ((r = ma_rb_init(
             single_frame_size * buf_size_frames,
             NULL,
             NULL,
             &self->rb
         )) != MA_SUCCESS)
        return error("miniaudio ringbuf initialization error (code: %i)!", r),
               UnknownErr;

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
        return ma_rb_uninit(&self->rb),
               error("miniaudio encoder initialization error (code: %i)!", r),
               UnknownErr;

    self->data_availability_threshold =
        single_frame_size * data_availability_threshold_frames;
    self->on_data_available = on_data_available;
    self->seek_data = seek_data;

    return info("recording initialized."), Ok;
}
void rec_uninit(Rec *const self) { ma_rb_uninit(&self->rb); }

Result rec_write_raw(
    Rec *const self,
    uint8_t const *const data,
    size_t const data_len_frames
) {
    ma_result r;

    // TODO!!! add format conversion here
    if ((r = ma_encoder_write_pcm_frames(
             &self->encoder,
             data,
             data_len_frames,
             NULL
         )) != MA_SUCCESS)
        return error("miniaudio encoder writing error (code: %i)!", r),
               UnknownErr;

    return Ok;
}
Result rec_read(
    Rec *const self,
    uint8_t const **const out_data,
    size_t *const out_data_size
) {
    size_t const data_size = ma_rb_available_read(&self->rb);
    uint8_t *const data = malloc(data_size);
    if (!data) return OutOfMemErr;

    size_t rem_data_size = data_size;
    uint8_t *rem_data = data;
    for (unsigned i = 0; rem_data_size && i < RECORDING_RB_ITER_LIMIT; i++) {
        void *buf = NULL;
        size_t read_size = rem_data_size;
        if (ma_rb_acquire_read(&self->rb, &read_size, &buf) != MA_SUCCESS)
            continue;

        memcpy(rem_data, buf, read_size);
        rem_data_size -= read_size;
        rem_data += read_size;

        if (ma_rb_commit_read(&self->rb, read_size) != MA_SUCCESS) continue;
    }
    if (rem_data_size)
        error(
            "could not read the remaining %zu bytes for some reason! expect severe glitches!",
            rem_data_size
        );

    return trace("read %zu bytes from the recording.", data_size),
         *out_data = data, *out_data_size = data_size, Ok;
}
void rec_end(Rec *const self) {
    ma_encoder_uninit(&self->encoder);

    if (ma_rb_available_read(&self->rb)) self->on_data_available(self);
}

// clang-format off

// this ensures safe casting between `RecorderEncoding` and `ma_encoder_format`
static_assert((int)REC_ENCODING_WAV == (int)ma_encoding_format_wav, "`REC_ENCODING_WAV` should match `ma_encoding_format_wav`.");
// static_assert((int)REC_ENCODING_FLAC == (int)ma_encoding_format_flac, "`REC_ENCODING_FLAC` should match `ma_encoding_format_flac`.");
// static_assert((int)REC_ENCODING_MP3 == (int)ma_encoding_format_mp3, "`REC_ENCODING_MP3` should match `ma_encoding_format_mp3`.");

// this ensures safe casting between `RecorderFormat` and `ma_format`
static_assert((int)REC_FORMAT_U8 == (int)ma_format_u8, "`REC_FORMAT_U8` should match `ma_format_u8`.");
static_assert((int)REC_FORMAT_S16 == (int)ma_format_s16, "`REC_FORMAT_S16` should match `ma_format_s16`.");
static_assert((int)REC_FORMAT_S24 == (int)ma_format_s24, "`REC_FORMAT_S24` should match `ma_format_s24`.");
static_assert((int)REC_FORMAT_S32 == (int)ma_format_s32, "`REC_FORMAT_S32` should match `ma_format_s32`.");
static_assert((int)REC_FORMAT_F32 == (int)ma_format_f32, "`REC_FORMAT_F32` should match `ma_format_f32`.");

// clang-format on
