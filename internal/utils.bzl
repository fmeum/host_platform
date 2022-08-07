def get_host_cpu_constraint(repository_ctx):
    cpu = _JAVA_OS_ARCH_TO_CPU.get(repository_ctx.os.arch)
    if not cpu:
        return None
    return Label("@platforms//cpu:" + cpu)

def get_host_os_constraint(repository_ctx):
    host_java_os_name = repository_ctx.os.name
    for java_os_name, os in _JAVA_OS_NAME_TO_OS.items():
        if host_java_os_name.startswith(java_os_name.lower()):
            return Label("@platforms//os:" + os)
    return None

def create_constraints_repo_contents(repository_ctx, constraints):
    for constraint in constraints:
        if type(constraint) != _LABEL_TYPE:
            fail("in constraints: want type Label, got '{}' of type {}".format(constraint, type(constraint)))

    repository_ctx.file("WORKSPACE", executable = False)
    repository_ctx.file("BUILD.bazel", "exports_files([\"constraints.bzl\"])", executable = False)

    bzl_lines = [
        "# DO NOT EDIT: automatically generated constraints list for local_config_platform",
        "# Auto-detected host platform constraints.",
        "HOST_CONSTRAINTS = [",
    ] + [
        "    \"{}\",".format(constraint)
        for constraint in constraints
    ] + [
        "]",
    ]
    repository_ctx.file("constraints.bzl", content = "\n".join(bzl_lines) + "\n", executable = False)

# Taken from
# https://cs.opensource.google/bazel/bazel/+/fe7deabfa094e35a63b83e7912efeb8097c71bc8:src/main/java/com/google/devtools/build/lib/util/CPU.java;l=24
_CPU_TO_JAVA_OS_ARCH_VALUES = {
    "x86_32": ["i386", "i486", "i586", "i686", "i786", "x86"],
    "x86_64": ["amd64", "x86_64", "x64"],
    "ppc": ["ppc", "ppc64", "ppc64le"],
    "arm": ["arm", "armv7l"],
    "aarch64": ["aarch64"],
    "s390x": ["s390x", "s390"],
    "mips64": ["mips64el", "mips64"],
    "riscv64": ["riscv64"],
}

_JAVA_OS_ARCH_TO_CPU = {
    os_arch: cpu
    for cpu, os_arch_values in _CPU_TO_JAVA_OS_ARCH_VALUES.items()
    for os_arch in os_arch_values
}

# Taken from
# https://cs.opensource.google/bazel/bazel/+/fe7deabfa094e35a63b83e7912efeb8097c71bc8:src/main/java/com/google/devtools/build/lib/util/OS.java;l=22
_JAVA_OS_NAME_TO_OS = {
    "Mac OS X": "osx",
    "FreeBSD": "freebsd",
    "OpenBSD": "openbsd",
    "Linux": "linux",
    "Windows": "windows",
}

_LABEL_TYPE = type(Label("//:BUILD.bazel"))
