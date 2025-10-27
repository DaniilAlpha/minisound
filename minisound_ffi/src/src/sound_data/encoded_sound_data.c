#include "../../include/sound_data/encoded_sound_data.h"

#include <stdlib.h>

#include "../../include/sound_data/silence_data_source.h"
#include "conviniences.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

/*************
 ** private **
 *************/

struct EncodedSoundData {
    // it would be great to supply custom streaming data source that will take a
    // dart callback
    ma_decoder decoder;

    bool is_looped;
    // TODO? maybe temporary, but who really knows
    bool is_using_loop_delay;
    SilenceDataSource loop_delay_ds;
};

static ma_data_source *encoded_sound_data_get_ds(EncodedSoundData *const self) {
    return &self->decoder;
}

/************
 ** public **
 ************/

EncodedSoundData *encoded_sound_data_alloc(void) {
    return malloc0(sizeof(EncodedSoundData));
}
Result encoded_sound_data_init(
    EncodedSoundData *const self,
    uint8_t const *const data,
    size_t const data_size
) {
    self->is_looped = false;
    self->is_using_loop_delay = false;

    ma_result const r =
        ma_decoder_init_memory(data, data_size, NULL, &self->decoder);

    if (r != MA_SUCCESS)
        return error(
                   "miniaudio decoder initialization error! Error code: %d",
                   r
               ),
               UnknownErr;

    return info(
               "encoded sound data initialized (format : %i, channel count : %u, sample rate : %u)",
               self->decoder.outputFormat,
               self->decoder.outputChannels,
               self->decoder.outputSampleRate
           ),
           Ok;
}
void encoded_sound_data_uninit(EncodedSoundData *const self) {
    ma_decoder_uninit(&self->decoder);
}

bool encoded_sound_data_get_is_looped(EncodedSoundData const *const self) {
    return self->is_looped;
}
void encoded_sound_data_set_looped(
    EncodedSoundData *const self,
    bool const value,
    size_t const delay_ms
) {
    // ma_data_source_set_current(&self->decoder, &self->decoder);
    ma_data_source_set_looping(&self->decoder, false);
    ma_data_source_set_next(&self->decoder, NULL);

    if (value) {
        if (delay_ms == 0) {
            ma_data_source_set_looping(&self->decoder, true);
        } else {
            if (self->is_using_loop_delay)
                silence_data_source_uninit(&self->loop_delay_ds);

            SilenceDataSourceConfig const config = silence_data_source_config(
                self->decoder.outputFormat,
                self->decoder.outputSampleRate,
                self->decoder.outputChannels,
                (delay_ms * self->decoder.outputSampleRate) / 1000
            );
            silence_data_source_init(&self->loop_delay_ds, &config);

            self->is_using_loop_delay = true;

            ma_data_source_set_next(&self->decoder, &self->loop_delay_ds);
            ma_data_source_set_next(&self->loop_delay_ds, &self->decoder);
        }
    }

    info(
        "encoded sound data looping set : %s (%zu ms delay)",
        value ? "true" : "false",
        delay_ms
    );
}

SoundData
encoded_sound_data_ww_sound_data(EncodedSoundData *const self) WRAP_BODY(
    SoundData,
    SOUND_DATA_INTERFACE(EncodedSoundData),
    {
        .type = SOUND_DATA_TYPE_ENCODED,

        .get_ds = encoded_sound_data_get_ds,
        .uninit = encoded_sound_data_uninit,
    }
);
