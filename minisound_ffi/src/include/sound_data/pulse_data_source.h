#ifndef PULSE_DATA_SOURCE_H
#define PULSE_DATA_SOURCE_H

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../external/result/result.h"

typedef struct PulseDataSource {
    ma_data_source_base _ds;

    ma_pulsewave pulsewave;
} PulseDataSource;

Result pulse_data_source_init(
    PulseDataSource *const self,
    ma_pulsewave_config const *const config
);
void pulse_data_source_uninit(PulseDataSource *const self);

#endif
