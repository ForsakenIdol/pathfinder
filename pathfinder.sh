#!/bin/sh

set -e -u

DEDUPLICATE=true
SUMMARY_PER_DIRECTORY=false
EFFECTIVE_EXECUTABLES_ONLY=false

send_help() {
    cat << 'EOF'
Usage:
    -p, --path=PATH
        use a custom PATH value instead of the one set in the shell's environment
    -u
        do not dedupe PATH, keep duplicate directories if present
    -e, --effective
        for duplicate executables in multiple locations, keep only the effective one that will be used when the executable is called directly
    -r, --random
        output a random executable from the list
    -s, --summary
        print only the number of executables in each directory in PATH (summary mode); this flag is ignored when -e / --executable is set
    -h, --help
        display this help and exit
EOF
}

# Basic PATH validation
validate_path() {
    PATH_TO_VALIDATE=$1
    if [ -z "${PATH_TO_VALIDATE+x}" ] || [ -z "$PATH_TO_VALIDATE" ]; then
        echo "Error: PATH (or custom PATH) is empty or unset" >&2
        exit 1
    fi
}

print_executables() {
    PATH_TO_EXAMINE=$1
    validate_path "$PATH_TO_EXAMINE" # Validate PATH_TO_EXAMINE

    # Deduplicate entries, maintaining directory order, strip trailing colon if present
    if $DEDUPLICATE; then
        PATH_TO_EXAMINE=$(printf '%s' "$PATH_TO_EXAMINE" |
                          awk -v RS=: -v ORS=: '!($0 in seen) { seen[$0] = 1; print $0 }')
        PATH_TO_EXAMINE="${PATH_TO_EXAMINE%:}" # ${VAR%PATTERN} removes PATTERN from the end of VAR if present
    fi

    if [ "$EFFECTIVE_EXECUTABLES_ONLY" = true ]; then
        # Collect ALL the executables first, before identifying effective executables by basename
        old_ifs=$IFS
        IFS=:
        for PATHNAME in $PATH_TO_EXAMINE; do
            test -d "$PATHNAME" || continue
            find "$PATHNAME" -maxdepth 1 -type f -executable -print
        done | awk '
            {
                name_of_executable = substr($0, match($0, "/[^/]*$") + 1)
                if (!seen[name_of_executable]++) print $0
            }
        '
        # The awk statement above matches the last part of the executable, so it has only the executable's name
        # The +1 is to avoid the last forward slash '/' being part of the match
        # awk only prints the executable's full path if it hasn't seen that executable name before
        # This matches the behavior when Linux searches for a specific executable; it uses only the first one it finds
        IFS=$old_ifs
    else
        old_ifs=$IFS
        IFS=: # Change the default character used to split a string to a colon ':'
        for PATHNAME in $PATH_TO_EXAMINE; do
            test -d "$PATHNAME" || continue # If $PATHNAME is not a directory, then continue to the next path name
            if $SUMMARY_PER_DIRECTORY; then
                echo "$PATHNAME $(find "$PATHNAME" -maxdepth 1 -type f -executable -print | wc -l)"
            else
                find "$PATHNAME" -maxdepth 1 -type f -executable -print
            fi
        done
        IFS=$old_ifs # Reset to original IFS character
    fi
}

main() {
    PATH_TO_EXAMINE=$PATH
    while getopts "husep:-:" opt; do
        case $opt in
            h) send_help; exit 0 ;;
            u) DEDUPLICATE=false ;;
            p) PATH_TO_EXAMINE=$OPTARG ;;
            s) SUMMARY_PER_DIRECTORY=true ;;
            e) EFFECTIVE_EXECUTABLES_ONLY=true ;;
            ?) echo "Unknown option $opt" >&2; exit 1 ;;
        esac
    done

    print_executables "$PATH_TO_EXAMINE"
}

main "$@"
