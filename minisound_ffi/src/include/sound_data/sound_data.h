#ifndef SOUND_DATA_H
#define SOUND_DATA_H

#include <stdbool.h>
#include <stdint.h>

#include "../../external/miniaudio/include/miniaudio.h"
#include "../../external/woodi/woodi.h"

#define SOUND_DATA_INTERFACE(Self)                                             \
    {                                                                          \
        ma_data_source *(*const get_ds)(Self *const);                          \
        void (*const uninit)(Self *const);                                     \
    }
WRAPPER(SoundData, SOUND_DATA_INTERFACE);

#define sound_data_get_ds(self) WRAPPER_CALL(get_ds, self)
#define sound_data_uninit(self) WRAPPER_CALL(uninit, self)

#endif
