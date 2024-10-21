#ifndef RECORDING_H
#define RECORDING_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"

typedef struct RecorderBuffer RecorderBuffer;

typedef struct Recording {
    uint8_t *buf;
    size_t size;
} Recording;

typedef enum RecordingEncoding {
    RECORDING_ENCODING_WAV = 1,
    // RECORDING_ENCODING_FLAC,
    // RECORDING_ENCODING_MP3,
} RecordingEncoding;

RecorderBuffer *recorder_buffer_alloc(void);
Result recorder_buffer_init(
    RecorderBuffer *const self,
    RecordingEncoding const encoding,
    void *const v_device
);
void recorder_buffer_uninit(RecorderBuffer *const self);

Result recorder_buffer_write(
    RecorderBuffer *const self,
    uint8_t const *const data,
    size_t const data_size
);

Recording recorder_buffer_consume(RecorderBuffer *const self);

#endif
