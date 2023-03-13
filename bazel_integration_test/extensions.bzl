"""Extensions for bzlmod."""

load(
    "//bazel_integration_test/private:bazel_binaries.bzl",
    _bazel_binary_repo_rule = "bazel_binary",
)
load("//bazel_integration_test/private:no_deps_utils.bzl", "no_deps_utils")

def _declare_bazel_binary(download):
    if download.version != "" and download.version_file != None:
        fail("""\
A bazel_binary.download can only have one of the following: \
version, version_file.\
""")
    if download.version != "":
        _bazel_binary_repo_rule(
            name = no_deps_utils.bazel_binary_repo_name(download.version),
            version = download.version,
        )
    else:
        _bazel_binary_repo_rule(
            name = no_deps_utils.bazel_binary_repo_name(str(download.version_file)),
            version_file = download.version_file,
        )

def _bazel_binary_impl(module_ctx):
    bazel_versions = []
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            _declare_bazel_binary(download)

_download = tag_class(
    attrs = {
        "version": attr.string(
            doc = """\
The Bazel version to download as a valid Bazel semantic version string.\
""",
        ),
        "version_file": attr.label(
            allow_single_file = True,
            doc = """\
A file (e.g., `//:.bazelversion`) that contains a valid Bazel semantic version \
string.\
""",
        ),
    },
)

bazel_binary = module_extension(
    implementation = _bazel_binary_impl,
    tag_classes = {"download": _download},
)
