# Set the shell explicitly for UNIX-like systems
SHELL := /bin/bash


SRC_DIR := ./minisound_ffi/src/
WEB_BUILD_DIR := ./minisound_web/lib/build/


help:
	@ echo "No target selected. Available targets:"
	@ echo "  help: Shows this help message."
	@ echo "  pubspec_local: Switches pubspecs for local dev."
	@ echo "  pubspec_release: Switches pubspecs for release."
	@ echo "  build_web_lib: Builds the ffi lib to web via emscripten."
	@ echo "  clean_web_lib: Cleans the web lib." 


_check_if_version_set:
ifndef VER
	$(error Variable `VER` is not set)
endif

pubspec_local: _check_if_version_set
	@ echo "Switching our pubspecs : dev $(VER)..."
	@ python update_pubspecs.py $(VER)

pubspec_release: _check_if_version_set
	@ echo "Switching our pubspecs : release $(VER)..."
	@ python update_pubspecs.py $(VER) --release

_init_submodules:
	git submodule update --init --recursive

build_web_lib: _init_submodules
	@ echo "Building ffi lib to web via emscripten..."
	@ emcmake cmake -S $(SRC_DIR) -B $(WEB_BUILD_DIR)/cmake_stuff/ && cmake --build $(WEB_BUILD_DIR)/cmake_stuff/

clean_web_lib:
	@ echo "Cleaning web lib..."
ifeq ($(OS),Windows_NT)
	@ del /S $(WEB_BUILD_DIR)/*
else
	@ rm -rf $(WEB_BUILD_DIR)/*
endif
