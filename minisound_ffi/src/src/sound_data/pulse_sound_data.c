#include "../../include/sound_data/pulse_sound_data.h"

#include <stdlib.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

#define DEFAULT_AMPLITUDE (0.5)

/*************
 ** private **
 *************/

struct PulseSoundData {
    ma_data_source_base ds;

    ma_pulsewave pulsewave;
};

static ma_data_source *pulse_sound_data_get_ds(PulseSoundData *const self) {
    return &self->ds;
}

static ma_result pulse_sound_data_on_read(
    ma_data_source *const v_self,
    void *const data,
    ma_uint64 data_len_frames,
    ma_uint64 *const out_read_data_len_frames
) {
    return ma_pulsewave_read_pcm_frames(
        &((PulseSoundData *)v_self)->pulsewave,
        data,
        data_len_frames,
        out_read_data_len_frames
    );
}
static ma_result pulse_sound_data_on_seek(
    ma_data_source *const v_self,
    ma_uint64 const new_pos_frames
) {
    return ma_pulsewave_seek_to_pcm_frame(
        &((PulseSoundData *)v_self)->pulsewave,
        new_pos_frames
    );
}
static ma_result pulse_sound_data_on_get_data_format(
    ma_data_source *const v_self,
    ma_format *const out_format,
    ma_uint32 *const out_channels,
    ma_uint32 *const out_sample_rate,
    ma_channel *const out_channel_map,
    size_t const channel_map_cap
) {
    PulseSoundData const *const self = v_self;

    return *out_format = self->pulsewave.waveform.config.format,
           *out_channels = self->pulsewave.waveform.config.channels,
           *out_sample_rate = self->pulsewave.waveform.config.sampleRate,
           ma_channel_map_init_standard(
               ma_standard_channel_map_default,
               out_channel_map,
               channel_map_cap,
               self->pulsewave.waveform.config.channels
           ),
           MA_SUCCESS;
}
static ma_result pulse_sound_data_on_get_cursor(
    ma_data_source *const v_self,
    ma_uint64 *const out_cursor
) {
    return ma_data_source_get_cursor_in_pcm_frames(
        &((PulseSoundData *)v_self)->pulsewave.waveform,
        out_cursor
    );
}

/************
 ** public **
 ************/

PulseSoundData *pulse_sound_data_alloc(void) {
    return malloc0(sizeof(PulseSoundData));
}
Result pulse_sound_data_init(PulseSoundData *const self) {
    ma_result r;

    ma_pulsewave_config const config = ma_pulsewave_config_init(
        ma_format_f32,
        1,
        48000,
        0.5,
        DEFAULT_AMPLITUDE,
        0.0
    );

    static ma_data_source_vtable const vtbl = {
        .onRead = pulse_sound_data_on_read,
        .onSeek = pulse_sound_data_on_seek,
        .onGetDataFormat = pulse_sound_data_on_get_data_format,
        .onGetCursor = pulse_sound_data_on_get_cursor,
        .onGetLength = NULL,
        .onSetLooping = NULL,
        .flags = 0,
    };
    ma_data_source_config ds_config = ma_data_source_config_init();
    ds_config.vtable = &vtbl;
    if ((r = ma_data_source_init(&ds_config, &self->ds)) != MA_SUCCESS)
        return error("miniaudio ds initialization error (code: %i)!", r),
               UnknownErr;

    if ((r = ma_pulsewave_init(&config, &self->pulsewave)) != MA_SUCCESS)
        return ma_data_source_uninit(&self->ds),
               error("miniaudio pulsewave initializatoin error (code: %i)!", r),
               UnknownErr;

    return Ok;
}
void pulse_sound_data_uninit(PulseSoundData *const self) {
    ma_data_source_uninit(&self->ds);
    ma_pulsewave_uninit(&self->pulsewave);
}

double pulse_sound_data_get_freq(PulseSoundData *const self) {
    return self->pulsewave.config.frequency;
}
void pulse_sound_data_set_freq(PulseSoundData *const self, double const value) {
    ma_pulsewave_set_frequency(&self->pulsewave, value);
}

double pulse_sound_data_get_duty_cycle(PulseSoundData *const self) {
    return self->pulsewave.config.dutyCycle;
}
void pulse_sound_data_set_duty_cycle(
    PulseSoundData *const self,
    double const value
) {
    ma_pulsewave_set_duty_cycle(&self->pulsewave, value);
}

SoundData pulse_sound_data_ww_sound_data(PulseSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(PulseSoundData),
    {
        .type = SOUND_DATA_TYPE_PULSE,

        .get_ds = pulse_sound_data_get_ds,
        .uninit = pulse_sound_data_uninit,
    }
);
