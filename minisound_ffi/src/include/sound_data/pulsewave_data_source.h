#ifndef PULSEWAVE_DATA_SOURCE_H
#define PULSEWAVE_DATA_SOURCE_H

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../external/result/result.h"

typedef struct PulsewaveDataSource {
    ma_data_source_base ds;

    ma_pulsewave pulsewave;
} PulsewaveDataSource;

Result pulsewave_data_source_init(
    PulsewaveDataSource *const self,
    ma_pulsewave_config const *const config
);
void pulsewave_data_source_uninit(PulsewaveDataSource *const self);

#endif
