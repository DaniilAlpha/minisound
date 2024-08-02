#ifndef RECORD_H
#define RECORD_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Recorder Recorder;

typedef enum {
    RECORDER_OK = 0,
    RECORDER_ERROR_UNKNOWN,
    RECORDER_ERROR_OUT_OF_MEMORY,
    RECORDER_ERROR_INVALID_ARGUMENT,
    RECORDER_ERROR_ALREADY_RECORDING,
    RECORDER_ERROR_NOT_RECORDING
} RecorderResult;

// Create a new recorder instance
Recorder* recorder_create(void);

// Initialize the recorder for file recording
RecorderResult recorder_init_file(Recorder* recorder, const char* filename);

// Initialize the recorder for streaming (no file output)
RecorderResult recorder_init_stream(Recorder* recorder);

// Start recording
RecorderResult recorder_start(Recorder* recorder);

// Stop recording
RecorderResult recorder_stop(Recorder* recorder);

// Check if the recorder is currently recording
bool recorder_is_recording(const Recorder* recorder);

// Get recorded audio data from the buffer
int32_t recorder_get_buffer(Recorder* recorder, float* output, int32_t frames_to_read);

// Destroy the recorder and free all associated resources
void recorder_destroy(Recorder* recorder);

#ifdef __cplusplus
}
#endif

#endif // RECORD_H
