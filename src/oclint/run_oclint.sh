#! /bin/bash

# Ref: https://github.com/bazelbuild/bazel/blob/d2750262695b1cef7365e5491711ce411cd85215/tools/bash/runfiles/runfiles.bash
# Stack Overflow: https://stackoverflow.com/questions/53472993/how-do-i-make-a-bazel-sh-binary-TARGET-depend-on-other-binary-TARGETs

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v2 ---

function warning() {
  echo >&2 -e "\033[33mWARNING: $*\033[0m"
}

function error() {
  echo >&2 -e "\033[0;31mERROR: $*\033[0m"
}

function info() {
  echo >&2 -e "\033[32mINFO: $*\033[0m"
}

function print_report() {
  echo -e "\n====================================================="
  jq . "$1"
  echo -e "\n====================================================="
}

ARCH="$(uname -m)"

if [[ "${ARCH}" == "x86_64" ]]; then
  OCLINT_BINARY="$(rlocation oclint_linux_amd64/bin/oclint)"
elif [[ "${ARCH}" == "aarch64" ]]; then
  OCLINT_BINARY="$(rlocation oclint_linux_arm64/bin/oclint)"
else
  OCLINT_BINARY="oclint"
fi

function main() {
  SRCS=()

  OUTFILE="$1"
  TARGET="$2"
  shift 2

  for arg in "$@"; do
    if [[ "${arg}" == "--" ]]; then
      break
    else
      SRCS+=("${arg}")
    fi
  done

  num_shift=$((${#SRCS[@]} + 1))
  shift "${num_shift}"

  if "${OCLINT_BINARY}" "${SRCS[@]}" --report-type json -o "${OUTFILE}" -- "$@"; then
    violations="$(jq .summary.numberOfFilesWithViolations "${OUTFILE}")"
    if [[ "${violations}" -gt 0 ]]; then
      warning "OCLint violation(s) found for '${TARGET}':"
      print_report "${OUTFILE}"
      exit 5
    else
      clang_sa="$(jq .clangStaticAnalyzer "${OUTFILE}")"
      if [[ "${clang_sa}" == "null" || "${clang_sa}" == "[]" ]]; then
        info "Great! No OCLint violations found for '${TARGET}'."
        exit 0
      else
        warning "OCLint violation(s) found for '${TARGET}':"
        print_report "${OUTFILE}"
        exit 5
      fi
    fi
  else
    retcode=$?
    error "Running OCLint failed, ret=${retcode}"
    error "${OCLINT_BINARY} ${SRCS[*]} --report-type json -o ${OUTFILE} -- $*"
    error "OCLint exit codes:"
    error "  0 - SUCCESS"
    error "  1 - RULE_NOT_FOUND"
    error "  2 - REPORTER_NOT_FOUND"
    error "  3 - ERROR_WHILE_PROCESSING"
    error "  4 - ERROR_WHILE_REPORTING"
    error "  5 - VIOLATIONS_EXCEED_THRESHOLD"
    error "  6 - COMPILATION_ERRORS"
    if [[ "${retcode}" -eq 5 ]]; then
      print_report "${OUTFILE}"
    fi
    exit "${retcode}"
  fi
}

main "$@"
