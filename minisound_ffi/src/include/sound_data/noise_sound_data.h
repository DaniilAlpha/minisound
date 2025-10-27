#ifndef NOISE_SOUND_DATA_H
#define NOISE_SOUND_DATA_H

#include <stdint.h>

#include "../../external/result/result.h"
#include "sound_data.h"

typedef struct NoiseSoundData NoiseSoundData;
typedef enum NoiseType {
    NOISE_TYPE_WHITE,
    NOISE_TYPE_PINK,
    NOISE_TYPE_BROWNIAN,
} NoiseType;

NoiseSoundData *noise_sound_data_alloc(void);
Result noise_sound_data_init(NoiseSoundData *const self, NoiseType const type);
void noise_sound_data_uninit(NoiseSoundData *const self);

SoundData noise_sound_data_ww_sound_data(NoiseSoundData *const self);

#endif
