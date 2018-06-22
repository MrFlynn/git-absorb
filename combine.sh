#!/bin/bash
#
# Combines multiple git repositories into a single monolithic repository.
# For example, this could be useful for backing up multiple GitHub classroom
# repositories into a single repository.
# 
# Maintainer: Nick Pleatsikas <nick@pleatsikas.me>

autoclone_repository () {
  # Function arguments.
  local source_folder="$1"
  local repo="$2"

  # Check to make sure the clone command worked. If not, create a folder in the
  # current directory with the name of the repository.
  if [[ $(git clone "$repo") -eq 0 ]]; then
    echo "Repository cloned."
  else
    echo "No valid repository url provided, creating folder in $(pwd)/$repo"
    mkdir "$repo"
  fi
}

merge_repos () {
  # Function arguments.
  local source_folder="$1"
  local repo_location="$2"

  # Copy the contents of the folder containin each repo into the mono-repo
  # directory.
  cp -r "$source_folder/." "$repo_location"

  for dir in $repo_location/*; do
    # Remove the .git/ folder from each copied repository.
    rm -rf "$dir/.git/"

    # Append the contents of each repository's .gitignore to the root
    # .gitignore and then remove the original. 
    cat "$dir/.gitignore" >> "$repo_location/.gitignore"
    rm "$dir/.gitignore"
  done
}

cleanup () {
  # Function arguments.
  local source_folder"$1"

  # Remove only folders. Leave files in the directory untouched.
  rm -rf "${source_folder:?}/*/"
}

main () {
  # Check to make sure source folder where each repository is located is
  # provided.
  if [[ $# -lt 1 ]]; then
    echo "No source folder provided. Exiting..."
    exit
  elif [[ $1 -eq "--*" ]]; then
    echo "No source folder provided. Exiting..."
    exit
  fi

  # Folder containing all repositories.
  local source_folder="$1"
  shift

  # Variable that determines whether or not repository should be created and
  # its location.
  local create_repo_folder=false
  local repo_location

  # Flag for weather or not the old repositories should be removed when the
  # script is done.
  local clean_old_repositories=false

  # Check for program flags.
  while [[ ! $# -eq 0 ]]; do
    case "$1" in
      --repository=* | --repo=*)
        # Use IFS to split repository folder/url after equals sign.
        IFS="=" read -ra LOC <<< "$1"
        repo_location="${LOC[1]}"

        create_repo_folder=true
        ;;
      --clean | -c)
        clean_old_repositories=true
    esac
    shift
  done

  # If the flag for the repository hasn't been set, then set the
  # name of the repository folder to monorepo with the PID of this
  # script appended.
  if [[ $create_repo_folder != true ]]; then
    repo_location="monorepo-$$"
  fi

  # Clone the repository or generate a new folder.
  autoclone_repository "$source_folder" "$repo_location"

  # Merge the repositories together.
  merge_repos "$source_folder" "$repo_location"

  if [[ $clean_old_repositories == true ]]; then
    cleanup "$source_folder"
  fi
}

main "$@"