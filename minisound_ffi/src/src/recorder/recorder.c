#include "recorder/recorder.h"

#include <stdlib.h>
#include <string.h>

#include <assert.h>
#include <miniaudio.h>

#include "conviniences.h"
#include "recorder/rec.h"
#include "recorder/rec_sink/encoded_rec_sink.h"

#define MILO_LVL RECORDER_MILO_LVL
#include <milo.h>

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

static void device_on_data(
    ma_device *const device,
    void *const _,
    void const *const data,
    uint32_t const data_len_frames
) {
    (void)_;

    Recorder *const self = device->pUserData;

    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++) {
        if (!*rec_ptr) continue;

        if (rec_write_raw(*rec_ptr, data, data_len_frames) == StateErr)
            *rec_ptr = NULL;
    }
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
Result recorder_init(Recorder *const self, uint32_t const period_ms) {
    if (self->state != RECORDER_STATE_UNINITIALIZED) return Ok;

    ma_result r;

    ma_device_config device_config =
        ma_device_config_init(ma_device_type_capture);
    device_config.periodSizeInMilliseconds = period_ms;
    device_config.dataCallback = device_on_data;
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

bool recorder_get_is_recording(
    Recorder const *const self,
    Rec const *const rec
) {
    for (Rec *const *rec_ptr = self->recs;
         rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (*rec_ptr == rec) return true;

    return false;
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

Result recorder_save_rec(
    Recorder *const self,
    Rec *const rec,
    AudioEncoding const encoding,
    SampleFormat const sample_format,
    uint32_t const channel_count,
    uint32_t const sample_rate,

    uint8_t **const data_ptr,
    size_t *const data_size_ptr
) {
    if (self->state == RECORDER_STATE_UNINITIALIZED) return StateErr;

    Rec **avail_rec_ptr = NULL;
    for (Rec **rec_ptr = self->recs; rec_ptr < self->recs + self->recs_len;
         rec_ptr++)
        if (!*rec_ptr) {
            avail_rec_ptr = rec_ptr;
            break;
        }
    if (!avail_rec_ptr) return RangeErr;

    EncodedRecSink *const encoded = encoded_rec_sink_alloc();
    if (!encoded) return OutOfMemErr;

    UNROLL_CLEANUP(
        encoded_rec_sink_init(
            encoded,
            encoding,
            sample_format ? sample_format
                          : (SampleFormat)self->device.capture.format,
            channel_count ? channel_count : self->device.capture.channels,
            sample_rate ? sample_rate : self->device.sampleRate,

            data_ptr,
            data_size_ptr
        ),
        { free(encoded); }
    );
    UNROLL_CLEANUP(
        rec_init(
            rec,
            encoded_rec_sink_ww_rec_sink(encoded),
            &self->device

        ),
        { encoded_rec_sink_uninit(encoded), free(rec); }
    );

    *avail_rec_ptr = rec;
    return info("recorder recording."), Ok;
}
Result recorder_resume_rec(Recorder *const self, Rec *const rec) {
    if (self->state == RECORDER_STATE_UNINITIALIZED ||
        self->state == RECORDER_STATE_INITIALIZED)
        return StateErr;

    if (recorder_get_is_recording(self, rec)) return Ok;

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
Result recorder_pause_rec(Recorder *const self, Rec const *const rec) {
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
