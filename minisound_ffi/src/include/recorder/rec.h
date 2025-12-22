#ifndef REC_H
#define REC_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../../external/result/result.h"
#include "../export.h"

typedef enum RecEncoding {
    REC_ENCODING_WAV = 1,
    // REC_ENCODING_FLAC,
    // REC_ENCODING_MP3,
} RecEncoding;
typedef enum RecFormat {
    REC_FORMAT_U8 = 1,
    REC_FORMAT_S16,
    REC_FORMAT_S24,
    REC_FORMAT_S32,
    REC_FORMAT_F32,
} RecFormat;
typedef struct Rec Rec;
typedef void RecOnDataFn(Rec *const self);

Rec *rec_alloc(void);
Result rec_init(
    Rec *const self,
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    RecOnDataFn *const on_data_available,
    uint32_t const data_availability_threshold_ms
);
void rec_uninit(Rec *const self);

Result rec_write_raw(
    Rec *const self,
    uint8_t const *const data,
    size_t const data_len_frames
);
EXPORT Result rec_read(
    Rec *const self,
    uint8_t const **const out_data,
    size_t *const out_data_size
);

#endif
