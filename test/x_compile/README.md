# Integration Test for Bazel-OCLint on X-Compilation

## Run Bazel-OCLint

```
bazel build --config=oclint --config=j5_cross //src:hello
```

## Run OCLint directly

```
oclint src/hello.cc  -- --target=aarch64-unknown-linux-gnu -U_FORTIFY_SOURCE -fstack-protector \
    -fno-omit-frame-pointer -fcolor-diagnostics -Wall -Wthread-safety -Wself-assign -std=c++17 \
    -stdlib=libstdc++ --sysroot=external/chromium_sysroot_linux_aarch64 -x c++
```


