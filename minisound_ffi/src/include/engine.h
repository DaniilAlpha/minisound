#ifndef ENGINE_H
#define ENGINE_H

#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "sound.h"

typedef struct Engine Engine;

EXPORT Engine *engine_alloc(void);
EXPORT Result engine_init(Engine *const self, uint32_t const period_ms);
EXPORT void engine_uninit(Engine *const self);
EXPORT Result engine_start(Engine *const self);
EXPORT Result engine_load_sound(
    Engine *const self,
    Sound *const sound,
    float const *const data,
    size_t const data_size,
    SoundFormat const sound_format,
    uint32_t const channels,
    uint32_t const sample_rate
);

#endif
