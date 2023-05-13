
libs_path=${0:a:h}

source "$libs_path/messaging.zsh"
source "$libs_path/git.zsh"

# Display the given <msg> as a failure message & exit the script with the
# given <exit-code> if the provided <result-to-evaluate> is NOT 0.
#
# usage: exit_nonzero <result-to-evaluate> <msg> <exit-code>
exit_nonzero() {
  result_to_evaluate=$1
  msg=$2
  exit_code=$3
  if [ $result_to_evaluate -ne 0 ]; then
    bad_msg ${msg}
    exit ${exit_code}
  fi
}

current_git_commit_message_contains() {
  keyword=$1
  message=$(get_current_commit_message)
  if [ $? -ne 0 ]; then
    return 2
  fi

  grep_output=$(echo $message | grep $keyword)
  if [ $? -ne 0 ]; then
    return 1
  fi

  return 0
}

# Exit if the specified command is missing
#
# usage: exit_if_cmd_missing <cmd-name> <err-msg> <exit-code>
exit_if_cmd_missing() {
	cmd_name=$1
	err_msg=$2
	exit_code=$3
	which_output=$(which $cmd_name)
	if [ $? -ne 0 ]; then
		echo $err_msg
		exit $exit_code
	fi
}
