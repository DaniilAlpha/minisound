#ifndef ENGINE_H
#define ENGINE_H

#include <stdint.h>

#include <result.h>

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
    uint8_t const *const data,
    size_t const data_size
);
EXPORT Result engine_generate_waveform(Engine *const self, Sound *const sound);
EXPORT Result engine_generate_noise(
    Engine *const self,
    Sound *const sound,
    NoiseType const type
);
EXPORT Result engine_generate_pulse(Engine *const self, Sound *const sound);

#endif
