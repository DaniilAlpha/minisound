# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.28

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
CMAKE_SOURCE_DIR = /home/Daniil/_work/_projects/_flutter/minisound/minisound_ffi/src

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js

# Utility rule file for minisound_web_js.

# Include any custom commands dependencies for this target.
include CMakeFiles/minisound_web_js.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/minisound_web_js.dir/progress.make

CMakeFiles/minisound_web_js:
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Copying js sources."
	/usr/bin/cmake -E copy /home/Daniil/_work/_projects/_flutter/minisound/minisound_ffi/src/js/*.js /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js/

minisound_web_js: CMakeFiles/minisound_web_js
minisound_web_js: CMakeFiles/minisound_web_js.dir/build.make
.PHONY : minisound_web_js

# Rule to build all files generated by this target.
CMakeFiles/minisound_web_js.dir/build: minisound_web_js
.PHONY : CMakeFiles/minisound_web_js.dir/build

CMakeFiles/minisound_web_js.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/minisound_web_js.dir/cmake_clean.cmake
.PHONY : CMakeFiles/minisound_web_js.dir/clean

CMakeFiles/minisound_web_js.dir/depend:
	cd /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/Daniil/_work/_projects/_flutter/minisound/minisound_ffi/src /home/Daniil/_work/_projects/_flutter/minisound/minisound_ffi/src /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js /home/Daniil/_work/_projects/_flutter/minisound/minisound_web/lib/js/CMakeFiles/minisound_web_js.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : CMakeFiles/minisound_web_js.dir/depend

