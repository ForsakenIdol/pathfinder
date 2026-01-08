#!/bin/sh

IFS=:
for PATHNAME in $(echo "$PATH" | sort | uniq); do
    if test -d "$PATHNAME"; then
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    fi
done
