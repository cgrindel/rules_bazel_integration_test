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

assertions_lib="$(rlocation cgrindel_rules_bazel_integration_test/tools/assertions.sh)"
source "${assertions_lib}"

common_lib="$(rlocation cgrindel_rules_bazel_integration_test/tools/common.sh)"
source "${common_lib}"

target_dir="foo"
target_file="${target_dir}/bar"

mkdir -p "${target_dir}"
touch "${target_file}"

normalized_dir="$(normalize_path "${target_dir}")"
assert_equal "${PWD}/${target_dir}" "${normalized_dir}"

normalized_file="$(normalize_path "${target_file}")"
assert_equal "${PWD}/${target_file}" "${normalized_file}"