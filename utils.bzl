load(
    "//internal:utils.bzl",
    _create_constraints_repo_contents = "create_constraints_repo_contents",
    _get_host_cpu_constraints = "get_host_cpu_constraint",
    _get_host_os_constraints = "get_host_os_constraint",
)

create_constraints_repo_contents = _create_constraints_repo_contents
get_host_cpu_constraints = _get_host_cpu_constraints
get_host_os_constraints = _get_host_os_constraints
