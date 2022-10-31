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

# Utility rule file for keytrans.

# Include any custom commands dependencies for this target.
include kbdgentables/CMakeFiles/keytrans.dir/compiler_depend.make

# Include the progress variables for this target.
include kbdgentables/CMakeFiles/keytrans.dir/progress.make

kbdgentables/CMakeFiles/keytrans: kbdgentables/keytrans.h
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "maintainance tool to create keytrans.h"

kbdgentables/keytrans.h: kbdgentables/kbdgentables
kbdgentables/keytrans.h: ../kbdgentables/keynumber_to_scancode.dat
kbdgentables/keytrans.h: ../kbdgentables/xcode_to_keynumber.dat
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating keytrans.h"
	cd /home/xeder/simulavr/build/kbdgentables && ./kbdgentables /home/xeder/simulavr/kbdgentables /home/xeder/simulavr/build/kbdgentables/keytrans.h

kbdgentables/kbdgentables: ../kbdgentables/kbdgentables.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/xeder/simulavr/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Generating kbdgentables"
	cd /home/xeder/simulavr/build/kbdgentables && g++ -o /home/xeder/simulavr/build/kbdgentables/kbdgentables -g -O2 -fPIC /home/xeder/simulavr/kbdgentables/kbdgentables.cpp

keytrans: kbdgentables/CMakeFiles/keytrans
keytrans: kbdgentables/kbdgentables
keytrans: kbdgentables/keytrans.h
keytrans: kbdgentables/CMakeFiles/keytrans.dir/build.make
.PHONY : keytrans

# Rule to build all files generated by this target.
kbdgentables/CMakeFiles/keytrans.dir/build: keytrans
.PHONY : kbdgentables/CMakeFiles/keytrans.dir/build

kbdgentables/CMakeFiles/keytrans.dir/clean:
	cd /home/xeder/simulavr/build/kbdgentables && $(CMAKE_COMMAND) -P CMakeFiles/keytrans.dir/cmake_clean.cmake
.PHONY : kbdgentables/CMakeFiles/keytrans.dir/clean

kbdgentables/CMakeFiles/keytrans.dir/depend:
	cd /home/xeder/simulavr/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/xeder/simulavr /home/xeder/simulavr/kbdgentables /home/xeder/simulavr/build /home/xeder/simulavr/build/kbdgentables /home/xeder/simulavr/build/kbdgentables/CMakeFiles/keytrans.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : kbdgentables/CMakeFiles/keytrans.dir/depend

