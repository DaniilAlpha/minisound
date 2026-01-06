// Relative import to be able to reuse the C sources.
// See the comment in ../minisound_ffi.podspec for more information.

#include "../../src/src/engine.c"
#include "../../src/src/milo.c"
#include "../../src/src/recorder/recorder.c"
#include "../../src/src/recorder/recorder_buffer.c"
#include "../../src/src/recorder/recording.c"
#include "../../src/src/sound.c"
#include "../../src/src/sound_data/encoded_sound_data.c"
#include "../../src/src/sound_data/noise_sound_data.c"
#include "../../src/src/sound_data/pulse_sound_data.c"
#include "../../src/src/sound_data/silence_data_source.c"
#include "../../src/src/sound_data/waveform_sound_data.c"
