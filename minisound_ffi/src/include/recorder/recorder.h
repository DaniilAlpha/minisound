#ifndef RECORDER_H
#define RECORDER_H

#include <stdbool.h>
#include <stdint.h>

#include "../../external/result/result.h"
#include "../export.h"
#include "./rec.h"

typedef struct Recorder Recorder;

EXPORT Recorder *recorder_alloc(size_t const max_rec_count);
EXPORT Result recorder_init(Recorder *const self);
EXPORT void recorder_uninit(Recorder *const self);

EXPORT Result recorder_start(Recorder *const self);

EXPORT Result recorder_record(
    Recorder *const self,
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    size_t const data_availability_threshold_ms,
    RecOnDataFn *const on_data_available,
    RecSeekDataFn *const seek_data,

    Rec **const out
);
EXPORT Result
recorder_stop_recording(Recorder *const self, Rec const *const rec);

#endif
