#include "../include/sound.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../external/milo/milo.h"
#include "../include/miniaudio.h"

Sound *sound_alloc()
{
    Sound *const sound = malloc(sizeof(Sound));
    if (sound == NULL)
        error("%s", explain(OutOfMemErr));
    return sound;
}

Result sound_init(
    Sound *const self,
    float *data,
    size_t const data_size,
    const ma_format format,
    const int channels,
    const int sample_rate,
    ma_engine *const engine)
{
    self->engine = engine;
    self->is_looped = false;
    self->loop_delay_ms = 0;

    // Debug: Print first few bytes of data
    printf("First 16 bytes of audio data: ");
    for (int i = 0; i < 16 && i < data_size; i++)
    {
        printf("%02x ", ((unsigned char *)data)[i]);
    }
    printf("\n");

    printf("Format: %d, Channels: %d, Sample Rate: %d\n", format, channels, sample_rate);

    if (format != ma_format_unknown && channels > 0 && sample_rate > 0)
    {
        // Raw PCM data
        self->is_raw_data = true;

        size_t frame_count = data_size / (channels * ma_get_bytes_per_sample(format));
        printf("Calculated frame count: %zu\n", frame_count);

        ma_audio_buffer_config buffer_config = ma_audio_buffer_config_init(
            format,
            channels,
            frame_count,
            data,
            NULL);

        ma_result result = ma_audio_buffer_init(&buffer_config, &self->buffer);
        if (result != MA_SUCCESS)
        {
            return error("miniaudio audio buffer initialization error! Error code: %d", result), UnknownErr;
        }

        result = ma_sound_init_from_data_source(
            engine,
            &self->buffer,
            MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
            NULL,
            &self->sound);
        if (result != MA_SUCCESS)
        {
            ma_audio_buffer_uninit(&self->buffer);
            return error("miniaudio raw sound initialization error! Error code: %d", result), UnknownErr;
        }
    }
    else
    {
        // Encoded audio file data
        self->is_raw_data = false;

        ma_result result = ma_decoder_init_memory(data, data_size, NULL, &self->decoder);
        if (result != MA_SUCCESS)
        {
            return error("miniaudio decoder initialization error! Error code: %d", result), UnknownErr;
        }

        result = ma_sound_init_from_data_source(
            engine,
            &self->decoder,
            MA_SOUND_FLAG_NO_PITCH | MA_SOUND_FLAG_NO_SPATIALIZATION,
            NULL,
            &self->sound);
        if (result != MA_SUCCESS)
        {
            ma_decoder_uninit(&self->decoder);
            return error("miniaudio sound initialization error! Error code: %d", result), UnknownErr;
        }
    }

    info("sound loaded successfully");
    return Ok;
}

void sound_unload(Sound *const self)
{
    if (self->is_raw_data)
    {
        ma_sound_uninit(&self->sound);
        ma_audio_buffer_uninit(&self->buffer);
    }
    else
    {
        ma_sound_uninit(&self->sound);
        ma_decoder_uninit(&self->decoder);
    }
}

Result sound_play(Sound *const self)
{
    ma_sound *sound =  &self->sound;
    if (ma_sound_start(sound) != MA_SUCCESS)
        return error("miniaudio sound starting error!"), UnknownErr;

    info("sound played");
    return Ok;
}

Result sound_replay(Sound *const self)
{
    sound_stop(self);
    return sound_play(self);
}

void sound_pause(Sound *const self)
{
    ma_sound *sound =  &self->sound;
    ma_sound_stop(sound);
}

void sound_stop(Sound *const self)
{
    ma_sound *sound =  &self->sound;
    ma_sound_stop(sound);
    ma_sound_seek_to_pcm_frame(sound, 0);
}

float sound_get_volume(Sound const *const self)
{
    ma_sound *sound =  &self->sound;
    return ma_sound_get_volume(sound);
}

void sound_set_volume(Sound *const self, float const value)
{
    ma_sound *sound = &self->sound;
    ma_sound_set_volume(sound, value);
}

float sound_get_duration(Sound *const self)
{
    ma_uint64 length_in_frames;
    if (self->is_raw_data)
    {
        ma_audio_buffer_get_length_in_pcm_frames(&self->buffer, &length_in_frames);
    }
    else
    {
        ma_sound_get_length_in_pcm_frames(&self->sound, &length_in_frames);
    }
    return (float)length_in_frames / ma_engine_get_sample_rate(self->engine);
}

bool sound_get_is_looped(Sound const *const self)
{
    return self->is_looped;
}

void sound_set_looped(
    Sound *const self,
    bool const value,
    size_t const delay_ms)
{
    if (value)
    {
        if (delay_ms <= 0)
        {
            ma_data_source_set_looping(&self->decoder, true);
        }
        else
        {
            SilenceDataSourceConfig const config = silence_data_source_config(
                self->decoder.outputFormat,
                self->decoder.outputChannels,
                self->decoder.outputSampleRate,
                (delay_ms * self->decoder.outputSampleRate) / 1000);
            silence_data_source_init(&self->loop_delay_ds, &config);

            ma_data_source_set_next(&self->decoder, &self->loop_delay_ds);
            ma_data_source_set_next(&self->loop_delay_ds, &self->decoder);
        }
    }
    else
    {
        // TODO? maybe refactor this

        ma_data_source_set_current(&self->decoder, &self->decoder);
        ma_data_source_set_looping(&self->decoder, false);
        ma_data_source_set_next(&self->decoder, NULL);
    }
}
