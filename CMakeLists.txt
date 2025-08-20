cmake_minimum_required(VERSION 3.15)
project(mylib)

add_library(mylib src/mylib.cpp)
target_include_directories(mylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
