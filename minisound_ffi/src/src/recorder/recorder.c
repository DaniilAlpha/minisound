#include "../../include/recorder/recorder.h"

#include <stdlib.h>
#include <string.h>

#include <assert.h>
#include <miniaudio.h>

#include "../../include/recorder/rec.h"
#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include "../../external/milo/milo.h"

#define RECORDING_BUF_COUNT (3)

/*************
 ** private **
 *************/

typedef enum RecorderState {
    RECORDER_STATE_UNINITIALIZED = 0,
    RECORDER_STATE_INITIALIZED,
    RECORDER_STATE_STARTED,
} RecorderState;

struct Recorder {
    ma_device device;

    RecorderState state;

    size_t recs_len;
    Rec *recs[];
};

static void on_data(
    ma_device *const device,
    void *const _,
    void const *const data,
    uint32_t const data_len_frames
) {
    (void)_;

    Recorder *const self = device->pUserData;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (*rec_ptr) rec_write_raw(*rec_ptr, data, data_len_frames);
}

/************
 ** public **
 ************/

Recorder *recorder_alloc(size_t const max_rec_count) {
    Recorder *const self =
        malloc0(sizeof(*self) + max_rec_count * elsizeof(self->recs));
    self->recs_len = max_rec_count;
    return self;
}
Result recorder_init(Recorder *const self) {
    if (self->state != RECORDER_STATE_UNINITIALIZED) return Ok;

    ma_result r;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.capture.format = ma_format_s16;
    device_config.capture.channels = 2;
    device_config.sampleRate = 44100;
    device_config.dataCallback = on_data;
    device_config.pUserData = self;

    if ((r = ma_device_init(NULL, &device_config, &self->device)) != MA_SUCCESS)
        return error("minisudio device initialization error (code: %i)!", r),
               UnknownErr;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        *rec_ptr = NULL;

    self->state = RECORDER_STATE_INITIALIZED;
    return info("recorder initialized."), Ok;
}
void recorder_uninit(Recorder *const self) {
    if (self->state == RECORDER_STATE_UNINITIALIZED) return;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (*rec_ptr) rec_end(*rec_ptr), *rec_ptr = NULL;

    ma_device_uninit(&self->device);

    self->state = RECORDER_STATE_UNINITIALIZED;
}

Result recorder_start(Recorder *const self) {
    ma_result r;

    if (self->state == RECORDER_STATE_UNINITIALIZED) return StateErr;
    if (self->state == RECORDER_STATE_STARTED) return Ok;

    if ((r = ma_device_start(&self->device)) != MA_SUCCESS)
        return error("miniaudio recorder device starting error (code: %i)!", r),
               UnknownErr;

    self->state = RECORDER_STATE_STARTED;
    return info("recorder started."), Ok;
}

Result recorder_record(
    Recorder *const self,
    RecEncoding const encoding,
    RecFormat const format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    size_t const data_availability_threshold_ms,
    RecOnDataFn *const on_data_available,
    RecSeekDataFn *const seek_data,

    Rec **const out
) {
    if (self->state == RECORDER_STATE_UNINITIALIZED ||
        self->state == RECORDER_STATE_INITIALIZED)
        return StateErr;

    Rec **avail_rec_ptr = NULL;
    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (!*rec_ptr) {
            avail_rec_ptr = rec_ptr;
            break;
        }
    if (!avail_rec_ptr) return RangeErr;

    Rec *const rec = rec_alloc();
    if (!rec) return OutOfMemErr;

    size_t const buf_size_ms = self->device.capture.internalPeriodSizeInFrames *
                               1000 / self->device.capture.internalSampleRate;
    size_t const data_availability_threshold_bufs =
        data_availability_threshold_ms < buf_size_ms
            ? 1
            : data_availability_threshold_ms / buf_size_ms;

    size_t const data_availability_threshold_frames =
        self->device.capture.internalPeriodSizeInFrames *
        data_availability_threshold_bufs;
    trace(
        "determined recording threshold = %zu frames",
        data_availability_threshold_frames
    );
    UNROLL_CLEANUP(
        rec_init(
            rec,
            encoding,
            format,
            channel_count,
            sample_rate,

            data_availability_threshold_frames * RECORDING_BUF_COUNT,
            data_availability_threshold_frames,
            on_data_available,
            seek_data
        ),
        { free(rec); }
    );

    *avail_rec_ptr = rec;
    return info("recorder recording."), *out = rec, Ok;
}
Result recorder_pause_recording(Recorder *const self, Rec const *const rec) {
    if (self->state == RECORDER_STATE_UNINITIALIZED ||
        self->state == RECORDER_STATE_INITIALIZED)
        return StateErr;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (*rec_ptr == rec) {
            *rec_ptr = NULL;
            break;
        }

    return info("recording paused."), Ok;
}
Result recorder_resume_recording(Recorder *const self, Rec *const rec) {
    if (self->state == RECORDER_STATE_UNINITIALIZED ||
        self->state == RECORDER_STATE_INITIALIZED)
        return StateErr;

    Rec **avail_rec_ptr = NULL;
    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (!*rec_ptr) {
            avail_rec_ptr = rec_ptr;
            break;
        }
    if (!avail_rec_ptr) return RangeErr;

    *avail_rec_ptr = rec;
    return info("recording resumed."), Ok;
}
Result recorder_stop_recording(Recorder *const self, Rec const *const rec) {
    if (self->state == RECORDER_STATE_UNINITIALIZED ||
        self->state == RECORDER_STATE_INITIALIZED)
        return StateErr;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (*rec_ptr == rec) {
            rec_end(*rec_ptr), *rec_ptr = NULL;
            break;
        }

    return info("recording stopped."), Ok;
}
