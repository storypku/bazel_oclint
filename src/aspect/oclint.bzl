load(
    ":cc_compile_helper.bzl",
    _toolchain_flags = "toolchain_flags",
    _is_cpp_target = "is_cpp_target",
    _rule_sources = "rule_sources",
)

def oclint_aspect_impl(target, ctx):
    if CcInfo not in target:
        return []

    srcs = _rule_sources(ctx, genfile_included = True)
    if not srcs:
        return []

    is_cpp = _is_cpp_target(srcs)

    compile_flags = _toolchain_flags(ctx, is_cpp)
    print("Target '{}': {}".format(str(target.label), compile_flags))

    
    return []
