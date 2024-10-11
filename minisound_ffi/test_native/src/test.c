#include <stdio.h>
#include <stdlib.h>

#include <threads.h>

#include "engine.h"

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

typedef struct Buffer {
    size_t const len;
    uint8_t *const buf;
} Buffer;
bool size_buffer_is_empty(Buffer const *const self) {
    return self->buf == NULL;
}

Buffer load_file(char const *const file_path) {
    FILE *const file = fopen(file_path, "rb");
    if (file == NULL) return (Buffer){0};

    size_t const buf_len = fsize(file);
    if (buf_len <= 0) return (Buffer){0};

    uint8_t *const buf = malloc(buf_len);
    fread(buf, 1, buf_len, file);

    fclose(file);

    return (Buffer){.len = buf_len, .buf = buf};
}

Result test_sound(Engine *const engine, char const *const file_path) {
    Sound *const sound = sound_alloc();
    if (sound == NULL) return OutOfMemErr;

    Buffer const data = load_file(file_path);
    if (size_buffer_is_empty(&data)) return free(sound), FileReadingErr;

    UNROLL_CLEANUP(engine_load_sound(engine, sound, data.buf, data.len), {
        free(data.buf), free(sound);
    });

    sound_play(sound);

    sleep(3);

    sound_unload(sound), free(data.buf), free(sound);

    return 0;
}

int main(int const argc, char const *const argv[]) {
    Engine *const engine = engine_alloc();
    if (engine == NULL) return -2;

    engine_init(engine, 33), engine_start(engine);

    Result const r =
        test_sound(engine, "../minisound/example/assets/laser_shoot.wav");
    if (r != Ok) printf("ERROR: %s\n", explain(r));

    engine_uninit(engine), free(engine);
    return 0;
}
