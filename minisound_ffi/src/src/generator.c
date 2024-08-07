#include "../include/generator.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

Generator *generator_create(void)
{
    Generator *generator = (Generator *)malloc(sizeof(Generator));
    if (generator == NULL)
    {
        printf("Error: Failed to allocate memory for Generator.\n");
        return NULL;
    }
    memset(generator, 0, sizeof(Generator));
    printf("Debug: Generator created successfully.\n");
    return generator;
}

void generator_destroy(Generator *generator)
{
    if (generator != NULL)
    {
        ma_waveform_uninit(&generator->waveform);
        ma_pulsewave_uninit(&generator->pulsewave);
        ma_noise_uninit(&generator->noise, NULL);
        circular_buffer_uninit(&generator->circular_buffer);
        free(generator);
        printf("Debug: Generator destroyed successfully.\n");
    }
}

void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    Generator *generator;
    generator = (Generator *)pDevice->pUserData;
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in data_callback.\n");
        return;
    }

    switch (generator->type)
    {
    case GENERATOR_TYPE_WAVEFORM:
        ma_waveform_read_pcm_frames(&generator->waveform, pOutput, frameCount, NULL);
        break;
    case GENERATOR_TYPE_PULSEWAVE:
        ma_pulsewave_read_pcm_frames(&generator->pulsewave, pOutput, frameCount, NULL);
        break;
    case GENERATOR_TYPE_NOISE:
        ma_noise_read_pcm_frames(&generator->noise, pOutput, frameCount, NULL);
        break;
    default:
        printf("Warning: Unknown generator type in data_callback.\n");
        break;
    }

    circular_buffer_write(&generator->circular_buffer, pOutput, frameCount * generator->channels);

    (void)pInput;
}

GeneratorResult generator_init(Generator *generator, ma_format format, ma_uint32 channels, ma_uint32 sample_rate, int buffer_duration_seconds)
{
    ma_device_config device_config;
    ma_device device;
    ma_context context;
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_init.\n");
        return GENERATOR_ERROR;
    }
    if (buffer_duration_seconds <= 0 || sample_rate <= 0 || channels <= 0)
    {
        printf("Error: Invalid parameters in generator_init. Buffer duration: %d, Sample rate: %u, Channels: %u\n",
               buffer_duration_seconds, sample_rate, channels);
        return GENERATOR_ERROR;
    }

    printf("Debug: Initializing generator with format: %d, channels: %u, sample rate: %u, buffer duration: %d seconds\n",
           format, channels, sample_rate, buffer_duration_seconds);

    device_config = ma_device_config_init(ma_device_type_playback);
    printf("Debug: Device config initialized.\n");
    device_config.playback.format = format;
    device_config.playback.channels = channels;
    device_config.sampleRate = sample_rate;
    device_config.dataCallback = data_callback;
    device_config.pUserData = &generator->waveform;
    generator->sample_rate = sample_rate;
    generator->channels = channels;

    if (ma_context_init(NULL, 0, NULL, &context) != MA_SUCCESS)
    {
        printf("Failed to initialize context.\n");
        return -2;
    }

    if (ma_device_init(&context, &device_config, &device) != MA_SUCCESS)
    {
        printf("Error: Failed to initialize audio device.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Audio device initialized.\n");

    size_t buffer_size_in_bytes = (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) * buffer_duration_seconds);
    if (circular_buffer_init(&generator->circular_buffer, buffer_size_in_bytes) != 0)
    {
        printf("Error: Failed to initialize circular buffer.\n");
        ma_device_uninit(&generator->device);
        return GENERATOR_ERROR;
    }

    printf("Debug: Generator initialized successfully.\n");
    return GENERATOR_OK;
}

