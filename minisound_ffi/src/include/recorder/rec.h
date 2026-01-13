#ifndef REC_H
#define REC_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include <sys/types.h>

#include "../../external/result/result.h"
#include "../export.h"
#include "rec_sink/rec_sink.h"

typedef struct Rec Rec;
typedef struct ma_device ma_device;

EXPORT Rec *rec_alloc(void);
EXPORT Result
rec_init(Rec *const self, RecSink const rec_sink, ma_device *const device);
EXPORT void rec_uninit(Rec *const self);

Result rec_write_raw(
    Rec *const self,
    uint8_t const *const data,
    size_t const data_len_frames
);
EXPORT Result rec_end(Rec *const self);

#endif
