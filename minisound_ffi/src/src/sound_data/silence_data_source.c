#include "../../include/sound_data/silence_data_source.h"

#include <string.h>

#include "../../external/result/result.h"

#define SILENCE_DATA_SOURCE_CHANNEL_COUNT (1)

/*************
 ** private **
 *************/

static ma_result silence_data_source_on_read(
    ma_data_source *const v_self,
    void *const data,
    ma_uint64 data_len_frames,
    ma_uint64 *const out_read_data_len_frames
) {
    SilenceDataSource *const self = v_self;

    ma_uint64 const remain_len_frames =
        self->_pos_frames <= self->_config.len_frames
            ? self->_config.len_frames - 1 - self->_pos_frames
            : 0;
    if (data_len_frames > remain_len_frames)
        data_len_frames = remain_len_frames;

    self->_pos_frames += data_len_frames;

    ma_silence_pcm_frames(
        data,
        data_len_frames,
        self->_config.format,
        SILENCE_DATA_SOURCE_CHANNEL_COUNT
    );

    return *out_read_data_len_frames = data_len_frames, MA_SUCCESS;
}

static ma_result silence_data_source_on_seek(
    ma_data_source *const v_self,
    ma_uint64 const new_pos_frames
) {
    SilenceDataSource *const self = v_self;

    self->_pos_frames = new_pos_frames;

    return MA_SUCCESS;
}

static ma_result silence_data_source_on_get_data_format(
    ma_data_source *const v_self,
    ma_format *const out_format,
    ma_uint32 *const out_channels,
    ma_uint32 *const out_sample_rate,
    ma_channel *const out_channel_map,
    size_t const channel_map_cap
) {
    SilenceDataSource const *const self = v_self;

    return *out_format = self->_config.format,
           *out_channels = SILENCE_DATA_SOURCE_CHANNEL_COUNT,
           *out_sample_rate = self->_config.sample_rate,
           ma_channel_map_init_standard(
               ma_standard_channel_map_default,
               out_channel_map,
               channel_map_cap,
               SILENCE_DATA_SOURCE_CHANNEL_COUNT
           ),
           MA_SUCCESS;
}

static ma_result silence_data_source_on_get_cursor(
    ma_data_source *const v_self,
    ma_uint64 *const out_cursor
) {
    SilenceDataSource const *const self = v_self;

    return *out_cursor = self->_pos_frames, MA_SUCCESS;
}

static ma_result silence_data_source_on_get_len(
    ma_data_source *const v_self,
    ma_uint64 *const out_len
) {
    SilenceDataSource const *const self = v_self;

    return *out_len = self->_config.len_frames, MA_SUCCESS;
}

/************
 ** public **
 ************/

SilenceDataSourceConfig silence_data_source_config(
    ma_format const format,
    ma_uint32 const sample_rate,

    ma_uint64 const len_frames
) {
    return (SilenceDataSourceConfig){
        .format = format,
        .sample_rate = sample_rate,

        .len_frames = len_frames,
    };
}

Result silence_data_source_init(
    SilenceDataSource *const self,
    SilenceDataSourceConfig const *const config
) {
    static ma_data_source_vtable const vtbl = {
        .onRead = silence_data_source_on_read,
        .onSeek = silence_data_source_on_seek,
        .onGetDataFormat = silence_data_source_on_get_data_format,
        .onGetCursor = silence_data_source_on_get_cursor,
        .onGetLength = silence_data_source_on_get_len,
        .onSetLooping = NULL,
        .flags = 0,
    };

    ma_data_source_config ds_config = ma_data_source_config_init();
    ds_config.vtable = &vtbl;
    if (ma_data_source_init(&ds_config, &self->_ds) != MA_SUCCESS)
        return UnknownErr;

    self->_config = *config;
    self->_pos_frames = 0;

    return Ok;
}
void silence_data_source_uninit(SilenceDataSource *const self) {
    ma_data_source_uninit(&self->_ds);
}
