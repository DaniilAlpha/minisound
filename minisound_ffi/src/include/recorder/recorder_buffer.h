#ifndef RECORDER_BUFFER_H
#define RECORDER_BUFFER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../../external/result/result.h"
#include "recording.h"

typedef struct ma_device ma_device;

typedef struct RecorderBuffer RecorderBuffer;
typedef enum RecordingEncoding {
    RECORDING_ENCODING_WAV = 1,
    // RECORDING_ENCODING_FLAC,
    // RECORDING_ENCODING_MP3,
} RecordingEncoding;

RecorderBuffer *recorder_buffer_alloc(void);
Result recorder_buffer_init(
    RecorderBuffer *const self,
    RecordingEncoding const encoding,
    ma_device *const device
);
void recorder_buffer_uninit(RecorderBuffer *const self);

Result recorder_buffer_write(
    RecorderBuffer *const self,
    uint8_t const *const data,
    size_t const data_len_pcm
);

Recording recorder_buffer_consume(RecorderBuffer *const self);

#endif
