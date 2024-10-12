

#include <stdio.h>
#include <stdlib.h>

#include <miunte.h>
#include <threads.h>

#include "engine.h"

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

int sleep(size_t const s) {
    return thrd_sleep(&(struct timespec){.tv_sec = s}, NULL);
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

    engine_init(engine, 33);
    engine_start(engine);

    MIUNTE_PASS();
}

MiunteResult teardown_test() {
    engine_uninit(engine);
    free(engine);

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

        sleep(1);

        sound_unload(sound);
        free(buf);
        free(sound);
    }

    MIUNTE_PASS();
}
MiunteResult test_generated_waveform_sounds() {
    double freqs[] =
        {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25};
    for (size_t i = 0; i < lenof(freqs); i++) {
        Sound *const sound = sound_alloc();
        MIUNTE_EXPECT(sound != NULL, "sound should be allocated properly");

        MIUNTE_EXPECT(
            engine_generate_waveform(
                engine,
                sound,
                WAVEFORM_TYPE_SINE,
                freqs[i],
                0.5
            ) == Ok,
            "sound generation should not fail"
        );
        MIUNTE_EXPECT(sound_play(sound) == Ok, "sound playing should not fail");

        sleep(1);

        sound_unload(sound);
        free(sound);
    }

    MIUNTE_PASS();
}

int main() {
    MIUNTE_RUN(
        setup_test,
        teardown_test,
        {
            test_encoded_sounds,
            test_generated_waveform_sounds,
        }
    );

    return 0;
}
