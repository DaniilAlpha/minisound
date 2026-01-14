part of "minisound_web.dart";

extension on AudioEncoding {
  c.AudioEncoding toC() => switch (this) {
        // AudioEncoding.raw => c.AudioEncoding.AUDIO_ENCODING_RAW,
        AudioEncoding.wav => c.AudioEncoding.AUDIO_ENCODING_WAV,
        AudioEncoding.flac => c.AudioEncoding.AUDIO_ENCODING_FLAC,
        AudioEncoding.mp3 => c.AudioEncoding.AUDIO_ENCODING_MP3,
      };
}

extension on SampleFormat {
  c.SampleFormat toC() => switch (this) {
        SampleFormat.u8 => c.SampleFormat.SAMPLE_FORMAT_U8,
        SampleFormat.s16 => c.SampleFormat.SAMPLE_FORMAT_S16,
        SampleFormat.s24 => c.SampleFormat.SAMPLE_FORMAT_S24,
        SampleFormat.s32 => c.SampleFormat.SAMPLE_FORMAT_S32,
        SampleFormat.f32 => c.SampleFormat.SAMPLE_FORMAT_F32,
      };
}
