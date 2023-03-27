load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def clean_dep(dep):
    return str(Label(dep))

def oclint_deps():
    maybe(
        http_archive,
        name = "oclint_linux_amd64",
        strip_prefix = "oclint-22.02",
        sha256 = "1b890b970aecc6607f1a1a4a2293f1f93e638583100ce0a13dcc7ff255109af3",
        build_file = clean_dep("//third_party:oclint.prebuilt.BUILD"),
        urls = [
            "https://qcraft-web.oss-cn-beijing.aliyuncs.com/cache/packages/oclint-22.02-x86_64-linux-ubuntu1804.tar.gz",
        ],
    )

