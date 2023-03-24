load(":oclint.bzl", "oclint_aspect_impl")

def oclint_aspect_factory(
        config = Label("@bazel_oclint//:oclint_empty_config"),
        recursive = False):
    """
    Create an OCLint aspect.
    Args:
        recursive: If true, execute the aspect on all trannsitive dependencies.
                   If false, analyze only the target the aspect is being executed on.
    Returns:
        Configured DWYU aspect
    """
    attr_aspects = ["deps"] if recursive else []
    return aspect(
        implementation = oclint_aspect_impl,
        attr_aspects = attr_aspects,
        fragments = ["cpp"],
        toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
        attrs = {
            "_cc_toolchain": attr.label(
                default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            ),
            "_config": attr.label(
                default = config,
            ),
            "_oclint_wrapper": attr.label(
                default = Label("@bazel_oclint//src/oclint:run_oclint"),
                allow_files = True,
                executable = True,
                cfg = "exec",
            ),
            "_recursive": attr.bool(
                default = recursive,
            ),
        },
    )
