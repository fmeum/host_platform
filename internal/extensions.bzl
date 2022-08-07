load(":utils.bzl", "create_constraints_repo_contents", "get_host_cpu_constraint", "get_host_os_constraint")

_add_constraints_tag = tag_class(
    attrs = {
        "bzl_file": attr.label(),
    },
)

def _host_platform_impl(module_ctx):
    module_to_bzl_label = {}
    for module in module_ctx.modules:
        if len(module.tags.add_constraints) > 1:
            fail("module '{}' declares multiple host_platform.add_constraints tags; may declare at most one".format(module.name))

        for tag in module.tags.add_constraints:
            module_to_bzl_label[module.name] = str(tag.bzl_file)

    _combined_constraints(
        name = "host_platform_constraints",
        constraints = module_to_bzl_label,
    )

host_platform = module_extension(
    implementation = _host_platform_impl,
    tag_classes = {
        "add_constraints": _add_constraints_tag,
    },
)

def _as_identifier(name):
    upper = name.upper()

    # RepositoryName#VALID_MODULE_NAME is "[a-z]([a-z0-9._-]*[a-z0-9])?"
    replaced = upper.replace("-", "_").replace(".", "_")
    if replaced == upper:
        return replaced
    return replaced + "_" + str(hash(upper))

def _combined_constraints_impl(repository_ctx):
    build_tpl = repository_ctx.path(Label("//internal:BUILD.bazel.tpl"))

    repository_ctx.file("WORKSPACE", executable = False)

    identifier_to_bzl_label = {
        _as_identifier(name): label
        for name, label in repository_ctx.attr.constraints.items()
    }

    loads = [
        "load(\"{label}\", {identifier}_HOST_CONSTRAINTS = \"HOST_CONSTRAINTS\")".format(
            label = label,
            identifier = identifier,
        )
        for identifier, label in identifier_to_bzl_label.items()
    ]
    constraints_vars = [
        "{}_HOST_CONSTRAINTS".format(identifier)
        for identifier in identifier_to_bzl_label.keys()
    ]

    bzl_lines = [
        "# DO NOT EDIT: automatically generated constraints list for local_config_platform",
        "# Auto-detected host platform constraints.",
    ] + loads + [
        "",
        "HOST_CONSTRAINTS = {}".format(" + ".join(constraints_vars)),
    ]
    repository_ctx.file("constraints.bzl", content = "\n".join(bzl_lines) + "\n", executable = False)

    bzl_files = [4 * " " + "\"{}\",\n" + 4 * " ".format(bzl_file) for bzl_file in identifier_to_bzl_label.values()]
    repository_ctx.template("BUILD.bazel", build_tpl, substitutions = {
        "%{bzl_files}": "".join(bzl_files),
    }, executable = False)

_combined_constraints = repository_rule(
    implementation = _combined_constraints_impl,
    attrs = {
        "constraints": attr.string_dict(),
    },
)

def _host_cpu_os_constraints_repo_impl(repository_ctx):
    constraints = [
        get_host_cpu_constraint(repository_ctx),
        get_host_os_constraint(repository_ctx),
    ]
    create_constraints_repo_contents(repository_ctx, [c for c in constraints if c])

_host_cpu_os_constraints_repo = repository_rule(
    implementation = _host_cpu_os_constraints_repo_impl,
)

def _host_cpu_os_constraints_impl(module_ctx):
    _host_cpu_os_constraints_repo(
        name = "host_cpu_os_constraints",
    )

host_cpu_os_constraints = module_extension(
    implementation = _host_cpu_os_constraints_impl,
)
