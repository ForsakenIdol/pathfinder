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

`set -euo pipefail` enables "strict mode":
    -e (errexit): Script exits immediately on any command's non-zero exit status, preventing error propagation; exceptions include conditionals and command lists.
    -u (nounset): Treats unset or null variables as errors during expansion to avoid silent failures from typos such as ${typo_var}.
    -o: Enables a shell option. Here, it is used to enable the `pipefail` option.
    pipefail: Pipeline exit status reflects the last (rightmost) command that failed (non-zero), rather than just the final command, catching mid-pipe errors like cmd1 | cmd2 | cmd3. 
