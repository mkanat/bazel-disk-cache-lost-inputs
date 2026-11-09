# Disk cache outputs are lost inputs for remote execution

`gen` writes `gen.txt`, and `check_test` reads it. Every action except the
test runs locally and is cached in `--disk_cache`. The test runs on a remote
executor whose CAS starts empty.

1. Start a remote execution server with an empty CAS, and run
   `./repro.sh <its address>`. The test passes.
2. Restart the server with an empty CAS, and run `./repro.sh <its address>`
   again. `gen` is a disk cache hit, and the test fails:

   ```
   ERROR: BUILD.bazel:5:11: Testing //:check_test failed: Unexpected lost inputs (pass --rewind_lost_inputs to enable recovery): gen.txt
   ```

With `./repro.sh <address> --remote_download_outputs=all`, step 2 passes.

`repro.sh` passes `--norewind_lost_inputs` and
`--experimental_remote_cache_eviction_retries=0` so the failure is visible.
Without them, Bazel rewinds and runs `gen` again, and the build passes.
