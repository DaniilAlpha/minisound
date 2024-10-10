#ifndef ENGINE_H
#define ENGINE_H

#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "sound.h"
#include "sound_data/generated_sound_data.h"

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
    // SoundFormat const sound_format,
    // uint32_t const channels,
    // uint32_t const sample_rate
);
EXPORT Result engine_generate_waveform(
    Engine *const self,
    Sound *const sound,
    WaveformType const type,
    double const frequency,
    double const amplitude
);

#endif
