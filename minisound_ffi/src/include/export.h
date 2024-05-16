#ifndef EXPORT_H
#define EXPORT_H

#if _WIN32
#  define EXPORT __declspec(dllexport)
#elif __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

#endif
