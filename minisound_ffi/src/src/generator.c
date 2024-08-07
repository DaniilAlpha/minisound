#include "../include/generator.h"
#include <stdlib.h>
#include <string.h>

Generator* generator_create(void) {
    Generator* generator = (Generator*)malloc(sizeof(Generator));
    if (generator == NULL) {
        return NULL;
    }
    memset(generator, 0, sizeof(Generator));
    return generator;
}

void generator_destroy(Generator* generator) {
    if (generator != NULL) {
        ma_waveform_uninit(&generator->waveform);
        ma_pulsewave_uninit(&generator->pulsewave);
        ma_noise_uninit(&generator->noise, NULL);
        circular_buffer_uninit(&generator->circular_buffer);
        free(generator);
    }
}

GeneratorResult generator_init(Generator* generator, ma_format format, ma_uint32 channels, ma_uint32 sample_rate, float buffer_duration_seconds) {
    if (generator == NULL) {
        return GENERATOR_ERROR;
    }

    generator->sample_rate = sample_rate;
    generator->channels = channels;

    size_t buffer_size_in_bytes = (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) * buffer_duration_seconds);
    circular_buffer_init(&generator->circular_buffer, buffer_size_in_bytes);

    return GENERATOR_OK;
}

GeneratorResult generator_set_waveform(Generator* generator, ma_waveform_type type, double frequency, double amplitude) {
    if (generator == NULL) {
        return GENERATOR_ERROR;
    }

    ma_waveform_config config = ma_waveform_config_init(ma_format_f32, generator->channels, generator->sample_rate, type, amplitude, frequency);
    ma_waveform_uninit(&generator->waveform);
    if (ma_waveform_init(&config, &generator->waveform) != MA_SUCCESS) {
        return GENERATOR_ERROR;
    }

    return GENERATOR_OK;
}

GeneratorResult generator_set_pulsewave(Generator* generator, double frequency, double amplitude, double dutyCycle) {
    if (generator == NULL) {
        return GENERATOR_ERROR;
    }

    ma_pulsewave_config config = ma_pulsewave_config_init(ma_format_f32, generator->channels, generator->sample_rate, dutyCycle, amplitude, frequency);
    ma_pulsewave_uninit(&generator->pulsewave);
    if (ma_pulsewave_init(&config, &generator->pulsewave) != MA_SUCCESS) {
        return GENERATOR_ERROR;
    }

    return GENERATOR_OK;
}

GeneratorResult generator_set_noise(Generator* generator, ma_noise_type type, ma_int32 seed, double amplitude) {
    if (generator == NULL) {
        return GENERATOR_ERROR;
    }

    ma_noise_config config = ma_noise_config_init(ma_format_f32, generator->channels, type, seed, amplitude);
    ma_noise_uninit(&generator->noise, NULL);
    if (ma_noise_init(&config, NULL, &generator->noise) != MA_SUCCESS) {
        return GENERATOR_ERROR;
    }

    return GENERATOR_OK;
}

ma_uint32 generator_get_buffer(Generator* generator, float* output, ma_uint32 frames_to_read) {
    if (generator == NULL || output == NULL || frames_to_read <= 0) {
        return 0;
    }

    ma_uint64 frames_read;
    ma_waveform_read_pcm_frames(&generator->waveform, output, frames_to_read, &frames_read);
    ma_pulsewave_read_pcm_frames(&generator->pulsewave, output, frames_to_read, &frames_read);
    ma_noise_read_pcm_frames(&generator->noise, output, frames_to_read, &frames_read);

    circular_buffer_write(&generator->circular_buffer, output, frames_read * generator->channels);

    return (ma_uint32)frames_read;
}

ma_uint32 generator_get_available_frames(Generator* generator) {
    if (generator == NULL) {
        return 0;
    }

    size_t available_floats = circular_buffer_get_available_floats(&generator->circular_buffer);
    return (ma_uint32)(available_floats / generator->channels);
}