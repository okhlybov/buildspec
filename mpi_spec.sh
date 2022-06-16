#!/bin/sh

eval "$(shellspec - -c) exit 1"

Context "MPI"
  Parameters:matrix
    - -static
  End
  Example "C test $1" mpi c
    When call test_program --mpi $1 hello_mpi.c
    The output should match pattern "*"
    The status should be success
  End
  Example "C++ test $1" mpi c++
    When call test_program --mpi $1 hello_mpi.cpp
    The output should match pattern "*"
    The status should be success
  End
  Example "FORTRAN test $1" mpi fortran
    When call test_program --mpi $1 hello_mpi.f90
    The output should match pattern "*"
    The status should be success
  End
End