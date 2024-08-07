#ifndef ENGINE_H
#define ENGINE_H

#include <stdint.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../external/result/result.h"
#include "export.h"
#include "sound.h"

typedef struct Engine Engine;

EXPORT Engine *engine_alloc();

EXPORT Result engine_init(Engine *const self, uint32_t const period_ms);
EXPORT void engine_uninit(Engine *const self);

EXPORT Result engine_start(Engine *const self);

EXPORT Result engine_load_sound(
    Engine *const self,
    Sound *const sound,
    void const *const data,
    size_t const data_size,
    ma_format format,
    ma_uint32 sample_rate,
    ma_uint32 channels
);

#endif
