#ifndef RECORDING_H
#define RECORDING_H

#include <stddef.h>
#include <stdint.h>

#include "../external/result/result.h"

typedef struct Recording Recording;

Recording *recording_alloc(void);
Result recording_init(Recording *const self);
void recording_uninit(Recording *const self);

uint8_t const *recording_get_buf(Recording const *const self);
size_t recording_get_size(Recording const *const self);

size_t recording_get_off(Recording const *const self);
void recording_set_off(Recording *const self, size_t const value);

Result recording_write(
    Recording *const self,
    uint8_t const *const data,
    size_t const data_size
);

Result recording_fit(Recording *const self);

#endif
