#include <stdio.h>

#define milo_printf(format, ...) (printf(format, ##__VA_ARGS__), fflush(stdout))
#define milo_eprintf(format, ...)                                              \
    (fprintf(stderr, format, ##__VA_ARGS__), fflush(stderr))
