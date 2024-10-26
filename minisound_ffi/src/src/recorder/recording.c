#include "../../include/recorder/recording.h"

size_t sizeof_recording() { return sizeof(Recording); }

uint8_t const *recording_get_buf(Recording const *const self) {
    return self->buf;
}
size_t recording_get_size(Recording const *const self) { return self->size; }
