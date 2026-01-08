Output all the executables available on the system based on the $PATH environment variable. The script is only confirmed to work on GNU / BSH-ish systems, despite the shebang targeting `/bin/sh`.

$PATH doesn't search in subdirectories.

Possible arguments:
    -p, --path=PATH
        use a custom PATH value instead of the one set in the shell's environment
    -u
        do not dedupe PATH, keep duplicate entries if present
    -e, --effective=EXECUTABLE
        for duplicate executables in multiple locations, keep only the effective one that will be used when the executable is called directly
    -r, --random
        output a random executable from the list
    -s, --summary
        print only the number of executables in each directory in PATH (summary mode)
    -h, --help
        display this help and exit

shellcheck --shell=sh pathfinder.sh

`set -euo pipefail` enables "strict mode":
    -e (errexit): Script exits immediately on any command's non-zero exit status, preventing error propagation; exceptions include conditionals and command lists.
    -u (nounset): Treats unset or null variables as errors during expansion to avoid silent failures from typos such as ${typo_var}.
    -o: Enables a shell option. Here, it is used to enable the `pipefail` option.
    pipefail: Pipeline exit status reflects the last (rightmost) command that failed (non-zero), rather than just the final command, catching mid-pipe errors like cmd1 | cmd2 | cmd3. 

You can replace the `-executable` flag with `-exec test -x {} \;` in the `find` utility if desired, because:
- `-executable` is a GNU find predicate that tests whether the current user is actually allowed to execute the file, taking ACLs and effective IDs into account.
- `-exec test -x {} \; (or [ -x {} ])` instead checks the execute permission bits for the file against the real UID/GID of the process running the `find` utility.
The second instance makes the script execute much slower, but decouples the script from being GNU specific, and both instances actually do really similar things.

I've replaced the `| sort | uniq` pipe fix with the `DEDUP_PATH` assignment with `awk`. This is because maintaining the order of the directories in $PATH is extremely important for duplicate executable handling. The `awk` block does the following:
1. Split the PATH into individual directory entries using the Record Separator (RS=:).
2. For each directory, if `awk` has already seen it, continue.
3. If the directory is new to `awk`, add it to the `seen` associative array, then print it.
4. Rejoin the output using the Output Record Separator (ORS=:).

Misc. Notes:
    - SC3040 (warning): In POSIX sh, set option pipefail (set -o pipefail) is undefined. We can't use it in an sh-compatible script.
    - 
