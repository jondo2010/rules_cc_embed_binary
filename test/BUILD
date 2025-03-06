load("@rules_cc//cc:defs.bzl", "cc_test")
load("//embed_binary:defs.bzl", "cc_embed_binary")

TEST_STRING = "reproducible_string"

# Generate a test input file to embed.
genrule(
    name = "data_bin",
    outs = ["data.bin"],
    cmd = "echo -n {} > $@".format(TEST_STRING),
)

cc_embed_binary(
    name = "data",
    src = ":data_bin",
)

cc_test(
    name = "test",
    size = "small",
    srcs = ["test.cc"],
    defines = ["__TEST_STRING__=\\\"{}\\\"".format(TEST_STRING)],
    tags = ["unit_test"],
    deps = [":data"],
)
