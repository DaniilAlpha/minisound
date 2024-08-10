#ifndef CIRCULAR_BUFFER_H
#define CIRCULAR_BUFFER_H

#include <stddef.h>

#include "export.h"

typedef struct
{
    float *buffer;
    size_t capacity;
    size_t write_pos;
    size_t read_pos;
} CircularBuffer;

int circular_buffer_init(CircularBuffer *cb, size_t size_in_bytes);
void circular_buffer_uninit(CircularBuffer *cb);
void circular_buffer_write(CircularBuffer *cb, const float *data, size_t size_in_floats);
size_t circular_buffer_read(CircularBuffer *cb, float *data, size_t size_in_floats);
size_t circular_buffer_get_available_floats(CircularBuffer *cb);
size_t circular_buffer_read_available(CircularBuffer *cb, float *data, size_t max_size_in_floats);

#endif // CIRCULAR_BUFFER_H