cmake_minimum_required(VERSION 3.15)
project(test_package)

find_package(mylib REQUIRED CONFIG)

add_executable(test_package test.cpp)
target_link_libraries(test_package mylib::mylib)
