#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "sound_data/sound_data.h"

typedef struct Sound Sound;

EXPORT Sound *sound_alloc(void);

Result sound_init(
    Sound *const self,
    SoundData const sound_data,
    //
    // float const *const data,
    // size_t const data_size,
    //
    // SoundFormat const sound_format,
    // uint32_t const channels,
    // uint32_t const sample_rate,
    void *const v_engine
);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT Result sound_replay(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(Sound const *const self);
EXPORT void sound_set_volume(Sound *const self, float const value);

EXPORT float sound_get_duration(Sound *const self);

EXPORT void
sound_set_looped(Sound *const self, bool const value, size_t const delay_ms);

#endif
