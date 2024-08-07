#include "../include/circular_buffer.h"
#include <pthread.h>
#include "../include/miniaudio.h"

#include <stdlib.h>

void circular_buffer_init(CircularBuffer *cb, size_t size_in_bytes)
{
    cb->buffer = (float *)malloc(size_in_bytes);
    cb->capacity = size_in_bytes / sizeof(float);
    cb->write_pos = 0;
    cb->read_pos = 0;
    pthread_mutex_init(&cb->mutex, NULL);
}

void circular_buffer_uninit(CircularBuffer *cb)
{
    free(cb->buffer);
    cb->buffer = NULL;
    pthread_mutex_destroy(&cb->mutex);
}

void circular_buffer_write(CircularBuffer *cb, const float *data, size_t size_in_floats)
{
    size_t to_write = size_in_floats;
    size_t write_pos = cb->write_pos;

    while (to_write > 0)
    {
        size_t available_space;
        pthread_mutex_lock(&cb->mutex);
        available_space = cb->capacity - ((write_pos - cb->read_pos + cb->capacity) % cb->capacity);
        if (available_space == 0)
        {
            // Buffer is full, move read_pos
            cb->read_pos = (cb->read_pos + 1) % cb->capacity;
        }
        pthread_mutex_unlock(&cb->mutex);

        size_t chunk = (to_write < available_space) ? to_write : available_space;
        for (size_t i = 0; i < chunk; i++)
        {
            cb->buffer[write_pos] = data[size_in_floats - to_write + i];
            write_pos = (write_pos + 1) % cb->capacity;
        }
        to_write -= chunk;
    }

    pthread_mutex_lock(&cb->mutex);
    cb->write_pos = write_pos;
    pthread_mutex_unlock(&cb->mutex);
}

size_t circular_buffer_read(CircularBuffer *cb, float *data, size_t size_in_floats)
{
    pthread_mutex_lock(&cb->mutex);
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    size_t to_read = (size_in_floats < available) ? size_in_floats : available;
    pthread_mutex_unlock(&cb->mutex);

    for (size_t i = 0; i < to_read; i++)
    {
        size_t read_pos;
        pthread_mutex_lock(&cb->mutex);
        read_pos = cb->read_pos;
        cb->read_pos = (cb->read_pos + 1) % cb->capacity;
        pthread_mutex_unlock(&cb->mutex);

        data[i] = cb->buffer[read_pos];
    }

    return to_read;
}

size_t circular_buffer_get_available_floats(CircularBuffer *cb)
{
    pthread_mutex_lock(&cb->mutex);
    size_t available = (cb->write_pos - cb->read_pos + cb->capacity) % cb->capacity;
    pthread_mutex_unlock(&cb->mutex);
    return available;
}

size_t circular_buffer_read_available(CircularBuffer *cb, float *data, size_t max_size_in_floats)
{
    size_t read_pos, write_pos, available, to_read;

    pthread_mutex_lock(&cb->mutex);

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

    pthread_mutex_unlock(&cb->mutex);

    return to_read;
}