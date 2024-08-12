#ifndef GENERATOR_H
#define GENERATOR_H

#include "export.h"
#include "sound.h"

typedef enum GeneratorResult {
    GENERATOR_OK = 0,
    GENERATOR_UNKNOWN_ERROR,
    GENERATOR_DEVICE_INIT_ERROR,
    GENERATOR_ARG_ERROR,
    GENERATOR_CIRCULAR_BUFFER_INIT_ERROR,
    GENERATOR_SET_TYPE_ERROR,
    GENERATOR_DEVICE_START_ERROR,
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

EXPORT GeneratorResult generator_init(
    Generator *const self,
    SoundFormat const sound_format,
    uint32_t const channels,
    uint32_t const sample_rate,
    float const buffer_len_s
);
EXPORT void generator_uninit(Generator *const self);

EXPORT float generator_get_volume(Generator const *const self);
EXPORT void generator_set_volume(Generator *const self, float const value);

EXPORT GeneratorResult generator_set_waveform(
    Generator *const self,
    GeneratorWaveformType const type,
    double const frequency,
    double const amplitude
);
EXPORT GeneratorResult generator_set_pulsewave(
    Generator *const generator,
    double const frequency,
    double const amplitude,
    double const duty_cycle
);
EXPORT GeneratorResult generator_set_noise(
    Generator *const self,
    GeneratorNoiseType const type,
    int32_t const seed,
    double const amplitude
);

EXPORT GeneratorResult generator_start(Generator *const self);
EXPORT void generator_stop(Generator *const self);

EXPORT size_t generator_get_available_frame_count(Generator *const self);
EXPORT size_t generator_load_buffer(
    Generator *const self,
    float *const output,
    size_t const floats_to_read
);

#endif  // GENERATOR_H
