#include "../include/record.h"

#include "../external/milo/milo.h"
#include "../external/miniaudio/include/miniaudio.h"

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

    void *user_data;
};

static void data_callback(
    ma_device *pDevice,
    void *pOutput,
    void const *pInput,
    ma_uint32 frameCount
) {
    Recorder *recorder = (Recorder *)pDevice->pUserData;

    size_t floatsToWrite = frameCount * recorder->channels;

    // Write raw PCM data directly to the circular buffer
    circular_buffer_write(
        &recorder->circular_buffer,
        (float const *)pInput,
        floatsToWrite
    );

    if (recorder->is_file_recording) {
        ma_encoder_write_pcm_frames(
            &recorder->encoder,
            pInput,
            frameCount,
            NULL
        );
    }

    (void)pOutput;
}

Recorder *recorder_create(void) {
    Recorder *recorder = (Recorder *)malloc(sizeof(Recorder));
    if (recorder == NULL) { return NULL; }
    memset(recorder, 0, sizeof(Recorder));
    return recorder;
}

void recorder_destroy(Recorder *recorder) {
    if (recorder != NULL) {
        ma_device_uninit(&recorder->device);
        if (recorder->is_file_recording) {
            ma_encoder_uninit(&recorder->encoder);
            free(recorder->filename);
        }
        circular_buffer_uninit(&recorder->circular_buffer);
        free(recorder);
    }
}

static RecorderResult recorder_init_common(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format,
    int const buffer_duration_seconds
) {
    ma_format const format = (ma_format)sound_format;

    if (self == NULL) { return RECORDER_ERROR_INVALID_ARGUMENT; }

    self->is_file_recording = (filename != NULL);
    self->sample_rate = sample_rate;
    self->channels = channels;
    self->format = format;

    size_t buffer_size_in_bytes =
        (size_t)(sample_rate * channels * ma_get_bytes_per_sample(format) *
                 buffer_duration_seconds);
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
    self->user_data = NULL;

    return RECORDER_OK;
}

RecorderResult recorder_init_file(
    Recorder *const self,
    char const *const filename,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format
) {
    if (filename == NULL) { return RECORDER_ERROR_INVALID_ARGUMENT; }
    return recorder_init_common(
        self,
        filename,
        sample_rate,
        channels,
        sound_format,
        5.0f
    );  // 5 seconds buffer
}

RecorderResult recorder_init_stream(
    Recorder *const self,
    uint32_t const sample_rate,
    uint32_t const channels,
    SoundFormat const sound_format,
    int const buffer_duration_seconds
) {
    return recorder_init_common(
        self,
        NULL,
        sample_rate,
        channels,
        sound_format,
        buffer_duration_seconds
    );
}

RecorderResult recorder_start(Recorder *recorder) {
    if (recorder == NULL) { return RECORDER_ERROR_INVALID_ARGUMENT; }
    if (recorder->is_recording) { return RECORDER_ERROR_ALREADY_RECORDING; }

    if (ma_device_start(&recorder->device) != MA_SUCCESS) {
        return RECORDER_ERROR_UNKNOWN;
    }
    recorder->is_recording = true;
    return RECORDER_OK;
}

RecorderResult recorder_stop(Recorder *recorder) {
    if (recorder == NULL) { return RECORDER_ERROR_INVALID_ARGUMENT; }
    if (!recorder->is_recording) { return RECORDER_ERROR_NOT_RECORDING; }

    ma_device_stop(&recorder->device);
    recorder->is_recording = false;
    return RECORDER_OK;
}

bool recorder_is_recording(Recorder const *recorder) {
    return recorder != NULL && recorder->is_recording;
}

int recorder_get_buffer(
    Recorder *const self,
    float *const output,
    size_t const floats_to_read
) {
    if (self == NULL || output == NULL || floats_to_read <= 0) { return 0; }

    size_t const available_floats =
        circular_buffer_get_available_floats(&self->circular_buffer);
    size_t const to_read =
        (floats_to_read < available_floats) ? floats_to_read : available_floats;

    return (int)circular_buffer_read(&self->circular_buffer, output, to_read);
}

size_t recorder_get_available_frames(Recorder *const self) {
    if (self == NULL) return RECORDER_ERROR_INVALID_ARGUMENT;

    // Check if channels is zero to prevent division by zero
    if (self->channels == 0) self->channels = 1;

    size_t const available_floats =
        circular_buffer_get_available_floats(&self->circular_buffer);
    if (available_floats == 0) return RECORDER_ERROR_UNKNOWN;
    return available_floats / self->channels;
}
