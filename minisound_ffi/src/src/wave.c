#include "wave.h"
#include "../external/miniaudio/include/miniaudio.h"

#include <stdlib.h>
#include <string.h>

struct Wave {
    ma_waveform waveform;
};

static ma_waveform_type convert_wave_type(WaveType type) {
    switch (type) {
        case WAVE_TYPE_SINE:     return ma_waveform_type_sine;
        case WAVE_TYPE_SQUARE:   return ma_waveform_type_square;
        case WAVE_TYPE_TRIANGLE: return ma_waveform_type_triangle;
        case WAVE_TYPE_SAWTOOTH: return ma_waveform_type_sawtooth;
        default:                 return ma_waveform_type_sine;
    }
}

Wave* wave_create(void) {
    Wave* wave = (Wave*)malloc(sizeof(Wave));
    if (wave == NULL) {
        return NULL;
    }
    memset(wave, 0, sizeof(Wave));
    return wave;
}

void wave_destroy(Wave* wave) {
    free(wave);
}

WaveResult wave_init(Wave* wave, WaveType type, double frequency, double amplitude, uint32_t sample_rate) {
    if (wave == NULL) {
        return WAVE_ERROR;
    }

    ma_waveform_config config = ma_waveform_config_init(
        ma_format_f32,
        1,
        sample_rate,
        convert_wave_type(type),
        amplitude,
        frequency
    );

    if (ma_waveform_init(&config, &wave->waveform) != MA_SUCCESS) {
        return WAVE_ERROR;
    }

    return WAVE_OK;
}

WaveResult wave_set_type(Wave* wave, WaveType type) {
    if (wave == NULL) {
        return WAVE_ERROR;
    }
    ma_waveform_set_type(&wave->waveform, convert_wave_type(type));
    return WAVE_OK;
}

WaveResult wave_set_frequency(Wave* wave, double frequency) {
    if (wave == NULL) {
        return WAVE_ERROR;
    }
    ma_waveform_set_frequency(&wave->waveform, frequency);
    return WAVE_OK;
}

WaveResult wave_set_amplitude(Wave* wave, double amplitude) {
    if (wave == NULL) {
        return WAVE_ERROR;
    }
    ma_waveform_set_amplitude(&wave->waveform, amplitude);
    return WAVE_OK;
}

WaveResult wave_set_sample_rate(Wave* wave, uint32_t sample_rate) {
    if (wave == NULL) {
        return WAVE_ERROR;
    }
    ma_waveform_set_sample_rate(&wave->waveform, sample_rate);
    return WAVE_OK;
}

int32_t wave_read(Wave* wave, float* output, int32_t frames_to_read) {
    if (wave == NULL || output == NULL || frames_to_read <= 0) {
        return 0;
    }

    ma_waveform_read_pcm_frames(&wave->waveform, output, (ma_uint64)frames_to_read, NULL);
    return frames_to_read;
}
