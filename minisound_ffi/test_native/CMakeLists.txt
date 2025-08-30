cmake_minimum_required(VERSION 3.11)
project(minisound_test VERSION 1.0.0 LANGUAGES C)


set(TEST minisound_test)
set(TEST_PATH ${CMAKE_CURRENT_SOURCE_DIR}/)


add_executable(${TEST})

file(GLOB_RECURSE TEST_SOURCES ${TEST_PATH}/src/*.c)
target_sources(${TEST} PRIVATE ${TEST_SOURCES})

target_include_directories(${TEST} PRIVATE external/miunte/)

set(COMPILE_AND_LINK_OPTS -Og -g -fsanitize=address,leak)
target_compile_options(${TEST} PRIVATE ${COMPILE_AND_LINK_OPTS})
target_link_options(${TEST} PRIVATE ${COMPILE_AND_LINK_OPTS})

add_subdirectory(../src/ ${CMAKE_CURRENT_BINARY_DIR}/minisound/)
target_link_libraries(${TEST} minisound_ffi)
