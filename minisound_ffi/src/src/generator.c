#include "../include/generator.h"

#include <stdlib.h>
#include <string.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/circular_buffer.h"

#define MILO_LVL GENERATOR_MILO_LVL
#include "../external/milo/milo.h"

#define DEVICE_FORMAT      (ma_format_f32)
#define DEVICE_CHANNELS    (2)
#define DEVICE_SAMPLE_RATE (48000)

// clang-format off

// this ensures safe casting between `GeneratorWaveformType` and `ma_waveform_type`
_Static_assert((int)GENERATOR_WAVEFORM_TYPE_SINE == (int)ma_waveform_type_sine, "GENERATOR_WAVEFORM_TYPE_SINE should match ma_vaweform_type_sine.");
_Static_assert((int)GENERATOR_WAVEFORM_TYPE_SQUARE == (int)ma_waveform_type_square, "GENERATOR_WAVEFORM_TYPE_SQUARE should match ma_waveform_type_square.");
_Static_assert((int)GENERATOR_WAVEFORM_TYPE_TRIANGLE == (int)ma_waveform_type_triangle, "GENERATOR_WAVEFORM_TYPE_TRIANGLE should match ma_waveform_type_triangle.");
_Static_assert((int)GENERATOR_WAVEFORM_TYPE_SAWTOOTH == (int)ma_waveform_type_sawtooth, "GENERATOR_WAVEFORM_TYPE_SAWTOOTH should match ma_waveform_type_sawtooth.");

// this ensures safe casting between `GeneratorNoiseType` and `ma_noise_type`
_Static_assert((int)GENERATOR_NOISE_TYPE_WHITE == (int)ma_noise_type_white, "GENERATOR_NOISE_TYPE_WHITE should match ma_noise_type_white.");
_Static_assert((int)GENERATOR_NOISE_TYPE_PINK == (int)ma_noise_type_pink, "GENERATOR_NOISE_TYPE_PINK should match ma_noise_type_pink.");
_Static_assert((int)GENERATOR_NOISE_TYPE_BROWNIAN == (int)ma_noise_type_brownian, "GENERATOR_NOISE_TYPE_BROWNIAN should match ma_noise_type_brownian.");

// clang-format on

struct Generator {
    CircularBuffer circular_buffer;
    uint32_t channels;
    uint32_t sample_rate;

    GeneratorType type;

    ma_device device;
};

// TODO! move out of global variables to make multi-generator setup work
ma_waveform waveform;
ma_pulsewave pulsewave;
ma_noise noise;
ma_waveform_config sineWaveConfig;

/*************
 ** private **
 *************/

static void data_callback(
    ma_device *pDevice,
    void *pOutput,
    void const *pInput,
    ma_uint32 frameCount
) {
    Generator *const self = pDevice->pUserData;

    circular_buffer_read_available(&self->circular_buffer, pOutput, frameCount);

    switch (self->type) {
    case GENERATOR_TYPE_WAVEFORM:
        ma_waveform_read_pcm_frames(&waveform, pOutput, frameCount, NULL);
        break;
    case GENERATOR_TYPE_PULSEWAVE:
        ma_pulsewave_read_pcm_frames(&pulsewave, pOutput, frameCount, NULL);
        break;
    case GENERATOR_TYPE_NOISE:
        ma_noise_read_pcm_frames(&noise, pOutput, frameCount, NULL);
        break;
    default: warn("unknown generator type.\n");
    }

    circular_buffer_write(
        &self->circular_buffer,
        pOutput,
        frameCount * self->channels
    );

    (void)pInput;
}

/************
 ** public **
 ************/

Generator *generator_create(void) {
    Generator *const generator = malloc(sizeof(*generator));
    if (generator == NULL) return error("failed to allocate generator"), NULL;
    memset(generator, 0, sizeof(Generator));
    return generator;
}

