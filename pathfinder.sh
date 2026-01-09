#!/bin/sh

set -e -u

PATH_TO_EXAMINE=$PATH

print_executables() {

    # Deduplicate entries, maintaining directory order
    PATH_TO_EXAMINE=$(printf '%s' "$PATH_TO_EXAMINE" |
                      awk -v RS=: -v ORS=: '!($0 in seen) { seen[$0] = 1; print $0 }')

    old_ifs=$IFS
    IFS=: # Change the default character used to split a string to a colon ':'
    for PATHNAME in $PATH_TO_EXAMINE; do
        test -d "$PATHNAME" || continue # If $PATHNAME is not a directory, then continue to the next path name
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    done
    IFS=$old_ifs # Reset to original IFS character
}

main() {
    while getopts "p:-:" opt; do
        case $opt in
            p) PATH_TO_EXAMINE=$OPTARG ;;
            ?) exit 1 ;;
        esac
    done
    print_executables
}

main "$@"
