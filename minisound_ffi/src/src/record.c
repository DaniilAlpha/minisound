#include "record.h"
#include "../include/miniaudio.h"
#include <stdlib.h>
#include <string.h>
#include "../external/milo/milo.h"

typedef struct
{
    uint8_t *buffer;
    size_t buffer_size;
    size_t write_pos;
    size_t read_pos;
    ma_spinlock lock;
} CircularBuffer;

struct Recorder
{
    ma_encoder encoder;
    ma_encoder_config encoder_config;
    ma_device device;
    ma_device_config device_config;
    char *filename;
    bool is_recording;
    bool is_file_recording;

    CircularBuffer circular_buffer;

    ma_uint32 sample_rate;
    ma_uint32 channels;
    ma_format format;

    uint8_t *encode_buffer;
    size_t encode_buffer_size;
    size_t encode_buffer_used;
};

static void circular_buffer_init(CircularBuffer *cb, size_t size)
{
    cb->buffer = malloc(size);
    cb->buffer_size = size;
    cb->write_pos = 0;
    cb->read_pos = 0;
    cb->lock = 0;
}

static void circular_buffer_uninit(CircularBuffer *cb)
{
    free(cb->buffer);
}

static void circular_buffer_write(CircularBuffer *cb, const void *data, size_t size)
{
    ma_spinlock_lock(&cb->lock);
    for (size_t i = 0; i < size; i++)
    {
        cb->buffer[cb->write_pos] = ((const uint8_t *)data)[i];
        cb->write_pos = (cb->write_pos + 1) % cb->buffer_size;
        if (cb->write_pos == cb->read_pos)
        {
            cb->read_pos = (cb->read_pos + 1) % cb->buffer_size;
        }
    }
    ma_spinlock_unlock(&cb->lock);
}

static size_t circular_buffer_read(CircularBuffer *cb, void *data, size_t size)
{
    ma_spinlock_lock(&cb->lock);
    size_t available = (cb->write_pos - cb->read_pos + cb->buffer_size) % cb->buffer_size;
    size_t to_read = (size < available) ? size : available;
    for (size_t i = 0; i < to_read; i++)
    {
        ((uint8_t *)data)[i] = cb->buffer[cb->read_pos];
        cb->read_pos = (cb->read_pos + 1) % cb->buffer_size;
    }
    ma_spinlock_unlock(&cb->lock);
    return to_read;
}

static void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    Recorder *recorder = (Recorder *)pDevice->pUserData;

    size_t bytesToWrite = frameCount * recorder->channels * ma_get_bytes_per_sample(recorder->format);
    
    // Write raw PCM data directly to the circular buffer
    circular_buffer_write(&recorder->circular_buffer, pInput, bytesToWrite);

    if (recorder->is_file_recording)
    {
        ma_encoder_write_pcm_frames(&recorder->encoder, pInput, frameCount, NULL);
    }

    (void)pOutput;
}

Recorder *recorder_create(void)
{
    Recorder *recorder = (Recorder *)malloc(sizeof(Recorder));
    if (recorder == NULL)
    {
        return NULL;
    }
    memset(recorder, 0, sizeof(Recorder));
    return recorder;
}

static RecorderResult recorder_init_common(Recorder *recorder, const char *filename, ma_uint32 sample_rate, ma_uint32 channels, ma_format format, float buffer_duration_seconds)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }

    recorder->is_file_recording = (filename != NULL);
    recorder->sample_rate = sample_rate;
    recorder->channels = channels;
    recorder->format = format;

    size_t buffer_size_in_bytes = (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) * buffer_duration_seconds);
    circular_buffer_init(&recorder->circular_buffer, buffer_size_in_bytes);

    if (recorder->is_file_recording)
    {
        recorder->filename = strdup(filename);
        if (recorder->filename == NULL)
        {
            circular_buffer_uninit(&recorder->circular_buffer);
            return RECORDER_ERROR_OUT_OF_MEMORY;
        }

        recorder->encoder_config = ma_encoder_config_init(ma_encoding_format_wav, format, channels, sample_rate);

        if (ma_encoder_init_file(recorder->filename, &recorder->encoder_config, &recorder->encoder) != MA_SUCCESS)
        {
            free(recorder->filename);
            circular_buffer_uninit(&recorder->circular_buffer);
            return RECORDER_ERROR_UNKNOWN;
        }
    }

    recorder->device_config = ma_device_config_init(ma_device_type_capture);
    recorder->device_config.capture.format = format;
    recorder->device_config.capture.channels = channels;
    recorder->device_config.sampleRate = sample_rate;
    recorder->device_config.dataCallback = data_callback;
    recorder->device_config.pUserData = recorder;

    if (ma_device_init(NULL, &recorder->device_config, &recorder->device) != MA_SUCCESS)
    {
        if (recorder->is_file_recording)
        {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        circular_buffer_uninit(&recorder->circular_buffer);
        return RECORDER_ERROR_UNKNOWN;
    }

    recorder->is_recording = false;

    return RECORDER_OK;
}

RecorderResult recorder_init_file(Recorder *recorder, const char *filename, ma_uint32 sample_rate, ma_uint32 channels, ma_format format)
{
    if (filename == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    return recorder_init_common(recorder, filename, sample_rate, channels, format, 5.0f); // 5 seconds buffer
}

RecorderResult recorder_init_stream(Recorder *recorder, ma_uint32 sample_rate, ma_uint32 channels, ma_format format, float buffer_duration_seconds)
{
    return recorder_init_common(recorder, NULL, sample_rate, channels, format, buffer_duration_seconds);
}

RecorderResult recorder_start(Recorder *recorder)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    if (recorder->is_recording)
    {
        return RECORDER_ERROR_ALREADY_RECORDING;
    }

    if (ma_device_start(&recorder->device) != MA_SUCCESS)
    {
        return RECORDER_ERROR_UNKNOWN;
    }
    recorder->is_recording = true;
    return RECORDER_OK;
}

RecorderResult recorder_stop(Recorder *recorder)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    if (!recorder->is_recording)
    {
        return RECORDER_ERROR_NOT_RECORDING;
    }

    ma_device_stop(&recorder->device);
    recorder->is_recording = false;
    return RECORDER_OK;
}

bool recorder_is_recording(const Recorder *recorder)
{
    return recorder != NULL && recorder->is_recording;
}

int recorder_get_buffer(Recorder *recorder, void *output, int32_t bytes_to_read)
{
    if (recorder == NULL || output == NULL || bytes_to_read <= 0)
    {
        return 0;
    }

    size_t bytes_read = circular_buffer_read(&recorder->circular_buffer, output, bytes_to_read);

    return (int)bytes_read;
}

void recorder_destroy(Recorder *recorder)
{
    if (recorder != NULL)
    {
        ma_device_uninit(&recorder->device);
        if (recorder->is_file_recording)
        {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        circular_buffer_uninit(&recorder->circular_buffer);
        free(recorder);
    }
}
