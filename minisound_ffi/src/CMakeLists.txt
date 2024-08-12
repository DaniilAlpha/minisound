# Setup
cmake_minimum_required(VERSION 3.5)
project(minisound_ffi VERSION 1.0.0 LANGUAGES C)

# Specify the filename to search for
set(FILENAME ".projectroot")

# Function to check for file existence up the directory hierarchy
function(find_project_root current_dir filename result_var)
    set(found FALSE)  # Flag to indicate if the file is found
    set(current_check_dir "${current_dir}")  # Start from the given directory

    # Windows flutter embeds 8 levels deep
    foreach(i RANGE 0 8)
        set(filepath "${current_check_dir}/${filename}")

        if(EXISTS "${filepath}")
            set(${result_var} "${current_check_dir}" PARENT_SCOPE)
            set(found TRUE)
            break()
        endif()

        # Move one level up
        get_filename_component(current_check_dir "${current_check_dir}" DIRECTORY)
    endforeach()

    if(NOT found)
        set(${result_var} "" PARENT_SCOPE)  # Set to empty if not found
    endif()
endfunction()

# Call the function to find the project root
find_project_root("${CMAKE_CURRENT_SOURCE_DIR}" "${FILENAME}" TARGET_FILE_PATH)

# Check if the target file path was found
if(TARGET_FILE_PATH)
    message(STATUS "Project root found at ${TARGET_FILE_PATH}")
else()
    message(FATAL_ERROR "File ${FILENAME} not found within 2 levels up from ${CMAKE_CURRENT_SOURCE_DIR}")
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
set(WEB_OUTPUT_DIR ${TARGET_FILE_PATH}/minisound_web/lib/build)

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
    ENGINE_MILO_LVL=MILO_LVL_NONE
    GENERATOR_MILO_LVL=MILO_LVL_NONE
    RECORDER_MILO_LVL=MILO_LVL_NONE
    SOUND_MILO_LVL=MILO_LVL_NONE
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
    )
elseif(APPLE)
    target_compile_definitions(${MAIN_LIB} PUBLIC MA_ENABLE_COREAUDIO)
elseif(UNIX)
    target_compile_definitions(${MAIN_LIB} PUBLIC
        MA_ENABLE_JACK
        MA_ENABLE_PULSEAUDIO
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
    target_compile_options(${MAIN_LIB} PUBLIC -O0 -g)
    target_link_options(${MAIN_LIB} PUBLIC -O0 -g)
else()
    set_target_properties(${MAIN_LIB} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${WEB_OUTPUT_DIR}
    )
    target_compile_options(${MAIN_LIB} PUBLIC
        -O0
        -flto -fno-rtti
        -sWASM_WORKERS=1
    )
    set_target_properties(${MAIN_LIB} PROPERTIES LINK_FLAGS "\
        -O2 \
        -flto \
        -sEXPORTED_FUNCTIONS=_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall \
        -sALLOW_MEMORY_GROWTH -sMAXIMUM_MEMORY=1gb  \
        -sNO_DEFAULT_TO_CXX -sNO_TEXTDECODER -sFORCE_FILESYSTEM=1 -sNO_FETCH_SUPPORT_INDEXEDDB \
        -sAUDIO_WORKLET=1 -sWASM_WORKERS=1 -sASYNCIFY -sSTACK_SIZE=1mb \
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
        WORKING_DIRECTORY ${WEB_OUTPUT_DIR}
        COMMENT "Post-processing ${MAIN_LIB}.js"
    )
endif()

# Additional libs
if(ANDROID)
    target_link_libraries(${MAIN_LIB} OpenSLES log)
endif()
