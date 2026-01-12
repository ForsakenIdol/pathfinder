# Pathfinder

[![execute-test-scripts](https://github.com/ForsakenIdol/pathfinder/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/ForsakenIdol/pathfinder/actions/workflows/test.yaml)

Output all the executables available on the system based on the $PATH environment variable. The script is only confirmed to work on GNU / BSH-ish systems, despite the shebang targeting `/bin/sh`.

Directories in `PATH` are not recursed upon on Linux when searching for an executable. This tool therefore does not recurse, nor does it expect anything other than directories to be present in `PATH`.

## Execution

Simply call the `pathfinder` script. With no arguments, `pathfinder` analyzes the shell environment's `PATH` variable and prints out the full path to each executable that can be called directly, based on the current state of the `PATH`.

```
./pathfinder
```

Possible arguments:

```
    -p PATH
        use a custom PATH value instead of the one set in the shell's environment
    -u
        do not dedupe PATH, keep duplicate directories if present
    -e
        for duplicate executables in multiple locations, keep only the effective one that will be used when the executable is called directly
    -r
        output a random executable from the list
    -s
        print only the number of executables in each directory in PATH (summary mode)
    -h
        display this help and exit
```

Note:
- The `-s` and `-e` flags are incompatible with each other and will produce invalid results if used together. This is due to the implementation of the `-e` flag, which uses directory splitting to find the executable name, given the full path to the executable.
- Long-form arguments are currently unsupported, but these are planned for future releases.

## Build (Debian)

To build the `pathfinder` utility from source for a Debian system, execute the `build.sh` script, ensuring your system has all required dependencies.

```sh
sudo apt install dh-make devscripts
./build.sh
```

This will provide you with a `.deb` package you can install with `dpkg`.

## Testing

Tests should go into the `tests/` directory. Included in this repository is a basic test script `test_pathfinder.sh` which ensures that this tool maintains basic functionality for all flags (except `-r`).
