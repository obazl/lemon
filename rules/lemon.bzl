load("@bazel_skylib//lib:paths.bzl", "paths")

def _lemon_impl(ctx):

    (bn, ext) = paths.split_extension(ctx.file.yy.basename)

    out_c = ctx.actions.declare_file(bn + ".c")
    out_out = ctx.actions.declare_file(bn + ".out")

    exe = ctx.file._tool.path

    if (len(ctx.attr.defines) > 0):
        defs = "-D" + " -D".join(ctx.attr.defines)
    else:
        defs = ""

    if not ctx.attr.compress:
        compress = "-c"
    else:
        compress = ""

    cmd = "{lemon} {args} {yy} {compress} {defines} -T{template} -d{outdir}".format(
        lemon=exe, yy=ctx.file.yy.path,
        compress=compress,
        defines=defs,
        template=ctx.file.template.path,
        outdir=out_c.dirname,
        args = "-m"
    )

    ctx.actions.run_shell(
        inputs = [ctx.file.yy, ctx.file.template],
        outputs = ctx.outputs.outs,
        tools = [ctx.file._tool],
        command = cmd
    )

    return [DefaultInfo(files = depset(ctx.outputs.outs))]

#############
lemon = rule(
    implementation = _lemon_impl,
    attrs = {
        "yy": attr.label(
            allow_single_file = True,
            default = "syntaxis.y"
        ),
        "outs": attr.output_list( ),
        "compress": attr.bool(
            doc = "False: pass -c, do not compress action tables",
            default = True
        ),
        "defines": attr.string_list(
        ),
        "template": attr.label(
            allow_single_file =  True,
            default = "//bin:lempar.c"
        ),
        "_tool": attr.label(
            allow_single_file = True,
            default = "//bin:lemon",
            executable = True,
            cfg = "host"
        )
    }
)

