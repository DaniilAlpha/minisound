#ifndef GENERATOR_H
#define GENERATOR_H

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/circular_buffer.h"

#include "export.h"

EXPORT typedef enum {
    GENERATOR_OK,
    GENERATOR_ERROR
} GeneratorResult;

EXPORT typedef struct {
    ma_waveform waveform;
    ma_pulsewave pulsewave;
    ma_noise noise;
    CircularBuffer circular_buffer;
    ma_uint32 sample_rate;
    ma_uint32 channels;
} Generator;

EXPORT Generator* generator_create(void);
EXPORT void generator_destroy(Generator* generator);
EXPORT GeneratorResult generator_init(Generator* generator, ma_format format, ma_uint32 channels, ma_uint32 sample_rate, float buffer_duration_seconds);
EXPORT GeneratorResult generator_set_waveform(Generator* generator, ma_waveform_type type, double frequency, double amplitude);
EXPORT GeneratorResult generator_set_pulsewave(Generator* generator, double frequency, double amplitude, double dutyCycle);
EXPORT GeneratorResult generator_set_noise(Generator* generator, ma_noise_type type, ma_int32 seed, double amplitude);
EXPORT ma_uint32 generator_get_buffer(Generator* generator, float* output, ma_uint32 frames_to_read);
EXPORT ma_uint32 generator_get_available_frames(Generator* generator);

#endif // GENERATOR_H