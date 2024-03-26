#ifndef ENGINE_H
#define ENGINE_H

#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "sound.h"

typedef struct Engine Engine;

EXPORT Engine *engine_alloc();

EXPORT Result engine_init(Engine *const self, const uint32_t period_ms);
EXPORT void engine_uninit(Engine *const self);

EXPORT Result engine_start(Engine *const self);

EXPORT Result engine_load_sound(
  Engine *const self,
  Sound *const sound,
  const void *const data,
  const size_t data_size
);

#endif
