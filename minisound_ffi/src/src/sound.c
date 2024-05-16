#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/milo/milo.h"
#include "../external/miniaudio/include/miniaudio.h"

/*************
 ** private **
 *************/

struct Sound {
    ma_sound wave;
    ma_decoder decoder;
};

/************
 ** public **
 ************/

Sound *sound_alloc() {
    Sound *const sound = malloc(sizeof(Sound));
    if (sound == NULL) error("%s", explain(OutOfMemErr));
    return sound;
}

Result sound_init(
    Sound *const self,
    void const *const data,
    size_t const data_size,
    void const *const dec_config,
    void *const engine
) {
    if (ma_decoder_init_memory(data, data_size, dec_config, &self->decoder) !=
        MA_SUCCESS)
        return error("miniaudio decoder initialization error!"), UnknownErr;

    if (ma_sound_init_from_data_source(
            engine,
            &self->decoder,
            MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
            NULL,
            &self->wave
        ) != MA_SUCCESS) {
        ma_decoder_uninit(&self->decoder);
        return error("miniaudio sound initialization error!"), UnknownErr;
    }

    info("sound loaded");
    return Ok;
}
void sound_unload(Sound *const self) {
    ma_sound_uninit(&self->wave);
    ma_decoder_uninit(&self->decoder);
}

Result sound_play(Sound *const self) {
    if (ma_sound_start(&self->wave) != MA_SUCCESS)
        return error("miniaudio sound starting error!"), UnknownErr;

    info("sound played");
    return Ok;
}
void sound_pause(Sound *const self) { ma_sound_stop(&self->wave); }
void sound_stop(Sound *const self) {
    ma_sound_stop(&self->wave);
    ma_sound_seek_to_pcm_frame(&self->wave, 0);
}

float sound_get_volume(Sound const *const self) {
    return ma_sound_get_volume(&self->wave);
}
void sound_set_volume(Sound *const self, float const value) {
    ma_sound_set_volume(&self->wave, value);
}

float sound_get_duration(Sound *const self) {
    float duration = 0;
    ma_sound_get_length_in_seconds(&self->wave, &duration);
    return duration;
}

Result sound_set_is_looped(Sound *const self, bool value) {
    if (ma_data_source_set_looping(&self->decoder, value) != MA_SUCCESS)
        return error("miniaudio setting looping error!"), UnknownErr;

    return Ok;
}
