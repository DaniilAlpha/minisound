#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/miniaudio/include/miniaudio.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../external/milo/milo.h"

struct Sound {
    ma_sound sound;

    SoundData sound_data;

    ma_engine *engine;
};

Sound *sound_alloc(void) { return malloc(sizeof(Sound)); }
Result
sound_init(Sound *const self, SoundData const sound_data, void *const vengine) {
    self->sound_data = sound_data;
    self->engine = vengine;

    ma_result const r = ma_sound_init_from_data_source(
        self->engine,
        sound_data_get_ds(&self->sound_data),
        MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
        NULL,
        &self->sound
    );
    if (r != MA_SUCCESS)
        return sound_data_uninit(&self->sound_data),
               error("miniaudio sound initialization error! Error code: %d", r),
               UnknownErr;

    return Ok;
}

// Result sound_init_raw(
//     Sound *const self,
//     float const *const data,
//     size_t const data_size,
//     SoundFormat const sound_format,
//     uint32_t const channels,
//     // uint32_t const sample_rate,  // TODO! unused, maybe by mistake
//     void *const vengine
// ) {
//     self->is_raw = true;
//
//     ma_format const format = (ma_format)sound_format;
//
//     size_t const frame_count =
//         data_size / (channels * ma_get_bytes_per_sample(format));
//
//     ma_audio_buffer_config const buffer_config =
//         ma_audio_buffer_config_init(format, channels, frame_count, data,
//         NULL);
//
//     ma_result r = ma_audio_buffer_init(&buffer_config, &self->data.raw_buf);
//     if (r != MA_SUCCESS) {
//         return error(
//                    "miniaudio audio buffer initialization error! Error code:
//                    %d",
//                    r
//                ),
//                UnknownErr;
//     }
//
//     r = ma_sound_init_from_data_source(
//         vengine,
//         &self->data.raw_buf,
//         MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
//         NULL,
//         &self->sound
//     );
//     if (r != MA_SUCCESS) {
//         ma_audio_buffer_uninit(&self->data.raw_buf);
//         return error(
//                    "miniaudio raw sound initialization error! Error code:
//                    %d",
//                    r
//                ),
//                UnknownErr;
//     }
//
//     return Ok;
// }

void sound_unload(Sound *const self) {
    ma_sound_uninit(&self->sound);
    sound_data_uninit(&self->sound_data);
}

Result sound_play(Sound *const self) {
    ma_sound *sound = &self->sound;
    if (ma_sound_start(sound) != MA_SUCCESS)
        return error("miniaudio sound starting error!"), UnknownErr;

    info("sound played");
    return Ok;
}

Result sound_replay(Sound *const self) {
    sound_stop(self);
    return sound_play(self);
}

void sound_pause(Sound *const self) {
    ma_sound *sound = &self->sound;
    ma_sound_stop(sound);
}

void sound_stop(Sound *const self) {
    ma_sound *sound = &self->sound;
    ma_sound_stop(sound);
    ma_sound_seek_to_pcm_frame(sound, 0);
}

float sound_get_volume(Sound const *const self) {
    return ma_sound_get_volume(&self->sound);
}

void sound_set_volume(Sound *const self, float const value) {
    ma_sound_set_volume(&self->sound, value);
}

float sound_get_duration(Sound *const self) {
    ma_uint64 length_in_frames;
    ma_sound_get_length_in_pcm_frames(&self->sound, &length_in_frames);
    return (float)length_in_frames / ma_engine_get_sample_rate(self->engine);
}
