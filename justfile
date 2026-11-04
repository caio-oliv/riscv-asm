set default-list
set unstable

build_path := 'build'

asm_file(name) := f'{{ name }}.s'
object_path(program) := f'{{ build_path }}/{{ program }}.o'
exec_path(program) := f'{{ build_path }}/{{ program }}'


_build_flags(profile) := if profile == "--debug" {
    "--target=riscv64 -march=rv64g -mcpu=generic-rv64 \
        -mno-relax -nostdlib -Wall --debug"
} else {
    "--target=riscv64 -march=rv64g -mcpu=generic-rv64 \
        -nostdlib -Wall"
}

_link_flags(profile) := if profile == "--debug" {
    "--nostdlib --static --pie"
} else {
    "--nostdlib --static --pie --strip-all"
}

@_mkbuild_path:
    mkdir --parents {{ build_path }}

alias b := build

[arg('profile', pattern="--debug|--release")]
@build program='sleep' profile='--debug': _mkbuild_path
    clang {{ _build_flags(profile) }} \
        --compile {{ asm_file(program) }} \
        --output {{ object_path(program) }}
    ld.lld {{ _link_flags(profile) }} \
        {{ object_path(program) }} \
        -o {{ exec_path(program) }}


[positional-arguments]
@run program='sleep': (build program)
    qemu-riscv64 {{ exec_path(program) }} "$@"


@clear:
    rm -rf {{ build_path }}
