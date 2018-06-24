# repo-combiner
This tool merges multiple local git repositories into a single monolithic 
repository while still maintaining the history from each combined repository.
Each merged repository is located in a subdirectory with the name of the source
repository.

The usefullness of this tool is mainly in its ability to automate the grouping
of a collection of related repositories. For example, at my university many of
my programming classes have separate repositories for each assignment. Using this
program I can merge all those repositories together and back it up to my own 
GitHub account, etc. Preserving the history of each repository is just a nice
bonus.

_Note:_ I don't really recommend using this to merge particularly complex repos.
I haven't tested this tool on repositories with more than a couple of branches 
each, so YMMV with more complex repositories (i.e. avoid the `--clean` flag).

### How to Use:
First, clone the repository. Next, if needed create a target remote repository.
Finally, run the script. Use the `--help` flag to get familiar with the options,
but I've also included a copy of the help screen below.
```
$ repo-combiner/combine.sh --help
Usage: combine.sh [FOLDER] [OPTIONS]
  Combines multiple repositories into one while preserving history.

  The folder argument is required for the script to run.

  Options:
      --repository=URL/FOLDER Link to remote for combined repository or path to
                              folder for initializing a new repository.
      --combine-ignores       Combine the .gitignore files from each repository
                              into a single .gitignore at the root of the new
                              repository.
  -c  --clean                 Remove local copies of repositories merged into
                              the new repository when script has finished.
  -h  --help                  Display this menu and exit immediately.
```

### Goals:
These were my goals when writing this program:
1. Attain a better understanding of how to write bash scripts. Functions, globbing,
data manipulation, arrays, error checking and handling, and script flags.
2. Develop a better understanding of git--more specifically with merges. How
to combine multiple histories seamlessly was important.