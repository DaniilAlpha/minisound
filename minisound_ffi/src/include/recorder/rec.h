#ifndef REC_H
#define REC_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include <sys/types.h>

#include "../../external/result/result.h"
#include "../export.h"

typedef enum RecEncoding {
    REC_ENCODING_RAW,  // TODO! not implemented yet
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
typedef void RecSeekDataFn(Rec *const self, long const off, int const origin);

Rec *rec_alloc(void);
EXPORT Result rec_init(
    Rec *const self,
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate,
    int const in_format,
    uint32_t const in_channel_count,
    uint32_t const in_sample_rate,

    size_t const buf_size_frames,
    size_t const data_availability_threshold_frames,
    RecOnDataFn *const on_data_available,
    RecSeekDataFn *const seek_data
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
Result rec_end(Rec *const self);

#endif
