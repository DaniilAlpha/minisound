#include "../include/recorder.h"

#include "../external/miniaudio/include/miniaudio.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"

struct Recorder {
    ma_encoder encoder;
    ma_encoder_config encoder_config;
    ma_device device;
    ma_device_config device_config;
    char *filename;
    bool is_recording;
    bool is_file_recording;

    CircularBuffer circular_buffer;

    int sample_rate;
    int channels;
    ma_format format;

    uint8_t *encode_buffer;
    size_t encode_buffer_size;
    size_t encode_buffer_used;
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
    Recorder *const self = pDevice->pUserData;

    size_t const floatsToWrite = frameCount * self->channels;

    // Write raw PCM data directly to the circular buffer
    circular_buffer_write(
        &self->circular_buffer,
        (float const *)pInput,
        floatsToWrite
    );

    if (self->is_file_recording)
        ma_encoder_write_pcm_frames(&self->encoder, pInput, frameCount, NULL);

    (void)pOutput;
}

static RecorderResult recorder_init_common(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format,
    float const buffer_len_s
) {
    ma_format const format = (ma_format)sound_format;

    self->is_file_recording = (filename != NULL);
    self->sample_rate = sample_rate;
    self->channels = channels;
    self->format = format;

    size_t const buffer_size_in_bytes =
        (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) *
                 buffer_len_s);
    circular_buffer_init(&self->circular_buffer, buffer_size_in_bytes);

    if (self->is_file_recording) {
        self->filename = strdup(filename);
        if (self->filename == NULL) {
            circular_buffer_uninit(&self->circular_buffer);
            return RECORDER_ERROR_OUT_OF_MEMORY;
        }

        self->encoder_config = ma_encoder_config_init(
            ma_encoding_format_wav,
            format,
            channels,
            sample_rate
        );

        if (ma_encoder_init_file(
                self->filename,
                &self->encoder_config,
                &self->encoder
            ) != MA_SUCCESS) {
            free(self->filename);
            circular_buffer_uninit(&self->circular_buffer);
            return RECORDER_ERROR_UNKNOWN;
        }
    }

    self->device_config = ma_device_config_init(ma_device_type_capture);
    self->device_config.capture.format = format;
    self->device_config.capture.channels = channels;
    self->device_config.sampleRate = sample_rate;
    self->device_config.dataCallback = data_callback;
    self->device_config.pUserData = self;

    if (ma_device_init(NULL, &self->device_config, &self->device) !=
        MA_SUCCESS) {
        if (self->is_file_recording) {
            ma_encoder_uninit(&self->encoder);
            free(self->filename);
        }
        circular_buffer_uninit(&self->circular_buffer);
        return RECORDER_ERROR_UNKNOWN;
    }

    self->is_recording = false;

    return RECORDER_OK;
}

/************
 ** public **
 ************/

Recorder *recorder_create(void) {
    Recorder *const recorder = (Recorder *)malloc(sizeof(Recorder));
    if (recorder == NULL) { return NULL; }
    memset(recorder, 0, sizeof(Recorder));
    return recorder;
}

RecorderResult recorder_init_file(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format
) {
    if (filename == NULL) return RECORDER_ERROR_INVALID_ARGUMENT;
    return recorder_init_common(
        self,
        filename,
        sample_rate,
        channels,
        sound_format,
        5.0f
    );
}

RecorderResult recorder_init_stream(
    Recorder *const self,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format,
    float const buffer_len_s
) {
    return recorder_init_common(
        self,
        NULL,
        sample_rate,
        channels,
        sound_format,
        buffer_len_s
    );
}
void recorder_uninit(Recorder *const self) {
    ma_device_uninit(&self->device);
    if (self->is_file_recording) {
        ma_encoder_uninit(&self->encoder);
        free(self->filename);
    }
    circular_buffer_uninit(&self->circular_buffer);
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
    return circular_buffer_get_available_floats(&self->circular_buffer);
}
size_t recorder_load_buffer(
    Recorder *const self,
    float *const output,
    size_t const floats_to_read
) {
    if (self == NULL || output == NULL || floats_to_read <= 0) { return 0; }

    size_t const available_floats = recorder_get_available_float_count(self);
    size_t const to_read =
        (floats_to_read < available_floats) ? floats_to_read : available_floats;

    return circular_buffer_read(&self->circular_buffer, output, to_read);
}
