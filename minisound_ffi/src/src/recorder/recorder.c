#include "../../include/recorder/recorder.h"

#include <stdlib.h>

#include <assert.h>
#include <miniaudio.h>

#include "../../include/recorder/recorder_buffer.h"
#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../external/milo/milo.h"

/*************
 ** private **
 *************/

typedef enum RecorderState {
    RECORDER_UNINITIALIZED = 0,
    RECORDER_INITIALIZED,
} RecorderState;

struct Recorder {
    ma_device device;

    RecorderBuffer *rec_buf;

    RecorderState state;
};

static void data_callback(
    ma_device *const device,
    void *const _,
    void const *const data,
    uint32_t const data_len_pcm
) {
    (void)_;
    Recorder *const self = device->pUserData;

    recorder_buffer_write(self->rec_buf, data, data_len_pcm);
}

/************
 ** public **
 ************/

Recorder *recorder_alloc(void) { return malloc0(sizeof(Recorder)); }
Result recorder_init(
    Recorder *const self,
    RecorderFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    if (self->state != RECORDER_UNINITIALIZED) return Ok;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.capture.format = (ma_format)format;
    device_config.capture.channels = channel_count;
    device_config.sampleRate = sample_rate;
    device_config.dataCallback = data_callback;
    device_config.pUserData = self;
    ma_result const r = ma_device_init(NULL, &device_config, &self->device);
    if (r != MA_SUCCESS)
        return error(
                   "minisudio device initialization error! Error code: %d",
                   r
               ),
               UnknownErr;

    self->rec_buf = NULL;

    self->state = RECORDER_INITIALIZED;
    return info("recorder initialized"), Ok;
}
void recorder_uninit(Recorder *const self) {
    if (self->state == RECORDER_UNINITIALIZED) return;

    ma_device_uninit(&self->device);
    if (self->rec_buf != NULL)
        recorder_buffer_uninit(self->rec_buf), free(self->rec_buf);
    self->state = RECORDER_UNINITIALIZED;
}

bool recorder_get_is_recording(Recorder const *self) {
    if (self->state == RECORDER_UNINITIALIZED) return false;
    return self->rec_buf != NULL;
}

Result recorder_start(Recorder *const self, RecordingEncoding const encoding) {
    if (self->state == RECORDER_UNINITIALIZED) return StateErr;
    if (self->rec_buf != NULL) return Ok;

    self->rec_buf = recorder_buffer_alloc();
    if (self->rec_buf == NULL) return OutOfMemErr;

    UNROLL_CLEANUP(
        recorder_buffer_init(self->rec_buf, encoding, &self->device),
        { free(self->rec_buf); }
    );

    if (ma_device_start(&self->device) != MA_SUCCESS) {
        recorder_buffer_uninit(self->rec_buf), free(self->rec_buf);
        return error("miniaudio device starting error!"), UnknownErr;
    }

    return info("recorder started"), Ok;
}
Recording recorder_stop(Recorder *const self) {
    static Recording const empty = {.buf = NULL, .size = 0};
    if (self->state == RECORDER_UNINITIALIZED) return empty;
    if (self->rec_buf == NULL) return empty;

    ma_device_stop(&self->device);

    Recording const flush = recorder_buffer_consume(self->rec_buf);
    free(self->rec_buf), self->rec_buf = NULL;

    return info("recorder stopped"), flush;
}

// clang-format off

// this ensures safe casting between `RecorderEncoding` and `ma_encoder_format`
static_assert((int)RECORDING_ENCODING_WAV == (int)ma_encoding_format_wav, "`RECORDING_ENCODING_WAV` should match `ma_encoding_format_wav`.");
// static_assert((int)RECORDING_ENCODING_FLAC == (int)ma_encoding_format_flac, "`RECORDING_ENCODING_FLAC` should match `ma_encoding_format_flac`.");
// static_assert((int)RECORDING_ENCODING_MP3 == (int)ma_encoding_format_mp3, "`RECORDING_ENCODING_MP3` should match `ma_encoding_format_mp3`.");

// this ensures safe casting between `RecorderFormat` and `ma_format`
static_assert((int)RECORDER_FORMAT_U8 == (int)ma_format_u8, "`RECORDER_FORMAT_U8` should match `ma_format_u8`.");
static_assert((int)RECORDER_FORMAT_S16 == (int)ma_format_s16, "`RECORDER_FORMAT_S16` should match `ma_format_s16`.");
static_assert((int)RECORDER_FORMAT_S24 == (int)ma_format_s24, "`RECORDER_FORMAT_S24` should match `ma_format_s24`.");
static_assert((int)RECORDER_FORMAT_S32 == (int)ma_format_s32, "`RECORDER_FORMAT_S32` should match `ma_format_s32`.");
static_assert((int)RECORDER_FORMAT_F32 == (int)ma_format_f32, "`RECORDER_FORMAT_F32` should match `ma_format_f32`.");

// clang-format on
