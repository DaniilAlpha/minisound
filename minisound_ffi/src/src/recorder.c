#include "../include/recorder.h"

#include <stdlib.h>
#include <string.h>

#include "../external/miniaudio/include/miniaudio.h"
#include "../include/recording.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"

/*************
 ** private **
 *************/

// recorder

struct Recorder {
    bool is_recording;

    ma_device device;

    Recording *recording;
};

ma_result encoder_on_write(
    ma_encoder *const encoder,
    void const *const data,
    size_t const data_size,
    size_t *const out_written_data_size
) {
    Recorder *const self = encoder->pUserData;

    if (recording_write(self->recording, data, data_size) != Ok)
        return MA_ERROR;

    return *out_written_data_size = data_size, MA_SUCCESS;
}

ma_result encoder_on_seek(
    ma_encoder *const encoder,
    long long const off_from_origin,
    ma_seek_origin const origin
) {
    Recorder *const self = encoder->pUserData;

    size_t off = 0;
    switch (origin) {
    case ma_seek_origin_start: off = off_from_origin; break;
    case ma_seek_origin_current:
        off = recording_get_off(self->recording) + off_from_origin;
        break;
    case ma_seek_origin_end:
        off = recording_get_size(self->recording) - 1 - off_from_origin;
        break;
    }

    recording_set_off(self->recording, off);

    return recording_get_off(self->recording) == off ? MA_SUCCESS : MA_ERROR;
}

static void data_callback(
    ma_device *const device,
    void *const _,
    void const *const data,
    uint32_t const data_size
) {
    (void)_;

    Recorder *const self = device->pUserData;

    ma_encoder_write_pcm_frames(
        // TODO! bad
        (ma_encoder *)self->recording,
        data,
        data_size,
        NULL
    );
}

/************
 ** public **
 ************/

Recorder *recorder_alloc() { return malloc(sizeof(Recorder)); }
Result recorder_init(
    Recorder *const self,
    RecorderEncoding const encoding,
    RecorderFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    self->is_recording = false;
    info("%u", sample_rate);

    self->recording = recording_alloc();
    if (self->recording == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(recording_init(self->recording), { free(self->recording); });

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.capture.format = (ma_format)format;
    device_config.capture.channels = channel_count;
    device_config.sampleRate = sample_rate;
    device_config.dataCallback = data_callback;
    device_config.pUserData = self;
    ma_result r = ma_device_init(NULL, &device_config, &self->device);
    if (r != MA_SUCCESS) {
        recording_uninit(self->recording), free(self->recording);
        return error(
                   "minisudio device initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    ma_encoder_config const config = ma_encoder_config_init(
        (ma_encoding_format)encoding,
        self->device.capture.format,
        self->device.capture.channels,
        self->device.sampleRate
    );
    r = ma_encoder_init(
        encoder_on_write,
        encoder_on_seek,
        self,
        &config,
        (ma_encoder *)self->recording
    );
    if (r != MA_SUCCESS) {
        recording_uninit(self->recording), free(self->recording);
        ma_device_uninit(&self->device);
        return error(
                   "miniaudio encoder initialization error! Error code: %d",
                   r
               ),
               UnknownErr;
    }

    return Ok;
}
void recorder_uninit(Recorder *const self) {
    ma_encoder_uninit((ma_encoder *)self->recording);
    ma_device_uninit(&self->device);
    recording_uninit(self->recording), free(self->recording);
}

bool recorder_get_is_recording(Recorder const *self) {
    return self->is_recording;
}

Result recorder_start(Recorder *const self) {
    if (self->is_recording) return Ok;

    if (ma_device_start(&self->device) != MA_SUCCESS)
        return error("miniaudio device starting error!"), UnknownErr;

    self->is_recording = true;

    return Ok;
}
Recording *recorder_stop(Recorder *const self) {
    self->is_recording = false;

    ma_device_stop(&self->device);

    Recording *const recording = self->recording;
    // TODO! very bad
    ma_encoder_uninit((ma_encoder *)recording);

    self->recording = recording_alloc();
    recording_init(self->recording);

    ma_encoder_config const config = ma_encoder_config_init(
        ma_encoding_format_wav,
        self->device.capture.format,
        self->device.capture.channels,
        self->device.sampleRate
    );
    ma_result const r = ma_encoder_init(
        encoder_on_write,
        encoder_on_seek,
        self,
        &config,
        (ma_encoder *)self->recording
    );
    if (r != MA_SUCCESS) {
        recording_uninit(self->recording), free(self->recording);
        error("miniaudio encoder initialization error! Error code: %d", r);
    }

    return recording_fit(recording), recording;
}

// clang-format off

// this ensures safe casting between `RecorderEncoding` and `ma_encoder_format`
_Static_assert((int)RECORDER_ENCODING_WAV == (int)ma_encoding_format_wav, "`RECORDER_ENCODING_WAV` should match `ma_encoding_format_wav`.");
_Static_assert((int)RECORDER_ENCODING_FLAC == (int)ma_encoding_format_flac, "`RECORDER_ENCODING_FLAC` should match `ma_encoding_format_flac`.");
_Static_assert((int)RECORDER_ENCODING_MP3 == (int)ma_encoding_format_mp3, "`RECORDER_ENCODING_MP3` should match `ma_encoding_format_mp3`.");

// this ensures safe casting between `RecorderFormat` and `ma_format`
_Static_assert((int)RECORDER_FORMAT_U8 == (int)ma_format_u8, "`RECORDER_FORMAT_U8` should match `ma_format_u8`.");
_Static_assert((int)RECORDER_FORMAT_S16 == (int)ma_format_s16, "`RECORDER_FORMAT_S16` should match `ma_format_s16`.");
_Static_assert((int)RECORDER_FORMAT_S24 == (int)ma_format_s24, "`RECORDER_FORMAT_S24` should match `ma_format_s24`.");
_Static_assert((int)RECORDER_FORMAT_S32 == (int)ma_format_s32, "`RECORDER_FORMAT_S32` should match `ma_format_s32`.");
_Static_assert((int)RECORDER_FORMAT_F32 == (int)ma_format_f32, "`RECORDER_FORMAT_F32` should match `ma_format_f32`.");

// clang-format on
