#include "recorder/rec.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <miniaudio.h>

#include "conviniences.h"

#define MILO_LVL RECORDER_MILO_LVL
#include <milo.h>

#define RECORDING_RB_ITER_LIMIT (16)

/*************
 ** private **
 *************/

typedef enum RecState {
    REC_STATE_UNINITIALIZED = 0,
    REC_STATE_INITIALIZED,
    REC_STATE_ENDED,
} RecState;

struct Rec {
    ma_data_converter conv;
    uint8_t *conv_buf;
    size_t conv_buf_len_frames;

    RecSink rec_sink;

    RecState state;
};

/************
 ** public **
 ************/

Rec *rec_alloc(void) { return malloc0(sizeof(Rec)); }
Result
rec_init(Rec *const self, RecSink const rec_sink, ma_device *const device) {
    if (self->state != REC_STATE_UNINITIALIZED) return Ok;

    ma_result r;

    ma_encoder const *const encoder = rec_sink_get_enc(&rec_sink);
    ma_data_converter_config const conv_config = ma_data_converter_config_init(
        device->capture.format,
        encoder->config.format,
        device->capture.channels,
        encoder->config.channels,
        device->sampleRate,
        encoder->config.sampleRate
    );
    if ((r = ma_data_converter_init(&conv_config, NULL, &self->conv)) !=
        MA_SUCCESS)
        return error(
                   "miniaudio data converter initialization error (code: %i)!",
                   r
               ),
               UnknownErr;

    self->rec_sink = rec_sink;

    self->state = REC_STATE_INITIALIZED;
    return info("recording initialized."), Ok;
}
void rec_uninit(Rec *const self) {
    if (self->state == REC_STATE_UNINITIALIZED) return;

    if (self->state != REC_STATE_ENDED) rec_end(self);

    if (self->conv_buf)
        free(self->conv_buf), self->conv_buf = NULL,
                              self->conv_buf_len_frames = 0;
    ma_data_converter_uninit(&self->conv, NULL);

    self->state = REC_STATE_UNINITIALIZED;
}

Result rec_write_raw(
    Rec *const self,
    uint8_t const *const data,
    size_t const data_len_frames
) {
    if (self->state == REC_STATE_UNINITIALIZED ||
        self->state == REC_STATE_ENDED)
        return StateErr;

    ma_result r;

    ma_uint64 required_conv_buf_len_frames = 0;
    if ((r = ma_data_converter_get_expected_output_frame_count(
             &self->conv,
             data_len_frames,
             &required_conv_buf_len_frames
         )) != MA_SUCCESS)
        return error(
                   "miniaudio data conversion size estimate error (code: %i)!",
                   r
               ),
               UnknownErr;

    if (self->conv_buf_len_frames < required_conv_buf_len_frames) {
        ma_encoder const *const encoder = rec_sink_get_enc(&self->rec_sink);

        if (self->conv_buf) free(self->conv_buf);
        self->conv_buf = malloc(
            required_conv_buf_len_frames * ma_get_bytes_per_frame(
                                               encoder->config.format,
                                               encoder->config.channels
                                           )
        );
        if (!self->conv_buf) return OutOfMemErr;

        self->conv_buf_len_frames = required_conv_buf_len_frames;
    }

    ma_uint64 conv_data_len_frames = data_len_frames,
              res_conv_data_len_frames = self->conv_buf_len_frames;
    if ((r = ma_data_converter_process_pcm_frames(
             &self->conv,
             data,
             &conv_data_len_frames,
             self->conv_buf,
             &res_conv_data_len_frames
         )) != MA_SUCCESS)
        return error("miniaudio data conversion error (code: %i)!", r),
               UnknownErr;

    if ((r = ma_encoder_write_pcm_frames(
             rec_sink_get_enc(&self->rec_sink),
             self->conv_buf,
             res_conv_data_len_frames,
             NULL
         )) != MA_SUCCESS)
        return error("miniaudio encoder writing error (code: %i)!", r),
               UnknownErr;

    return Ok;
}
Result rec_end(Rec *const self) {
    if (self->state == REC_STATE_UNINITIALIZED) return StateErr;
    if (self->state == REC_STATE_ENDED) return Ok;

    // ends the encoder internally
    rec_sink_uninit(&self->rec_sink), free(self->rec_sink._self);

    self->state = REC_STATE_ENDED;
    return Ok;
}
