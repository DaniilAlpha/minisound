#include "../../include/sound_data/pulse_data_source.h"

/*************
 ** private **
 *************/

static ma_result pulse_data_source_on_read(
    ma_data_source *const v_self,
    void *const data,
    ma_uint64 data_len_frames,
    ma_uint64 *const out_read_data_len_frames
) {
    PulseDataSource *const self = v_self;

    return ma_pulsewave_read_pcm_frames(
        &self->pulsewave,
        data,
        data_len_frames,
        out_read_data_len_frames
    );
}

static ma_result pulse_data_source_on_seek(
    ma_data_source *const v_self,
    ma_uint64 const new_pos_frames
) {
    PulseDataSource *const self = v_self;

    return ma_pulsewave_seek_to_pcm_frame(&self->pulsewave, new_pos_frames);
}

static ma_result pulse_data_source_on_get_data_format(
    ma_data_source *const v_self,
    ma_format *const out_format,
    ma_uint32 *const out_channels,
    ma_uint32 *const out_sample_rate,
    ma_channel *const out_channel_map,
    size_t const channel_map_cap
) {
    PulseDataSource const *const self = v_self;

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

static ma_result pulse_data_source_on_get_cursor(
    ma_data_source *const v_self,
    ma_uint64 *const out_cursor
) {
    PulseDataSource *const self = v_self;

    return ma_data_source_get_cursor_in_pcm_frames(
        &self->pulsewave.waveform,
        out_cursor
    );
}

/************
 ** public **
 ************/

Result pulse_data_source_init(
    PulseDataSource *const self,
    ma_pulsewave_config const *const config
) {
    if (ma_pulsewave_init(config, &self->pulsewave) != MA_SUCCESS)
        return UnknownErr;

    static ma_data_source_vtable const vtbl = {
        .onRead = pulse_data_source_on_read,
        .onSeek = pulse_data_source_on_seek,
        .onGetDataFormat = pulse_data_source_on_get_data_format,
        .onGetCursor = pulse_data_source_on_get_cursor,
        .onGetLength = NULL,
        .onSetLooping = NULL,
        .flags = 0,
    };

    ma_data_source_config ds_config = ma_data_source_config_init();
    ds_config.vtable = &vtbl;
    if (ma_data_source_init(&ds_config, &self->_ds) != MA_SUCCESS)
        return UnknownErr;

    return Ok;
}
void pulse_data_source_uninit(PulseDataSource *const self) {
    ma_data_source_uninit(&self->_ds);
    ma_pulsewave_uninit(&self->pulsewave);
}
