#ifndef WAVEFORM_SOUND_DATA_H
#define WAVEFORM_SOUND_DATA_H

#include "../../external/result/result.h"
#include "../../include/export.h"
#include "sound_data.h"

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
    int const format,
    uint32_t const channels,
    uint32_t const sample_rate
);
void waveform_sound_data_uninit(WaveformSoundData *const self);

EXPORT WaveformType waveform_sound_data_get_type(WaveformSoundData *const self);
EXPORT void waveform_sound_data_set_type(
    WaveformSoundData *const self,
    WaveformType const value
);

EXPORT double waveform_sound_data_get_freq(WaveformSoundData *const self);
EXPORT void
waveform_sound_data_set_freq(WaveformSoundData *const self, double const value);

SoundData waveform_sound_data_ww_sound_data(WaveformSoundData *const self);

#endif
