#include "../../../include/recorder/rec_sink/encoded_rec_sink.h"

#include <stdlib.h>
#include <string.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../../external/milo/milo.h"

#define ENCODED_REC_SINK_MIN_CAP (1024)

/*************
 ** private **
 *************/

struct EncodedRecSink {
    ma_encoder encoder;

    size_t pos, cap;
    uint8_t **data_ptr;
    size_t *data_size_ptr;
};

static ma_encoder *encoded_rec_sink_get_enc(EncodedRecSink *const self) {
    return &self->encoder;
}

static ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *const new_data,
    size_t const new_data_size,
    size_t *const out_written_data_size
) {
    EncodedRecSink *const self = encoder->pUserData;
    assert(self->data_ptr);
    uint8_t *data = *self->data_ptr;

    size_t const end_pos = self->pos + new_data_size;

    size_t cap = self->cap;
    if (cap < ENCODED_REC_SINK_MIN_CAP) cap = ENCODED_REC_SINK_MIN_CAP;
    while (end_pos > cap) cap = cap * 3 / 2;

    if (cap > self->cap) {
        trace("encoded rec sink being resized: %zu -> %zu", self->cap, cap);

        data = realloc(data, cap);
        if (!data) return MA_OUT_OF_MEMORY;

        *self->data_ptr = data, self->cap = cap;
    }

    memcpy(data + self->pos, new_data, new_data_size);
    self->pos = end_pos;
    if (self->pos > *self->data_size_ptr) *self->data_size_ptr = self->pos;

    return *out_written_data_size = new_data_size,
           trace("encoded rec sink wrote %zu bytes.", new_data_size),
           MA_SUCCESS;
}
static ma_result encoder_on_seek(
    ma_encoder *const encoder,
    ma_int64 const off,
    ma_seek_origin const origin
) {
    EncodedRecSink *const self = encoder->pUserData;

    switch (origin) {
    case MA_SEEK_CUR: self->pos += off; break;
    case MA_SEEK_SET: self->pos = off; break;
    case MA_SEEK_END: self->pos = *self->data_size_ptr - off; break;
    }

    return MA_SUCCESS;
}

/************
 ** public **
 ************/

EncodedRecSink *encoded_rec_sink_alloc(void) {
    return malloc0(sizeof(EncodedRecSink));
}
Result encoded_rec_sink_init(
    EncodedRecSink *const self,
    AudioEncoding const encoding,
    SampleFormat const sample_format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    uint8_t **const data_ptr,
    size_t *const data_size_ptr
) {
    ma_result r;

    self->data_ptr = data_ptr, self->data_size_ptr = data_size_ptr;
    self->pos = self->cap = *self->data_size_ptr = 0;
    *self->data_ptr = NULL;

    ma_encoder_config const encoder_config = ma_encoder_config_init(
        (ma_encoding_format)encoding,
        (ma_format)sample_format,
        channel_count,
        sample_rate

    );
    if ((r = ma_encoder_init(
             encoder_on_write,
             encoder_on_seek,
             self,
             &encoder_config,
             &self->encoder
         )) != MA_SUCCESS)
        return self->data_ptr = NULL,
               error("miniaudio encoder initialization error (code: %i)!", r),
               UnknownErr;

    return info("encoded rec sink initialized."), Ok;
}
void encoded_rec_sink_uninit(EncodedRecSink *const self) {
    ma_encoder_uninit(&self->encoder);
}

RecSink encoded_rec_sink_ww_rec_sink(EncodedRecSink *const self) WRAP_BODY(
    RecSink,
    REC_SINK_INTERFACE(EncodedRecSink),
    {
        .type = REC_SINK_TYPE_ENCODED,

        .get_enc = encoded_rec_sink_get_enc,
        .uninit = encoded_rec_sink_uninit,
    }
);
