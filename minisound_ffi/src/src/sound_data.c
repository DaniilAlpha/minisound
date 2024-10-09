#include "../include/sound_data.h"

#include <stdbool.h>
#include <stdlib.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/circular_buffer.h"
#include "../include/silence_data_source.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** structs **
 *************/

// recorded

struct RecordedSoundData {
    CircularBuffer circular_buffer;

    bool do_write_to_file;
    ma_encoder encoder;
};

// generated

struct WaveformSoundData {
    ma_waveform waveform;
};

struct NoiseSoundData {
    ma_noise noise;
};

struct PulseSoundData {
    ma_pulsewave pulse;
};

/*************
 ** methods **
 *************/

// generated

Result waveform_sound_data_init(
    WaveformSoundData *const self,
    WaveformType const type,
    double const frequency,
    double const amplitude
) {
    ma_waveform_config const config = ma_waveform_config_init(
        // self->device.playback.format,
        // self->device.playback.channels,
        // self->device.sampleRate,
        0,
        0,
        0,
        (ma_waveform_type)type,
        amplitude,
        frequency
    );
    if (ma_waveform_init(&config, &self->waveform) != MA_SUCCESS)
        return error("failed to initialize waveform"), UnknownErr;

    return Ok;
}
Result noise_sound_data_init(
    NoiseSoundData *const self,
    NoiseType const type,
    int32_t const seed,
    double const amplitude
) {
    ma_noise_config const config = ma_noise_config_init(
        // self->device.playback.format,
        // self->device.playback.channels,
        0,
        0,
        (ma_noise_type)type,
        seed,
        amplitude
    );
    if (ma_noise_init(&config, NULL, &self->noise) != MA_SUCCESS)
        return error("failed to initialize noise"), UnknownErr;

    return Ok;
}
Result pulse_sound_data_init(
    PulseSoundData *const self,
    double const frequency,
    double const amplitude,
    double const duty_cycle
) {
    ma_pulsewave_config const config =
        ma_pulsewave_config_init(0, 0, 0, duty_cycle, amplitude, frequency);
    if (ma_pulsewave_init(&config, &self->pulse) != MA_SUCCESS)
        return error("failed to initialize pulsewave"), UnknownErr;

    return Ok;
}

// clang-format off

// this ensures safe casting between `WaveformType` and `ma_waveform_type`
_Static_assert((int)WAVEFORM_TYPE_SINE == (int)ma_waveform_type_sine, "GENERATOR_WAVEFORM_TYPE_SINE should match ma_vaweform_type_sine.");
_Static_assert((int)WAVEFORM_TYPE_SQUARE == (int)ma_waveform_type_square, "GENERATOR_WAVEFORM_TYPE_SQUARE should match ma_waveform_type_square.");
_Static_assert((int)WAVEFORM_TYPE_TRIANGLE == (int)ma_waveform_type_triangle, "GENERATOR_WAVEFORM_TYPE_TRIANGLE should match ma_waveform_type_triangle.");
_Static_assert((int)WAVEFORM_TYPE_SAWTOOTH == (int)ma_waveform_type_sawtooth, "GENERATOR_WAVEFORM_TYPE_SAWTOOTH should match ma_waveform_type_sawtooth.");

// this ensures safe casting between `NoiseType` and `ma_noise_type`
_Static_assert((int)NOISE_TYPE_WHITE == (int)ma_noise_type_white, "GENERATOR_NOISE_TYPE_WHITE should match ma_noise_type_white.");
_Static_assert((int)NOISE_TYPE_PINK == (int)ma_noise_type_pink, "GENERATOR_NOISE_TYPE_PINK should match ma_noise_type_pink.");
_Static_assert((int)NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "GENERATOR_NOISE_TYPE_BROWNIAN should match ma_noise_type_brownian.");

// clang-format on
