#include "../../include/recorder/recorder.h"

#include <stdlib.h>

#include <assert.h>
#include <miniaudio.h>

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

    Recording *rec;

    RecorderState state;
};

static void data_callback(
    ma_device *const device,
    void *const _,
    void const *const data,
    uint32_t const data_len_pcm
) {
    Recorder *const self = device->pUserData;

    recording_write(self->rec, data, data_len_pcm);
}

/************
 ** public **
 ************/

Recorder *recorder_alloc(void) { return malloc0(sizeof(Recorder)); }
Result recorder_init(Recorder *const self) {
    if (self->state != RECORDER_UNINITIALIZED) return Ok;

    ma_result r;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.dataCallback = data_callback;
    device_config.pUserData = self;
    if ((r = ma_device_init(NULL, &device_config, &self->device)) != MA_SUCCESS)
        return error("minisudio device initialization error (code: %i)!", r),
               UnknownErr;

    self->rec = NULL;

    self->state = RECORDER_INITIALIZED;
    return info("recorder initialized."), Ok;
}
void recorder_uninit(Recorder *const self) {
    if (self->state == RECORDER_UNINITIALIZED) return;

    ma_device_uninit(&self->device);
    if (self->rec) recording_uninit(self->rec), free(self->rec);
    self->state = RECORDER_UNINITIALIZED;
}

bool recorder_get_is_recording(Recorder const *self) {
    if (self->state == RECORDER_UNINITIALIZED) return false;
    return self->rec;
}

Result recorder_start(
    Recorder *const self,
    RecordingEncoding const encoding,
    RecordingFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate
) {
    ma_result r;

    if (self->state == RECORDER_UNINITIALIZED) return StateErr;
    if (self->rec) return Ok;

    self->rec = recording_alloc();
    if (!self->rec) return OutOfMemErr;

    UNROLL_CLEANUP(
        recording_init(self->rec, encoding, format, channel_count, sample_rate),
        { free(self->rec); }
    );

    if ((r = ma_device_start(&self->device)) != MA_SUCCESS)
        return recording_uninit(self->rec), free(self->rec),
               error("miniaudio device starting error (code: %i)!", r),
               UnknownErr;

    return info("recorder started."), Ok;
}
Recording *recorder_stop(Recorder *const self) {
    if (self->state == RECORDER_UNINITIALIZED) return NULL;
    if (!self->rec) return NULL;

    ma_device_stop(&self->device);

    if (recording_fit(self->rec) != Ok)
        warn("fitting a recording failed, but this is fine.");
    return info("recorder stopped."), self->rec;
}
