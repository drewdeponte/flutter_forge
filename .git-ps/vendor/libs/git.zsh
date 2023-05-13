
# usage: get_uncommitted_files_count
# $?: 0 on success, 1 on failure
# stdout: on success, the number of uncommited files with changes
get_uncommitted_files_count() {
  count=`git status --porcelain=v1 2>/dev/null | wc -l`
  if [ $? -ne 0 ]; then
    return 1
  fi
  echo -n $count
  return 0
}

# usage: get_current_commit_message
# $?: 0 on success, 1 on failure
# stdout: on success, the commit message
get_current_commit_message() {
  message=$(git --no-pager log -1 --pretty=%B)
  if [ $? -ne 0 ]; then
    echo $message
    return 1
  fi
  echo $message
  return 0
}

# usage: get_current_commit_sha
# $?: return code, 0 = success, non-zero = failure
# stdout: sha of current commmit when command is successful, message explaining error when not successful
get_current_commit_sha() {
  sha=$(git rev-parse HEAD)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to get current commit sha - git rev-parse HEAD exited with ${retval}"
    return 1
  fi
  echo $sha
  return 0
}

# usage: get_parent_commit_sha "<commit-sha>"
# $?: return code, 0 = success, non-zero = failure
# stdout: sha of current commmit when command is successful, message explaining error when not successful
get_parent_commit_sha() {
  current_sha=$1
  parent_sha=$(git rev-parse ${current_sha}^)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to get parent commit sha - git rev-parse ${current_sha} exited with ${retval}"
    return 1
  fi

  echo $parent_sha
  return 0
}
