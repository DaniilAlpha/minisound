#ifndef RECORDER_H
#define RECORDER_H

#include <stdbool.h>
#include <stdint.h>

#include "../../external/result/result.h"
#include "../export.h"
#include "./rec.h"
#include "audio_common.h"

typedef struct Recorder Recorder;
typedef void
RecorderOnDataFn(size_t const pos, uint8_t *const data, size_t const data_size);

EXPORT Recorder *recorder_alloc(size_t const max_rec_count);
EXPORT Result recorder_init(Recorder *const self, uint32_t const period_ms);
EXPORT void recorder_uninit(Recorder *const self);

EXPORT bool
recorder_get_is_recording(Recorder const *const self, Rec const *const rec);

EXPORT Result recorder_start(Recorder *const self);

EXPORT Result recorder_save_rec(
    Recorder *const self,
    Rec *const rec,
    AudioEncoding const encoding,
    SampleFormat const sample_format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    uint8_t **const data_ptr,
    size_t *const data_size_ptr
);
EXPORT Result recorder_resume_rec(Recorder *const self, Rec *const rec);
EXPORT Result recorder_pause_rec(Recorder *const self, Rec const *const rec);

#endif
