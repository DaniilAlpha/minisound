# minisound_ffi

The FFI implementation of `minisound`.

## Usage

This package is endorsed, which means you can simply use `minisound` normally. This package will be automatically included in your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you import this package to use any of its APIs directly, you should add it to your `pubspec.yaml` as usual.

## Building the project

To manually build the project, follow these steps:

1. Initialize the submodules:

    ```bash
    git submodule update --init --recursive
    ```

2. Run the following commands to build the project using emcmake:

    ```bash
    emcmake cmake -S ./minisound_ffi/src/ -B ./minisound_web/lib/build/cmake_stuff 
    cmake --build ./minisound_web/lib/build/cmake_stuff 
    ```

    If you encounter issues or want to start fresh, clean the `build` folder and rerun the cmake commands:

    ```bash
    rm -rf *
    emcmake cmake -S ./minisound_ffi/src/ -B ./minisound_web/lib/build/cmake_stuff 
    cmake --build ./minisound_web/lib/build/cmake_stuff 
    ```

4. For development work, it's useful to run `ffigen` from the `minisound_ffi` directory:

    ```bash
    cd ./minisound_ffi/
    dart run ffigen
    ```
