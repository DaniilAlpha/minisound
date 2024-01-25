#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>
#include <stddef.h>

#include "../external/result/result.h"
#include "export.h"

typedef struct Sound Sound;

EXPORT Sound *sound_alloc();

EXPORT Result sound_init(
  Sound *const self,
  const void *const data,
  const size_t data_size,
  const void *const dec_config,
  void *const engine
);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(const Sound *const self);
EXPORT void sound_set_volume(Sound *const self, const float value);

EXPORT float sound_get_duration(Sound *const self);

EXPORT bool sound_get_is_looped(const Sound *const self);
EXPORT Result sound_set_is_looped(Sound *const self, bool value);

#endif