GeneratorResult generator_init(
    Generator *const self,
    SoundFormat const sound_format,
    uint32_t const channels,
    uint32_t const sample_rate,
    float const buffer_len_s
) {
    self->channels = channels;
    self->sample_rate = sample_rate;

    ma_format const format = (ma_format)sound_format;

    if (buffer_len_s <= 0 || sample_rate <= 0 || channels <= 0)
        return error(
                   "`generator_init` invalid arg: %i, %u, %u, %f",
                   sound_format,
                   channels,
                   sample_rate,
                   buffer_duration_seconds,
               ),
               GENERATOR_ARG_ERROR;

    size_t const buffer_size_in_bytes =
        (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) *
                 buffer_len_s);
    if (circular_buffer_init(&self->circular_buffer, buffer_size_in_bytes) != 0)
        return error("failed to init circular buffer"),
               GENERATOR_CIRCULAR_BUFFER_INIT_ERROR;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_playback);
    device_config.playback.format = format;
    device_config.playback.channels = channels;
    device_config.sampleRate = sample_rate;
    device_config.dataCallback = data_callback;
    device_config.pUserData = self;
    if (ma_device_init(NULL, &device_config, &self->device) != MA_SUCCESS)
        return circular_buffer_uninit(&self->circular_buffer),
               error("failed to init device"), GENERATOR_DEVICE_INIT_ERROR;

    generator_set_noise(self, GENERATOR_NOISE_TYPE_WHITE, 0, 0.5);
    generator_set_pulsewave(self, 440.0, 0.5, 0.5);
    generator_set_waveform(self, GENERATOR_WAVEFORM_TYPE_SINE, 440.0, 0.5);

    return GENERATOR_OK;
}
void generator_uninit(Generator *const self) {
    ma_waveform_uninit(&waveform);
    ma_pulsewave_uninit(&pulsewave);
    ma_noise_uninit(&noise, NULL);
    circular_buffer_uninit(&self->circular_buffer);
}

float generator_get_volume(Generator *const self) {
    float volume;
    ma_device_get_master_volume(&self->device, &volume);
    return volume;
}
void generator_set_volume(Generator *const self, float const value) {
    ma_device_set_master_volume(&self->device, value);
}

GeneratorResult generator_set_waveform(
    Generator *const self,
    GeneratorWaveformType const type,
    double const frequency,
    double const amplitude
) {
    self->type = GENERATOR_TYPE_WAVEFORM;

    ma_waveform_config const config = ma_waveform_config_init(
        self->device.playback.format,
        self->device.playback.channels,
        self->device.sampleRate,
        (ma_waveform_type)type,
        amplitude,
        frequency
    );

    // TODO! we are possibly leaking memory here (coz waveform can already be
    // init)
    if (ma_waveform_init(&config, &waveform) != MA_SUCCESS)
        return error("failed to initialize waveform"), GENERATOR_SET_TYPE_ERROR;

    return GENERATOR_OK;
}

GeneratorResult generator_set_pulsewave(
    Generator *const self,
    double const frequency,
    double const amplitude,
    double const duty_cycle
) {
    self->type = GENERATOR_TYPE_PULSEWAVE;

    ma_pulsewave_config const config = ma_pulsewave_config_init(
        self->device.playback.format,
        self->device.playback.channels,
        self->device.sampleRate,
        duty_cycle,
        amplitude,
        frequency
    );
    // TODO! we are possibly leaking memory here (coz waveform can already be
    // init)
    if (ma_pulsewave_init(&config, &pulsewave) != MA_SUCCESS)
        return error("failed to initialize pulsewave"),
               GENERATOR_SET_TYPE_ERROR;

    return GENERATOR_OK;
}

GeneratorResult generator_set_noise(
    Generator *const self,
    GeneratorNoiseType const type,
    int32_t const seed,
    double const amplitude
) {
    self->type = GENERATOR_TYPE_NOISE;

    ma_noise_config const config = ma_noise_config_init(
        self->device.playback.format,
        self->device.playback.channels,
        (ma_noise_type)type,
        seed,
        amplitude
    );
    // TODO! we are possibly leaking memory here (coz waveform can already be
    // init)
    if (ma_noise_init(&config, NULL, &noise) != MA_SUCCESS)
        return error("failed to initialize noise"), GENERATOR_SET_TYPE_ERROR;

    return GENERATOR_OK;
}

GeneratorResult generator_start(Generator *const self) {
    if (ma_device_start(&self->device) != MA_SUCCESS)
        return error("Error: Failed to start generator.\n"),
               GENERATOR_DEVICE_START_ERROR;

    return GENERATOR_OK;
}
void generator_stop(Generator *const self) { ma_device_stop(&self->device); }

size_t generator_get_available_float_count(Generator *const self) {
    return circular_buffer_get_available_floats(&self->circular_buffer);
}
size_t generator_load_buffer(
    Generator *const self,
    float *const output,
    size_t const floats_to_read
) {
    size_t const available_floats = generator_get_available_float_count(self);
    size_t const to_read =
        floats_to_read < available_floats ? floats_to_read : available_floats;

    return circular_buffer_read(&self->circular_buffer, output, to_read);
}
