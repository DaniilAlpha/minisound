#include "../../include/recorder/rec.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../external/milo/milo.h"

#define RECORDING_MIN_CAP (8192)
// #define RECORDING_FADE_MS (64)

/*************
 ** private **
 *************/

struct Rec {
    ma_encoder encoder;
    ma_rb rb;

    RecOnDataFn *on_data_available;
    size_t data_availability_threshold;
};

static inline size_t approx_1ms_size_for(
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    switch (encoding) {
    case REC_ENCODING_WAV:
        return format /* good enough */ * channel_count * sample_rate / 1000;
    default: return 4096;
    }
}

static ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *add_data,
    size_t add_data_size,
    size_t *const out_written_data_size
) {
    Rec *const self = encoder->pUserData;

    // size_t const min_target_size = self->off + add_data_size;
    // size_t new_cap = self->cap;
    // while (new_cap < min_target_size) new_cap = grow_cap(new_cap);
    // if (new_cap != self->cap) {
    //     uint8_t *const new_buf = realloc(self->buf, new_cap);
    //     if (new_buf == NULL) return MA_OUT_OF_MEMORY;
    //     self->buf = new_buf, self->cap = new_cap;
    // }
    // memcpy(self->buf + self->off, add_data, add_data_size);
    // self->off += add_data_size;
    // if (self->size < min_target_size) self->size = min_target_size;

    // waiting til the reader thread takes enough data from the rb
    // not really for thread-safety but rather for polling ellimination
    size_t const avail_size = ma_rb_available_write(&self->rb);
    size_t const insufficient_size =
        avail_size < add_data_size ? (add_data_size - avail_size) : 0;
    if (insufficient_size) {
        void *buf = NULL;
        size_t read_size = insufficient_size;
        ma_rb_acquire_read(&self->rb, &read_size, &buf);
        // ma_rb_seek_read(&self->rb, read_size);
        ma_rb_commit_read(&self->rb, read_size);

        warn(
            "recording dropped %zu bytes of data because of insufficient buffer!",
            read_size
        );
    }

    for (unsigned i = 0; add_data_size && i < 100; i++) {
        void *buf = NULL;
        size_t written_size = add_data_size;
        ma_rb_acquire_write(&self->rb, &written_size, &buf);
        memcpy(buf, add_data, written_size);
        add_data_size -= written_size;
        add_data += written_size;
        ma_rb_commit_write(&self->rb, written_size);
    }
    if (add_data_size)
        error(
            "recording buffer is insufficient for remaining %zu bytes! expect severe glitches!",
            add_data_size
        );

    if (ma_rb_available_read(&self->rb) >= self->data_availability_threshold) {
        if (self->on_data_available)
            self->on_data_available(self);
        else
            warn("`on_data_available` function is not provided!");
    }

    return *out_written_data_size = add_data_size, MA_SUCCESS;
}
static ma_result encoder_on_seek(
    ma_encoder *const encoder,
    long long const off_from_origin,
    ma_seek_origin const origin
) {
    (void)encoder, (void)off_from_origin, (void)origin;
    // Rec *const self = encoder->pUserData;

    // size_t off = 0;
    // switch (origin) {
    // case MA_SEEK_SET: off = off_from_origin; break;
    // case MA_SEEK_CUR: off = self->off + off_from_origin; break;
    // case MA_SEEK_END: off = self->size - 1 - off_from_origin; break;
    // }
    // return ma_rb_seek_write(&self->rb, off);
    return MA_NOT_IMPLEMENTED;
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

    RecOnDataFn *const on_data_available,
    uint32_t const data_availability_threshold_ms
) {
    ma_result r;

    size_t const approx_1ms_size =
        approx_1ms_size_for(encoding, format, channel_count, sample_rate);
    if ((r = ma_rb_init(100 * approx_1ms_size, NULL, NULL, &self->rb)) !=
        MA_SUCCESS)
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

    self->on_data_available = on_data_available,
    self->data_availability_threshold =
        data_availability_threshold_ms
            ? data_availability_threshold_ms * approx_1ms_size
            // default to some arbitrary value i think should be ok
            : 1 * approx_1ms_size;

    return info("recording initialized."), Ok;
}
void rec_uninit(Rec *const self) {
    ma_encoder_uninit(&self->encoder);

    ma_rb_uninit(&self->rb);
}

Result rec_write_raw(
    Rec *const self,
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

    return trace("wrote %zu bytes into the recording.", data_len_frames), Ok;
}
Result rec_read(
    Rec *const self,
    uint8_t const **const out_data,
    size_t *const out_data_size
) {
    void *buf = NULL;
    size_t read_size = ma_rb_available_read(&self->rb);

    uint8_t *const data = malloc(read_size);
    if (!data) return OutOfMemErr;
    size_t const avail_size = ma_rb_available_read(&self->rb);

    if (ma_rb_acquire_read(&self->rb, &read_size, &buf) != MA_SUCCESS ||
        !memcpy(data, buf, read_size) ||
        (printf("BUF: %zu / %zu\n", read_size, avail_size),
         fflush(stdout),
         0) ||
        ma_rb_commit_read(&self->rb, read_size) != MA_SUCCESS)
        error("miniaudio ringbuf reading failed!");

    return trace("read %zu bytes from the recording.", read_size),
         *out_data = data, *out_data_size = read_size, Ok;
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
