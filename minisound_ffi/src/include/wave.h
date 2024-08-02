#ifndef WAVE_H
#define WAVE_H

#include <stdbool.h>
#include <stdint.h>

typedef struct Wave Wave;

typedef enum {
    WAVE_OK = 0,
    WAVE_ERROR
} WaveResult;

typedef enum {
    WAVE_TYPE_SINE,
    WAVE_TYPE_SQUARE,
    WAVE_TYPE_TRIANGLE,
    WAVE_TYPE_SAWTOOTH
} WaveType;

Wave* wave_create(void);
void wave_destroy(Wave* wave);
WaveResult wave_init(Wave* wave, WaveType type, double frequency, double amplitude, uint32_t sample_rate);
WaveResult wave_set_type(Wave* wave, WaveType type);
WaveResult wave_set_frequency(Wave* wave, double frequency);
WaveResult wave_set_amplitude(Wave* wave, double amplitude);
WaveResult wave_set_sample_rate(Wave* wave, uint32_t sample_rate);
int32_t wave_read(Wave* wave, float* output, int32_t frames_to_read);

#endif // WAVE_H
