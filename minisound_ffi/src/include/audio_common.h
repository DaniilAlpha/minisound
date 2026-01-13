#ifndef AUDIO_COMMON_H
#define AUDIO_COMMON_H

typedef enum AudioEncoding {
    AUDIO_ENCODING_RAW,  // TODO not supported yet
    AUDIO_ENCODING_WAV = 1,
    AUDIO_ENCODING_FLAC,
    AUDIO_ENCODING_MP3,
} AudioEncoding;
typedef enum SampleFormat {
    SAMPLE_FORMAT_U8 = 1,
    SAMPLE_FORMAT_S16,
    SAMPLE_FORMAT_S24,
    SAMPLE_FORMAT_S32,
    SAMPLE_FORMAT_F32,
} SampleFormat;

#endif
