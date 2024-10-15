# Setup
cmake_minimum_required(VERSION 3.11)
project(minisound_ffi VERSION 1.0.0 LANGUAGES C)


# Set lib name
if(NOT EMSCRIPTEN)
    set(MAIN_LIB minisound_ffi)
else()
    set(MAIN_LIB minisound_web)
    set(MAIN_JS minisound_web_js)
endif()


# Main lib
if(NOT EMSCRIPTEN)
    add_library(${MAIN_LIB} SHARED)
else()
    add_executable(${MAIN_LIB})
endif()


# Set paths
set(MAIN_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if (EMSCRIPTEN)
    set(WEB_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/../)
endif()


# Sources
file(GLOB_RECURSE MAIN_SOURCES
    ${MAIN_PATH}/src/*.c
    ${MAIN_PATH}/external/*/src/*.c
)
target_sources(${MAIN_LIB} PRIVATE ${MAIN_SOURCES})

# Includes
# file(GLOB_RECURSE MAIN_INCLUDES LIST_DIRECTORIES TRUE
#     ${MAIN_PATH}/external/*/include/
# )
# list(APPEND MAIN_INCLUDES ${MAIN_PATH}/include/)
# target_include_directories(${MAIN_LIB} PRIVATE ${MAIN_INCLUDES})


# Definitions
target_compile_definitions(${MAIN_LIB} PRIVATE DART_SHARED_LIB
    # ours
    MILO_DEFAULT_LVL=MILO_LVL_NONE
    ENGINE_MILO_LVL=MILO_LVL_INFO
    SOUND_MILO_LVL=MILO_LVL_INFO
    RECORDER_MILO_LVL=MILO_LVL_INFO
    # miniaudio
    MA_ENABLE_ONLY_SPECIFIC_BACKENDS
    MA_NO_RESOURCE_MANAGER

    MA_DEBUG_OUTPUT
)

# Platform-specific definitions
if(NOT EMSCRIPTEN)
    if(NOT (WIN32 OR LINUX OR ANDROID OR APPLE))
        message(ERROR "No miniaudio backend for your platform enabled! Sound will not work!")
    endif()

    target_compile_definitions(${MAIN_LIB} PRIVATE
        # windows
        MA_ENABLE_WASAPI
        # linux
        MA_ENABLE_PULSEAUDIO
        MA_ENABLE_JACK
        MA_ENABLE_ALSA
        # android
        MA_ENABLE_OPENSL
        # apple
        MA_ENABLE_COREAUDIO
    )
else()
    target_compile_definitions(${MAIN_LIB} PRIVATE
        MA_ENABLE_WEBAUDIO
        MA_ENABLE_AUDIO_WORKLETS
    )
endif()


# Set properties
target_compile_options(${MAIN_LIB} PRIVATE -W -Wall -Wextra -Wformat -Wno-unused-function)

if(NOT EMSCRIPTEN)
    set_target_properties(${MAIN_LIB} PROPERTIES
        PUBLIC_HEADER include/minisound.h
        OUTPUT_NAME ${MAIN_LIB}
    )

    set(COMPILE_AND_LINK_OPTS -Og -g)
    target_compile_options(${MAIN_LIB} PRIVATE ${COMPILE_AND_LINK_OPTS})
    target_link_options(${MAIN_LIB} PRIVATE ${COMPILE_AND_LINK_OPTS})
    unset(COMMON_OPTIONS)
else()
    set_target_properties(${MAIN_LIB} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${WEB_OUT_DIR}
    )

    target_compile_options(${MAIN_LIB} PRIVATE -Og -g -flto -fno-rtti -fno-exceptions -sWASM_WORKERS=1)
    set_target_properties(${MAIN_LIB} PROPERTIES LINK_FLAGS "\
        -Og -g -gsource-map \
        -flto -fno-rtti -fno-exceptions \
        -sEXPORTED_FUNCTIONS=_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall \
        -sALLOW_MEMORY_GROWTH -sSTACK_SIZE=1048576 -sMAXIMUM_MEMORY=1gb \
        -sNO_DEFAULT_TO_CXX -sNO_TEXTDECODER -sNO_FETCH_SUPPORT_INDEXEDDB \
        -sWASM_WORKERS=1 -sAUDIO_WORKLET=1 -sASYNCIFY=1 -sASYNCIFY_STACK_SIZE=524288 \
        -sSTACK_OVERFLOW_CHECK=1 -sSAFE_HEAP \
    ")
    # \
    # -fsanitize=address \
endif()


# Additional emscripten-only stuff
if(EMSCRIPTEN)
    file(GLOB_RECURSE JS_SOURCES ${MAIN_PATH}/js/*.js)

    set(JS_OUTPUTS)
    foreach(JS_FILE ${JS_SOURCES})
        get_filename_component(JS_FILENAME ${JS_FILE} NAME)
        set(JS_OUTPUT ${WEB_OUT_DIR}/${JS_FILENAME})
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

    # Configure the modify_js.cmake script
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/modify_js.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/modify_js.cmake
        @ONLY
    )

    # Add custom command to modify the output JS file
    add_custom_command(
        TARGET ${MAIN_LIB} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Modifying ${MAIN_LIB}.js to use locateFile"
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/modify_js.cmake
        WORKING_DIRECTORY ${WEB_OUT_DIR}
        COMMENT "Post-processing ${MAIN_LIB}.js"
    )
endif()


# Additional libs
if(ANDROID)
    target_link_libraries(${MAIN_LIB} OpenSLES log)
endif()

