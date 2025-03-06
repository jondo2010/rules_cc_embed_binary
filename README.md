# rules_cc_embed_binary

Bazel rule to embed arbitrary static binary data into an object file, suitable for linking with other cc rules.

## Usage

Add the following to `MODULE.bazel`:

```py
bazel_dep(name="rules_cc_embed_binary", version="0.1.0")
```

Then in your `BUILD` file:
```py
load("@rules_cc_embed_binary//embed_binary:defs.bzl", "cc_embed_binary")

cc_embed_binary(
    name = "embedded_data",
    src = "my_data.bin",
)

cc_test(
    name = "test",
    srcs = [..],
    deps = [":embedded_data"],
)
```

## Example

See the `test` directory in this repo.