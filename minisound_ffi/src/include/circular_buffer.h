#ifndef CIRCULAR_BUFFER_H
#define CIRCULAR_BUFFER_H

#include <stddef.h>
#include <pthread.h>

#include "export.h"

EXPORT typedef struct
{
    float *buffer;
    size_t capacity;
    size_t write_pos;
    size_t read_pos;
    pthread_mutex_t mutex;
} CircularBuffer;

EXPORT void circular_buffer_init(CircularBuffer *cb, size_t size_in_bytes);
EXPORT void circular_buffer_uninit(CircularBuffer *cb);
EXPORT void circular_buffer_write(CircularBuffer *cb, const float *data, size_t size_in_floats);
EXPORT size_t circular_buffer_read(CircularBuffer *cb, float *data, size_t size_in_floats);
EXPORT size_t circular_buffer_get_available_floats(CircularBuffer *cb);
EXPORT size_t circular_buffer_read_available(CircularBuffer *cb, float *data, size_t max_size_in_floats);

#endif // CIRCULAR_BUFFER_H