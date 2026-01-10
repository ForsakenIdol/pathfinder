#!/bin/sh

set -e -u

DEDUPLICATE=true
SUMMARY_PER_DIRECTORY=false
EFFECTIVE_EXECUTABLES_ONLY=false
RANDOM_MODE=false

send_help() {
    cat << 'EOF'
Usage:
    -p PATH
        use a custom PATH value instead of the one set in the shell's environment
    -u
        do not dedupe PATH, keep duplicate directories if present
    -e
        for duplicate executables in multiple locations, keep only the effective one that will be used when the executable is called directly
    -r
        output a random executable from the list, will override the -s and -e output modes if either of these are set
    -s
        print only the number of executables in each directory in PATH (summary mode); this flag is ignored when -e is set
    -h
        display this help and exit
EOF
}

# Basic PATH validation
validate_path() {
    # We don't test for colon presence because PATH is still valid even if it only consists of a single directory.
    # Additionally, while ill-advised and a huge security risk, PATH=. is also valid.
    # This means we can't check for forward slash '/' characters as they don't need to be present in a valid PATH.
    if [ "$1" = "" ]; then # Unset variables expand to an empty string, simplifying this check
        echo "Error: PATH (or custom PATH) is empty or unset" >&2
        exit 1
    fi
}

list_execs() {
for PATHNAME in $PATH_TO_EXAMINE; do
    test -d "$PATHNAME" || continue # If $PATHNAME is not a directory, then continue to the next path name
    if $SUMMARY_PER_DIRECTORY; then
        echo "$PATHNAME $(find "$PATHNAME" -maxdepth 1 -type f -executable -print | wc -l)"
    else
        find "$PATHNAME" -maxdepth 1 -type f -executable -print
    fi
done
}

print_executables() {
    PATH_TO_EXAMINE=$1
    validate_path "$PATH_TO_EXAMINE" # Validate PATH_TO_EXAMINE

    # Deduplicate entries, maintaining directory order, strip trailing colon if present
    if [ "$DEDUPLICATE" = true ]; then
        PATH_TO_EXAMINE=$(printf '%s' "$PATH_TO_EXAMINE" |
                          awk -v RS=: -v ORS=: '!($0 in seen) { seen[$0] = 1; print $0 }')
        PATH_TO_EXAMINE="${PATH_TO_EXAMINE%:}" # ${VAR%PATTERN} removes PATTERN from the end of VAR if present
    fi

    old_ifs=$IFS
    IFS=: # Change the default character used to split a string to a colon ':'
    if [ "$RANDOM_MODE" = true ]; then
        list_execs | shuf -n 1
    elif [ "$EFFECTIVE_EXECUTABLES_ONLY" = true ]; then
        # Collect ALL the executables first, before identifying effective executables by basename
        list_execs | awk '
            {
                name_of_executable = substr($0, match($0, "/[^/]*$") + 1)
                if (!already_seen[name_of_executable]++) print $0
            }
        '
        # The awk statement above matches the last part of the executable, so it has only the executable's name
        # The +1 is to avoid the last forward slash '/' being part of the match
        # awk only prints the executable's full path if it hasn't seen that executable name before
        # This matches the behavior when Linux searches for a specific executable; it uses only the first one it finds
    else
        list_execs
    fi
    IFS=$old_ifs # Reset to original IFS character
}

main() {
    PATH_TO_EXAMINE=$PATH
    while getopts "huserp:-:" opt; do
        case $opt in
            h) send_help; exit 0 ;;
            u) DEDUPLICATE=false ;;
            p) PATH_TO_EXAMINE=$OPTARG ;;
            s) SUMMARY_PER_DIRECTORY=true ;;
            e) EFFECTIVE_EXECUTABLES_ONLY=true ;;
            r) RANDOM_MODE=true ;;
            ?) echo "Unknown option $opt" >&2; exit 1 ;;
        esac
    done
    print_executables "$PATH_TO_EXAMINE"
}

main "$@"
