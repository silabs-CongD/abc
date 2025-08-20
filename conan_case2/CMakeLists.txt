
cmake_minimum_required(VERSION 3.15)
project(hello)

add_library(hello src/hello.cpp)
target_include_directories(hello PUBLIC include)
