# shellcheck shell=sh

# buildspec 0.1.0
# https://github.com/okhlybov/buildspec

# Defining variables and functions here will affect all specfiles.
# Change shell options inside a function may cause different behavior,
# so it is better to set them here.
# set -eu

# This callback function will be invoked only once before loading specfiles.
buildspec_helper_precheck() {
  # Available functions: info, warn, error, abort, setenv, unsetenv
  # Available variables: VERSION, SHELL_TYPE, SHELL_VERSION
  : minimum_version "0.28.1"
}

# This callback function will be invoked after a specfile has been loaded.
buildspec_helper_loaded() {
  :
}

# This callback function will be invoked after core modules has been loaded.
buildspec_helper_configure() {
  # Available functions: import, before_each, after_each, before_all, after_all
  : import 'support/custom_matcher'
  export SHELLSPEC_TMPDIR=$(mktemp -d -p $SHELLSPEC_TMPDIR)
  trap "rm -rf $SHELLSPEC_TMPDIR" EXIT
}

#
test_program() {
  program=$(build_program $*) && $(program_launcher $program $*)
}

#
build_program() {
  compiler=$(source_compiler $*)
  cflags=$(pkg_config_cflags $*)
  ldflags=$(pkg_config_ldflags $*)
  case $(uname -s) in
    CYGWIN*|MSYS*|MINGW*) exe=.exe ;;
    *) exe= ;;
  esac
  program="$SHELLSPEC_TMPDIR/$RANDOM$RANDOM$exe"
  while (( $# )); do
    case $1 in
      -p|--pkg) shift 2 ;;
      --xyz) shift 2 ;;
      --mpi) shift ;;
      -) shift ;;
      *) args+=" $1"; shift ;;
    esac
  done
  $compiler -o $program $cflags $args $ldflags && echo $program
}

#
program_launcher() {
  program=$1; shift
  case $(host_environment $*) in
    mpi) echo ${MPIEXEC-mpiexec} $program; exit ;;
    *) echo $program; exit ;;
  esac
}

#
source_compiler() {
  case $(host_environment $*) in
    mpi)
      case $(source_language $*) in
        c) echo ${MPICC-mpicc}; exit ;;
        cxx) echo ${MPICXX-mpicxx}; exit ;;
        fortran) echo ${MPIFORT-mpifort}; exit ;;
        *) echo "failed to derermine MPI compiler driver" >&2; exit -1 ;;
      esac
    ;;
    *)
      case $(source_language $*) in
        c) echo ${CC-cc}; exit ;;
        cxx) echo ${CXX-c++}; exit ;;
        fortran) 
          case $MINGW_PACKAGE_PREFIX in
            *-clang-*) echo ${FC-flang}; exit ;; # MSYS2's Clang is yet to have a FORTRAN compiler
            *) echo ${FC-gfortran}; exit ;; # No unbranded FORTRAN compiler name, settle on GFortran
          esac
        ;;
        *) echo "failed to derermine compiler" >&2; exit -1 ;;
      esac
    ;;
  esac
}

#
host_environment() {
  while (( $# )); do
    case $1 in
      --xyz)
        case $2 in
          ?m?) echo mpi; exit ;;
          ?t?) echo mt; exit ;;
          *) exit ;;
        esac
      ;;
      --mpi) echo mpi; exit ;;
      *) shift ;;
    esac
  done
}

#
source_language() {
  while (( $# )); do
    case $1 in
      -x)
        case $2 in
          f77*|f90*) echo fortran; exit ;;
          c) echo c; exit ;;
          c++) echo cxx; exit ;;
          *) exit ;;
        esac
      ;;
      -*) shift ;;
      *.c) echo c; exit ;;
      *.cc|*.CC|*.cpp|*.cxx) echo cxx; exit ;;
      *.[Ff]|*[Ff]9?) echo fortran; exit ;;
      *) shift ;;
    esac
  done
}

#
pkg_config_packages() {
  pkgs=
  while (( $# )); do
    case $1 in
      -p|--pkg) pkgs+=" $2"; shift 2 ;;
      *) shift ;;
    esac
  done
  echo $pkgs
}

#
pkg_config_cflags() {
  pcs=$(pkg_config_packages $*)
  if [ ! -z "$pcs" ]; then
    echo $(${PKG_CONFIG-pkg-config} $pcs --cflags)
  fi
}

#
pkg_config_ldflags() {
  pcs=$(pkg_config_packages $*)
  if [ ! -z "$pcs" ]; then
    flags="--libs"
    while (( $# )); do
      case $1 in
        -static) flags+=" --static"; shift ;;
        *) shift ;;
      esac
    done
    echo $(${PKG_CONFIG-pkg-config} $pcs $flags)
  fi
}