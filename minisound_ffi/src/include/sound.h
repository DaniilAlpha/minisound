#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "sound_data/encoded_sound_data.h"
#include "sound_data/generated_sound_data.h"
#include "sound_data/sound_data.h"

typedef struct Sound Sound;

EXPORT Sound *sound_alloc(void);
Result
sound_init(Sound *const self, SoundData const sound_data, void *const v_engine);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(Sound const *const self);
EXPORT void sound_set_volume(Sound *const self, float const value);

EXPORT double sound_get_duration(Sound *const self);

EXPORT EncodedSoundData *sound_get_encoded_data(Sound const *const self);
EXPORT WaveformSoundData *sound_get_waveform_data(Sound const *const self);
EXPORT NoiseSoundData *sound_get_noise_data(Sound const *const self);
EXPORT PulseSoundData *sound_get_pulse_data(Sound const *const self);
#endif
