def _verify_constraint_impl(ctx):
    if not ctx.target_platform_has_constraint(ctx.attr._detected_constraint[platform_common.ConstraintValueInfo]):
        fail("target platform does not contain @foo//:detected_constraint")
    if not ctx.target_platform_has_constraint(ctx.attr._main_repo_constraint[platform_common.ConstraintValueInfo]):
        fail("target platform does not contain //:main_repo_constraint")

verify_constraint = rule(
    implementation = _verify_constraint_impl,
    attrs = {
        "_detected_constraint": attr.label(default = "@foo//:detected_constraint"),
        "_main_repo_constraint": attr.label(default = "//:main_repo_constraint"),
    },
)
