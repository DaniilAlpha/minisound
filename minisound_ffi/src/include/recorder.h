#ifndef RECORDER_H
#define RECORDER_H

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "circular_buffer.h"
#include "export.h"
#include "sound.h"

typedef enum RecorderResult {
    RECORDER_OK = 0,
    RECORDER_ERROR_UNKNOWN,
    RECORDER_ERROR_OUT_OF_MEMORY,
    RECORDER_ERROR_INVALID_ARGUMENT,
    RECORDER_ERROR_ALREADY_RECORDING,
    RECORDER_ERROR_NOT_RECORDING,
    RECORDER_ERROR_INVALID_FORMAT,
    RECORDER_ERROR_INVALID_CHANNELS
} RecorderResult;

typedef struct Recorder Recorder;

EXPORT Recorder *recorder_create(void);

EXPORT RecorderResult recorder_init_file(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format
);
EXPORT RecorderResult recorder_init_stream(
    Recorder *const self,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format,
    float const buffer_duration_seconds
);
EXPORT void recorder_uninit(Recorder *const self);

EXPORT bool recorder_get_is_recording(Recorder const *recorder);

EXPORT RecorderResult recorder_start(Recorder *const self);
EXPORT void recorder_stop(Recorder *const self);

EXPORT size_t recorder_get_available_float_count(Recorder *const self);
EXPORT size_t recorder_load_buffer(
    Recorder *const self,
    float *const output,
    size_t const floats_to_read
);

#endif  // RECORD_H
