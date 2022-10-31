# Install script for directory: /home/xeder/simulavr/libsim

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/xeder/simulavr/build/install/usr")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/xeder/simulavr/build/libsim/libsim.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsim.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/xeder/simulavr/include/adcpin.h"
    "/home/xeder/simulavr/include/application.h"
    "/home/xeder/simulavr/include/at4433.h"
    "/home/xeder/simulavr/include/at8515.h"
    "/home/xeder/simulavr/include/at90canbase.h"
    "/home/xeder/simulavr/include/atmega128.h"
    "/home/xeder/simulavr/include/atmega1284abase.h"
    "/home/xeder/simulavr/include/atmega16_32.h"
    "/home/xeder/simulavr/include/atmega2560base.h"
    "/home/xeder/simulavr/include/atmega668base.h"
    "/home/xeder/simulavr/include/atmega8.h"
    "/home/xeder/simulavr/include/attiny2313.h"
    "/home/xeder/simulavr/include/attiny25_45_85.h"
    "/home/xeder/simulavr/include/avrdevice.h"
    "/home/xeder/simulavr/include/avrerror.h"
    "/home/xeder/simulavr/include/avrfactory.h"
    "/home/xeder/simulavr/include/avrmalloc.h"
    "/home/xeder/simulavr/include/avrreadelf.h"
    "/home/xeder/simulavr/include/avrsignature.h"
    "/home/xeder/simulavr/include/config.h"
    "/home/xeder/simulavr/include/decoder.h"
    "/home/xeder/simulavr/include/externalirq.h"
    "/home/xeder/simulavr/include/externaltype.h"
    "/home/xeder/simulavr/include/flash.h"
    "/home/xeder/simulavr/include/flashprog.h"
    "/home/xeder/simulavr/include/funktor.h"
    "/home/xeder/simulavr/include/hardware.h"
    "/home/xeder/simulavr/include/helper.h"
    "/home/xeder/simulavr/include/hwacomp.h"
    "/home/xeder/simulavr/include/hwad.h"
    "/home/xeder/simulavr/include/hwdecls.h"
    "/home/xeder/simulavr/include/hweeprom.h"
    "/home/xeder/simulavr/include/hwpinchange.h"
    "/home/xeder/simulavr/include/hwport.h"
    "/home/xeder/simulavr/include/hwspi.h"
    "/home/xeder/simulavr/include/hwsreg.h"
    "/home/xeder/simulavr/include/hwstack.h"
    "/home/xeder/simulavr/include/hwuart.h"
    "/home/xeder/simulavr/include/hwusi.h"
    "/home/xeder/simulavr/include/hwwado.h"
    "/home/xeder/simulavr/include/ioregs.h"
    "/home/xeder/simulavr/include/irqsystem.h"
    "/home/xeder/simulavr/include/memory.h"
    "/home/xeder/simulavr/include/net.h"
    "/home/xeder/simulavr/include/pin.h"
    "/home/xeder/simulavr/include/pinatport.h"
    "/home/xeder/simulavr/include/pinmon.h"
    "/home/xeder/simulavr/include/pinnotify.h"
    "/home/xeder/simulavr/include/printable.h"
    "/home/xeder/simulavr/include/rwmem.h"
    "/home/xeder/simulavr/include/simulationmember.h"
    "/home/xeder/simulavr/include/specialmem.h"
    "/home/xeder/simulavr/include/spisink.h"
    "/home/xeder/simulavr/include/spisrc.h"
    "/home/xeder/simulavr/include/string2.h"
    "/home/xeder/simulavr/include/string2_template.h"
    "/home/xeder/simulavr/include/systemclock.h"
    "/home/xeder/simulavr/include/systemclocktypes.h"
    "/home/xeder/simulavr/include/traceval.h"
    "/home/xeder/simulavr/include/types.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/hwtimer" TYPE FILE FILES
    "/home/xeder/simulavr/include/hwtimer/hwtimer.h"
    "/home/xeder/simulavr/include/hwtimer/icapturesrc.h"
    "/home/xeder/simulavr/include/hwtimer/prescalermux.h"
    "/home/xeder/simulavr/include/hwtimer/timerirq.h"
    "/home/xeder/simulavr/include/hwtimer/timerprescaler.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/gdb" TYPE FILE FILES "/home/xeder/simulavr/include/gdb/gdb.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ui" TYPE FILE FILES
    "/home/xeder/simulavr/include/ui/extpin.h"
    "/home/xeder/simulavr/include/ui/keyboard.h"
    "/home/xeder/simulavr/include/ui/keytrans.h"
    "/home/xeder/simulavr/include/ui/lcd.h"
    "/home/xeder/simulavr/include/ui/mysocket.h"
    "/home/xeder/simulavr/include/ui/scope.h"
    "/home/xeder/simulavr/include/ui/serialrx.h"
    "/home/xeder/simulavr/include/ui/serialtx.h"
    "/home/xeder/simulavr/include/ui/tracecontrol.h"
    "/home/xeder/simulavr/include/ui/ui.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/cmd" TYPE FILE FILES "/home/xeder/simulavr/include/cmd/dumpargs.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/elfio/elfio" TYPE FILE FILES
    "/home/xeder/simulavr/include/elfio/elfio/elf_types.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_dump.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_dynamic.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_header.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_note.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_relocation.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_section.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_segment.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_strings.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_symbols.hpp"
    "/home/xeder/simulavr/include/elfio/elfio/elfio_utils.hpp"
    )
endif()

