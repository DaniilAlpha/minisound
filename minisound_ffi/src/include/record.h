#ifndef RECORD_H
#define RECORD_H

#include <stdbool.h>
#include <stdint.h>

#include "../external/miniaudio/include/miniaudio.h"

#include "export.h"

typedef struct Recorder Recorder;

EXPORT typedef enum {
    RECORDER_OK = 0,
    RECORDER_ERROR_UNKNOWN,
    RECORDER_ERROR_OUT_OF_MEMORY,
    RECORDER_ERROR_INVALID_ARGUMENT,
    RECORDER_ERROR_ALREADY_RECORDING,
    RECORDER_ERROR_NOT_RECORDING,
    RECORDER_ERROR_INVALID_FORMAT
} RecorderResult;

// Create a new recorder instance
EXPORT Recorder *recorder_create(void);

// Initialize the recorder for file recording
EXPORT RecorderResult recorder_init_file(Recorder *recorder, const char *filename, ma_uint32 sample_rate, ma_uint32 channels, ma_format format);

// Initialize the recorder for streaming (no file output)
EXPORT RecorderResult recorder_init_stream(Recorder *recorder, ma_uint32 sample_rate, ma_uint32 channels, ma_format format, float buffer_duration_seconds);

// Start recording
EXPORT RecorderResult recorder_start(Recorder *recorder);

// Stop recording
EXPORT RecorderResult recorder_stop(Recorder *recorder);

// Check if the recorder is currently recording
EXPORT bool recorder_is_recording(const Recorder *recorder);

// Get recorded audio data from the buffer
EXPORT float recorder_get_buffer(Recorder *recorder, void *output, int32_t frames_to_read);

// Destroy the recorder and free all associated resources
EXPORT void recorder_destroy(Recorder *recorder);

#endif // RECORD_H