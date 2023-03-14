"""Extensions for bzlmod."""

load(
    "//bazel_integration_test/private/bzlmod:bazel_binaries.bzl",
    _bazel_binaries = "bazel_binaries",
)

bazel_binaries = _bazel_binaries
