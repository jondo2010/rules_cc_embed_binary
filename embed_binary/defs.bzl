"""Bazel rule to embeds an input binary file into a C/C++ object file."""

load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cpp_toolchain", "use_cc_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")

DISABLED_FEATURES = []

def _sanitize_symbol_name(ctx):
    # Replace non-alphanumeric characters with underscores and ensure unique names
    package_path = ctx.label.package.replace("/", "_").replace("-", "_")
    name = ctx.attr.name.replace("-", "_")
    return "_binary_" + package_path + "_" + name

def _embed_binary_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    symbol_name = _sanitize_symbol_name(ctx)

    hdr_file = ctx.actions.declare_file("_" + ctx.attr.name + ".h")
    asm_file = ctx.actions.declare_file("_" + ctx.attr.name + ".S")

    ctx.actions.expand_template(
        template = ctx.file.hdr_template,
        output = hdr_file,
        substitutions = {
            "{alias}": ctx.attr.name.replace("-", "_"),
            "{symbol}": symbol_name,
        },
    )

    ctx.actions.expand_template(
        template = ctx.file.asm_template,
        output = asm_file,
        substitutions = {
            "{src}": ctx.file.src.short_path,
            "{symbol}": symbol_name,
        },
    )

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )

    compilation_ctx, compilation_outputs = cc_common.compile(
        actions = ctx.actions,
        cc_toolchain = cc_toolchain,
        name = "_" + ctx.attr.name,
        feature_configuration = feature_configuration,
        srcs = [asm_file],
        public_hdrs = [hdr_file],
        additional_inputs = [ctx.file.src],
        ### Add the bin output folder to the "-I" include paths.
        ### This is already added as an "-iquote" include by the cpp toolchain, however the ".incbin" directive used by
        ### the linker only works with "-I" paths.
        includes = [ctx.configuration.bin_dir.path],
    )

    linking_ctx, _linking_outputs = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        name = "_" + ctx.attr.name,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
    )

    return [
        DefaultInfo(files = depset([
            asm_file,
            hdr_file,
        ])),
        CcInfo(
            compilation_context = compilation_ctx,
            linking_context = linking_ctx,
        ),
    ]

cc_embed_binary = rule(
    implementation = _embed_binary_impl,
    attrs = {
        "asm_template": attr.label(
            allow_single_file = True,
            default = "//embed_binary:asm_template.S",
            doc = "Template for the generated assembly file. Defaults to the standard assembly template.",
        ),
        "hdr_template": attr.label(
            allow_single_file = True,
            default = "//embed_binary:hdr_template.h.tpl",
            doc = "Template for the generated header file. Defaults to the standard header template.",
        ),
        "src": attr.label(
            allow_single_file = True,
            doc = "The binary file to embed into the output object file.",
            mandatory = True,
        ),
    },
    toolchains = use_cc_toolchain(),
    fragments = ["cpp"],
    doc = """Embeds a binary file into a C/C++ object file.

This rule takes a binary file and creates:
1. A header file declaring external symbols for accessing the embedded data
2. An assembly file containing the binary data
3. A compiled object file ready to be linked into a C/C++ binary

Example:
    cc_embed_binary(
        name = "embedded_data",
        src = "data.bin",
    )

    cc_binary(
        name = "my_program",
        srcs = ["main.cc"],
        deps = [":embedded_data"],
    )
""",
)
