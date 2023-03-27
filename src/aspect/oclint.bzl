load(
    ":cc_compile_helper.bzl",
    _is_cpp_target = "is_cpp_target",
    _rule_sources = "rule_sources",
    _toolchain_flags = "toolchain_flags",
)

def _safe_flags(flags):
    # It seems that OCLint 22.02 support all these flags
    # unsupported_flags = [
    #    "-fno-canonical-system-headers",
    #    "-fstack-usage",
    # ]
    # return [f for f in flags if f not in unsupported_flags]
    return flags

def _run_oclint(ctx, oclint_wrapper, oclint_config, compile_flags, target, srcs):
    compilation_context = target[CcInfo].compilation_context

    outfile = ctx.actions.declare_file(
        "{}.oclint.json".format(target.label.name),
    )

    args = ctx.actions.args()
    args.add(outfile)
    args.add(target.label)
    args.add_all(srcs)
    args.add("--")
    args.add_all(compile_flags)

    # add defines
    for define in compilation_context.defines.to_list():
        args.add("-D" + define)
    for define in compilation_context.local_defines.to_list():
        args.add("-D" + define)

    # add includes
    for i in compilation_context.includes.to_list():
        args.add("-I" + i)
    args.add_all(compilation_context.quote_includes.to_list(), before_each = "-iquote")
    args.add_all(compilation_context.system_includes.to_list(), before_each = "-isystem")

    inputs = depset(direct = srcs + oclint_config, transitive = [compilation_context.headers])
    ctx.actions.run(
        inputs = inputs,
        outputs = [outfile],
        executable = oclint_wrapper,
        arguments = [args],
        mnemonic = "OCLint",
        progress_message = "Run OCLint on {}".format(target.label),
        execution_requirements = {
            "no-sandbox": "1",
        },
    )
    return outfile

def oclint_aspect_impl(target, ctx):
    if CcInfo not in target:
        return []

    srcs = _rule_sources(ctx, genfile_included = True)
    if not srcs:
        return []

    is_cpp = _is_cpp_target(srcs)

    toolchain_flags = _toolchain_flags(ctx, is_cpp)

    rule_flags = ["-x", "c++"] if is_cpp else []
    if hasattr(ctx.rule.attr, "copts"):
        rule_flags.extend(ctx.rule.attr.copts)

    safe_flags = _safe_flags(toolchain_flags + rule_flags)

    oclint_wrapper = ctx.attr._oclint_wrapper.files_to_run
    oclint_config = ctx.attr._config.files.to_list()
    recursive = ctx.attr._recursive

    reports = [_run_oclint(ctx, oclint_wrapper, oclint_config, safe_flags, target, srcs)]

    if ctx.attr._recursive:
        transitive_reports = [dep[OutputGroupInfo].oclint_report for dep in ctx.rule.attr.deps]
    else:
        transitive_reports = []

    accumulated_reports = depset(direct = reports, transitive = transitive_reports)
    return [
        OutputGroupInfo(oclint_report = accumulated_reports),
    ]
