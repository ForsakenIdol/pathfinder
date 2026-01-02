#!/bin/sh

for PATHNAME in $(echo "$PATH" | tr ":" "\n" | sort | uniq); do
    if test -d "$PATHNAME"; then
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    fi
done
