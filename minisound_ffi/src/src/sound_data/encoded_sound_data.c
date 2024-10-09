#include "../../include/sound_data/encoded_sound_data.h"

#include <stdlib.h>

#include "../../include/silence_data_source.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

struct EncodedSoundData {
    ma_decoder decoder;

    bool is_looped;
    SilenceDataSource loop_delay_ds;
};

EncodedSoundData *encoded_sound_data_alloc() {
    return malloc(sizeof(EncodedSoundData));
}
Result encoded_sound_data_init(
    EncodedSoundData *const self,
    float const *const data,
    size_t const data_size
) {
    self->is_looped = false;

    ma_result const r =
        ma_decoder_init_memory(data, data_size, NULL, &self->decoder);
    if (r != MA_SUCCESS) {
        return error(
                   "miniaudio decoder initialization error! Error code: %d",
                   result
               ),
               UnknownErr;
    }

    return Ok;
}
void encoded_sound_data_uninit(EncodedSoundData *const self) {
    ma_decoder_uninit(&self->decoder);
}

ma_data_source *encoded_sound_data_get_ds(EncodedSoundData *const self) {
    return (ma_data_source *)&self->decoder;
}

bool encoded_sound_data_get_is_looped(EncodedSoundData const *const self) {
    return self->is_looped;
}
void encoded_sound_data_set_looped(
    EncodedSoundData *const self,
    bool const value,
    size_t const delay_ms
) {
    if (value) {
        if (delay_ms == 0) {
            ma_data_source_set_looping(&self->decoder, true);
        } else {
            SilenceDataSourceConfig const config = silence_data_source_config(
                self->decoder.outputFormat,
                self->decoder.outputChannels,
                self->decoder.outputSampleRate,
                (delay_ms * self->decoder.outputSampleRate) / 1000
            );
            silence_data_source_init(&self->loop_delay_ds, &config);

            ma_data_source_set_next(&self->decoder, &self->loop_delay_ds);
            ma_data_source_set_next(&self->loop_delay_ds, &self->decoder);
        }
    } else {
        // TODO? maybe refactor this

        ma_data_source_set_current(&self->decoder, &self->decoder);
        ma_data_source_set_looping(&self->decoder, false);
        ma_data_source_set_next(&self->decoder, NULL);
    }
}

SoundData encoded_sound_data_ww_sound_data(EncodedSoundData *const self)
    WRAP_BODY(
        SoundData,
        SOUND_DATA_INTERFACE(EncodedSoundData),
        {
            .get_ds = encoded_sound_data_get_ds,
            .uninit = encoded_sound_data_uninit,
        }
    );