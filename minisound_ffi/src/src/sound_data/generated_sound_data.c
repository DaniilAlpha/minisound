#include "../../include/sound_data/generated_sound_data.h"

#include <stdlib.h>

#include "../../external/miniaudio/include/miniaudio.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

#define DEFAULT_AMPLITUDE (0.5)

// waveform

struct WaveformSoundData {
    ma_waveform waveform;
};

WaveformSoundData *waveform_sound_data_alloc(void) {
    return malloc(sizeof(WaveformSoundData));
}
Result waveform_sound_data_init(
    WaveformSoundData *const self,
    WaveformType const type,
    double const frequency
) {
    ma_waveform_config const config = ma_waveform_config_init(
        // TODO? maybe needs not to be hardcoded here
        ma_format_f32,
        1,
        48000,
        (ma_waveform_type)type,
        DEFAULT_AMPLITUDE,
        frequency
    );
    if (ma_waveform_init(&config, &self->waveform) != MA_SUCCESS)
        return error("failed to initialize waveform"), UnknownErr;

    return Ok;
}
void waveform_sound_data_uninit(WaveformSoundData *const self) {
    ma_waveform_uninit(&self->waveform);
}

ma_data_source *waveform_sound_data_get_ds(WaveformSoundData *const self) {
    return &self->waveform;
}

SoundData waveform_sound_data_ww_sound_data(WaveformSoundData *const self)
    WRAP_BODY(
        SoundData,
        SOUND_DATA_INTERFACE(WaveformSoundData),
        {
            .get_ds = waveform_sound_data_get_ds,
            .uninit = waveform_sound_data_uninit,
        }
    );

// noise

struct NoiseSoundData {
    ma_noise noise;
};

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

ma_data_source *noise_sound_data_get_ds(NoiseSoundData *const self) {
    return &self->noise;
}

SoundData noise_sound_data_ww_sound_data(NoiseSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(NoiseSoundData),
    {
        .get_ds = noise_sound_data_get_ds,
        .uninit = noise_sound_data_uninit,
    }
);

// pulse

struct PulseSoundData {
    ma_pulsewave pulse;
};

PulseSoundData *pulse_sound_data_alloc(void) {
    return malloc(sizeof(PulseSoundData));
}
Result pulse_sound_data_init(
    PulseSoundData *const self,
    double const frequency,
    double const duty_cycle
) {
    ma_pulsewave_config const config = ma_pulsewave_config_init(
        ma_format_f32,
        1,
        48000,
        duty_cycle,
        DEFAULT_AMPLITUDE,
        frequency
    );
    if (ma_pulsewave_init(&config, &self->pulse) != MA_SUCCESS)
        return error("failed to initialize pulsewave"), UnknownErr;

    return Ok;
}
void pulse_sound_data_uninit(PulseSoundData *const self) {
    ma_pulsewave_uninit(&self->pulse);
}

ma_data_source *pulse_sound_data_get_ds(PulseSoundData *const self) {
    return &self->pulse;
}

SoundData pulse_sound_data_ww_sound_data(PulseSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(PulseSoundData),
    {
        .get_ds = pulse_sound_data_get_ds,
        .uninit = pulse_sound_data_uninit,
    }
);

// clang-format off

// this ensures safe casting between `WaveformType` and `ma_waveform_type`
_Static_assert((int)WAVEFORM_TYPE_SINE == (int)ma_waveform_type_sine, "`GENERATOR_WAVEFORM_TYPE_SINE` should match `ma_vaweform_type_sine`.");
_Static_assert((int)WAVEFORM_TYPE_SQUARE == (int)ma_waveform_type_square, "`GENERATOR_WAVEFORM_TYPE_SQUARE` should match `ma_waveform_type_square`.");
_Static_assert((int)WAVEFORM_TYPE_TRIANGLE == (int)ma_waveform_type_triangle, "`GENERATOR_WAVEFORM_TYPE_TRIANGLE` should match `ma_waveform_type_triangle`.");
_Static_assert((int)WAVEFORM_TYPE_SAWTOOTH == (int)ma_waveform_type_sawtooth, "`GENERATOR_WAVEFORM_TYPE_SAWTOOTH` should match `ma_waveform_type_sawtooth`.");

// this ensures safe casting between `NoiseType` and `ma_noise_type`
_Static_assert((int)NOISE_TYPE_WHITE == (int)ma_noise_type_white, "`GENERATOR_NOISE_TYPE_WHITE` should match `ma_noise_type_white`.");
_Static_assert((int)NOISE_TYPE_PINK == (int)ma_noise_type_pink, "`GENERATOR_NOISE_TYPE_PINK` should match `ma_noise_type_pink`.");
_Static_assert((int)NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "`GENERATOR_NOISE_TYPE_BROWNIAN` should match `ma_noise_type_brownian`.");

// clang-format on
