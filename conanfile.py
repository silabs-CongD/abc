from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout

from conan.tools.files import copy
import os


class HelloConan(ConanFile):
    name = "hello"
    version = "0.1"
    settings = "os", "compiler", "build_type", "arch"
    exports_sources = "src/*", "include/*", "CMakeLists.txt"
    generators = "CMakeToolchain", "CMakeDeps"


    def layout(self):
        cmake_layout(self)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "*.h", dst=os.path.join(self.package_folder, "include"), src=os.path.join(self.source_folder, "include"))
        copy(self, "*.lib", dst=os.path.join(self.package_folder, "lib"), src=self.build_folder, keep_path=False)
        copy(self, "*.a", dst=os.path.join(self.package_folder, "lib"), src=self.build_folder, keep_path=False)
        copy(self, "*.so", dst=os.path.join(self.package_folder, "lib"), src=self.build_folder, keep_path=False)
        copy(self, "*.dylib*", dst=os.path.join(self.package_folder, "lib"), src=self.build_folder, keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["hello"]
