#ifndef RECORDING_H
#define RECORDING_H

#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"

typedef struct Recording Recording;
typedef enum RecordingEncoding {
    RECORDING_ENCODING_WAV = 1,
    // RECORDING_ENCODING_FLAC,
    // RECORDING_ENCODING_MP3,
} RecordingEncoding;

Recording *recording_alloc(void);
Result recording_init(
    Recording *const self,
    RecordingEncoding const encoding,
    void *const v_device
);
EXPORT void recording_uninit(Recording *const self);

EXPORT uint8_t const *recording_get_buf(Recording const *const self);
EXPORT size_t recording_get_size(Recording const *const self);

Result recording_write(
    Recording *const self,
    uint8_t const *const data,
    size_t const data_size
);

Result recording_fit(Recording *const self);

#endif
