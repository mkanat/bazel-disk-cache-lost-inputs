#!/bin/bash
# Usage: ./repro.sh <remote executor address> [extra bazel flags]
#
# Run this twice, restarting the remote executor with an empty CAS before each
# run. The first run fills the disk cache and passes. The second run fails.
set -u
cd "$(dirname "$0")"

# Ignores rc files so that only the flags below apply.
bazel() { command bazel --ignore_all_rc_files --output_base="$PWD/output_base" "$@"; }

bazel clean
bazel test \
  --disk_cache="$PWD/disk_cache" \
  --remote_executor="$1" \
  --strategy=TestRunner=remote \
  '--modify_execution_info=^(?!TestRunner$).*=+no-remote' \
  --nocache_test_results \
  --norewind_lost_inputs \
  --experimental_remote_cache_eviction_retries=0 \
  "${@:2}" //:check_test
