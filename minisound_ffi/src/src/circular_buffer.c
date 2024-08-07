#include "../include/circular_buffer.h"
#include "../include/miniaudio.h"

#include <stdlib.h>

int circular_buffer_init(CircularBuffer *cb, size_t size_in_bytes)
{
    cb->buffer = (float *)malloc(size_in_bytes);
    cb->capacity = size_in_bytes / sizeof(float);
    cb->write_pos = 0;
    cb->read_pos = 0;
    return (cb->buffer == NULL) ? 1 : 0;
}

void circular_buffer_uninit(CircularBuffer *cb)
{
    free(cb->buffer);
    cb->buffer = NULL;
}

void circular_buffer_write(CircularBuffer *cb, const float *data, size_t size_in_floats)
{
    size_t to_write = size_in_floats;
    size_t write_pos = cb->write_pos;

    while (to_write > 0)
    {
        size_t available_space;
        available_space = cb->capacity - ((write_pos - cb->read_pos + cb->capacity) % cb->capacity);
        if (available_space == 0)
        {
            // Buffer is full, move read_pos
            cb->read_pos = (cb->read_pos + 1) % cb->capacity;
        }

        size_t chunk = (to_write < available_space) ? to_write : available_space;
        for (size_t i = 0; i < chunk; i++)
        {
            cb->buffer[write_pos] = data[size_in_floats - to_write + i];
            write_pos = (write_pos + 1) % cb->capacity;
        }
        to_write -= chunk;
    }

    cb->write_pos = write_pos;
}

size_t circular_buffer_read(CircularBuffer *cb, float *data, size_t size_in_floats)
{
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    size_t to_read = (size_in_floats < available) ? size_in_floats : available;

    for (size_t i = 0; i < to_read; i++)
    {
        size_t read_pos;
        read_pos = cb->read_pos;
        cb->read_pos = (cb->read_pos + 1) % cb->capacity;

        data[i] = cb->buffer[read_pos];
    }

    return to_read;
}

size_t circular_buffer_get_available_floats(CircularBuffer *cb)
{
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    return available;
}

size_t circular_buffer_read_available(CircularBuffer *cb, float *data, size_t max_size_in_floats)
{
    size_t read_pos, write_pos, available, to_read;


    read_pos = cb->read_pos;
    write_pos = cb->write_pos;

    if (write_pos >= read_pos)
    {
        available = write_pos - read_pos;
    }
    else
    {
        available = cb->capacity - read_pos + write_pos;
    }

    to_read = (max_size_in_floats < available) ? max_size_in_floats : available;

    for (size_t i = 0; i < to_read; i++)
    {
        data[i] = cb->buffer[read_pos];
        read_pos = (read_pos + 1) % cb->capacity;
    }

    cb->read_pos = read_pos;

    return to_read;
}