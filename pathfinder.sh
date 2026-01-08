#!/bin/sh

set -e -u

print_executables() {

    DEDUP_PATH=$(printf '%s' "$PATH" |
           awk -v RS=: -v ORS=: '!($0 in seen) { seen[$0] = 1; print $0 }')

    old_ifs=$IFS
    IFS=: # Change the default character used to split a string to a colon ':'
    for PATHNAME in $DEDUP_PATH; do
        test -d "$PATHNAME" || continue # If $PATHNAME is not a directory, then continue to the next path name
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    done
    IFS=$old_ifs
}

main() {
    print_executables
}

main "$@"
