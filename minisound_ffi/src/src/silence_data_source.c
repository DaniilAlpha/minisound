#include "../include/silence_data_source.h"

#include <string.h>

#include "../external/milo/milo.h"
#include "../external/result/result.h"

/*************
 ** private **
 *************/

static ma_result silence_data_source_on_read(
    ma_data_source *const vself,
    void *const out_frames,
    ma_uint64 const frames,
    ma_uint64 *const out_read_frames
) {
    SilenceDataSource *const self = vself;

    ma_uint64 const remaining_frames =
        self->config.len_frames > self->pos_frames
            ? self->config.len_frames - self->pos_frames
            : 0;
    ma_uint64 const read_frames =
        remaining_frames > frames ? frames : remaining_frames;

    self->pos_frames += read_frames;

    return *out_read_frames = read_frames, memset(out_frames, 0, read_frames),
           MA_SUCCESS;
}

static ma_result silence_data_source_on_seek(
    ma_data_source *const vself,
    ma_uint64 const new_pos_frames
) {
    SilenceDataSource *const self = vself;

    self->pos_frames = new_pos_frames;
    return MA_SUCCESS;
}

static ma_result silence_data_source_on_get_data_format(
    ma_data_source *const vself,
    ma_format *const out_format,
    ma_uint32 *const out_channels,
    ma_uint32 *const out_sample_rate,
    ma_channel *const out_channel_map,
    size_t const channel_map_cap
) {
    SilenceDataSource const *const self = vself;

    return *out_format = self->config.format,
           *out_channels = self->config.channel_count,
           *out_sample_rate = self->config.sample_rate,
           ma_channel_map_init_standard(
               ma_standard_channel_map_default,
               out_channel_map,
               channel_map_cap,
               self->config.channel_count
           ),
           MA_SUCCESS;
}

static ma_result silence_data_source_on_get_cursor(
    ma_data_source *const vself,
    ma_uint64 *const out_cursor
) {
    SilenceDataSource const *const self = vself;

    return *out_cursor = self->pos_frames, MA_SUCCESS;
}

static ma_result silence_data_source_on_get_len(
    ma_data_source *const vself,
    ma_uint64 *const out_len
) {
    SilenceDataSource const *const self = vself;

    return *out_len = self->config.len_frames, MA_SUCCESS;
}

/************
 ** public **
 ************/

SilenceDataSourceConfig silence_data_source_config(
    ma_format const format,
    ma_uint32 const channel_count,
    ma_uint32 const sample_rate,

    ma_uint64 const len_frames
) {
    return (SilenceDataSourceConfig){
        .format = format,
        .channel_count = channel_count,
        .sample_rate = sample_rate,

        .len_frames = len_frames,
    };
}

Result silence_data_source_init(
    SilenceDataSource *const self,
    SilenceDataSourceConfig const *const config
) {
    static ma_data_source_vtable vtbl = {
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
    ma_data_source_init(&ds_config, &self->ds);

    self->config = *config;
    self->pos_frames = 0;

    return Ok;
}
void silence_data_source_uninit(SilenceDataSource *const self) {
    ma_data_source_uninit(&self->ds);
}
