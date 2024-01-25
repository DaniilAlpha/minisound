#include "../include/engine.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/miniaudio/include/miniaudio.h"

#include "../external/milo/include/milo.h"

/*************
 ** private **
 *************/

struct Engine {
  bool is_started;

  ma_engine engine;
  ma_decoder_config dec_config;
};

/************
 ** public **
 ************/

Engine *engine_alloc() {
  Engine *const engine = malloc(sizeof(Engine));
  if (engine == NULL) error("%s", explain(OutOfMemErr));
  return engine;
}

Result engine_init(Engine *const self, const uint32_t period_ms) {
  self->is_started = false;

  ma_engine_config engine_config = ma_engine_config_init();
  engine_config.periodSizeInMilliseconds = period_ms;
  engine_config.noAutoStart = true;
  if (ma_engine_init(&engine_config, &self->engine) != MA_SUCCESS) {
    error("miniaudio engine initialization error!");
    return UnknownErr;
  }

  self->dec_config = ma_decoder_config_init(
    self->engine.pDevice->playback.format,
    self->engine.pDevice->playback.channels,
    self->engine.sampleRate
  );

  info("engine initialized");

  return Ok;
}
void engine_uninit(Engine *const self) { ma_engine_uninit(&self->engine); }

Result engine_start(Engine *const self) {
  if (self->is_started) return Ok;

  if (ma_engine_start(&self->engine) != MA_SUCCESS) {
    error("miniaudio engine starting error!");
    return UnknownErr;
  }

  self->is_started = true;

  info("engine started");

  return Ok;
}

Result engine_load_sound(
  Engine *const self,
  Sound *const sound,
  const void *const data,
  const size_t data_size
) {
  return sound_init(sound, data, data_size, &self->dec_config, &self->engine);
}
