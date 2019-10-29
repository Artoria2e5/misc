#!/bin/bash
# Download and save as /usr/local/bin/lib.exe
# Pretends to be lib.exe and generates import libs with genlib.exe from mingw-w64.
# CC-0

# Under msys2 it's mingw-w64-cross-tools-git.
# I don't know where it is under Cygwin, but they do not have dependencies and
# can be run from anywhere.
possible_genlibs=(
    genlib
    /opt/x86_64-w64-mingw32/bin/genlib
    /opt/i686-w64-mingw32/bin/genlib
    FAIL
)

for genlib in "${possible_genlibs[@]}"
    if command -v "$genlib" &>/dev/null; then
        break
    fi
done

oops() {
    printf '%b\n' "$1" >&2
}

oof() {
    oops "$1"
    exit "${2:-2}"
}

if [[ $genlib == FAIL ]]; then
    oof 'Cannot find mingw-w64 genlib in PATH or the usual MSYS2 /opt locations. Please fix your PATH.'
fi

args=()
file=()

declare -A machine_transl
machine_transl[x86]=x86
machine_transl[x64]=x86_64
machine_transl[arm]=arm
machine_transl[aarch64]=aarch64 # ? Not found in MachineOptions

# The -o option for basename is not handled. This will break.
for i; do
    # force lowercase (I know this breaks filenames BUT...)
    i=${i,,}
    case $i in
        (/nologo)
            ;;
        (/machine:*)
            mach=${i#/machine:}
            args+=(-a "${machine_transl[$mach]}") ;;
        (/def:*)
            # I am thinking it should be guessed and handled here.
            file[0]=("${i#/def:}") ;;
        (/out:*)
            file[1]=("${i#/out:}") ;;
        (*)
            oof "I don't recognize $1. Hope it still works.";;
    esac
done

run_with_a_bang() {
    printf 'Running: '
    printf '%q ' "$@"
    printf '\n'
    "$@"
}

run_with_a_bang "$genlib" "${args[@]}" -- "${file[@]}"
