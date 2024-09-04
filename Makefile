# Set the shell explicitly for UNIX-like systems
SHELL := /bin/bash

# Detect the operating system
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    RMDIR_CMD := del /S
    SLASH := \\
else
    DETECTED_OS := $(shell uname)
    RMDIR_CMD := rm -rf
    SLASH := /
endif

PLATFORM_INTERFACE_DIR := ./minisound_platform_interface/
FFI_DIR := .$(SLASH)minisound_ffi$(SLASH)
WEB_DIR := .$(SLASH)minisound_web$(SLASH)
MINISOUND_DIR := .$(SLASH)minisound$(SLASH)
EXAMPLE_DIR := .$(SLASH)minisound$(SLASH)example$(SLASH)
SRC_DIR := .$(SLASH)minisound_ffi$(SLASH)src$(SLASH)
BUILD_DIR := .$(SLASH)minisound_ffi$(SLASH)src$(SLASH)build$(SLASH)
VERSION ?= 1.5.1

default: run

init_submodules:
	@echo "󰐊 Initializing submodules..."
	@git submodule update --init --recursive

pubspec_local:
	@echo "󰐊 Switching our pubspecs for local dev with version ${VERSION}."
	@python update_pubspecs.py ${VERSION}

pubspec_release:
	@echo "󰐊 Switching our pubspecs for release with version ${VERSION}."
	@python update_pubspecs.py ${VERSION} --release

clean:
	@echo "󰃢 Cleaning Example."
	@cd $(EXAMPLE_DIR) && flutter clean

run: init_submodules
ifeq ($(DETECTED_OS), Windows)
	@echo "󰐊 Running example on Windows..."
	@cd $(EXAMPLE_DIR) && cmd /c flutter run -d Windows
else ifeq ($(DETECTED_OS), Linux)
	@echo "󰐊 Running example on $(DETECTED_OS)..."
	@cd $(EXAMPLE_DIR) && flutter run -d Linux
else ifeq ($(DETECTED_OS), Darwin)
	@echo "󰐊 Running example on $(DETECTED_OS)..."
	@cd $(EXAMPLE_DIR) && flutter run -d MacOS
else
	@echo "Unsupported OS: $(DETECTED_OS)"
endif

run_device: init_submodules
	@echo "󰐊 Running example on device..."
	@cd $(EXAMPLE_DIR) && flutter run

run_web: build_weblib
	@echo "󰐊 Running web example..."
	@cd $(EXAMPLE_DIR) && flutter run -d chrome --web-browser-flag --enable-features=SharedArrayBuffer

ffigen: init_submodules
	@echo "Generating dart ffi bindings..."
	@cd $(FFI_DIR) && dart run ffigen

build_weblib: init_submodules
	@echo "Building ffi lib to web via emscripten..."
	@cd $(BUILD_DIR) && emcmake cmake .. && cmake --build .

clean_weblib:
	@echo "Cleaning web lib..."
	@$(RMDIR_CMD) "$(BUILD_DIR)/*"

help:
	@echo "Available targets:"
	@echo "  pubspec_local: Switches pubspecs for local dev."
	@echo "  pubspec_release: Switches pubspecs for release."
	@echo "  clean: Cleans the example project."
	@echo "  run: Runs the example project on current OS."
	@echo "  run_device: Runs the example project on chosen device."
	@echo "  run_web: Runs the web example project."
	@echo "  ffigen: Generates dart ffi bindings."
	@echo "  build_weblib: Builds the ffi lib to web via emscripten."
	@echo "  clean_weblib: Cleans the web lib."
	@echo "  help: Shows this help message."
