#include "record.h"
#include "../external/miniaudio/include/miniaudio.h"

#include <stdlib.h>
#include <string.h>

#define SAMPLE_RATE 44100
#define CHANNELS 2
#define SAMPLE_FORMAT ma_format_f32
#define BUFFER_SIZE_SECONDS 5
#define BUFFER_SIZE (SAMPLE_RATE * CHANNELS * BUFFER_SIZE_SECONDS)

struct Recorder {
    ma_encoder encoder;
    ma_encoder_config encoder_config;
    ma_device device;
    ma_device_config device_config;
    char* filename;
    bool is_recording;
    bool is_file_recording;
    
    float buffer[BUFFER_SIZE];
    size_t buffer_write_pos;
    size_t buffer_read_pos;
    ma_mutex buffer_mutex;
};

static void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    Recorder* recorder = (Recorder*)pDevice->pUserData;
    const float* input = (const float*)pInput;
    
    ma_mutex_lock(&recorder->buffer_mutex);
    
    for (ma_uint32 i = 0; i < frameCount * CHANNELS; ++i) {
        recorder->buffer[recorder->buffer_write_pos] = input[i];
        recorder->buffer_write_pos = (recorder->buffer_write_pos + 1) % BUFFER_SIZE;
    }
    
    ma_mutex_unlock(&recorder->buffer_mutex);
    
    if (recorder->is_file_recording) {
        ma_encoder_write_pcm_frames(&recorder->encoder, pInput, frameCount, NULL);
    }
    
    (void)pOutput;
}

Recorder* recorder_create(void) {
    Recorder* recorder = (Recorder*)malloc(sizeof(Recorder));
    if (recorder == NULL) {
        return NULL;
    }
    memset(recorder, 0, sizeof(Recorder));
    return recorder;
}

static RecorderResult recorder_init_common(Recorder* recorder, const char* filename) {
    if (recorder == NULL) {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }

    recorder->is_file_recording = (filename != NULL);

    if (recorder->is_file_recording) {
        recorder->filename = strdup(filename);
        if (recorder->filename == NULL) {
            return RECORDER_ERROR_OUT_OF_MEMORY;
        }

        recorder->encoder_config = ma_encoder_config_init(ma_encoding_format_wav, SAMPLE_FORMAT, CHANNELS, SAMPLE_RATE);

        if (ma_encoder_init_file(recorder->filename, &recorder->encoder_config, &recorder->encoder) != MA_SUCCESS) {
            free(recorder->filename);
            return RECORDER_ERROR_UNKNOWN;
        }
    }

    recorder->device_config = ma_device_config_init(ma_device_type_capture);
    recorder->device_config.capture.format = SAMPLE_FORMAT;
    recorder->device_config.capture.channels = CHANNELS;
    recorder->device_config.sampleRate = SAMPLE_RATE;
    recorder->device_config.dataCallback = data_callback;
    recorder->device_config.pUserData = recorder;

    if (ma_device_init(NULL, &recorder->device_config, &recorder->device) != MA_SUCCESS) {
        if (recorder->is_file_recording) {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        return RECORDER_ERROR_UNKNOWN;
    }

    if (ma_mutex_init(&recorder->buffer_mutex) != MA_SUCCESS) {
        ma_device_uninit(&recorder->device);
        if (recorder->is_file_recording) {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        return RECORDER_ERROR_UNKNOWN;
    }

    recorder->is_recording = false;
    recorder->buffer_write_pos = 0;
    recorder->buffer_read_pos = 0;
    
    return RECORDER_OK;
}

RecorderResult recorder_init_file(Recorder* recorder, const char* filename) {
    if (filename == NULL) {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    return recorder_init_common(recorder, filename);
}

RecorderResult recorder_init_stream(Recorder* recorder) {
    return recorder_init_common(recorder, NULL);
}

RecorderResult recorder_start(Recorder* recorder) {
    if (recorder == NULL) {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    if (recorder->is_recording) {
        return RECORDER_ERROR_ALREADY_RECORDING;
    }

    if (ma_device_start(&recorder->device) != MA_SUCCESS) {
        return RECORDER_ERROR_UNKNOWN;
    }

    recorder->is_recording = true;
    return RECORDER_OK;
}

RecorderResult recorder_stop(Recorder* recorder) {
    if (recorder == NULL) {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    if (!recorder->is_recording) {
        return RECORDER_ERROR_NOT_RECORDING;
    }

    ma_device_stop(&recorder->device);
    recorder->is_recording = false;
    return RECORDER_OK;
}

bool recorder_is_recording(const Recorder* recorder) {
    return recorder != NULL && recorder->is_recording;
}

int32_t recorder_get_buffer(Recorder* recorder, float* output, int32_t frames_to_read) {
    if (recorder == NULL || output == NULL || frames_to_read <= 0) {
        return 0;
    }

    ma_mutex_lock(&recorder->buffer_mutex);

    size_t frames_available = (recorder->buffer_write_pos - recorder->buffer_read_pos + BUFFER_SIZE) % BUFFER_SIZE;
    frames_available /= CHANNELS;
    int32_t frames_to_copy = (frames_to_read < (int32_t)frames_available) ? frames_to_read : (int32_t)frames_available;

    for (int32_t i = 0; i < frames_to_copy * CHANNELS; ++i) {
        output[i] = recorder->buffer[recorder->buffer_read_pos];
        recorder->buffer_read_pos = (recorder->buffer_read_pos + 1) % BUFFER_SIZE;
    }

    ma_mutex_unlock(&recorder->buffer_mutex);

    return frames_to_copy;
}

void recorder_destroy(Recorder* recorder) {
    if (recorder != NULL) {
        ma_device_uninit(&recorder->device);
        if (recorder->is_file_recording) {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        ma_mutex_uninit(&recorder->buffer_mutex);
        free(recorder);
    }
}
