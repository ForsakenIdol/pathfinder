Output all the executables available on the system based on the $PATH environment variable.

$PATH doesn't search in subdirectories.

Possible arguments:
    -d, --directory=DIR
        output only the executables available in the DIR directory
    -r, --random
        output a random executable from the full list
    -h, --help
        display this help and exit

shellcheck --shell=sh pathfinder.sh
