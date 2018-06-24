#!/bin/bash
#
# Combines multiple git repositories into a single monolithic repository
# while still retaining the history from each repository. For example, this 
# could be useful for backing up multiple GitHub classroom repositories into a 
# single repository.
# 
# Maintainer: Nick Pleatsikas <nick@pleatsikas.me>
#
# shellcheck disable=SC2207,SC2145

autobuild_repository () {
  # Function arguments.
  local source_folder="$1"
  local repo="$2"

  # Check to make sure the clone command worked. If not, create a folder in the
  # current directory with the name of the repository.
  git clone "$repo" 1> /dev/null || {
    # Failing condition; create a new folder and initialize it.
    echo "No valid repository url provided, creating folder in $(pwd)/$repo"
    mkdir "$repo"

    # Initialize repository if the repository wasn't cloned from a remote.
    # Change into the repo directory and quietly initialize repository.
    pushd . > /dev/null 2>&1 || return
    cd "$repo" || return
    git init --quiet

    popd > /dev/null 2>&1 || return
  }
}

merge_repos () {
  # Function arguments.
  local source_folder="$1"
  local mono_repo_location="$2"

  # Array for holding repo subfolder names.
  local repo_names=()

  pushd . > /dev/null 2>&1 || return 
  cd "$mono_repo_location" || return

  # Set shell extended globbing.
  shopt -s extglob

  for repo in "$source_folder/"*; do
    # Get name of repository.
    local current_repo_name
    current_repo_name=$(basename "$repo")
    repo_names+=("$current_repo_name")

    mkdir "$current_repo_name"

    # Add the remote and merge everything into the monorepo.
    git remote add -f "$current_repo_name" "$repo"
    git merge "$current_repo_name/master" --allow-unrelated-histories

    # Match all properly moveable files in the current directory.
    local current_repo_files
    local all_moveable_files
    current_repo_files=($(echo !(*(.git)|..|.)))
    
    # Remove all occurences of names of repo folders. Equivalent to set
    # operation A - B.
    all_moveable_files=($(comm -13 \
      <(printf '%s\n' "${repo_names[@]}") \
      <(printf '%s\n' "${current_repo_files[@]}")))

    echo "Incoming Files: ${all_moveable_files[@]}"

    git mv "${all_moveable_files[@]}" "$current_repo_name"
    git commit -m "Merged & moved $current_repo_name." > /dev/null 2>&1
  done

  # Unset extended globbing.
  shopt -u extglob

  popd > /dev/null 2>&1 || return
}

ignore_combiner () {
  # Function arguments.
  local mono_repo_location="$1"

  pushd . > /dev/null 2>&1 || return
  cd "$mono_repo_location" || return
  
  # Append each gitignore to the global ignore file and remove the files.
  find . -mindepth 1 -type f -name ".gitignore" -exec cat {} + >> .gitignore 
  find . -mindepth 2 -type f -name ".gitignore" -exec rm {} +

  git add ./* .gitignore && git commit -m "Merged .gitignores." > /dev/null 2>&1

  popd > /dev/null 2>&1 || return
}

cleanup () {
  # Function arguments.
  local source_folder="$1"

  # Remove only folders. Leave files in the directory untouched.
  rm -rf "${source_folder:?}/*/"
}

usage () {
  cat <<EOF
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
EOF
}

main () {
  # Check to make sure source folder where each repository is located is
  # provided.
  if [[ $# -lt 1 ]]; then
    echo "No source folder provided. Exiting..."
    exit
  elif [[ $1 = "--help" || $1 = "-h" ]]; then
    usage
    exit
  elif [[ $1 = "--"* ]]; then
    echo "No source folder provided. Exiting..."
    exit
  fi

  # Folder containing all repositories.
  local source_folder

  IFS="/" read -ra DIR_PATH <<< "$1"
  if [[ $1 = "${DIR_PATH[0]}"* ]] && [[ ! -z "${DIR_PATH[0]}" ]]; then
    source_folder="$(pwd)/$1"
  else
    source_folder="$1"
  fi

  shift

  # Variable that determines whether or not repository should be created and
  # its location.
  local create_repo_folder=false
  local mono_repo_location

  # Flag for weather or not the old repositories should be removed when the
  # script is done.
  local clean_old_repositories=false

  # User set flag that combines each .gitignore into a single gitignore at
  # the root of the monorepo.
  local combine_ignores=false

  # Check for program flags.
  while [[ ! $# -eq 0 ]]; do
    case "$1" in
      --repository=* | --repo=* | --folder=*)
        # Use IFS to split repository folder/url after equals sign.
        IFS="=" read -ra LOC <<< "$1"
        mono_repo_location="${LOC[1]}"

        if [[ -z "$mono_repo_location" ]]; then
          echo "No valid target repository or folder provided."
          exit
        fi

        create_repo_folder=true
        ;;
      --combine-ignores)
        combine_ignores=true
        ;;
      --clean | -c)
        clean_old_repositories=true
        ;;
      --help | -h)
        usage
        exit
        ;;
    esac
    shift
  done

  # If the flag for the repository hasn't been set, then set the
  # name of the repository folder to monorepo with the PID of this
  # script appended.
  if [[ $create_repo_folder != true ]]; then
    mono_repo_location="$(pwd)/monorepo-$$"
  fi

  # Clone the repository or generate a new folder.
  autobuild_repository "$source_folder" "$mono_repo_location"

  # Merge the repositories together.
  merge_repos "$source_folder" "$mono_repo_location"

  # Call function that combines all ignores into a single file if flag is set.
  if [[ $combine_ignores == true ]]; then
    ignore_combiner "$mono_repo_location"
  fi

  # Clean old copies of the copied repositories.
  if [[ $clean_old_repositories == true ]]; then
    cleanup "$source_folder"
  fi

  printf '\xE2\x9C\xA8 Merge success!\n'
}

main "$@"