#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/milo/milo.h"
#include "../include/miniaudio.h"
#include "../include/silence_data_source.h"

/*************
 ** private **
 *************/

struct Sound {
    ma_sound wave;
    ma_decoder decoder;

    SilenceDataSource loop_delay_ds;
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
Result sound_replay(Sound *const self) {
    sound_stop(self);
    return sound_play(self);
}
void sound_pause(Sound *const self) { ma_sound_stop(&self->wave); }
void sound_stop(Sound *const self) {
    ma_sound_stop(&self->wave);
    ma_data_source_set_current(&self->decoder, &self->decoder);
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

void sound_set_looped(
    Sound *const self,
    bool const value,
    size_t const delay_ms
) {
    if (value) {
        if (delay_ms <= 0) {
            ma_data_source_set_looping(&self->decoder, true);
        } else {
            SilenceDataSourceConfig const config = silence_data_source_config(
                self->decoder.outputFormat,
                self->decoder.outputChannels,
                self->decoder.outputSampleRate,
                (delay_ms * self->decoder.outputSampleRate) / 1000
            );
            silence_data_source_init(&self->loop_delay_ds, &config);

            ma_data_source_set_next(&self->decoder, &self->loop_delay_ds);
            ma_data_source_set_next(&self->loop_delay_ds, &self->decoder);
        }
    } else {
        // TODO? maybe refactor this

        ma_data_source_set_current(&self->decoder, &self->decoder);
        ma_data_source_set_looping(&self->decoder, false);
        ma_data_source_set_next(&self->decoder, NULL);
    }
}
