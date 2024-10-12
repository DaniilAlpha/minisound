// TODO allow for modifying generated properties not only on init

#ifndef GENERATED_SOUND_DATA_H
#define GENERATED_SOUND_DATA_H

#include <stdint.h>

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../external/result/result.h"
#include "sound_data.h"

// waveform

typedef struct WaveformSoundData WaveformSoundData;
typedef enum WaveformType {
    WAVEFORM_TYPE_SINE,
    WAVEFORM_TYPE_SQUARE,
    WAVEFORM_TYPE_TRIANGLE,
    WAVEFORM_TYPE_SAWTOOTH
} WaveformType;

WaveformSoundData *waveform_sound_data_alloc(void);
Result waveform_sound_data_init(
    WaveformSoundData *const self,
    WaveformType const type,
    double const frequency
);
void waveform_sound_data_uninit(WaveformSoundData *const self);

SoundData waveform_sound_data_ww_sound_data(WaveformSoundData *const self);

// noise

typedef struct NoiseSoundData NoiseSoundData;
typedef enum NoiseType {
    NOISE_TYPE_WHITE,
    NOISE_TYPE_PINK,
    NOISE_TYPE_BROWNIAN,
} NoiseType;

NoiseSoundData *noise_sound_data_alloc(void);
Result noise_sound_data_init(
    NoiseSoundData *const self,
    NoiseType const type,
    int32_t const seed
);
void noise_sound_data_uninit(NoiseSoundData *const self);

SoundData noise_sound_data_ww_sound_data(NoiseSoundData *const self);

// pulse

typedef struct PulseSoundData PulseSoundData;

PulseSoundData *pulse_sound_data_alloc(void);
Result pulse_sound_data_init(
    PulseSoundData *const self,
    double const frequency,
    double const duty_cycle
);
void pulse_sound_data_uninit(PulseSoundData *const self);

SoundData pulse_sound_data_ww_sound_data(PulseSoundData *const self);

// clang-format off

// this ensures safe casting between `WaveformType` and `ma_waveform_type`
_Static_assert((int)WAVEFORM_TYPE_SINE == (int)ma_waveform_type_sine, "GENERATOR_WAVEFORM_TYPE_SINE should match ma_vaweform_type_sine.");
_Static_assert((int)WAVEFORM_TYPE_SQUARE == (int)ma_waveform_type_square, "GENERATOR_WAVEFORM_TYPE_SQUARE should match ma_waveform_type_square.");
_Static_assert((int)WAVEFORM_TYPE_TRIANGLE == (int)ma_waveform_type_triangle, "GENERATOR_WAVEFORM_TYPE_TRIANGLE should match ma_waveform_type_triangle.");
_Static_assert((int)WAVEFORM_TYPE_SAWTOOTH == (int)ma_waveform_type_sawtooth, "GENERATOR_WAVEFORM_TYPE_SAWTOOTH should match ma_waveform_type_sawtooth.");

// this ensures safe casting between `NoiseType` and `ma_noise_type`
_Static_assert((int)NOISE_TYPE_WHITE == (int)ma_noise_type_white, "GENERATOR_NOISE_TYPE_WHITE should match ma_noise_type_white.");
_Static_assert((int)NOISE_TYPE_PINK == (int)ma_noise_type_pink, "GENERATOR_NOISE_TYPE_PINK should match ma_noise_type_pink.");
_Static_assert((int)NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "GENERATOR_NOISE_TYPE_BROWNIAN should match ma_noise_type_brownian.");

// clang-format on

#endif
