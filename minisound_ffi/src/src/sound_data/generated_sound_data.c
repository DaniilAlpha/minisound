#include "../../include/sound_data/generated_sound_data.h"

#include <stdlib.h>

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../include/sound_data/pulse_data_source.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

#define DEFAULT_AMPLITUDE (0.5)

/*************
 ** private **
 *************/

// waveform

struct WaveformSoundData {
    ma_waveform waveform;
};

static ma_data_source *waveform_sound_data_get_ds(WaveformSoundData *const self
) {
    return &self->waveform;
}

// noise

struct NoiseSoundData {
    ma_noise noise;
};

static ma_data_source *noise_sound_data_get_ds(NoiseSoundData *const self) {
    return &self->noise;
}

// pulse

struct PulseSoundData {
    PulseDataSource pulse;
};

ma_data_source *pulse_sound_data_get_ds(PulseSoundData *const self) {
    return &self->pulse;
}

/************
 ** public **
 ************/

// waveform

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

void waveform_sound_data_set_type(
    WaveformSoundData *const self,
    WaveformType const value
) {
    ma_waveform_set_type(&self->waveform, (ma_waveform_type)value);
}
void waveform_sound_data_set_freq(
    WaveformSoundData *const self,
    double const value
) {
    ma_waveform_set_frequency(&self->waveform, value);
}

SoundData waveform_sound_data_ww_sound_data(WaveformSoundData *const self)
    WRAP_BODY(
        SoundData,
        SOUND_DATA_INTERFACE(WaveformSoundData),
        {
            .type = SOUND_DATA_TYPE_WAVEFORM,

            .get_ds = waveform_sound_data_get_ds,
            .uninit = waveform_sound_data_uninit,
        }
    );

// noise

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

void noise_sound_data_set_seed(NoiseSoundData *const self, int32_t const seed) {
    ma_noise_set_seed(&self->noise, seed);
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

// pulse

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
    if (pulse_data_source_init(&self->pulse, &config) != Ok)
        return error("failed to initialize pulse"), UnknownErr;

    return Ok;
}
void pulse_sound_data_uninit(PulseSoundData *const self) {
    pulse_data_source_uninit(&self->pulse);
}

void pulse_sound_data_set_freq(PulseSoundData *const self, double const value) {
    ma_pulsewave_set_frequency(&self->pulse.pulsewave, value);
}
void pulse_sound_data_set_duty_cycle(
    PulseSoundData *const self,
    double const value
) {
    ma_pulsewave_set_duty_cycle(&self->pulse.pulsewave, value);
}

SoundData pulse_sound_data_ww_sound_data(PulseSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(PulseSoundData),
    {
        .type = SOUND_DATA_TYPE_PULSE,

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
