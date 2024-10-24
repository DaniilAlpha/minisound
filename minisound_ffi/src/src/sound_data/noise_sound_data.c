#include "../../include/sound_data/noise_sound_data.h"

#include <stdlib.h>

#include "../../external/miniaudio/include/miniaudio.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

#define DEFAULT_AMPLITUDE (0.5)

/*************
 ** private **
 *************/

struct NoiseSoundData {
    ma_noise noise;
};

static ma_data_source *noise_sound_data_get_ds(NoiseSoundData *const self) {
    return &self->noise;
}

/************
 ** public **
 ************/

NoiseSoundData *noise_sound_data_alloc(void) {
    return malloc(sizeof(NoiseSoundData));
}
Result noise_sound_data_init(
    NoiseSoundData *const self,
    NoiseType const type,
    int32_t const seed
) {
    ma_noise_config const config = ma_noise_config_init(
        ma_format_f32,
        1,
        (ma_noise_type)type,
        seed,
        DEFAULT_AMPLITUDE
    );
    if (ma_noise_init(&config, NULL, &self->noise) != MA_SUCCESS)
        return error("failed to initialize noise"), UnknownErr;

    return Ok;
}
void noise_sound_data_uninit(NoiseSoundData *const self) {
    ma_noise_uninit(&self->noise, NULL);
}

void noise_sound_data_set_seed(
    NoiseSoundData *const self,
    int32_t const value
) {
    ma_noise_set_seed(&self->noise, value);
}

SoundData noise_sound_data_ww_sound_data(NoiseSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(NoiseSoundData),
    {
        .type = SOUND_DATA_TYPE_NOISE,

        .get_ds = noise_sound_data_get_ds,
        .uninit = noise_sound_data_uninit,
    }
);

// clang-format off

// this ensures safe casting between `NoiseType` and `ma_noise_type`
_Static_assert((int)NOISE_TYPE_WHITE == (int)ma_noise_type_white, "`GENERATOR_NOISE_TYPE_WHITE` should match `ma_noise_type_white`.");
_Static_assert((int)NOISE_TYPE_PINK == (int)ma_noise_type_pink, "`GENERATOR_NOISE_TYPE_PINK` should match `ma_noise_type_pink`.");
_Static_assert((int)NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "`GENERATOR_NOISE_TYPE_BROWNIAN` should match `ma_noise_type_brownian`.");

// clang-format on
