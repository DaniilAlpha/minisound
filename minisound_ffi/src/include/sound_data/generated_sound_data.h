#ifndef GENERATED_SOUND_DATA_H
#define GENERATED_SOUND_DATA_H

#include <stdint.h>

#include "../../external/result/result.h"
#include "../../include/export.h"
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

EXPORT void waveform_sound_data_set_type(
    WaveformSoundData *const self,
    WaveformType const value
);
EXPORT void
waveform_sound_data_set_freq(WaveformSoundData *const self, double const value);

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

EXPORT void
noise_sound_data_set_seed(NoiseSoundData *const self, int32_t const seed);

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

EXPORT void
pulse_sound_data_set_freq(PulseSoundData *const self, double const value);
EXPORT void
pulse_sound_data_set_duty_cycle(PulseSoundData *const self, double const value);

SoundData pulse_sound_data_ww_sound_data(PulseSoundData *const self);

#endif
