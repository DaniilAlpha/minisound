# Setup
cmake_minimum_required(VERSION 3.5)
project(minisound_ffi VERSION 1.0.0 LANGUAGES C)

# Specify the filename to search for
set(FILENAME ".projectroot")

get_filename_component(PROJECT_ROOT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)
get_filename_component(PROJECT_ROOT ${PROJECT_ROOT} DIRECTORY)

# Construct potential paths
set(FILEPATH_CURRENT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME}")
set(FILEPATH_PROJECT_ROOT "${PROJECT_ROOT}/${FILENAME}")

# Check if the file exists in the current directory
if(EXISTS ${FILEPATH_CURRENT_DIR})
    set(TARGET_FILE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
elseif(EXISTS ${FILEPATH_PROJECT_ROOT})
    set(TARGET_FILE_PATH ${PROJECT_ROOT})
else()
    message(FATAL_ERROR "File ${FILENAME} not found in either ${CMAKE_CURRENT_SOURCE_DIR} or ${CMAKE_CURRENT_SOURCE_DIR}/../../")
endif()

# Set lib name
if(NOT EMSCRIPTEN)
    set(MAIN_LIB minisound_ffi)
else()
    set(MAIN_LIB minisound_web)
    set(MAIN_JS minisound_web_js)
endif()

# Set paths
set(MAIN_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(MAIN_OUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
set(WEB_OUTPUT_DIR ${TARGET_FILE_PATH}/minisound_web/lib/js)

# Main lib
if(NOT EMSCRIPTEN)
    add_library(${MAIN_LIB} SHARED)
else()
    add_executable(${MAIN_LIB})
endif()

# Sources
file(GLOB_RECURSE MAIN_SOURCES
    ${MAIN_PATH}/src/*.c
    ${MAIN_PATH}/external/*/src/*.c
)
target_sources(${MAIN_LIB} PUBLIC ${MAIN_SOURCES})

# Includes
file(GLOB_RECURSE MAIN_INCLUDES LIST_DIRECTORIES TRUE
    ${MAIN_PATH}/external/*/include/
)
list(APPEND MAIN_INCLUDES ${MAIN_PATH}/include/)
target_include_directories(${MAIN_LIB} PUBLIC ${MAIN_INCLUDES})

# Definitions
target_compile_definitions(${MAIN_LIB} PUBLIC 
    DART_SHARED_LIB
    MILO_DEFAULT_LVL=MILO_LVL_NONE
    MINIAUDIO_IMPLEMENTATION
    MA_ENABLE_ONLY_SPECIFIC_BACKENDS
    MA_DEBUG_OUTPUT
)

# Platform-specific definitions
if(WIN32)
    target_compile_definitions(${MAIN_LIB} PUBLIC MA_ENABLE_WASAPI)
elseif(ANDROID)
    target_compile_definitions(${MAIN_LIB} PUBLIC MA_ENABLE_OPENSL)
elseif(EMSCRIPTEN)
    target_compile_definitions(${MAIN_LIB} PUBLIC
        MA_ENABLE_WEBAUDIO
        MA_ENABLE_AUDIO_WORKLETS
        MA_AUDIO_WORKLETS_THREAD_STACK_SIZE=131072
    )
elseif(APPLE)
    target_compile_definitions(${MAIN_LIB} PUBLIC MA_ENABLE_COREAUDIO)
elseif(UNIX)
    target_compile_definitions(${MAIN_LIB} PUBLIC
        MA_ENABLE_PULSEAUDIO
        MA_ENABLE_JACK
        MA_ENABLE_ALSA
    )
else()
    message(FATAL_ERROR "No miniaudio backend specified for the platform.")
endif()

# Set properties
if(NOT EMSCRIPTEN)
    set_target_properties(${MAIN_LIB} PROPERTIES
        PUBLIC_HEADER include/minisound.h
        OUTPUT_NAME ${MAIN_LIB}
    )
else()
    set_target_properties(${MAIN_LIB} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${WEB_OUTPUT_DIR}
    )
    target_compile_options(${MAIN_LIB} PUBLIC
        -O3
        -flto -fno-rtti -fno-exceptions
        -sWASM_WORKERS
    )
    set_target_properties(${MAIN_LIB} PROPERTIES LINK_FLAGS "\
        -O3 \
        -flto \
        -sEXPORTED_FUNCTIONS=_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall \
        -sALLOW_MEMORY_GROWTH -sSTACK_SIZE=1mb -sMAXIMUM_MEMORY=1gb \
        -sNO_DEFAULT_TO_CXX -sNO_TEXTDECODER -sNO_FILESYSTEM -sNO_FETCH_SUPPORT_INDEXEDDB \
        -sAUDIO_WORKLET -sWASM_WORKERS -sASYNCIFY -ASYNCIFY_ONLYsASYNCIFY_STACK_SIZE=16384 \
        -sSTACK_OVERFLOW_CHECK \
    ")
endif()

# Main JS
if(EMSCRIPTEN)
    file(GLOB JS_SOURCES ${MAIN_PATH}/js/*.js)
    set(JS_OUTPUTS)
    foreach(JS_FILE ${JS_SOURCES})
        get_filename_component(JS_FILENAME ${JS_FILE} NAME)
        set(JS_OUTPUT ${WEB_OUTPUT_DIR}/${JS_FILENAME})
        list(APPEND JS_OUTPUTS ${JS_OUTPUT})
        add_custom_command(
            OUTPUT ${JS_OUTPUT}
            COMMAND ${CMAKE_COMMAND} -E copy ${JS_FILE} ${JS_OUTPUT}
            DEPENDS ${JS_FILE}
            COMMENT "Copying ${JS_FILENAME} to web output directory"
        )
    endforeach()

    add_custom_target(${MAIN_JS} ALL
        DEPENDS ${JS_OUTPUTS}
        COMMENT "Copying JS sources to web output directory"
    )
    add_dependencies(${MAIN_LIB} ${MAIN_JS})
endif()

# Additional libs
if(ANDROID)
    target_link_libraries(${MAIN_LIB} OpenSLES log)
endif()
