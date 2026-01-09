#!/bin/sh

set -e -u

PATH_TO_EXAMINE=$PATH
DEDUPLICATE=true
SUMMARY_PER_DIRECTORY=false

send_help() {
    cat << 'EOF'
Usage:
    -p, --path=PATH
        use a custom PATH value instead of the one set in the shell's environment
    -u
        do not dedupe PATH, keep duplicate directories if present
    -e, --effective=EXECUTABLE
        for duplicate executables in multiple locations, keep only the effective one that will be used when the executable is called directly
    -r, --random
        output a random executable from the list
    -s, --summary
        print only the number of executables in each directory in PATH (summary mode)
    -h, --help
        display this help and exit
EOF
}

# Basic PATH validation
validate_path() {
    if [ -z "${PATH_TO_EXAMINE+x}" ] || [ -z "$PATH_TO_EXAMINE" ]; then
        echo "Error: PATH (or custom PATH) is empty or unset" >&2
        exit 1
    fi
}


print_executables() {

    validate_path # Validate PATH_TO_EXAMINE

    # Deduplicate entries, maintaining directory order, strip trailing colon if present
    $DEDUPLICATE && PATH_TO_EXAMINE=$(printf '%s' "$PATH_TO_EXAMINE" |
                                      awk -v RS=: -v ORS=: '!($0 in seen) { seen[$0] = 1; print $0 }') &&
                    PATH_TO_EXAMINE="${PATH_TO_EXAMINE%:}" # ${VAR%PATTERN} removes PATTERN from the end of VAR if present
                    
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
}

main() {
    while getopts "husp:-:" opt; do
        case $opt in
            h) send_help; exit 0 ;;
            u) DEDUPLICATE=false ;;
            p) PATH_TO_EXAMINE=$OPTARG ;;
            s) SUMMARY_PER_DIRECTORY=true ;;
            ?) echo "Unknown option $opt" >&2; exit 1 ;;
        esac
    done
    print_executables
}

main "$@"
