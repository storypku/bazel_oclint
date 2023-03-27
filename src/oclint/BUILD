config_setting(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

config_setting(
    name = "linux_arm64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
)

sh_binary(
    name = "run_oclint",
    srcs = [
        "run_oclint.sh",
    ],
    data = select(
        {
            ":linux_arm64": ["@oclint_linux_arm64//:all_data"],
            ":linux_x86_64": ["@oclint_linux_amd64//:all_data"],
        },
        no_match_error = "Currently, only Linux x86_64 and arm64 are supported",
    ),
    visibility = ["//visibility:public"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
