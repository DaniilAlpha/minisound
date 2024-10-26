#ifndef RECORDING_H
#define RECORDING_H

#include <stddef.h>
#include <stdint.h>

#include "../export.h"

typedef struct Recording {
    uint8_t *buf;
    size_t size;
} Recording;

EXPORT size_t sizeof_recording();

EXPORT uint8_t const *recording_get_buf(Recording const *const self);
EXPORT size_t recording_get_size(Recording const *const self);

#endif
