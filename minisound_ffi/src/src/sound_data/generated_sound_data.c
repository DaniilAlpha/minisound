#include "../../include/sound_data/generated_sound_data.h"

#include <stdlib.h>

#include "../../external/miniaudio/include/miniaudio.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

struct WaveformSoundData {
    ma_waveform waveform;
};
struct NoiseSoundData {
    ma_noise noise;
};
struct PulseSoundData {
    ma_pulsewave pulse;
};

WaveformSoundData *waveform_sound_data_alloc(void) {
    return malloc(sizeof(WaveformSoundData));
}
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

NoiseSoundData *noise_sound_data_alloc(void) {
    return malloc(sizeof(NoiseSoundData));
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

PulseSoundData *pulse_sound_data_alloc(void) {
    return malloc(sizeof(PulseSoundData));
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
