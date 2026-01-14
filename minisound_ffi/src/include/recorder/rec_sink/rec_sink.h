#ifndef REC_SINK_H
#define REC_SINK_H

#include <stddef.h>
#include <stdint.h>

#include <woodi.h>

typedef enum RecSinkType {
    REC_SINK_TYPE_ENCODED,
} RecSinkType;
typedef struct ma_encoder ma_encoder;
#define REC_SINK_INTERFACE(Self)                                               \
    {                                                                          \
        RecSinkType const type;                                                \
                                                                               \
        ma_encoder *(*const get_enc)(Self *const);                             \
        void (*const uninit)(Self *const);                                     \
    }
WRAPPER(RecSink, REC_SINK_INTERFACE);

static inline RecSinkType rec_sink_get_type(RecSink const *const self) {
    return self->__vtbl->type;
}

/// Assuming returning `ma_encoder` (without exposing to public api).
static inline ma_encoder *rec_sink_get_enc(RecSink const *const self) {
    return WRAPPER_CALL(get_enc, self);
}
static inline void rec_sink_uninit(RecSink const *const self) {
    return WRAPPER_CALL(uninit, self);
}

#endif
