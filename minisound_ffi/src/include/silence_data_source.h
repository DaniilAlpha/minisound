#ifndef SILENCE_DATA_SOURCE_H
#define SILENCE_DATA_SOURCE_H

#include "../external/miniaudio/include/miniaudio.h"
#include "../external/result/result.h"

typedef struct SilenceDataSourceConfig {
    ma_format format;
    ma_uint32 sample_rate;

    ma_uint64 len_frames;
} SilenceDataSourceConfig;

SilenceDataSourceConfig silence_data_source_config(
    ma_format const format,
    ma_uint32 const sample_rate,

    ma_uint64 const len_frames
);

typedef struct SilenceDataSource {
    ma_data_source_base ds;

    SilenceDataSourceConfig _config;
    ma_uint64 pos_frames;
} SilenceDataSource;

Result silence_data_source_init(
    SilenceDataSource *const self,
    SilenceDataSourceConfig const *const config
);
void silence_data_source_uninit(SilenceDataSource *const self);

#endif
