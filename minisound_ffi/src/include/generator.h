#ifndef GENERATOR_H
#define GENERATOR_H

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/circular_buffer.h"

#include "export.h"

typedef enum {
    GENERATOR_OK,
    GENERATOR_ERROR
} GeneratorResult;

typedef enum {
    GENERATOR_TYPE_WAVEFORM,
    GENERATOR_TYPE_PULSEWAVE,
    GENERATOR_TYPE_NOISE
} GeneratorType;

EXPORT typedef struct {
    CircularBuffer circular_buffer;
    int sample_rate;
    int channels;
    GeneratorType type;
} Generator;

EXPORT Generator* generator_create(void);
EXPORT void generator_destroy(Generator* generator);
EXPORT GeneratorResult generator_init(Generator* generator, ma_format format, int channels, int sample_rate, int buffer_duration_seconds);
EXPORT GeneratorResult generator_set_waveform(Generator* generator, ma_waveform_type type, double frequency, double amplitude);
EXPORT GeneratorResult generator_set_pulsewave(Generator* generator, double frequency, double amplitude, double dutyCycle);
EXPORT GeneratorResult generator_set_noise(Generator* generator, ma_noise_type type, int seed, double amplitude);
EXPORT GeneratorResult generator_start(Generator* generator);
EXPORT GeneratorResult generator_stop(Generator* generator);
EXPORT float generator_get_volume(Generator const *const self);
EXPORT void generator_set_volume(Generator *const self, float const value);
EXPORT int generator_get_buffer(Generator* generator, float* output, int floats_to_read);
EXPORT int generator_get_available_frames(Generator* generator);

#endif // GENERATOR_H