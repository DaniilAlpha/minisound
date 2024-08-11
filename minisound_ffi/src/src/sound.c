#include "../include/sound.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/milo/milo.h"
#include "../external/miniaudio/include/miniaudio.h"
#include "../include/silence_data_source.h"

// this ensures safe casting between `SoundFormat` and `ma_format`
_Static_assert(
    (int)SOUND_FORMAT_UNKNOWN == (int)ma_format_unknown,
    "SOUND_FORMAT_UNKNOWN should match ma_format_unknown."
);
_Static_assert(
    (int)SOUND_FORMAT_U8 == (int)ma_format_u8,
    "SOUND_FORMAT_U8 should match ma_format_u8."
);
_Static_assert(
    (int)SOUND_FORMAT_S16 == (int)ma_format_s16,
    "SOUND_FORMAT_S16 should match ma_format_s16."
);
_Static_assert(
    (int)SOUND_FORMAT_S24 == (int)ma_format_s24,
    "SOUND_FORMAT_S24 should match ma_format_s24."
);
_Static_assert(
    (int)SOUND_FORMAT_S32 == (int)ma_format_s32,
    "SOUND_FORMAT_S32 should match ma_format_s32."
);
_Static_assert(
    (int)SOUND_FORMAT_F32 == (int)ma_format_f32,
    "SOUND_FORMAT_F32 should match ma_format_f32."
);
_Static_assert(
    (size_t)SOUND_FORMAT_COUNT == (size_t)ma_format_count,
    "Count of `SoundFormat` members and `ma_format` members does not match."
);

struct Sound {
    ma_sound sound;

    bool is_raw;
    union {
        struct {
            ma_decoder decoder;
            bool is_looped;
            size_t loop_delay_ms;
            SilenceDataSource loop_delay_ds;
        } non_raw;
        ma_audio_buffer raw_buf;
    } data;

    ma_engine *engine;
};

Sound *sound_alloc(void) {
    Sound *const sound = malloc(sizeof(Sound));
    if (sound == NULL) error("%s", explain(OutOfMemErr));
    return sound;
}

Result sound_init_from_data(
    Sound *const self,
    float const *const data,
    size_t const data_size,
    void *const vengine
) {
    self->is_raw = false;
    self->data.non_raw.is_looped = false;
    self->data.non_raw.loop_delay_ms = 0;

    self->engine = vengine;

    ma_result result = ma_decoder_init_memory(
        data,
        data_size,
        NULL,
        &self->data.non_raw.decoder
    );
    if (result != MA_SUCCESS) {
        return error(
                   "miniaudio decoder initialization error! Error code: %d",
                   result
               ),
               UnknownErr;
    }

    result = ma_sound_init_from_data_source(
        vengine,
        &self->data.non_raw.decoder,
        MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
        NULL,
        &self->sound
    );
    if (result != MA_SUCCESS) {
        ma_decoder_uninit(&self->data.non_raw.decoder);
        return error(
                   "miniaudio sound initialization error! Error code: %d",
                   result
               ),
               UnknownErr;
    }

    return Ok;
}

Result sound_init_raw(
    Sound *const self,
    float const *const data,
    size_t const data_size,
    SoundFormat const sound_format,
    uint32_t const channels,
    // uint32_t const sample_rate,  // TODO! unused, maybe by mistake
    void *const vengine
) {
    self->is_raw = true;

    ma_format const format = (ma_format)sound_format;

    size_t const frame_count =
        data_size / (channels * ma_get_bytes_per_sample(format));

    ma_audio_buffer_config const buffer_config =
        ma_audio_buffer_config_init(format, channels, frame_count, data, NULL);

    ma_result r = ma_audio_buffer_init(&buffer_config, &self->data.raw_buf);
    if (r != MA_SUCCESS) {
        return error(
                   "miniaudio audio buffer initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    r = ma_sound_init_from_data_source(
        vengine,
        &self->data.raw_buf,
        MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
        NULL,
        &self->sound
    );
    if (r != MA_SUCCESS) {
        ma_audio_buffer_uninit(&self->data.raw_buf);
        return error(
                   "miniaudio raw sound initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    return Ok;
}

Result sound_init(
    Sound *const self,

    float const *const data,
    size_t const data_size,

    SoundFormat const sound_format,
    uint32_t const channels,
    uint32_t const sample_rate,
    void *const vengine
) {
    UNROLL(
        sound_format != SOUND_FORMAT_UNKNOWN && channels > 0 && sample_rate > 0
            ? sound_init_raw(
                  self,
                  data,
                  data_size,
                  sound_format,
                  channels,
                  vengine
              )
            : sound_init_from_data(self, data, data_size, vengine)
    );

    info("sound loaded successfully");
    return Ok;
}

void sound_unload(Sound *const self) {
    ma_sound_uninit(&self->sound);
    if (self->is_raw) {
        ma_audio_buffer_uninit(&self->data.raw_buf);
    } else {
        ma_decoder_uninit(&self->data.non_raw.decoder);
    }
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
    if (self->is_raw) {
        ma_audio_buffer_get_length_in_pcm_frames(
            &self->data.raw_buf,
            &length_in_frames
        );
    } else {
        ma_sound_get_length_in_pcm_frames(&self->sound, &length_in_frames);
    }
    return (float)length_in_frames / ma_engine_get_sample_rate(self->engine);
}

bool sound_get_is_looped(Sound const *const self) {
    return self->is_raw ? true : self->data.non_raw.is_looped;
}

void sound_set_looped(
    Sound *const self,
    bool const value,
    size_t const delay_ms
) {
    // set_looped shuld not affect raw sounds (for now)
    if (self->is_raw) return;

    ma_decoder *const decoder = &self->data.non_raw.decoder;
    SilenceDataSource *const loop_delay_ds = &self->data.non_raw.loop_delay_ds;

    if (value) {
        if (delay_ms == 0) {
            ma_data_source_set_looping(decoder, true);
        } else {
            SilenceDataSourceConfig const config = silence_data_source_config(
                decoder->outputFormat,
                decoder->outputChannels,
                decoder->outputSampleRate,
                (delay_ms * decoder->outputSampleRate) / 1000
            );
            silence_data_source_init(loop_delay_ds, &config);

            ma_data_source_set_next(decoder, loop_delay_ds);
            ma_data_source_set_next(loop_delay_ds, decoder);
        }
    } else {
        // TODO? maybe refactor this

        ma_data_source_set_current(decoder, decoder);
        ma_data_source_set_looping(decoder, false);
        ma_data_source_set_next(decoder, NULL);
    }
}
