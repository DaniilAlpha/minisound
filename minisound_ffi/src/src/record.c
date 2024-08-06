#include "record.h"
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include "../external/milo/milo.h"

typedef struct
{
    float *buffer;
    size_t capacity;
    size_t write_pos;
    size_t read_pos;
    pthread_mutex_t mutex;
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

    void (*on_frames_available)(Recorder *recorder, float *frames, int frame_count);
    void *user_data;
};

static void circular_buffer_init(CircularBuffer *cb, size_t size_in_bytes)
{
    cb->buffer = (float *)malloc(size_in_bytes);
    cb->capacity = size_in_bytes / sizeof(float);
    cb->write_pos = 0;
    cb->read_pos = 0;
    pthread_mutex_init(&cb->mutex, NULL);
}

static void circular_buffer_uninit(CircularBuffer *cb)
{
    free(cb->buffer);
    cb->buffer = NULL;
    pthread_mutex_destroy(&cb->mutex);
}

static void circular_buffer_write(CircularBuffer *cb, const float *data, size_t size_in_floats)
{
    size_t to_write = size_in_floats;
    size_t write_pos = cb->write_pos;

    while (to_write > 0)
    {
        size_t available_space;
        pthread_mutex_lock(&cb->mutex);
        available_space = cb->capacity - ((write_pos - cb->read_pos + cb->capacity) % cb->capacity);
        if (available_space == 0)
        {
            // Buffer is full, move read_pos
            cb->read_pos = (cb->read_pos + 1) % cb->capacity;
        }
        pthread_mutex_unlock(&cb->mutex);

        size_t chunk = (to_write < available_space) ? to_write : available_space;
        for (size_t i = 0; i < chunk; i++)
        {
            cb->buffer[write_pos] = data[size_in_floats - to_write + i];
            write_pos = (write_pos + 1) % cb->capacity;
        }
        to_write -= chunk;
    }

    pthread_mutex_lock(&cb->mutex);
    cb->write_pos = write_pos;
    pthread_mutex_unlock(&cb->mutex);
}

static size_t circular_buffer_read(CircularBuffer *cb, float *data, size_t size_in_floats)
{
    pthread_mutex_lock(&cb->mutex);
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    size_t to_read = (size_in_floats < available) ? size_in_floats : available;
    pthread_mutex_unlock(&cb->mutex);

    for (size_t i = 0; i < to_read; i++)
    {
        size_t read_pos;
        pthread_mutex_lock(&cb->mutex);
        read_pos = cb->read_pos;
        cb->read_pos = (cb->read_pos + 1) % cb->capacity;
        pthread_mutex_unlock(&cb->mutex);

        data[i] = cb->buffer[read_pos];
    }

    return to_read;
}

static size_t circular_buffer_get_available_floats(CircularBuffer *cb)
{
    pthread_mutex_lock(&cb->mutex);
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    pthread_mutex_unlock(&cb->mutex);
    return available;
}

static size_t circular_buffer_read_available(CircularBuffer *cb, float *data, size_t max_size_in_floats)
{
    size_t read_pos, write_pos, available, to_read;

    pthread_mutex_lock(&cb->mutex);
    
    read_pos = cb->read_pos;
    write_pos = cb->write_pos;
    
    if (write_pos >= read_pos) {
        available = write_pos - read_pos;
    } else {
        available = cb->capacity - read_pos + write_pos;
    }
    
    to_read = (max_size_in_floats < available) ? max_size_in_floats : available;

    for (size_t i = 0; i < to_read; i++) {
        data[i] = cb->buffer[read_pos];
        read_pos = (read_pos + 1) % cb->capacity;
    }

    cb->read_pos = read_pos;
    
    pthread_mutex_unlock(&cb->mutex);

    return to_read;
}

static void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    Recorder *recorder = (Recorder *)pDevice->pUserData;

    size_t floatsToWrite = frameCount * recorder->channels;

    // Write raw PCM data directly to the circular buffer
    circular_buffer_write(&recorder->circular_buffer, (const float *)pInput, floatsToWrite);

    if (recorder->is_file_recording)
    {
        ma_encoder_write_pcm_frames(&recorder->encoder, pInput, frameCount, NULL);
    }

    if (recorder->on_frames_available != NULL)
    {
        recorder->on_frames_available(recorder, (float *)pInput, frameCount);
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
    recorder->on_frames_available = NULL;
    recorder->user_data = NULL;

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

RecorderResult recorder_init_stream(Recorder *recorder, ma_uint32 sample_rate, ma_uint32 channels, ma_format format, int buffer_duration_seconds)
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

int recorder_get_buffer(Recorder *recorder, float *output, ma_uint32 floats_to_read)
{
    if (recorder == NULL || output == NULL || floats_to_read <= 0)
    {
        return 0;
    }

    size_t available_floats = circular_buffer_get_available_floats(&recorder->circular_buffer);
    size_t to_read = (floats_to_read < available_floats) ? floats_to_read : available_floats;

    return (int)circular_buffer_read(&recorder->circular_buffer, output, to_read);
}

int recorder_get_available_frames(Recorder *recorder)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }

    size_t available_floats = circular_buffer_get_available_floats(&recorder->circular_buffer);
    return (int)(available_floats / recorder->channels);
}

RecorderResult recorder_start_streaming(Recorder *recorder, void (*on_frames_available)(Recorder *recorder, float *frames, int frame_count), void *user_data)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }

    recorder->on_frames_available = on_frames_available;
    recorder->user_data = user_data;

    return recorder_start(recorder);
}

RecorderResult recorder_stop_streaming(Recorder *recorder)
{
    if (recorder == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }

    recorder->on_frames_available = NULL;
    recorder->user_data = NULL;

    return recorder_stop(recorder);
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