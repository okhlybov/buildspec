#!/bin/sh

eval "$(shellspec - -c) exit 1"

Context "basic"
  Parameters:matrix
    -static -
  End
  Example "C $1 test"
    When call test_program hello.c
    The status should be success
  End
  Example "C++ $1 test"
    When call test_program hello.cpp
    The status should be success
  End
  Example "FORTRAN $1 test"
    When call test_program hello.f90
    The status should be success
  End
End