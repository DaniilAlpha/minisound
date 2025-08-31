#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** private **
 *************/

typedef enum SoundState {
    SOUND_STATE_UNINITIALIZED = 0,
    SOUND_STATE_STOPPED,
    SOUND_STATE_PLAYING,
} SoundState;

struct Sound {
    ma_sound sound;
    ma_engine *engine;

    SoundData sound_data;

    SoundState state;
};

static void on_sound_ended(void *const vself, ma_sound *const _) {
    Sound *const self = vself;

    self->state = SOUND_STATE_STOPPED;
}

/************
 ** public **
 ************/

Sound *sound_alloc(void) { return malloc0(sizeof(Sound)); }
Result sound_init(
    Sound *const self,
    SoundData const sound_data,
    ma_engine *const engine
) {
    if (self->state != SOUND_STATE_UNINITIALIZED) return Ok;

    self->sound_data = sound_data;
    self->engine = engine;

    ma_sound_notifications notifications = ma_sound_notifications_init();
    notifications.onAtEnd = on_sound_ended;
    notifications.pUserData = self;

    ma_result const r = ma_sound_init_from_data_source(
        self->engine,
        sound_data_get_ds(&self->sound_data),
        MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
        NULL,
        &notifications,
        &self->sound
    );
    if (r != MA_SUCCESS)
        return error("miniaudio sound initialization error! Error code: %d", r),
               UnknownErr;

    self->state = SOUND_STATE_STOPPED;
    return info("sound initialized"), Ok;
}
void sound_unload(Sound *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return;

    ma_sound_uninit(&self->sound);
    sound_data_uninit(&self->sound_data);
    free(self->sound_data._self);
    self->state = SOUND_STATE_UNINITIALIZED;
}

Result sound_play(Sound *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return StateErr;
    if (self->state != SOUND_STATE_STOPPED) return Ok;

    if (ma_sound_start(&self->sound) != MA_SUCCESS)
        return error("miniaudio sound starting error!"), UnknownErr;

    self->state = SOUND_STATE_PLAYING;
    return info("sound played"), Ok;
}
void sound_pause(Sound *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return;
    if (self->state != SOUND_STATE_PLAYING) return;

    ma_sound_stop(&self->sound);

    self->state = SOUND_STATE_STOPPED;
    info("sound paused");
}
void sound_stop(Sound *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return;

    sound_pause(self);
    ma_sound_seek_to_pcm_frame(&self->sound, 0);
    info("sound stopped");
}

float sound_get_volume(Sound const *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return 0.0;
    return ma_sound_get_volume(&self->sound);
}
void sound_set_volume(Sound *const self, float const value) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return;
    ma_sound_set_volume(&self->sound, value);
}

double sound_get_duration(Sound *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return 0.0;

    ma_uint64 length_in_frames;
    ma_sound_get_length_in_pcm_frames(&self->sound, &length_in_frames);
    return (double)length_in_frames / ma_engine_get_sample_rate(self->engine);
}

EncodedSoundData *sound_get_encoded_data(Sound const *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return NULL;
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_ENCODED
             ? self->sound_data._self
             : NULL;
}
WaveformSoundData *sound_get_waveform_data(Sound const *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return NULL;
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_WAVEFORM
             ? self->sound_data._self
             : NULL;
}
NoiseSoundData *sound_get_noise_data(Sound const *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return NULL;
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_NOISE
             ? self->sound_data._self
             : NULL;
}
PulseSoundData *sound_get_pulse_data(Sound const *const self) {
    if (self->state == SOUND_STATE_UNINITIALIZED) return NULL;
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_PULSE
             ? self->sound_data._self
             : NULL;
}
