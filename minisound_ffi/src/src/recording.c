#include "../include/recording.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MILO_LVL RECORDER_MILO_LVL
#include "../external/milo/milo.h"
#include "../external/miniaudio/include/miniaudio.h"

#define RECORDING_MIN_CAP               (65536)
#define next_recording_cap(current_len) (current_len << 1)

typedef struct Recording {
    ma_encoder encoder;

    uint8_t *_buf;
    size_t _size, _off, _cap;
} Recording;

Recording *recording_alloc(void) { return malloc(sizeof(Recording)); }
Result recording_init(Recording *const self) {
    self->_buf = malloc(RECORDING_MIN_CAP);
    if (self->_buf == NULL) return OutOfMemErr;

    self->_size = self->_off = 0;
    self->_cap = RECORDING_MIN_CAP;

    return Ok;
}
void recording_uninit(Recording *const self) {
    free(self->_buf), self->_buf = NULL;
    self->_size = self->_off = self->_cap = 0;
}

uint8_t const *recording_get_buf(Recording const *const self) {
    return self->_buf;
}
size_t recording_get_size(Recording const *const self) { return self->_size; }

size_t recording_get_off(Recording const *const self) { return self->_off; }
void recording_set_off(Recording *const self, size_t const value) {
    self->_off = value;
    if (self->_off >= self->_size) self->_off = self->_size - 1;
}

Result recording_write(
    Recording *const self,
    uint8_t const *const data,
    size_t const data_size
) {
    size_t const min_target_size = self->_off + data_size;
    size_t new_cap = self->_cap;
    while (new_cap < min_target_size) new_cap = next_recording_cap(new_cap);

    if (new_cap != self->_cap) {
        uint8_t *const new_buf = realloc(self->_buf, new_cap);
        if (new_buf == NULL) return OutOfMemErr;

        self->_buf = new_buf;
        self->_cap = new_cap;
    }

    memcpy(self->_buf + self->_off, data, data_size);
    if (self->_size < min_target_size) self->_size = min_target_size;

    self->_off += data_size;

    return Ok;
}

Result recording_fit(Recording *const self) {
    size_t const new_cap = self->_size;
    uint8_t *const new_buf = realloc(self->_buf, new_cap);
    if (new_buf == NULL) return OutOfMemErr;

    self->_cap = new_cap;
    self->_buf = new_buf;

    return Ok;
}
