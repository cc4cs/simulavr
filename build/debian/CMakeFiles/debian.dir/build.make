# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.23

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/xeder/simulavr

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/xeder/simulavr/build

# Utility rule file for debian.

# Include any custom commands dependencies for this target.
include debian/CMakeFiles/debian.dir/compiler_depend.make

# Include the progress variables for this target.
include debian/CMakeFiles/debian.dir/progress.make

debian/CMakeFiles/debian: debian/libsim_1.1.0_amd64.deb
debian/CMakeFiles/debian: debian/simulavr_1.1.0_amd64.deb
debian/CMakeFiles/debian: debian/simulavr-dev_1.1.0_amd64.deb
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "build debian packages"

debian/libsim_1.1.0_amd64.deb:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating libsim_1.1.0_amd64.deb"
	cd /home/xeder/simulavr/build/debian && chmod 755 /home/xeder/simulavr/build/debian/mk_debian_package.sh
	cd /home/xeder/simulavr/build/debian && ./mk_debian_package.sh libsim

debian/simulavr-dev_1.1.0_amd64.deb:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Generating simulavr-dev_1.1.0_amd64.deb"
	cd /home/xeder/simulavr/build/debian && chmod 755 /home/xeder/simulavr/build/debian/mk_debian_package.sh
	cd /home/xeder/simulavr/build/debian && ./mk_debian_package.sh simulavr-dev

debian/simulavr_1.1.0_amd64.deb:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Generating simulavr_1.1.0_amd64.deb"
	cd /home/xeder/simulavr/build/debian && chmod 755 /home/xeder/simulavr/build/debian/mk_debian_package.sh
	cd /home/xeder/simulavr/build/debian && ./mk_debian_package.sh simulavr

debian: debian/CMakeFiles/debian
debian: debian/libsim_1.1.0_amd64.deb
debian: debian/simulavr-dev_1.1.0_amd64.deb
debian: debian/simulavr_1.1.0_amd64.deb
debian: debian/CMakeFiles/debian.dir/build.make
.PHONY : debian

# Rule to build all files generated by this target.
debian/CMakeFiles/debian.dir/build: debian
.PHONY : debian/CMakeFiles/debian.dir/build

debian/CMakeFiles/debian.dir/clean:
	cd /home/xeder/simulavr/build/debian && $(CMAKE_COMMAND) -P CMakeFiles/debian.dir/cmake_clean.cmake
.PHONY : debian/CMakeFiles/debian.dir/clean

debian/CMakeFiles/debian.dir/depend:
	cd /home/xeder/simulavr/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/xeder/simulavr /home/xeder/simulavr/debian /home/xeder/simulavr/build /home/xeder/simulavr/build/debian /home/xeder/simulavr/build/debian/CMakeFiles/debian.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : debian/CMakeFiles/debian.dir/depend

