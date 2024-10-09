#ifndef RECORDED_SOUND_DATA_H
#define RECORDED_SOUND_DATA_H

#include "../../external/result/result.h"
#include "sound_data.h"

typedef struct RecordedSoundData RecordedSoundData;

RecordedSoundData *recorded_sound_data_alloc(void);
Result recorded_sound_data_init(
    RecordedSoundData *const self,
    float const *const data,
    size_t const data_size
);
void recorded_sound_data_uninit(RecordedSoundData *const self);

SoundData recorded_sound_data_ww_sound_data(RecordedSoundData *const self);

#endif
