cmake_minimum_required(VERSION 3.10.2)
project(fasttext_wrapper)

set(CMAKE_CXX_STANDARD 17)

file(GLOB FASTTEXT_SOURCES "fasttext/src/*.cc")

add_library(fasttext_wrapper SHARED
        fasttext_wrapper.cpp
        ${FASTTEXT_SOURCES}
)

target_include_directories(fasttext_wrapper PRIVATE "fasttext/src")