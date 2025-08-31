#ifndef CONVINIENCES_H
#define CONVINIENCES_H

#include <stddef.h>
#include <stdlib.h>

static inline void *malloc0(size_t const size) { return calloc(1, size); }

#endif
