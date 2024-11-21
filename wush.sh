# -----
# Subroutines
# -----

function printError() {
  echo -e "\e[31m$1\e[0m"
}

function highlightText() {
  echo -e "\e[32m$1\e[0m"
}

function confirm() {
  local valid_options=("y" "Y" "n" "N" "")

  is_valid_option() {
    local input=$1

    for option in "${valid_options[@]}"; do
      if [[ "$input" = "$option" ]]; then
        return 0
      fi
    done
    return 1
  }

  local user_input=-1
  while ! is_valid_option "$user_input"; do
    echo -n -e "$1"
    read user_input
  done

  if [[ $user_input = '' || $user_input = "y" || $user_input = "Y" ]]; then
    return 0
  else
    return 1
  fi
}

prompt_output=''
function prompt() {
  prompt_output=''

  local user_input=""
  while [[ $user_input = "" ]]; do
    echo -n -e "$1"
    read user_input
  done
  1=$user_input
  prompt_output=$user_input
}

# ----
# Start
# ----

# Handle user inputs
cohort_id=$1
session=$2

# Interactive mode if no cohort id is provided
if [ $# -lt 1 ]; then
  test
  prompt "Enter cohort id (hh-test-24-1): "
  cohort_id="$prompt_output"
fi

if [ "$cohort_id" = "" ]; then
  echo $(printError "Error: You must provide a cohort id.")
  exit 1
fi

# Interactive mode if no session name is provided
if [ $# -lt 2 ]; then
  prompt "Enter session name (shell-basics): "
  session="$prompt_output"
fi

if [ "$session" = '' ]; then
  echo $(printError "Error: You must provide a session name.")
  exit 1
fi

# Check if current folder is a git repository
if [ ! -d ".git" ]; then

  if ! confirm "This directory is not a git repository. Initialize one? [Y/n]: "; then
    echo $(printError "Error: This command needs to be executed in a git repository you want to upload.")
    exit 1
  fi

  git init
fi

repository_name="$cohort_id"-"$session"

# Let user check for spelling mistakes
if ! confirm "A new remote repository $(highlightText "$repository_name") will be created. Proceed? [Y/n]: "; then
  echo "Abort..."
  exit 0
fi

Commit everything and upload the repository
git add . && git commit -m "initial commit"
gh repo create -s=. --push --public --remote=origin neuefische-web-demos/"$repository_name"

if [ $? -eq 0 ]; then
  echo $(highlightText "Repository created: https://github.com/wd-bootcamp/$repository_name")
else
  echo $(printError "Failed to create repository. Please check if 'gh' command is installed.")
fi
