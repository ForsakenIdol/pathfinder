Output all the executables available on the system based on the $PATH environment variable.

$PATH doesn't search in subdirectories.

Possible arguments:
    -d, --directory=DIR
        output only the executables available in the DIR directory
    -r, --random
        output a random executable from the list. If -d / --directory is also specified, the random executable will be chosen from that list instead
    - s, --summary
        print only the number of executables in each directory in PATH (summary mode)
    -h, --help
        display this help and exit

shellcheck --shell=sh pathfinder.sh

https://www.perplexity.ai/search/my-plan-is-to-start-with-the-s-LeKwnp.XQeaUWThdaeo6EA
