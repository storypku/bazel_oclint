# Integrated Test for Bazel-OCLint on X-Compilation

## Run Bazel-OCLint

```
bazel build --config=oclint --config=j5_cross //src:hello
```

will fail with error:

```
Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
ERROR: Running OCLint failed, ret=6
ERROR: OCLint exit codes:
ERROR:   0 - SUCCESS
ERROR:   1 - RULE_NOT_FOUND
ERROR:   2 - REPORTER_NOT_FOUND
ERROR:   3 - ERROR_WHILE_PROCESSING
ERROR:   4 - ERROR_WHILE_REPORTING
ERROR:   5 - VIOLATIONS_EXCEED_THRESHOLD
ERROR:   6 - COMPILATION_ERRORS
Aspect //:oclint.bzl%my_oclint_aspect of //src:hello failed to build
```

## Run OCLint directly

```
oclint src/hello.cc  -- --target=aarch64-unknown-linux-gnu -U_FORTIFY_SOURCE -fstack-protector \
    -fno-omit-frame-pointer -fcolor-diagnostics -Wall -Wthread-safety -Wself-assign -std=c++17 \
    -stdlib=libstdc++ --sysroot=external/chromium_sysroot_linux_aarch64 -x c++
```

will generate OCLint report successfully.


