load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_COMPILE_ACTION_NAME",
    "C_COMPILE_ACTION_NAME",
)
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

# Ref: https://bazel.build/reference/be/c-cpp#cc_library.srcs
_CPP_HEADER_EXTENSIONS = ["hh", "hxx", "hpp", "H"]
_C_OR_CPP_HEADER_EXTENSIONS = ["h"] + _CPP_HEADER_EXTENSIONS
_CPP_EXTENSIONS = ["cc", "cxx", "cpp", "C"] + _CPP_HEADER_EXTENSIONS

def is_cpp_target(srcs):
    if all([src.extension in _C_OR_CPP_HEADER_EXTENSIONS for src in srcs]):
        return True  # Assume header-only lib is C++
    return any([src.extension in _CPP_EXTENSIONS for src in srcs])

def rule_sources(ctx, genfile_included = False):
    srcs = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.attr.srcs:
            if genfile_included:
                srcs += src.files.to_list()
            else:
                srcs += [f for f in src.files.to_list() if f.is_source]
    if hasattr(ctx.rule.attr, "hdrs"):
        for hdr in ctx.rule.attr.hdrs:
            if genfile_included:
                srcs += [f for f in hdr.files.to_list() if f.is_source]
            else:
                srcs += hdr.files.to_list()
    return srcs

def toolchain_flags(ctx, is_cpp_target):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    user_compile_flags = ctx.fragments.cpp.copts
    if is_cpp_target:
        user_compile_flags += ctx.fragments.cpp.cxxopts
        action_name = CPP_COMPILE_ACTION_NAME
    else:
        user_compile_flags += ctx.fragments.cpp.conlyopts
        action_name = C_COMPILE_ACTION_NAME

    compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = user_compile_flags,
    )

    # See also: https://bazel.build/rules/lib/cc_common#create_compile_variables
    return cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = action_name,
        variables = compile_variables,
    )
