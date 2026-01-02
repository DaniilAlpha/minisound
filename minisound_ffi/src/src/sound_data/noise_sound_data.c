#include "../../include/sound_data/noise_sound_data.h"

#include <assert.h>
#include <miniaudio.h>

#include "conviniences.h"

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
    return malloc0(sizeof(NoiseSoundData));
}
Result noise_sound_data_init(
    NoiseSoundData *const self,
    NoiseType const type,

    int const format,
    uint32_t const channels
) {
    ma_result r;

    ma_noise_config const config = ma_noise_config_init(
        format,
        channels,
        (ma_noise_type)type,
        1999999999,
        DEFAULT_AMPLITUDE
    );
    if ((r = ma_noise_init(&config, NULL, &self->noise)) != MA_SUCCESS)
        return error("miniaudio noise initialization error (code: %i)!", r),
               UnknownErr;

    return Ok;
}
void noise_sound_data_uninit(NoiseSoundData *const self) {
    ma_noise_uninit(&self->noise, NULL);
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
static_assert((int)NOISE_TYPE_WHITE == (int)ma_noise_type_white, "`GENERATOR_NOISE_TYPE_WHITE` should match `ma_noise_type_white`.");
static_assert((int)NOISE_TYPE_PINK == (int)ma_noise_type_pink, "`GENERATOR_NOISE_TYPE_PINK` should match `ma_noise_type_pink`.");
static_assert((int)NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "`GENERATOR_NOISE_TYPE_BROWNIAN` should match `ma_noise_type_brownian`.");

// clang-format on
