#ifndef PULSE_SOUND_DATA_H
#define PULSE_SOUND_DATA_H

#include "../../external/result/result.h"
#include "../../include/export.h"
#include "sound_data.h"

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
