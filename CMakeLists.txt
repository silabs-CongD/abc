cmake_minimum_required(VERSION 3.15)
project(hello)

add_library(hello src/hello.cpp)
target_include_directories(hello PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

install(TARGETS hello
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin)
install(DIRECTORY src/ DESTINATION include FILES_MATCHING PATTERN "*.h")
