#include "../include/record.h"

#include "../external/milo/milo.h"



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

static RecorderResult recorder_init_common(Recorder *recorder, const char *filename, int sample_rate, int channels, ma_format format, int buffer_duration_seconds)
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
    recorder->user_data = NULL;

    return RECORDER_OK;
}

RecorderResult recorder_init_file(Recorder *recorder, const char *filename, int sample_rate, int channels, ma_format format)
{
    if (filename == NULL)
    {
        return RECORDER_ERROR_INVALID_ARGUMENT;
    }
    return recorder_init_common(recorder, filename, sample_rate, channels, format, 5.0f); // 5 seconds buffer
}

RecorderResult recorder_init_stream(Recorder *recorder, int sample_rate, int channels, ma_format format, int buffer_duration_seconds)
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

int recorder_get_buffer(Recorder *recorder, float *output, int floats_to_read)
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