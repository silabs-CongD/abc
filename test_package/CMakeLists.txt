cmake_minimum_required(VERSION 3.15)
project(test_package)

find_package(hello REQUIRED CONFIG)

add_executable(example example.cpp)
target_link_libraries(example hello::hello)
