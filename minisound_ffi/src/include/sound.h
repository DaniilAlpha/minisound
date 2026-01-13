#ifndef SOUND_H
#define SOUND_H

#include "../external/result/result.h"
#include "export.h"
#include "sound_data/encoded_sound_data.h"
#include "sound_data/noise_sound_data.h"
#include "sound_data/pulse_sound_data.h"
#include "sound_data/sound_data.h"
#include "sound_data/waveform_sound_data.h"

typedef struct Sound Sound;
typedef struct ma_engine ma_engine;

EXPORT Sound *sound_alloc(void);
Result sound_init(
    Sound *const self,
    SoundData const sound_data,
    ma_engine *const engine
);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(Sound const *const self);
EXPORT void sound_set_volume(Sound *const self, float const value);

EXPORT float sound_get_duration(Sound const *const self);
EXPORT bool sound_get_is_playing(Sound const *const self);

EXPORT float sound_get_cursor(Sound const *const self);
EXPORT void sound_set_cursor(Sound *const self, float const value);

EXPORT float sound_get_pitch(Sound const *const self);
EXPORT void sound_set_pitch(Sound *const self, float const value);

EXPORT EncodedSoundData *sound_get_encoded_data(Sound const *const self);
EXPORT WaveformSoundData *sound_get_waveform_data(Sound const *const self);
EXPORT NoiseSoundData *sound_get_noise_data(Sound const *const self);
EXPORT PulseSoundData *sound_get_pulse_data(Sound const *const self);

#endif
