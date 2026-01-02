MAKEFLAGS += --always-make -j2
SHELL := /bin/bash # set the shell explicitly for UNIX-like systems

### cmake settings ###

export CMAKE_EXPORT_COMPILE_COMMANDS ?= 1
export CMAKE_LOG_LEVEL ?= NOTICE


### dirs ###

PROJ_PI_DIR = ./minisound_platform_interface/ 

PROJ_FFI_DIR = ./minisound_ffi/ 
PROJ_FFI_SRC_DIR = ./minisound_ffi/src/
PROJ_FFI_NATIVE_TEST_SRC_DIR = ./minisound_ffi/test_native/
PROJ_FFI_NATIVE_TEST_BUILD_DIR = ./minisound_ffi/test_native/build/

PROJ_WEB_DIR = ./minisound_web/ 
PROJ_WEB_LIB_BUILD_DIR = ./minisound_web/lib/build/

PROJ_MAIN_DIR = ./minisound/ 
PROJ_MAIN_EXAMPLE_DIR = ./minisound/example/


### tasks ###

all: proj-main-example-run

# flutter

projs-get: --proj-pi-get --proj-ffi-get --proj-web-get --proj-main-get --proj-main-example-get
--proj-pi-get:
	@ cd $(PROJ_PI_DIR) && flutter pub get && flutter pub upgrade
--proj-ffi-get:
	@ cd $(PROJ_FFI_DIR) && flutter pub get && flutter pub upgrade
--proj-web-get:
	@ cd $(PROJ_WEB_DIR) && flutter pub get && flutter pub upgrade
--proj-main-get:
	@ cd $(PROJ_MAIN_DIR) && flutter pub get && flutter pub upgrade
--proj-main-example-get:
	@ cd $(PROJ_MAIN_EXAMPLE_DIR) && flutter pub get && flutter pub upgrade

projs-clean: --proj-pi-clean --proj-ffi-clean --proj-web-clean --proj-main-clean --proj-main-example-clean
--proj-pi-clean:
	@ cd $(PROJ_PI_DIR) && flutter clean
--proj-ffi-clean:
	@ cd $(PROJ_FFI_DIR) && flutter clean
--proj-web-clean:
	@ cd $(PROJ_WEB_DIR) && flutter clean
--proj-main-clean:
	@ cd $(PROJ_MAIN_DIR) && flutter clean
--proj-main-example-clean:
	@ cd $(PROJ_MAIN_EXAMPLE_DIR) && flutter clean

proj-ffi-gen-bindings:
	@ cd $(PROJ_FFI_DIR) && dart run ffigen 

proj-main-example-run:
	@ cd $(PROJ_MAIN_EXAMPLE_DIR) && flutter run 
proj-main-example-run-web:
	@ cd $(PROJ_MAIN_EXAMPLE_DIR) && flutter run -d chrome --web-browser-flag '--enable-features=SharedArrayBuffer'
proj-main-example-run-wasm:
	@ cd $(PROJ_MAIN_EXAMPLE_DIR) && flutter run -d chrome --wasm --web-browser-flag '--enable-features=SharedArrayBuffer'


# native test

proj-ffi-native-test-run: proj-ffi-native-test-build
	@ $(RUNNER) $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)/minisound_test # to allow the same command with the GDB

proj-ffi-native-test-build:
	@\
	cmake -B $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)/lib/ -S $(PROJ_FFI_SRC_DIR) -DCMAKE_BUILD_TYPE=Debug &&\
	cmake --build $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)/lib/
	@\
	cmake -B $(PROJ_FFI_NATIVE_TEST_BUILD_DIR) -S $(PROJ_FFI_NATIVE_TEST_SRC_DIR) -DCMAKE_BUILD_TYPE=Debug &&\
	cmake --build $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)

proj-ffi-native-test-clean:
ifdef PROJ_FFI_NATIVE_TEST_BUILD_DIR
ifeq ($(OS),Windows_NT)
	@ rd /s /q $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)/*
else
	@ rm -r -f $(PROJ_FFI_NATIVE_TEST_BUILD_DIR)/*
endif
endif

# web lib

proj-web-lib-build:
	@\
	emcmake cmake -B $(PROJ_WEB_LIB_BUILD_DIR)/cmake_stuff/ -S $(SRC_DIR) -DCMAKE_BUILD_TYPE=Debug &&\
	cmake --build $(PROJ_WEB_LIB_BUILD_DIR)/cmake_stuff/

proj-web-lib-clean:
ifdef PROJ_WEB_LIB_BUILD_DIR
ifeq ($(OS),Windows_NT)
	@ rd /s /q $(PROJ_WEB_LIB_BUILD_DIR)/*
else
	@ rm -r -f $(PROJ_WEB_LIB_BUILD_DIR)/*
endif
endif

# pubspec 

# _check_if_version_set:
# ifndef VER
# 	$(error Variable `VER` is not set)
# endif

# pubspec_local: _check_if_version_set
# 	@ echo "Switching our pubspecs : dev $(VER)..."
# 	@ python update_pubspecs.py $(VER)

# pubspec_release: _check_if_version_set
# 	@ echo "Switching our pubspecs : release $(VER)..."
# 	@ python update_pubspecs.py $(VER) --release
