load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "header_only",
    hdrs = ["header_only.h"],
)

cc_library(
    name = "foo",
    srcs = ["foo.cc"],
    hdrs = ["foo.h"],
)

cc_binary(
    name = "hello",
    srcs = ["hello.cc"],
    deps = [
        ":foo",
    ],
)

cc_binary(
    name = "pure_c",
    srcs = ["pure_c.c"],
)
