#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>
#include <stddef.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../external/result/result.h"
#include "export.h"
#include "silence_data_source.h"

typedef struct
{
    bool is_raw_data;
    ma_engine *engine;
    ma_decoder decoder;
    union
    {
        struct
        {
            ma_sound sound;
            ma_decoder decoder;
        } file;
        struct
        {
            ma_sound sound;
            ma_audio_buffer buffer;
        } raw;
    };
    bool is_looped;
    size_t loop_delay_ms;
    SilenceDataSource loop_delay_ds;
} Sound;

EXPORT Sound *sound_alloc();

Result sound_init(
    Sound *const self,
    float *data,
    size_t const data_size,
    const ma_format format,
    const int channels,
    const int sample_rate,
    ma_engine *const engine);
EXPORT void sound_unload(Sound *const self);

EXPORT Result sound_play(Sound *const self);
EXPORT Result sound_replay(Sound *const self);
EXPORT void sound_pause(Sound *const self);
EXPORT void sound_stop(Sound *const self);

EXPORT float sound_get_volume(Sound const *const self);
EXPORT void sound_set_volume(Sound *const self, float const value);

EXPORT float sound_get_duration(Sound *const self);

EXPORT bool sound_get_is_looped(Sound const *const self);
EXPORT void
sound_set_looped(Sound *const self, bool const value, size_t const delay_ms);

#endif
