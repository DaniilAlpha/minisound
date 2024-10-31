#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/miniaudio/include/miniaudio.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../external/milo/milo.h"

struct Sound {
    SoundData sound_data;

    ma_sound sound;

    ma_engine *engine;
};

Sound *sound_alloc(void) { return malloc(sizeof(Sound)); }
Result sound_init(
    Sound *const self,
    SoundData const sound_data,
    void *const v_engine
) {
    self->sound_data = sound_data;
    self->engine = v_engine;

    ma_result const r = ma_sound_init_from_data_source(
        self->engine,
        sound_data_get_ds(&self->sound_data),
        MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
        NULL,
        NULL,
        &self->sound
    );
    if (r != MA_SUCCESS)
        return error("miniaudio sound initialization error! Error code: %d", r),
               UnknownErr;

    return info("sound initialized"), Ok;
}
void sound_unload(Sound *const self) {
    ma_sound_uninit(&self->sound);
    sound_data_uninit(&self->sound_data);
    free(self->sound_data._self);
}

Result sound_play(Sound *const self) {
    ma_sound *sound = &self->sound;
    if (ma_sound_start(sound) != MA_SUCCESS)
        return error("miniaudio sound starting error!"), UnknownErr;

    return info("sound played"), Ok;
}
void sound_pause(Sound *const self) {
    ma_sound_stop(&self->sound);

    info("sound paused");
}
void sound_stop(Sound *const self) {
    ma_sound_stop(&self->sound);
    ma_sound_seek_to_pcm_frame(&self->sound, 0);

    info("sound stopped");
}

float sound_get_volume(Sound const *const self) {
    return ma_sound_get_volume(&self->sound);
}
void sound_set_volume(Sound *const self, float const value) {
    ma_sound_set_volume(&self->sound, value);
}

double sound_get_duration(Sound *const self) {
    ma_uint64 length_in_frames;
    ma_sound_get_length_in_pcm_frames(&self->sound, &length_in_frames);
    return (float)length_in_frames / ma_engine_get_sample_rate(self->engine);
}

EncodedSoundData *sound_get_encoded_data(Sound const *const self) {
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_ENCODED
             ? self->sound_data._self
             : NULL;
}
WaveformSoundData *sound_get_waveform_data(Sound const *const self) {
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_WAVEFORM
             ? self->sound_data._self
             : NULL;
}
NoiseSoundData *sound_get_noise_data(Sound const *const self) {
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_NOISE
             ? self->sound_data._self
             : NULL;
}
PulseSoundData *sound_get_pulse_data(Sound const *const self) {
    return sound_data_get_type(&self->sound_data) == SOUND_DATA_TYPE_PULSE
             ? self->sound_data._self
             : NULL;
}
