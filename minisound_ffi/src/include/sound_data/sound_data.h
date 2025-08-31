#ifndef SOUND_DATA_H
#define SOUND_DATA_H

#include <stdbool.h>
#include <stdint.h>

#include <miniaudio.h>

#include "../../external/woodi/woodi.h"

typedef enum SoundDataType {
    SOUND_DATA_TYPE_ENCODED,
    SOUND_DATA_TYPE_WAVEFORM,
    SOUND_DATA_TYPE_NOISE,
    SOUND_DATA_TYPE_PULSE
} SoundDataType;
#define SOUND_DATA_INTERFACE(Self)                                             \
    {                                                                          \
        SoundDataType const type;                                              \
                                                                               \
        ma_data_source *(*const get_ds)(Self *const);                          \
        void (*const uninit)(Self *const);                                     \
    }
WRAPPER(SoundData, SOUND_DATA_INTERFACE);

static inline SoundDataType sound_data_get_type(SoundData const *const self) {
    return self->__vtbl->type;
}

static inline ma_data_source *sound_data_get_ds(SoundData *const self) {
    return WRAPPER_CALL(get_ds, self);
}
static inline void sound_data_uninit(SoundData *const self) {
    return WRAPPER_CALL(uninit, self);
}

#endif
