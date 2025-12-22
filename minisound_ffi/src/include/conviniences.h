#ifndef CONVINIENCES_H
#define CONVINIENCES_H

#include <stddef.h>
#include <stdlib.h>

#define elsizeof(ARR_) (sizeof(*(ARR_)))
#define lenof(ARR_)    (sizeof(ARR_) / elsizeof(ARR_))

static inline void *malloc0(size_t const size) { return calloc(1, size); }

#endif
