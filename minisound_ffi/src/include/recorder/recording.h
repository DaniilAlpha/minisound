#ifndef RECORDING_H
#define RECORDING_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../../external/result/result.h"
#include "../export.h"

typedef struct ma_device ma_device;

typedef struct Recording Recording;
typedef enum RecordingEncoding {
    RECORDING_ENCODING_WAV = 1,
    // RECORDING_ENCODING_FLAC,
    // RECORDING_ENCODING_MP3,
} RecordingEncoding;
typedef enum RecordingFormat {
    RECORDING_FORMAT_U8 = 1,
    RECORDING_FORMAT_S16,
    RECORDING_FORMAT_S24,
    RECORDING_FORMAT_S32,
    RECORDING_FORMAT_F32,
} RecordingFormat;

Recording *recording_alloc(void);
Result recording_init(
    Recording *const self,
    RecordingEncoding const encoding,
    RecordingFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
);
void recording_uninit(Recording *const self);

EXPORT uint8_t const *recording_get_buf(Recording const *const self);
EXPORT size_t recording_get_size(Recording const *const self);

Result recording_write(
    Recording *const self,
    uint8_t const *const data,
    size_t const data_len_frames
);
Result recording_fit(Recording *const self);

#endif
