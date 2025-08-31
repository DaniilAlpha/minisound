#include "../include/engine.h"

#include <stdbool.h>
#include <stdlib.h>

#include <miniaudio.h>

#include "../include/sound_data/encoded_sound_data.h"
#include "../include/sound_data/pulse_sound_data.h"
#include "conviniences.h"

#define MILO_LVL ENGINE_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** private **
 *************/

typedef enum EngineState {
    ENGINE_STATE_UNINITIALIZED = 0,
    ENGINE_STATE_INITIALIZED,
    ENGINE_STATE_STARTED,
} EngineState;

struct Engine {
    ma_engine engine;

    EngineState state;
};

/************
 ** public **
 ************/

Engine *engine_alloc(void) { return malloc0(sizeof(Engine)); }

Result engine_init(Engine *const self, uint32_t const period_ms) {
    if (self->state != ENGINE_STATE_UNINITIALIZED) return Ok;

    ma_engine_config config = ma_engine_config_init();
#if (__EMSCRIPTEN__)
    (void)period_ms;
#else
    config.periodSizeInMilliseconds = period_ms;
#endif
    config.noAutoStart = true;
    if (ma_engine_init(&config, &self->engine) != MA_SUCCESS)
        return error("miniaudio engine initialization error!"), UnknownErr;

    self->state = ENGINE_STATE_INITIALIZED;
    return info("engine initialized"), Ok;
}
void engine_uninit(Engine *const self) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return;

    ma_engine_uninit(&self->engine);
    self->state = ENGINE_STATE_UNINITIALIZED;
}

Result engine_start(Engine *const self) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return StateErr;
    if (self->state == ENGINE_STATE_STARTED) return Ok;

    if (ma_engine_start(&self->engine) != MA_SUCCESS)
        return error("miniaudio engine starting error!"), UnknownErr;

    self->state = ENGINE_STATE_STARTED;
    return info("engine started"), Ok;
}

Result engine_load_sound(
    Engine *const self,
    Sound *const sound,
    uint8_t const *const data,
    size_t const data_size
) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return StateErr;

    EncodedSoundData *const encoded = encoded_sound_data_alloc();
    if (encoded == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(encoded_sound_data_init(encoded, data, data_size), {
        free(encoded);
    });

    UNROLL_CLEANUP(
        sound_init(
            sound,
            encoded_sound_data_ww_sound_data(encoded),
            &self->engine
        ),
        { encoded_sound_data_uninit(encoded), free(encoded); }
    );

    return info("sound loaded"), Ok;
}

Result engine_generate_waveform(
    Engine *const self,
    Sound *const sound,
    WaveformType const type,
    double const frequency
) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return StateErr;

    WaveformSoundData *const waveform = waveform_sound_data_alloc();
    if (waveform == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(waveform_sound_data_init(waveform, type, frequency), {
        free(waveform);
    });

    UNROLL_CLEANUP(
        sound_init(
            sound,
            waveform_sound_data_ww_sound_data(waveform),
            &self->engine
        ),
        { waveform_sound_data_uninit(waveform), free(waveform); }
    );

    return info("waveform generated"), Ok;
}
Result engine_generate_noise(
    Engine *const self,
    Sound *const sound,
    NoiseType const type,
    int32_t const seed
) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return StateErr;

    NoiseSoundData *const noise = noise_sound_data_alloc();
    if (noise == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(noise_sound_data_init(noise, type, seed), { free(noise); });

    UNROLL_CLEANUP(
        sound_init(sound, noise_sound_data_ww_sound_data(noise), &self->engine),
        { noise_sound_data_uninit(noise), free(noise); }
    );

    return info("noise generated"), Ok;
}
Result engine_generate_pulse(
    Engine *const self,
    Sound *const sound,
    double const frequency,
    double const duty_cycle
) {
    if (self->state == ENGINE_STATE_UNINITIALIZED) return StateErr;

    PulseSoundData *const pulse = pulse_sound_data_alloc();
    if (pulse == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(pulse_sound_data_init(pulse, frequency, duty_cycle), {
        free(pulse);
    });

    UNROLL_CLEANUP(
        sound_init(sound, pulse_sound_data_ww_sound_data(pulse), &self->engine),
        { pulse_sound_data_uninit(pulse), free(pulse); }
    );

    return info("pulse generated"), Ok;
}
