#ifndef GENERATOR_H
#define GENERATOR_H

#include "export.h"
#include "sound.h"

typedef enum GeneratorResult {
    GENERATOR_OK,
    GENERATOR_ERROR,
} GeneratorResult;

typedef enum GeneratorType {
    GENERATOR_TYPE_WAVEFORM,
    GENERATOR_TYPE_PULSEWAVE,
    GENERATOR_TYPE_NOISE,
} GeneratorType;

typedef enum GeneratorWaveformType {
    GENERATOR_WAVEFORM_TYPE_SINE,
    GENERATOR_WAVEFORM_TYPE_SQUARE,
    GENERATOR_WAVEFORM_TYPE_TRIANGLE,
    GENERATOR_WAVEFORM_TYPE_SAWTOOTH
} GeneratorWaveformType;

typedef enum GeneratorNoiseType {
    GENERATOR_NOISE_TYPE_WHITE,
    GENERATOR_NOISE_TYPE_PINK,
    GENERATOR_NOISE_TYPE_BROWNIAN,
} GeneratorNoiseType;

typedef struct Generator Generator;

EXPORT Generator *generator_create(void);
EXPORT void generator_destroy(Generator *generator);
EXPORT GeneratorResult generator_init(
    Generator *generator,
    SoundFormat sound_format,
    uint32_t channels,
    uint32_t sample_rate,
    int buffer_duration_seconds  // TODO? maybe should be float/double
);
EXPORT GeneratorResult generator_set_waveform(
    Generator *generator,
    GeneratorWaveformType type,
    double frequency,
    double amplitude
);
EXPORT GeneratorResult generator_set_pulsewave(
    Generator *generator,
    double frequency,
    double amplitude,
    double dutyCycle
);
EXPORT GeneratorResult generator_set_noise(
    Generator *generator,
    GeneratorNoiseType type,
    int32_t seed,
    double amplitude
);
EXPORT GeneratorResult generator_start(Generator *generator);
EXPORT GeneratorResult generator_stop(Generator *generator);
EXPORT float generator_get_volume(Generator const *const self);
EXPORT void generator_set_volume(Generator *const self, float const value);
EXPORT int generator_get_buffer(
    Generator *const self,
    float *const output,
    size_t const floats_to_read
);
EXPORT int generator_get_available_frames(Generator *generator);

#endif  // GENERATOR_H
