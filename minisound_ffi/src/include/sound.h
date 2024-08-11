#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"

// this is just a redirection to exclude miniaudio.h from generated bindings
typedef enum SoundFormat {
    SOUND_FORMAT_UNKNOWN = 0,
    SOUND_FORMAT_U8 = 1,
    SOUND_FORMAT_S16 = 2,
    SOUND_FORMAT_S24 = 3,
    SOUND_FORMAT_S32 = 4,
    SOUND_FORMAT_F32 = 5,

    SOUND_FORMAT_COUNT
} SoundFormat;

typedef struct Sound Sound;

EXPORT Sound *sound_alloc();

Result sound_init(
    Sound *const self,

    float const *const data,
    size_t const data_size,

    SoundFormat const sound_format,
    uint32_t const channels,
    uint32_t const sample_rate,
    void *const vengine
);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT Result sound_replay(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(Sound const *const self);
EXPORT void sound_set_volume(Sound *const self, float const value);

EXPORT float sound_get_duration(Sound *const self);

EXPORT bool sound_get_is_looped(Sound const *const self);
EXPORT void
sound_set_looped(Sound *const self, bool const value, size_t const delay_ms);

#endif
