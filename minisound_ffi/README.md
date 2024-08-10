# minisound_ffi

The FFI implementation of `minisound`.

## Usage

This package is endorsed, which means you can simply use `minisound` normally. This package will be automatically included in your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you import this package to use any of its APIs directly, you should add it to your `pubspec.yaml` as usual.

## Building the project

To build the project, follow these steps:

1. Initialize the submodules:

   ```bash
   git submodule update --init --recursive
   ```

2. Make and/or Navigate to the `minisound_ffi/src/build` directory:

   ```bash
   cd minisound_ffi/src/build
   ```

3. Run the following commands to build the project using emcmake and cmake:

   ```bash
   emcmake cmake ..
   cmake --build .
   ```

   If you want to build the native version, encounter issues or want to start fresh, clean the `build` folder and rerun the cmake commands:

    ```bash
    rm -rf *
    cmake ..
    cmake --build .
    ```

4. For development work, it's useful to run `ffigen` from the `minisound_ffi` directory:

   ```bash
   cd minisound_ffi
   dart run ffigen
   ```
