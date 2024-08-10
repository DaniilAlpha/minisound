#ifndef RECORD_H
#define RECORD_H

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "../external/miniaudio/include/miniaudio.h"

#include "circular_buffer.h"
#include "export.h"

typedef struct
{
    ma_encoder encoder;
    ma_encoder_config encoder_config;
    ma_device device;
    ma_device_config device_config;
    char *filename;
    bool is_recording;
    bool is_file_recording;

    CircularBuffer circular_buffer;

    int sample_rate;
    int channels;
    ma_format format;

    uint8_t *encode_buffer;
    size_t encode_buffer_size;
    size_t encode_buffer_used;

    void *user_data;
} Recorder;

EXPORT typedef enum {
    RECORDER_OK = 0,
    RECORDER_ERROR_UNKNOWN,
    RECORDER_ERROR_OUT_OF_MEMORY,
    RECORDER_ERROR_INVALID_ARGUMENT,
    RECORDER_ERROR_ALREADY_RECORDING,
    RECORDER_ERROR_NOT_RECORDING,
    RECORDER_ERROR_INVALID_FORMAT,
    RECORDER_ERROR_INVALID_CHANNELS
} RecorderResult;

EXPORT Recorder *recorder_create(void);
EXPORT RecorderResult recorder_init_file(Recorder *recorder, const char *filename, int sample_rate, int channels, ma_format format);
EXPORT RecorderResult recorder_init_stream(Recorder *recorder, int sample_rate, int channels, ma_format format, int buffer_duration_seconds);
EXPORT RecorderResult recorder_start(Recorder *recorder);
EXPORT RecorderResult recorder_stop(Recorder *recorder);
EXPORT int recorder_get_available_frames(Recorder *recorder);
EXPORT int recorder_get_buffer(Recorder *recorder, float *output, int floats_to_read);
EXPORT bool recorder_is_recording(const Recorder *recorder);
EXPORT void recorder_destroy(Recorder *recorder);

#endif // RECORD_H
