#! /usr/bin/env python
###############################################################################
#
# simulavr - A simulator for the Atmel AVR family of microcontrollers.
# Copyright (C) 2001, 2002  Theodore A. Roth
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
###############################################################################
#
# $Id: regress.py.in,v 1.1 2004/07/31 00:58:05 rivetwa Exp $
#

from __future__ import print_function
import os, os.path, sys

# This should let you run the regress.py.in script directly for testing.
if len('/home/xeder/simulavr/regress') == 0:
  srcdir = '.'
else:
  srcdir = '/home/xeder/simulavr/regress'

regressdir = os.getcwd()

# Change dir to srcdir so that building in other dir works
os.chdir(srcdir)

# Add modules dir to module search path
sys.path.append(os.path.join(srcdir, "modules"))

import fnmatch, glob
import time, socket, signal
import subprocess
import argparse

import avr_target, base_test

"""Main regression test driver program.

Test cases are organised into three levels: directories -> modules -> classes.
Directories are the most generic and classes are the most specific.

This program will search the current directory for subdirectories with names
matching 'test_*'. Each matching subdirectory will be searched for python
modules with names matching test_*.py. Each module will be loaded and the
attributes searched for classes with names beginning with 'test_'. Each class
will perform a single test and if the test fails, an exception derived from
base_test.TestFail is raised to indicate that the test has failed.

There can be many matches are each level.

"""

def read_args():
  p = argparse.ArgumentParser(description = "Run simulavr code regression test")
  p.add_argument("-d", "--dev", help = "device name", default = "atmega128")
  p.add_argument("-s", "--sim", help = "path to simulavr executable", required = True)
  p.add_argument("-o", "--out", help = "test result output file")
  p.add_argument("targs", help = "test arguments: [directory [module [name]]]", nargs = argparse.REMAINDER)
  res = p.parse_args()
  if len(res.targs) > 3: p.error("max 3 targs possible")
  return res

class OutputStream(object):

  def __init__(self, outname):
    self.__hdl = None
    if outname is not None: self.__hdl = open(outname, "w")
    
  def write(self, s):
    print(s, end = " ")
    if self.__hdl is not None: self.__hdl.write(s)
    
  def writeln(self, s):
    print(s)
    if self.__hdl is not None:
      self.__hdl.write(s)
      self.__hdl.write("\n")
    
  def close(self):
    if self.__hdl is not None: self.__hdl.close()

EXIT_STATUS_PASS = 0
EXIT_STATUS_FAIL = 1

def run_tests(ostream, target, tdir = None, tmodule = None, tname = None):
  result = EXIT_STATUS_PASS

  num_tests         = 0
  num_passes        = 0
  num_fails         = 0
  num_not_supported = 0

  start_time = sum(os.times()[:2])

  if tdir is None:
    test_dirs = glob.glob("test_*")
  else:
    if tdir[:5] != 'test_':
      tdir = 'test_'+tdir
    test_dirs = [tdir]

  for test_dir in test_dirs:
    if tmodule is None:
      try:
        test_modules = os.listdir(test_dir)
      except OSError:
        # problem getting dir listing, go to next dir
        continue
    else:
      if tmodule[:5] != 'test_':
        tmodule = 'test_'+tmodule
      if tmodule[-3:] != '.py':
        tmodule += '.py'
      test_modules = [tmodule]

    ostream.writeln('='*8 + ' running tests in %s directory' % (test_dir))
    # add tests dir to module search patch
    sys.path.append(test_dir)

    # Loop through all files in test dir
    for file in test_modules:
      # skip files which are not test modules (test modules are 'test_*.py')
      if not fnmatch.fnmatch(file, 'test_*.py'):
        continue

      # get test module name by stripping off .py from file name
      test_module_name = file[:-3]
      ostream.writeln('-'*4 + ' loading tests from %s module' % (test_module_name))
      test_module = __import__(test_module_name)

      if tname is None:
        test_names = dir(test_module)
      else:
        if tname[:5] != 'test_':
          tname = 'test_'+tname
        test_names = [tname]

      # Loop through all attributes of test_module
      for test_name in test_names:
        # If attribute is not a test case, skip it.
        if test_name[:5] != 'test_':
          continue

        try:
          # Create an instance of the test case object and run it
          test = getattr(test_module,test_name)(*(target,))
          ostream.write('%-30s  ->  ' % (test_name))
          test.run()
        except base_test.TestFail as reason:
          ostream.writeln('FAILED: {}'.format(reason))
          num_fails += 1
          # Could also do a sys.exit(1) here is user wishes
          result = EXIT_STATUS_FAIL
        except base_test.TestOpcodeNotSupported as reason:
          ostream.writeln("{}".format(reason))
          num_not_supported += 1
        else:
          num_passes += 1
          ostream.writeln('passed')

        num_tests += 1

        # reset the target after each test
        target.reset()

      test_names = None
    test_modules = None

    # remove test_dir from the module search path
    sys.path.remove(test_dir)

  elapsed = sum(os.times()[:2]) - start_time

  ostream.writeln("") 
  ostream.writeln('Ran %d tests in %.3f seconds [%0.3f tests/second].' % (num_tests, elapsed, num_tests/elapsed))
  ostream.writeln('  Number of Passing Tests: %d' % (num_passes))
  ostream.writeln('  Number of Failing Tests: %d' % (num_fails))
  ostream.writeln('  Number of Skipped Tests: %d (opcode not supported by target)' % (num_not_supported))
  ostream.writeln("")
  
  return result

def run_simulator(prog, dev, port=1212):
  """Attempt to start up a simulator and return pid.
  """

  # Check if prog file exists
  if not os.path.isfile(prog):
    sys.stderr.write('%s does not exist\n' % (prog))
    sys.exit(EXIT_STATUS_FAIL)

  out = os.open(regressdir+'/sim.out', os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
  err = os.open(regressdir+'/sim.err', os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
  p = subprocess.Popen((prog, '-g', '-G', '-d', dev, '-p', str(port)),
                       shell = False,
                       stdout = out,
                       stderr = err)

  return p
  
if __name__ == '__main__':

  # parse command line options
  cargs = read_args()

  # start simulavr
  sim_p = run_simulator(cargs.sim, cargs.dev)

  # open a connection to the target
  tries = 5
  while (tries > 0):
    try:
      target = avr_target.AvrTarget(cargs.dev)
    except socket.error:
      sys.stderr.write('Simulator not responding, wait a second and try again\n')
      tries -= 1
      time.sleep(1)
    else:
      break
  if tries == 0:
    sys.stderr.write('Fatal error: simulator did not start\n')
    sys.exit(EXIT_STATUS_FAIL)

  # run the tests
  try:
    ostream = OutputStream(cargs.out)
    status = run_tests(*[ostream, target]+cargs.targs)
  except Exception as e:
    sys.stderr.write("Exception occured while run tests: %s\n" % str(e))
  finally:
    # We always want to shut down the simulator
    target.close()
    ostream.close()
    
    # make sure that the simulator has quit
    sim_p.wait()

  if status == EXIT_STATUS_PASS:
     fhdl = open(cargs.out + ".success", "w")
     fhdl.write("success")
     fhdl.close()

  sys.exit(status)
