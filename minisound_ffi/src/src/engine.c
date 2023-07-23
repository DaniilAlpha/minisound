#include "engine.h"

#include <stdbool.h>

#include <miniaudio.h>

#define MILO_LVL MILO_LVL_INFO
#include <milo.h>

/*************
 ** private **
 *************/

struct Engine {
  bool was_engine_started;

  ma_engine engine;
  ma_decoder_config dec_config;
};

struct Sound {
  ma_sound wave;
  ma_decoder decoder;
};

// sound functions

Sound *_sound_alloc() {
  Sound *const sound = malloc(sizeof(Sound));
  if (sound == NULL) error("not enough memory to allocate sound");
  return sound;
}

/************
 ** public **
 ************/

// engine functions

Engine *engine_alloc() {
  Engine *const engine = malloc(sizeof(Engine));
  if (engine == NULL) error("not enough memory to allocate engine");
  return engine;
}

Result engine_init(Engine *const self, const uint32_t period_ms) {
  self->was_engine_started = false;

  ma_engine_config engine_config = ma_engine_config_init();
  engine_config.periodSizeInMilliseconds = period_ms;
  engine_config.noAutoStart = true;
  if (ma_engine_init(&engine_config, &self->engine) != MA_SUCCESS) {
    error("cannot init audio engine");
    goto error;
  }

  self->dec_config = ma_decoder_config_init(
    self->engine.pDevice->playback.format,
    self->engine.pDevice->playback.channels,
    self->engine.sampleRate
  );

  info("engine initialized successfully!");

  return Ok;

error:
  engine_uninit(self);
  return Error;
}
void engine_uninit(Engine *const self) { ma_engine_uninit(&self->engine); }

Result engine_start(Engine *const self) {
  if (self->was_engine_started) return Ok;

  if (ma_engine_start(&self->engine) != MA_SUCCESS) {
    error("cannot start audio device");
    goto error;
  }

  self->was_engine_started = true;

  info("engine started successfully");

  return Ok;

error:
  return Error;
}

Sound *engine_load_sound(
  Engine *const self,
  const void *const data,
  const size_t data_size
) {
  Sound *const sound = _sound_alloc();
  if (sound == NULL) return NULL;

  if (ma_decoder_init_memory(data, data_size, &self->dec_config, &sound->decoder) != MA_SUCCESS) {
    error("cannot init decoder from memory");
    goto error;
  }

  if (ma_sound_init_from_data_source(&self->engine, &sound->decoder, MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION, NULL, &sound->wave) != MA_SUCCESS){
    error("cannot init sound from decoder");
    goto error;
  }

  info("sound loaded successfully!");

  return sound;

error:
  sound_unload(sound);
  return NULL;
}

// sound functions

void sound_unload(Sound *const self) {
  ma_sound_uninit(&self->wave);
  ma_decoder_uninit(&self->decoder);
  free(self);
}

Result sound_play(Sound *const self) {
  if (ma_sound_start(&self->wave) != MA_SUCCESS) {
    error("cannot play sound");
    goto error;
  }

  info("sound played successfully!");

  return Ok;

error:
  return Error;
}
void sound_pause(Sound *const self) { ma_sound_stop(&self->wave); }
void sound_stop(Sound *const self) {
  ma_sound_stop(&self->wave);
  ma_sound_seek_to_pcm_frame(&self->wave, 0);
}

float sound_get_volume(const Sound *const self) {
  return ma_sound_get_volume(&self->wave);
}
void sound_set_volume(Sound *const self, const float value) {
  ma_sound_set_volume(&self->wave, value);
}

float sound_get_duration(Sound *const self) {
  float duration = 0;
  ma_sound_get_length_in_seconds(&self->wave, &duration);
  return duration;
}
