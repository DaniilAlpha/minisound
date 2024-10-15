#ifndef ENCODED_SOUND_DATA_H
#define ENCODED_SOUND_DATA_H

#include <stdint.h>

#include "../../external/result/result.h"
#include "../export.h"
#include "sound_data.h"

typedef struct EncodedSoundData EncodedSoundData;

EncodedSoundData *encoded_sound_data_alloc(void);
Result encoded_sound_data_init(
    EncodedSoundData *const self,
    uint8_t const *const data,
    size_t const data_size
);
void encoded_sound_data_uninit(EncodedSoundData *const self);

EXPORT bool encoded_sound_data_get_is_looped(EncodedSoundData const *const self
);
EXPORT void encoded_sound_data_set_looped(
    EncodedSoundData *const self,
    bool const value,
    size_t const delay_ms
);

SoundData encoded_sound_data_ww_sound_data(EncodedSoundData *const self);

#endif
