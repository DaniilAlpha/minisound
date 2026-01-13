#ifndef ENCODED_REC_SINK_H
#define ENCODED_REC_SINK_H

#include <stdbool.h>
#include <stdint.h>

#include "../../../external/result/result.h"
#include "audio_common.h"
#include "rec_sink.h"

typedef struct EncodedRecSink EncodedRecSink;

EncodedRecSink *encoded_rec_sink_alloc(void);
Result encoded_rec_sink_init(
    EncodedRecSink *const self,
    AudioEncoding const encoding,
    SampleFormat const sample_format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    uint8_t **const data_ptr,
    size_t *const data_size_ptr
);
void encoded_rec_sink_uninit(EncodedRecSink *const self);

RecSink encoded_rec_sink_ww_rec_sink(EncodedRecSink *const self);

#endif
