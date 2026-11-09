# Disk cache outputs are lost inputs for remote execution

`gen` writes `gen.txt`, and `check_test` reads it. Every action except the
test runs locally and is cached in `--disk_cache`. The test runs on a remote
executor whose CAS starts empty.

Reproduced with Bazel 9.3.2 on Linux, using Bazel's own remote worker.

1. In a checkout of Bazel 9.3.2, build the remote worker:

   ```
   bazel build //src/tools/remote:worker
   ```

2. Start the worker with an empty CAS:

   ```
   rm -rf /tmp/worker && mkdir -p /tmp/worker/work /tmp/worker/cas
   bazel-bin/src/tools/remote/worker --listen_port=8980 \
     --work_path=/tmp/worker/work --cas_path=/tmp/worker/cas
   ```

3. In this repository, run `./repro.sh grpc://localhost:8980`. The test
   passes, and `gen.txt` is now in the disk cache.
4. Stop the worker, and start it again with an empty CAS, as in step 2.
5. Run `./repro.sh grpc://localhost:8980` again. `gen` is a disk cache hit,
   and the test fails:

   ```
   ERROR: BUILD.bazel:5:11: Testing //:check_test failed: Unexpected lost inputs (pass --rewind_lost_inputs to enable recovery): gen.txt
   ```

With `--remote_download_outputs=all` added to both runs, the test passes.

`repro.sh` passes `--norewind_lost_inputs` and
`--experimental_remote_cache_eviction_retries=0` so that the failure is
visible. Without them, Bazel rewinds and gets `gen.txt` from the disk cache
again, and the build passes.
