#include "../include/engine.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/sound_data/encoded_sound_data.h"
#include "../include/sound_data/generated_sound_data.h"

#define MILO_LVL ENGINE_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** private **
 *************/

struct Engine {
    bool is_started;

    ma_engine engine;
    ma_decoder_config dec_config;
};

/************
 ** public **
 ************/

Engine *engine_alloc(void) { return malloc(sizeof(Engine)); }

Result engine_init(Engine *const self, uint32_t const period_ms) {
    self->is_started = false;

    ma_engine_config engine_config = ma_engine_config_init();
    engine_config.periodSizeInMilliseconds = period_ms;
    engine_config.noAutoStart = true;
    if (ma_engine_init(&engine_config, &self->engine) != MA_SUCCESS)
        return error("miniaudio engine initialization error!"), UnknownErr;

    self->dec_config = ma_decoder_config_init(
        self->engine.pDevice->playback.format,
        self->engine.pDevice->playback.channels,
        self->engine.sampleRate
    );

    info("engine initialized");

    return Ok;
}
void engine_uninit(Engine *const self) { ma_engine_uninit(&self->engine); }

Result engine_start(Engine *const self) {
    if (self->is_started) return Ok;

    if (ma_engine_start(&self->engine) != MA_SUCCESS)
        return error("miniaudio engine starting error!"), UnknownErr;

    self->is_started = true;

    info("engine started");

    return Ok;
}

Result engine_load_sound(
    Engine *const self,
    Sound *const sound,
    uint8_t const *const data,
    size_t const data_size
) {
    EncodedSoundData *const sound_data = encoded_sound_data_alloc();
    if (sound_data == NULL) return OutOfMemErr;
    UNROLL(encoded_sound_data_init(sound_data, data, data_size));

    return sound_init(
        sound,
        encoded_sound_data_ww_sound_data(sound_data),
        self
    );
}

Result engine_generate_waveform(
    Engine *const self,
    Sound *const sound,
    WaveformType const type,
    double const frequency,
    double const amplitude
) {
    WaveformSoundData *const waveform = waveform_sound_data_alloc();
    if (waveform == NULL) return OutOfMemErr;
    UNROLL(waveform_sound_data_init(waveform, type, frequency, amplitude));

    return sound_init(sound, waveform_sound_data_ww_sound_data(waveform), self);
}
