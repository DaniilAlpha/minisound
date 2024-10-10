#include "../include/recorder.h"

#include "../external/miniaudio/include/miniaudio.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"

struct Recorder {
    bool is_recording;

    ma_device device;
};

/*************
 ** private **
 *************/

static void data_callback(
    ma_device *pDevice,
    void *pOutput,
    void const *pInput,
    ma_uint32 frameCount
) {
    // Recorder *const self = pDevice->pUserData;
    //
    // size_t const floatsToWrite = frameCount * self->channels;
    //
    // // Write raw PCM data directly to the circular buffer
    // circular_buffer_write(
    //     &self->circular_buffer,
    //     (float const *)pInput,
    //     floatsToWrite
    // );
    //
    // if (self->do_write_to_file)
    //     ma_encoder_write_pcm_frames(&self->encoder, pInput, frameCount,
    //     NULL);
    //
    // (void)pOutput;
}

static RecorderResult recorder_init_common(
    Recorder *const self,
    uint32_t const sample_rate,
    uint32_t const channels,
    // SoundFormat const sound_format,
    float const buffer_len_s
) {
    // self->is_recording = false;
    // self->format = (ma_format)sound_format;
    // self->channels = channels;
    //
    // size_t const buffer_size_in_bytes =
    //     (size_t)(sample_rate *
    //              ma_get_bytes_per_frame(self->format, self->channels) *
    //              buffer_len_s);
    // if (circular_buffer_init(&self->circular_buffer, buffer_size_in_bytes) !=
    // 0)
    //     return RECORDER_ERROR_OUT_OF_MEMORY;
    //
    // ma_device_config device_config =
    //     ma_device_config_init(ma_device_type_capture);
    // device_config.capture.format = self->format;
    // device_config.capture.channels = self->channels;
    // device_config.sampleRate = sample_rate;
    // device_config.dataCallback = data_callback;
    // device_config.pUserData = self;
    // if (ma_device_init(NULL, &device_config, &self->device) != MA_SUCCESS) {
    //     circular_buffer_uninit(&self->circular_buffer);
    //     return RECORDER_ERROR_UNKNOWN;
    // }
    //
    return RECORDER_OK;
}

/************
 ** public **
 ************/

Recorder *recorder_create(void) { return malloc(sizeof(Recorder)); }

RecorderResult recorder_init_file(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels
    // SoundFormat const sound_format
) {
    // if (filename == NULL) return RECORDER_ERROR_INVALID_ARGUMENT;
    //
    // self->do_write_to_file = true;
    //
    // ma_encoder_config encoder_config = ma_encoder_config_init(
    //     ma_encoding_format_wav,
    //     (ma_format)sound_format,
    //     channels,
    //     sample_rate
    // );
    // if (ma_encoder_init_file(filename, &encoder_config, &self->encoder) !=
    //     MA_SUCCESS)
    //     return RECORDER_ERROR_UNKNOWN;
    //
    // RecorderResult const r =
    //     recorder_init_common(self, sample_rate, channels,
    //     sound_format, 5.0f);
    // return r;
    return RECORDER_OK;
}

RecorderResult recorder_init_stream(
    Recorder *const self,
    uint32_t const sample_rate,
    uint32_t const channels,
    // SoundFormat const sound_format,
    float const buffer_len_s
) {
    return recorder_init_common(
        self,
        sample_rate,
        channels,
        // sound_format,
        buffer_len_s
    );
}
void recorder_uninit(Recorder *const self) {
    // ma_device_uninit(&self->device);
    // if (self->do_write_to_file) ma_encoder_uninit(&self->encoder);
    // circular_buffer_uninit(&self->circular_buffer);
}

bool recorder_get_is_recording(Recorder const *recorder) {
    return recorder->is_recording;
}

RecorderResult recorder_start(Recorder *const self) {
    if (self->is_recording) return RECORDER_ERROR_ALREADY_RECORDING;

    if (ma_device_start(&self->device) != MA_SUCCESS)
        return RECORDER_ERROR_UNKNOWN;

    self->is_recording = true;

    return RECORDER_OK;
}
void recorder_stop(Recorder *const self) {
    ma_device_stop(&self->device);

    self->is_recording = false;
}

size_t recorder_get_available_float_count(Recorder *const self) {
    // return circular_buffer_get_available_floats(&self->circular_buffer);
    return 0;
}
size_t recorder_load_buffer(
    Recorder *const self,
    float *const output,
    size_t const floats_to_read
) {
    // if (self == NULL || output == NULL || floats_to_read <= 0) { return 0; }
    //
    // size_t const available_floats = recorder_get_available_float_count(self);
    // size_t const to_read =
    //     (floats_to_read < available_floats) ? floats_to_read :
    //     available_floats;

    // return circular_buffer_read(&self->circular_buffer, output, to_read);
    return 0;
}
