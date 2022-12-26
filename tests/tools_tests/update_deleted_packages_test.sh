#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
source "${assertions_lib}"

update_bin="$(rlocation contrib_rules_bazel_integration_test/tools/update_deleted_packages.sh)"

starting_path="${PWD}"


# Set up the parent workspace
setup_test_workspace_sh_location=contrib_rules_bazel_integration_test/tests/tools_tests/setup_test_workspace.sh
setup_test_workspace_sh="$(rlocation "${setup_test_workspace_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_test_workspace_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/setup_test_workspace.sh
source "${setup_test_workspace_sh}"

# MARK - Variables

expected_with_change="
# BOF
build --deleted_packages=examples/child_a,examples/child_a/foo,somewhere_else/child_b/bar
query --deleted_packages=examples/child_a,examples/child_a/foo,somewhere_else/child_b/bar
# EOF"

reset_test_workspace() {
  cd "${starting_path}"
  reset_bazelrc_files
}

# MARK - Test Specifying Flags

# DEBUG BEGIN
echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") FIRST" 
# DEBUG END

# Execute specifying workspace flag
"${update_bin}" --workspace "${parent_dir}" --bazelrc "${parent_bazelrc}"

actual=$(< "${parent_bazelrc}")
assert_equal "${expected_with_change}" "${actual}"

for child_bazelrc in "${child_bazelrcs[@]}" ; do
  actual=$(< "${child_bazelrc}")
  assert_equal "${bazelrc_template}" "${actual}"
done

# MARK - Reset Workspace

reset_test_workspace

# MARK - Test From Outside Workspace with BUILD_WORKSPACE_DIRECTORY

# Set up fake Bazel output
fake_bazel_output_dir="${starting_path}/fake_bazel_out"
mkdir -p "${fake_bazel_output_dir}"
cd "${fake_bazel_output_dir}"

# Set the BUILD_WORKSPACE_DIRECTORY
export BUILD_WORKSPACE_DIRECTORY="${examples_dir}"

# Execute the update
"${update_bin}" 

actual=$(< "${parent_bazelrc}")
assert_equal "${expected_with_change}" "${actual}"

for child_bazelrc in "${child_bazelrcs[@]}" ; do
  actual=$(< "${child_bazelrc}")
  assert_equal "${bazelrc_template}" "${actual}"
done

# Unset the BUILD_WORKSPACE_DIRECTORY
unset BUILD_WORKSPACE_DIRECTORY

