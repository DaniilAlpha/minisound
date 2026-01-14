#include "audio_common.h"

#include <assert.h>
#include <miniaudio.h>

#if __EMSCRIPTEN__
#  include <assert.h>

// clang-format off

static_assert(sizeof(size_t) == 4, "The dart-wasm bindings assume the size of `size_t` to be 4.");
static_assert(sizeof(void *) == 4, "The dart-wasm bindings assume the size of `void *` to be 4.");

// clang-format on

#endif

// clang-format off

// this ensures safe casting between `AudioEncoding` and `ma_encoder_format`
static_assert((int)AUDIO_ENCODING_RAW == (int)ma_encoding_format_unknown, "`AUDIO_ENCODING_RAW` should match `ma_encoding_format_unknown`.");
static_assert((int)AUDIO_ENCODING_WAV == (int)ma_encoding_format_wav, "`AUDIO_ENCODING_WAV` should match `ma_encoding_format_wav`.");
static_assert((int)AUDIO_ENCODING_FLAC == (int)ma_encoding_format_flac, "`AUDIO_ENCODING_FLAC` should match `ma_encoding_format_flac`.");
static_assert((int)AUDIO_ENCODING_MP3 == (int)ma_encoding_format_mp3, "`AUDIO_ENCODING_MP3` should match `ma_encoding_format_mp3`.");

// this ensures safe casting between `SampleFormat` and `ma_format`
static_assert((int)SAMPLE_FORMAT_U8 == (int)ma_format_u8, "`SAMPLE_FORMAT_U8` should match `ma_format_u8`.");
static_assert((int)SAMPLE_FORMAT_S16 == (int)ma_format_s16, "`SAMPLE_FORMAT_S16` should match `ma_format_s16`.");
static_assert((int)SAMPLE_FORMAT_S24 == (int)ma_format_s24, "`SAMPLE_FORMAT_S24` should match `ma_format_s24`.");
static_assert((int)SAMPLE_FORMAT_S32 == (int)ma_format_s32, "`SAMPLE_FORMAT_S32` should match `ma_format_s32`.");
static_assert((int)SAMPLE_FORMAT_F32 == (int)ma_format_f32, "`SAMPLE_FORMAT_F32` should match `ma_format_f32`.");

// clang-format on
