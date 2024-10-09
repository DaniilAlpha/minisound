#include <stdbool.h>

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../include/circular_buffer.h"
#include "../../include/sound_data/recorded_sound_data.h"

#define MILO_LVL SOUND_MILO_LVL
#include "../../external/milo/milo.h"

struct RecordedSoundData {
    CircularBuffer circular_buffer;

    bool do_write_to_file;
    ma_encoder encoder;
};
