# git-absorb
This tool merges multiple local git repositories into a single monolithic 
repository while still maintaining the history from each combined repository.
Each merged repository is located in a subdirectory with the name of the source
repository.

The usefullness of this tool is mainly in its ability to automate the grouping
of a collection of related repositories. For example, at my university many of
my programming classes have separate repositories for each assignment. Using this
tool I can merge all those repositories together and back it up to my own 
GitHub account, etc. Preserving the history from each repository is helpful for
me so I can go back and understand my thought process of solving some specific
problem.

### Caveats
I don't really recommend using this to merge particularly complex repos.
I haven't tested this tool on repositories with more than a couple of branches 
each, so YMMV with more complex repositories (i.e. avoid the `--clean` flag).

Additionally, this tool doesn't check for hash collisions between two 
separate repositories. I expect that is extremely unlikely to happen, and would 
likely require effort in order to accomplish.

## Installation
Homebrew is the recommended installationation method. Just run the following
commands to get started.

```bash
$ brew tap mrflynn/cider
$ brew install mrflynn/cider/git-absorb
```

Alternatively, you can install the tool manually by cloning this repository 
and adding `bin/` and `man/` to your `PATH` and 
`MANPATH` variables, respectively.

## Usage
```
$ git absorb --help
Usage: git absorb [FOLDER ...] [OPTIONS]
  Combines multiple repositories into one while preserving history.

  The folder argument is required for the script to run.

  Options:
  -c  --clean   Remove local copies of repositories merged into
                the new repository when script has finished.
  -h  --help    Display this menu and exit immediately.
```

## Goals
These were my goals when writing this program:
1. Attain a better understanding of how to write bash scripts. Functions, globbing,
data manipulation, arrays, error checking and handling, and script flags.
2. Develop a better understanding of git--more specifically with merges. How
to combine multiple histories seamlessly was important.
3. Familiarize myself with code linting tools, particularly those that exist for
shell script. I am using [ShellCheck](https://github.com/koalaman/shellcheck)
as my linter for this project.
