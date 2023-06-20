### setup ##############
cmake_minimum_required(VERSION 3.1)
project(minisound_ffi VERSION 1.0.0 LANGUAGES C)

# lib name
if(NOT EMSCRIPTEN)
set("MAIN_LIB" minisound_ffi)
else()
set("MAIN_LIB" minisound_web)
set("MAIN_JS" minisound_web_js)
endif()

# lib path
set("MAIN_PATH" ${CMAKE_CURRENT_SOURCE_DIR})
set("MAIN_OUT_PATH" ${CMAKE_CURRENT_BINARY_DIR})
########################


### main lib ###########
if(NOT EMSCRIPTEN)
add_library(${MAIN_LIB} SHARED)
else()
add_executable(${MAIN_LIB})
endif()

# sources
file(GLOB_RECURSE "MAIN_SOURCES" CONFIGURE_DEPENDS
    ${MAIN_PATH}/src/*.c
    ${MAIN_PATH}/external/*/src/*.c
)
target_sources(${MAIN_LIB} PUBLIC ${MAIN_SOURCES})

# includes
file(GLOB_RECURSE "MAIN_INCLUDES" CONFIGURE_DEPENDS LIST_DIRECTORIES TRUE
    ${MAIN_PATH}/external/*/include/
)
set("MAIN_INCLUDES" ${MAIN_INCLUDES} ${MAIN_PATH}/include/)
target_include_directories(${MAIN_LIB} PUBLIC ${MAIN_INCLUDES})

# dart ffi definitions
target_compile_definitions(${MAIN_LIB} PUBLIC DART_SHARED_LIB)

# milo definitions
target_compile_definitions(${MAIN_LIB} PUBLIC MILO_DEFAULT_LVL=MILO_LVL_INFO)

# miniaudio definitions
target_compile_definitions(${MAIN_LIB} PUBLIC
    MINIAUDIO_IMPLEMENTATION
    MA_ENABLE_ONLY_SPECIFIC_BACKENDS
    # MA_NO_RUNTIME_LINKING

    MA_NO_ENCODING
    MA_NO_GENERATION

    MA_DEBUG_OUTPUT
)
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
target_compile_definitions(${MAIN_LIB} PUBLIC MA_ENABLE_PULSEAUDIO MA_ENABLE_ALSA)
else()
message(FATAL_ERROR "No miniaudio backend specified for the platform.")
endif()

if(NOT EMSCRIPTEN)
set_target_properties(${MAIN_LIB} PROPERTIES
    PUBLIC_HEADER include/minisound.h
    OUTPUT_NAME ${MAIN_LIB}
)
else()
set_target_properties(${MAIN_LIB} PROPERTIES 
    RUNTIME_OUTPUT_DIRECTORY ${MAIN_OUT_PATH}/emscripten/ 
)
target_compile_options(${MAIN_LIB} PUBLIC 
    -pthread
    -O3 -g0
    -flto -fno-rtti -fno-exceptions
    -sNO_DEFAULT_TO_CXX
    -sWASM_WORKERS
)
set_target_properties(${MAIN_LIB} PROPERTIES LINK_FLAGS "\
    -pthread \
    -O3 -g0 \
    -flto \
    -sEXPORTED_FUNCTIONS=_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall \
    -sALLOW_MEMORY_GROWTH -sSTACK_SIZE=1mb -sMAXIMUM_MEMORY=256mb \
    -sNO_DEFAULT_TO_CXX -sNO_TEXTDECODER -sNO_FILESYSTEM -sNO_FETCH_SUPPORT_INDEXEDDB \
    -sAUDIO_WORKLET -sWASM_WORKERS -sASYNCIFY -sASYNCIFY_STACK_SIZE=16384 \
    -sSTACK_OVERFLOW_CHECK \
")
endif()
########################


### main js ############
if(EMSCRIPTEN)
add_custom_target(${MAIN_JS} ALL 
    COMMAND ${CMAKE_COMMAND} -E copy ${MAIN_PATH}/js/*.js ${MAIN_OUT_PATH}/
    COMMENT "Copying js sources."
)
add_dependencies(${MAIN_LIB} ${MAIN_JS})
endif()
########################


### additional libs ####
if(ANDROID)
target_link_libraries(${MAIN_LIB} OpenSLES log)
endif()
########################