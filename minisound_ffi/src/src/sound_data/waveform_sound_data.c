#include "../../include/sound_data/waveform_sound_data.h"

#include <assert.h>
#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

#define DEFAULT_AMPLITUDE (0.5)

/*************
 ** private **
 *************/

struct WaveformSoundData {
    ma_waveform waveform;
};

static ma_data_source *waveform_sound_data_get_ds(
    WaveformSoundData *const self
) {
    return &self->waveform;
}

/************
 ** public **
 ************/

WaveformSoundData *waveform_sound_data_alloc(void) {
    return malloc0(sizeof(WaveformSoundData));
}
Result waveform_sound_data_init(
    WaveformSoundData *const self,
    int const format,
    uint32_t const channels,
    uint32_t const sample_rate
) {
    ma_result r;

    ma_waveform_config const config = ma_waveform_config_init(
        // TODO? maybe needs not to be hardcoded here
        format,
        channels,
        sample_rate,
        ma_waveform_type_sine,
        DEFAULT_AMPLITUDE,
        0.0
    );
    if ((r = ma_waveform_init(&config, &self->waveform)) != MA_SUCCESS)
        return error("miniaudio waveform initialization error (code: %i)!", r),
               UnknownErr;

    return Ok;
}
void waveform_sound_data_uninit(WaveformSoundData *const self) {
    ma_waveform_uninit(&self->waveform);
}

WaveformType waveform_sound_data_get_type(WaveformSoundData *const self) {
    return (WaveformType)self->waveform.config.type;
}
void waveform_sound_data_set_type(
    WaveformSoundData *const self,
    WaveformType const value
) {
    ma_waveform_set_type(&self->waveform, (ma_waveform_type)value);
}

double waveform_sound_data_get_freq(WaveformSoundData *const self) {
    return (WaveformType)self->waveform.config.frequency;
}
void waveform_sound_data_set_freq(
    WaveformSoundData *const self,
    double const value
) {
    ma_waveform_set_frequency(&self->waveform, value);
}

SoundData
waveform_sound_data_ww_sound_data(WaveformSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(WaveformSoundData),
    {
        .type = SOUND_DATA_TYPE_WAVEFORM,

        .get_ds = waveform_sound_data_get_ds,
        .uninit = waveform_sound_data_uninit,
    }
);

// clang-format off

// this ensures safe casting between `WaveformType` and `ma_waveform_type`
static_assert((int)WAVEFORM_TYPE_SINE == (int)ma_waveform_type_sine, "`GENERATOR_WAVEFORM_TYPE_SINE` should match `ma_vaweform_type_sine`.");
static_assert((int)WAVEFORM_TYPE_SQUARE == (int)ma_waveform_type_square, "`GENERATOR_WAVEFORM_TYPE_SQUARE` should match `ma_waveform_type_square`.");
static_assert((int)WAVEFORM_TYPE_TRIANGLE == (int)ma_waveform_type_triangle, "`GENERATOR_WAVEFORM_TYPE_TRIANGLE` should match `ma_waveform_type_triangle`.");
static_assert((int)WAVEFORM_TYPE_SAWTOOTH == (int)ma_waveform_type_sawtooth, "`GENERATOR_WAVEFORM_TYPE_SAWTOOTH` should match `ma_waveform_type_sawtooth`.");

// clang-format on
