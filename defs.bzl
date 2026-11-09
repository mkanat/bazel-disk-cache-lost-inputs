def _gen_impl(ctx):
    out = ctx.actions.declare_file(ctx.attr.name + ".txt")
    ctx.actions.run_shell(outputs = [out], command = "echo hello > " + out.path)
    return [DefaultInfo(files = depset([out]), runfiles = ctx.runfiles(files = [out]))]

gen = rule(implementation = _gen_impl)

def _check_test_impl(ctx):
    script = ctx.actions.declare_file(ctx.attr.name + ".sh")
    ctx.actions.write(script, "#!/bin/sh\ncat gen.txt\n", is_executable = True)
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.attr.dep[DefaultInfo].default_runfiles,
    )]

check_test = rule(
    implementation = _check_test_impl,
    attrs = {"dep": attr.label()},
    test = True,
)
