#!/bin/sh

eval "$(shellspec - -c) exit 1"

Context "basic"
  Parameters:matrix
    -static -
  End
  Example "C $1 test" c
    When call test_program hello.c
    The output should equal "hello"
    The status should be success
  End
  Example "C source $1 test with C++ compiler" c++
    When call test_program -x c++ hello.c
    The output should equal "hello"
    The status should be success
  End
  Example "C++ $1 test" c++
    When call test_program hello.cpp
    The output should equal "hello"
    The status should be success
  End
  Example "FORTRAN $1 test" fortran
    When call test_program hello.f90
    The output should equal "hello"
    The status should be success
  End
End