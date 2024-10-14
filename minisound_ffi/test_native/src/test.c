

#include <stdio.h>
#include <stdlib.h>

#include <miunte.h>
#include <threads.h>

#include "engine.h"
#include "recorder.h"
#include "recording.h"

#define lenof(arr) (sizeof(arr) / sizeof(arr[0]))

long fsize(FILE *const file) {
    long const file_pos = ftell(file);
    if (file_pos < 0) return file_pos;

    fseek(file, 0, SEEK_END);
    long const file_last = ftell(file);
    if (file_last < 0) return file_last;

    fseek(file, file_pos, SEEK_SET);

    return file_last + 1;
}

int sleep(size_t const ms) {
    return thrd_sleep(
        ms >= 1000 ? &(struct timespec){.tv_sec = ms / 1000}
                   : &(struct timespec){.tv_nsec = ms * 1000000},
        NULL
    );
}

Result load_file(
    char const *const file_path,
    uint8_t **const out_buf,
    size_t *const out_buf_len
) {
    FILE *const file = fopen(file_path, "rb");
    if (file == NULL) return FileReadingErr;

    size_t const buf_len = fsize(file);
    if (buf_len <= 0) return FileReadingErr;

    uint8_t *const buf = malloc(buf_len);
    if (buf == NULL) return OutOfMemErr;

    fread(buf, 1, buf_len, file);
    fclose(file);

    return *out_buf = buf, *out_buf_len = buf_len, Ok;
}

// tests

Engine *engine;

MiunteResult setup_test() {
    engine = engine_alloc();
    MIUNTE_EXPECT(engine != NULL, "engine should be allocated properly");

    MIUNTE_EXPECT(
        engine_init(engine, 33) == Ok,
        "engine initialization should not fail"
    );
    MIUNTE_EXPECT(
        engine_start(engine) == Ok,
        "engine starting should not fail"
    );

    MIUNTE_PASS();
}

MiunteResult teardown_test() {
    engine_uninit(engine);
    free(engine), engine = NULL;

    MIUNTE_PASS();
}

MiunteResult test_encoded_sounds() {
    char const *const paths[] = {
        "./minisound/example/assets/laser_shoot.wav",
        "./minisound/example/assets/laser_shoot.mp3",
    };
    for (size_t i = 0; i < lenof(paths); i++) {
        Sound *const sound = sound_alloc();
        MIUNTE_EXPECT(sound != NULL, "sound should be allocated properly");

        uint8_t *buf;
        size_t buf_len;
        MIUNTE_EXPECT(
            load_file(paths[i], &buf, &buf_len) == Ok,
            "file loading should not fail"
        );

        MIUNTE_EXPECT(
            engine_load_sound(engine, sound, buf, buf_len) == Ok,
            "sound loading should not fail"
        );

        MIUNTE_EXPECT(sound_play(sound) == Ok, "sound playing should not fail");

        sleep(600);

        sound_unload(sound);
        free(buf), buf = NULL;
        free(sound);
    }

    MIUNTE_PASS();
}
MiunteResult test_generated_waveform_sounds() {
    double freqs[] = {261.63, 329.63, 440.00, 523.25};
    for (size_t i = 0; i < lenof(freqs); i++) {
        Sound *const sound = sound_alloc();
        MIUNTE_EXPECT(sound != NULL, "sound should be allocated properly");

        MIUNTE_EXPECT(
            engine_generate_waveform(
                engine,
                sound,
                WAVEFORM_TYPE_SINE,
                freqs[i]
            ) == Ok,
            "sound generation should not fail"
        );
        MIUNTE_EXPECT(sound_play(sound) == Ok, "sound playing should not fail");

        sleep(200);

        sound_unload(sound);
        free(sound);
    }

    MIUNTE_PASS();
}
MiunteResult test_generated_noise_sounds() {
    Sound *const sound = sound_alloc();
    MIUNTE_EXPECT(sound != NULL, "sound should be allocated properly");

    MIUNTE_EXPECT(
        engine_generate_noise(engine, sound, NOISE_TYPE_BROWNIAN, 0) == Ok,
        "sound generation should not fail"
    );
    MIUNTE_EXPECT(sound_play(sound) == Ok, "sound playing should not fail");

    sleep(1000);

    sound_unload(sound);
    free(sound);

    MIUNTE_PASS();
}
MiunteResult test_generated_pulse_sounds() {
    Sound *const sound = sound_alloc();
    MIUNTE_EXPECT(sound != NULL, "sound should be allocated properly");

    MIUNTE_EXPECT(
        engine_generate_pulse(engine, sound, 261.63, 0.1) == Ok,
        "sound generation should not fail"
    );
    MIUNTE_EXPECT(sound_play(sound) == Ok, "sound playing should not fail");

    sleep(600);

    sound_unload(sound);
    free(sound);

    MIUNTE_PASS();
}
MiunteResult test_recording() {
    Recorder *const recorder = recorder_alloc();
    MIUNTE_EXPECT(recorder != NULL, "recorder should be allocated properly");

    MIUNTE_EXPECT(
        recorder_init(
            recorder,
            RECORDER_ENCODING_WAV,
            RECORDER_FORMAT_F32,
            2,
            48000
        ) == Ok,
        "recorder initialization should not fail"
    );
    MIUNTE_EXPECT(
        recorder_start(recorder) == Ok,
        "recorder starting should not fail"
    );

    sleep(3000);

    Recording *const rec = recorder_stop(recorder);

    FILE *const file = fopen("recording.wav", "wb");
    MIUNTE_EXPECT(file != NULL, "file should open properly");
    fwrite(recording_get_buf(rec), 1, recording_get_size(rec), file);
    fclose(file);

    recording_uninit(rec), free(rec);
    recorder_uninit(recorder), free(recorder);

    MIUNTE_PASS();
}

int main() {
    MIUNTE_RUN(
        setup_test,
        teardown_test,
        {
            test_encoded_sounds,
            test_generated_waveform_sounds,
            test_generated_noise_sounds,
            test_generated_pulse_sounds,
            test_recording,
        }
    );

    return 0;
}
