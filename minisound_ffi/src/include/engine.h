#ifndef _INC_ENGINE
#define _INC_ENGINE

#include <stdint.h>
#include <stdlib.h>

#include "export.h"
#include "result.h"

typedef struct Engine Engine;
typedef struct Sound Sound;

// engine functions

EXPORT Engine *engine_alloc();

EXPORT Result engine_init(Engine *const self, const uint32_t period_ms);
EXPORT void engine_uninit(Engine *const self);

EXPORT Result engine_start(Engine *const self);

EXPORT Sound *engine_load_sound(
  Engine *const self,
  const void *const data,
  const size_t data_size
);

// sound functions

EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(const Sound *const self);
EXPORT void sound_set_volume(Sound *const self, const float value);

EXPORT float sound_get_duration(Sound *const self);

#endif
