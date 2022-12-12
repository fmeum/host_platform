load("@host_platform//:constraints.bzl", "HOST_CONSTRAINTS")

def print_host_constraints():
    """Prints the constraints of the host platform."""
    print(HOST_CONSTRAINTS)
