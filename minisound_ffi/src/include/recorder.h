#ifndef RECORDER_H
#define RECORDER_H

#include <stdbool.h>
#include <stdint.h>

#include "../external/result/result.h"
#include "export.h"
#include "recording.h"

typedef struct Recorder Recorder;
typedef enum RecorderEncoding {
    RECORDER_ENCODING_WAV = 1,
    RECORDER_ENCODING_FLAC,
    RECORDER_ENCODING_MP3,
} RecorderEncoding;
typedef enum RecorderFormat {
    RECORDER_FORMAT_U8 = 1,
    RECORDER_FORMAT_S16,
    RECORDER_FORMAT_S24,
    RECORDER_FORMAT_S32,
    RECORDER_FORMAT_F32,
} RecorderFormat;

EXPORT Recorder *recorder_alloc(void);
EXPORT Result recorder_init(
    Recorder *const self,
    RecorderEncoding const encoding,
    RecorderFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
);
EXPORT void recorder_uninit(Recorder *const self);

EXPORT bool recorder_get_is_recording(Recorder const *recorder);

EXPORT Result recorder_start(Recorder *const self);
EXPORT Recording *recorder_stop(Recorder *const self);

#endif  // RECORD_H
