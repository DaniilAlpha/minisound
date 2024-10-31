#ifndef NOISE_SOUND_DATA_H
#define NOISE_SOUND_DATA_H

#include <stdint.h>

#include "../../external/result/result.h"
#include "../../include/export.h"
#include "sound_data.h"

typedef struct NoiseSoundData NoiseSoundData;
typedef enum NoiseType {
    NOISE_TYPE_WHITE,
    NOISE_TYPE_PINK,
    NOISE_TYPE_BROWNIAN,
} NoiseType;

NoiseSoundData *noise_sound_data_alloc(void);
Result noise_sound_data_init(
    NoiseSoundData *const self,
    NoiseType const type,
    int32_t const seed
);
void noise_sound_data_uninit(NoiseSoundData *const self);

EXPORT void
noise_sound_data_set_seed(NoiseSoundData *const self, int32_t const value);

SoundData noise_sound_data_ww_sound_data(NoiseSoundData *const self);

#endif