GeneratorResult generator_set_waveform(Generator *generator, ma_waveform_type type, double frequency, double amplitude)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_set_waveform.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Setting waveform with type: %d, frequency: %f, amplitude: %f\n", type, frequency, amplitude);

    generator->device_config.pUserData = &generator->waveform;
    generator->type = GENERATOR_TYPE_WAVEFORM;

    ma_waveform_config config = ma_waveform_config_init(generator->device.playback.format, generator->device.playback.channels, generator->device.sampleRate, type, amplitude, frequency);
    if (ma_waveform_init(&config, &generator->waveform) != MA_SUCCESS)
    {
        printf("Error: Failed to initialize waveform.\n");
        return GENERATOR_ERROR;
    }

    if (ma_device_start(&generator->device) != MA_SUCCESS)
    {
        printf("Error: Failed to start playback device.\n");
        ma_waveform_uninit(&generator->waveform);
        return GENERATOR_ERROR;
    }

    printf("Debug: Waveform set successfully.\n");
    return GENERATOR_OK;
}

GeneratorResult generator_set_pulsewave(Generator *generator, double frequency, double amplitude, double dutyCycle)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_set_pulsewave.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Setting pulsewave with frequency: %f, amplitude: %f, duty cycle: %f\n", frequency, amplitude, dutyCycle);

    generator->type = GENERATOR_TYPE_PULSEWAVE;
    generator->device_config.pUserData = &generator->pulsewave;

    ma_pulsewave_config config = ma_pulsewave_config_init(ma_format_f32, generator->channels, generator->sample_rate, dutyCycle, amplitude, frequency);
    if (ma_pulsewave_init(&config, &generator->pulsewave) != MA_SUCCESS)
    {
        printf("Error: Failed to initialize pulsewave.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Pulsewave set successfully.\n");
    return GENERATOR_OK;
}

GeneratorResult generator_set_noise(Generator *generator, ma_noise_type type, ma_int32 seed, double amplitude)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_set_noise.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Setting noise with type: %d, seed: %d, amplitude: %f\n", type, seed, amplitude);

    generator->type = GENERATOR_TYPE_NOISE;
    generator->device_config.pUserData = &generator->noise;

    ma_noise_config config = ma_noise_config_init(ma_format_f32, generator->channels, type, seed, amplitude);
    if (ma_noise_init(&config, NULL, &generator->noise) != MA_SUCCESS)
    {
        printf("Error: Failed to initialize noise.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Noise set successfully.\n");
    return GENERATOR_OK;
}

GeneratorResult generator_start(Generator *generator)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_start.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Starting generator.\n");

    if (ma_device_start(&generator->device) != MA_SUCCESS)
    {
        printf("Error: Failed to start generator.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Generator started successfully.\n");
    return GENERATOR_OK;
}

GeneratorResult generator_stop(Generator *generator)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_stop.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Stopping generator.\n");

    if (ma_device_stop(&generator->device) != MA_SUCCESS)
    {
        printf("Error: Failed to stop generator.\n");
        return GENERATOR_ERROR;
    }

    printf("Debug: Generator stopped successfully.\n");
    return GENERATOR_OK;
}

ma_uint32 generator_get_available_frames(Generator *generator)
{
    if (generator == NULL)
    {
        printf("Error: Generator is NULL in generator_get_available_frames.\n");
        return 0;
    }

    size_t available_floats = circular_buffer_get_available_floats(&generator->circular_buffer);
    ma_uint32 available_frames = (ma_uint32)(available_floats / generator->channels);
    printf("Debug: Available frames: %u\n", available_frames);
    return available_frames;
}

ma_uint32 generator_get_buffer(Generator *generator, float *output, ma_uint32 frames_to_read)
{
    if (generator == NULL || output == NULL || frames_to_read <= 0)
    {
        printf("Error: Invalid parameters in generator_get_buffer. Generator: %p, Output: %p, Frames to read: %u\n",
               generator, output, frames_to_read);
        return 0;
    }

    ma_uint32 frames_read = (ma_uint32)circular_buffer_read(&generator->circular_buffer, output, frames_to_read * generator->channels);
    ma_uint32 actual_frames_read = frames_read / generator->channels;
    printf("Debug: Requested frames: %u, Actual frames read: %u\n", frames_to_read, actual_frames_read);
    return actual_frames_read;
}