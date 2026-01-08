#!/bin/sh

print_executables() {
    IFS=: # Change the default character used to split a string to a colon ':'
    for PATHNAME in $(echo "$PATH" | sort | uniq); do
        test -d "$PATHNAME" || continue # If $PATHNAME is not a directory, then continue to the next path name
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    done
}

main() {
    print_executables
}

main
