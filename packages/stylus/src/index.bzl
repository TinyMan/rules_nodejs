"""
Support running the stylus processor as a Bazel rule.
"""

def _stylus_binary(ctx):
    src = ctx.file.src

    # We want foo.styl to produce foo.css
    output_name = src.basename[:-5] + ".css"
    css_output = ctx.actions.declare_file(output_name)
    map_output = ctx.actions.declare_file(output_name + ".map")
    ctx.actions.run(
        outputs = [css_output, map_output],
        inputs = [src] + ctx.files.deps,
        executable = ctx.executable._compiler,
        arguments = [
            "--sourcemap",
            "--out",
            ctx.bin_dir.path + "/" + ctx.label.package,
            src.path,
        ],
    )
    return [
        DefaultInfo(files = depset([css_output, map_output])),
    ]

stylus_binary = rule(
    implementation = _stylus_binary,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "deps": attr.label_list(
            allow_files = True,
        ),
        "_compiler": attr.label(
            default = Label("@npm//stylus/bin:stylus"),
            cfg = "host",
            executable = True,
        ),
    },
)