#ifndef RECORD_H
#define RECORD_H

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
    int const buffer_duration_seconds
);
EXPORT RecorderResult recorder_start(Recorder *recorder);
EXPORT RecorderResult recorder_stop(Recorder *recorder);
EXPORT size_t recorder_get_available_frames(Recorder *const self);
EXPORT size_t recorder_get_buffer(
    Recorder *const self,
    float *const output,
    size_t const floats_to_read
);
EXPORT bool recorder_is_recording(Recorder const *recorder);
EXPORT void recorder_destroy(Recorder *recorder);

#endif  // RECORD_H
