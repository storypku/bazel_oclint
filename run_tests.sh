#! /bin/bash
CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
pushd "${CURR_DIR}/test/valid" > /dev/null
bazel build --config=oclint  --keep_going //src:hello //src:header_only //src:foo //src:pure_c
popd >/dev/null


