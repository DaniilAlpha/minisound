#ifndef RECORDER_H
#define RECORDER_H

#include <stdbool.h>
#include <stdint.h>

#include "export.h"
#include "sound.h"

typedef struct Recording {
    uint8_t *const buf;
    size_t const buf_len;
} Recording;
typedef struct Recorder Recorder;
typedef enum RecorderEncoding {
    RECORDING_ENCODER_FORMAT_WAV = ma_encoding_format_wav,
    RECORDING_ENCODER_FORMAT_FLAC = ma_encoding_format_flac,
    RECORDING_ENCODER_FORMAT_MP3 = ma_encoding_format_mp3,
} RecorderEncoding;
typedef enum RecorderFormat {
    RECORDING_FORMAT_U8 = ma_format_u8,
    RECORDING_FORMAT_S16 = ma_format_s16,
    RECORDING_FORMAT_S24 = ma_format_s24,
    RECORDING_FORMAT_S32 = ma_format_s32,
    RECORDING_FORMAT_F32 = ma_format_f32,
} RecorderFormat;

EXPORT Recorder *recorder_alloc(void);
EXPORT Result recorder_init(
    Recorder *const self,
    RecorderEncoding const encoding,
    RecorderFormat const format,
    uint32_t const sample_rate,
    uint32_t const channel_count
);
EXPORT void recorder_uninit(Recorder *const self);

EXPORT bool recorder_get_is_recording(Recorder const *recorder);

EXPORT Result recorder_start(Recorder *const self);
EXPORT Recording recorder_stop(Recorder *const self);

#endif  // RECORD_H
