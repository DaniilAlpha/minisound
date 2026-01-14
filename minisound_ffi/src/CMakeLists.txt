if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(IOS TRUE)
endif()
cmake_minimum_required(VERSION 3.18)

if(IOS)
    set(LANG OBJC)
else()
    set(LANG C)
endif()
project(minisound_ffi VERSION 1.0.0 LANGUAGES ${LANG})


### paths ###

set(MAIN_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if (EMSCRIPTEN)
    set(WEB_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/../)
endif()


### library ###

if(EMSCRIPTEN)
    set(MAIN_LIB minisound_web)
    set(MAIN_JS minisound_web_js)
else()
    set(MAIN_LIB minisound_ffi)
endif()

if(EMSCRIPTEN)
    add_executable(${MAIN_LIB})
else()
    add_library(${MAIN_LIB} SHARED)
endif()

file(GLOB_RECURSE MAIN_SOURCES ${MAIN_PATH}/src/*.c)
target_sources(${MAIN_LIB} PRIVATE ${MAIN_SOURCES})
set_source_files_properties(${MAIN_SOURCES} PROPERTIES LANGUAGE ${LANG})

target_include_directories(${MAIN_LIB} PUBLIC
    include/ external/result/ external/woodi/ external/milo/)

# dart stuff
target_compile_definitions(${MAIN_LIB} PRIVATE DART_SHARED_LIB)
# logging
target_compile_definitions(${MAIN_LIB} PRIVATE
    $<$<CONFIG:Debug>:
        MILO_DEFAULT_LVL=MILO_LVL_INFO
        ENGINE_MILO_LVL=MILO_LVL_INFO
        SOUND_MILO_LVL=MILO_LVL_INFO
        RECORDER_MILO_LVL=MILO_LVL_TRACE
    > $<$<CONFIG:Release>:
        MILO_DEFAULT_LVL=MILO_LVL_NONE
        ENGINE_MILO_LVL=MILO_LVL_NONE
        SOUND_MILO_LVL=MILO_LVL_NONE
        RECORDER_MILO_LVL=MILO_LVL_NONE
    >)

# warnings
if(MSVC)
    target_compile_options(${MAIN_LIB} PRIVATE
        /W2 /wd5287 /wd4098)
else()
    target_compile_options(${MAIN_LIB} PRIVATE
        -W -Wall -Wextra -Wformat -Wno-unused-function)
    # if(APPLE)
    #     target_compile_options(${MAIN_LIB} PUBLIC
    #           -Wno-strict-prototypes -Wno-comma)
    # endif()
endif()

if(EMSCRIPTEN)
    target_compile_options(${MAIN_LIB} PUBLIC
    $<$<CONFIG:Debug>:
        -Og -g3
    > $<$<CONFIG:Release>:
        -O3 -flto
    >
    -fno-rtti -fno-exceptions -sWASM_WORKERS)
    target_link_options(${MAIN_LIB} PUBLIC
    $<$<CONFIG:Debug>:
        -Og -g3 -gsource-map
        -sSAFE_HEAP
    > $<$<CONFIG:Release>:
        -O3 -fltp
    >
    -fno-rtti -fno-exceptions
    -sEXPORTED_FUNCTIONS=_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall
    -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb -sMAXIMUM_MEMORY=1gb
    -sNO_DEFAULT_TO_CXX -sNO_FILESYSTEM -sNO_FETCH_SUPPORT_INDEXEDDB
    -sWASM_WORKERS -sAUDIO_WORKLET -sASYNCIFY -sASYNCIFY_STACK_SIZE=131072
    -sSTACK_OVERFLOW_CHECK=1)
endif()

if(EMSCRIPTEN)
    set_target_properties(${MAIN_LIB} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${WEB_OUT_DIR})
elseif(APPLE)
    set_target_properties(${MAIN_LIB} PROPERTIES
        PUBLIC_HEADER include/minisound.h
        OUTPUT_NAME ${MAIN_LIB}
        FRAMEWORK TRUE
        MACOSX_RPATH TRUE
        MACOSX_FRAMEWORK_IDENTIFIER "com.daniilalpha.${MAIN_LIB}")
else()
    set_target_properties(${MAIN_LIB} PROPERTIES
        PUBLIC_HEADER include/minisound.h
        OUTPUT_NAME ${MAIN_LIB})
endif()


### miniaudio ###

# // TODO? maybe make an issue in miniaudio to make defs PUBLIC
option(MINIAUDIO_USE_STDINT "" ON)
option(MINIAUDIO_NO_EXTRA_NODES "" ON)
option(MINIAUDIO_NO_RESOURCE_MANAGER "" ON)
option(MINIAUDIO_ENABLE_ONLY_SPECIFIC_BACKENDS "" ON)
if (EMSCRIPTEN)
    # web
    option(MINIAUDIO_ENABLE_WEBAUDIO "" ON)
else()
    if(NOT (WIN32 OR LINUX OR ANDROID OR APPLE))
        message(ERROR
            "Sound won't work, as no backend for your platform was enabled!")
    endif()

    # linux
    option(MINIAUDIO_ENABLE_PIPEWIRE "" ON)
    # // TODO when pipewire backend will be mature enough to use, get rid of this
    option(MINIAUDIO_ENABLE_PULSEAUDIO "" ON)
    option(MINIAUDIO_ENABLE_ALSA "" ON)
    # windows
    option(MINIAUDIO_ENABLE_WASAPI "" ON)
    # android
    option(MINIAUDIO_ENABLE_AAUDIO "" ON)
    option(MINIAUDIO_ENABLE_OPENSL "" ON)
    # apple
    option(MINIAUDIO_ENABLE_COREAUDIO "" ON)
endif()

add_subdirectory(external/miniaudio/ EXCLUDE_FROM_ALL)

if(EMSCRIPTEN)
    target_compile_options(miniaudio PRIVATE -sWASM_WORKERS -Wno-c23-extensions -Wno-unknown-warning-option)
    target_compile_definitions(miniaudio PUBLIC MA_ENABLE_AUDIO_WORKLETS)
elseif(MSVC)
else()
    target_compile_options(miniaudio PUBLIC -fPIC)
endif()

target_link_libraries(${MAIN_LIB} miniaudio)


### compile emscripten into the JS+WASM lib ###

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
        COMMAND ${CMAKE_COMMAND} -E echo "Using locateFile in ${MAIN_LIB}.js"
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/modify_js.cmake
        WORKING_DIRECTORY ${WEB_OUT_DIR}
        COMMENT "Post-processing ${MAIN_LIB}.js"
    )
endif()


### ###

if(ANDROID)
    target_link_libraries(${MAIN_LIB} log)
endif()
