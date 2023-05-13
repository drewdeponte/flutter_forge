
libs_path=${0:a:h}

source "$libs_path/git.zsh"

# usage: push_test_coverage_data "<git-remote-name>"
# $?: return code
#   0 = success
#   non-zero = failure
# stdout: none on success, failure message providing details about failure
push_test_coverage_data() {
  remote=$1
  refspec="refs/test_coverage/*:refs/test_coverage/*"
  output=$(git push -f $remote $refspec)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to push test coverage data - $output"
    return 1
  fi

  echo ""
  return 0
}

# usage: push_commit_test_coverage_data "<commit-sha>" "<git-remote-name>"
# $?: return code
#   0 = success
#   non-zero = failure
# stdout: none on success, failure message providing details about failure
push_commit_test_coverage_data() {
  commit_sha=$1
  remote=$2
  refspec="refs/test_coverage/${commit_sha}:refs/test_coverage/${commit_sha}"
  output=$(git push -f $remote $refspec)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to push test coverage data - $output"
    return 1
  fi

  echo ""
  return 0
}

# usage: fetch_test_coverage_data "<git-remote-name>"
# $?: return code
#   0 = success
#   non-zero = failure
# stdout: none on success, failure message providing details about failure
fetch_test_coverage_data() {
  remote=$1
  refspec="refs/test_coverage/*:refs/test_coverage/*"
  output=$(git fetch $remote $refspec)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to fetch test coverage data - $output"
    return 1
  fi

  echo ""
  return 0
}

# usage: read_test_coverage "<commit-sha>"
# $?: return code
#   0 = success
#    positive non-zero = failure
#      1 = reference doesn't exist
#      2 = unhandled error
# stdout: test coverage value, eg. "52.3" when command is successful, when failure output message explaining failure
read_test_coverage() {
  commit_sha=$1
  ref="refs/test_coverage/${commit_sha}"
  coverage=$(git cat-file -p ${ref} 2> /dev/null)
  retval=$?
  if [ $retval -eq 128 ]; then
    echo "failed to get coverage - reference ${ref} doesn't exist - $coverage"
    return 1
  elif [ $retval -eq 0 ]; then
    echo $coverage
    return 0
  else
    echo "failed to get coverage - unhandled error - $coverage"
    return 2
  fi
}

# usage: store_test_coverage "52.3" "<commit-sha>"
# $?: return code, 0 = success, non-zero = failure
# stdout: none
store_test_coverage() {
  coverage=$1
  commit_sha=$2
  ref="refs/test_coverage/${commit_sha}"
  objectId=$(echo "${coverage}" | git hash-object -w --stdin)
  retval=$?
  if [ $retval -eq 0 ]; then
    git update-ref ${ref} $objectId
    ref_update_retval=$?
    if [ $retval -eq 0 ]; then
      echo ""
      return 0
    else
      echo "git update-ref refs/test_coverage/$2 $objectId exited with $ref_update_retval"
      return 2
    fi
  else
    echo "echo \"$1\" | git hash-object -w --stdin exited with $retval"
    return 1
  fi
}

# usage: evaluate_test_coverage $current_commit_test_coverage $remote
# $?: return code
#   0 = success - code coverage increased or stayed the same
#   1 = success - parent commit has no code coverage
#   2 = success - code coverage decreased
#   other positive non-zero = failure
# stdout:
#   return code 0 - "<cur_commit_coverage> <cur_commit_sha> <parent_commit_coverage> <parent_commit_sha>"
#   return code 1 - "<cur_commit_coverage> <cur_commit_sha>"
#   return code 2 - "<cur_commit_coverage> <cur_commit_sha> <parent_commit_coverage> <parent_commit_sha>"
#   on failure contains message describing the failure, on success progressive messaging
#
# The output in success cases is designed to be used with word splitting.
# ZSH has some unexpected behaviors with word splitting, see https://zsh.sourceforge.io/FAQ/zshfaq03.html
#
# The following is an example of how you can get the return value
#
# test_coverage_output=$(evaluate_test_coverage)
# retval=$?
# echo $test_coverage_output
# if [ $retval -eq 0 ]; then
#   eval "stringarray=($test_coverage_output)"
#   cur_commit_coverage=$stringarray[1]
#   cur_commit_sha=$stringarray[2]
#   parent_commit_coverage=$stringarray[3]
#   parent_commit_sha=$stringarray[4]
#   echo "Increased or maintained test coverage"
#   echo "${cur_commit_coverage}"
#   echo "${cur_commit_sha}"
#   echo "${parent_commit_coverage}"
#   echo "${parent_commit_sha}"
#   exit 0
# elif [ $retval -eq 1 ]; then
#   eval "stringarray=($test_coverage_output)"
#   cur_commit_coverage=${stringarray[1]}
#   cur_commit_sha=${stringarray[2]}
#   echo "Missing parent test coverage"
#   echo "${cur_commit_coverage}"
#   echo "${cur_commit_sha}"
#   exit 0
# elif [ $retval -eq 2 ]; then
#   eval "stringarray=($test_coverage_output)"
#   cur_commit_coverage=$stringarray[1]
#   cur_commit_sha=$stringarray[2]
#   parent_commit_coverage=$stringarray[3]
#   parent_commit_sha=$stringarray[4]
#   echo "Decreased test coverage"
#   echo "${cur_commit_coverage}"
#   echo "${cur_commit_sha}"
#   echo "${parent_commit_coverage}"
#   echo "${parent_commit_sha}"
#   exit 0
# elif [ $retval -gt 2 ]; then
#   bad_msg "$test_coverage_output"
#   exit 60
# fi
#
evaluate_test_coverage() {
  current_test_coverage=$1
  remote=$2

  current_commit_sha=$(get_current_commit_sha)
  if [ $? -ne 0 ]; then
    echo "get_current_commit_sha failed - $current_commit_sha"
    return 3
  fi

  parent_commit_sha=$(get_parent_commit_sha $current_commit_sha)
  if [ $? -ne 0 ]; then
    echo "get_parent_commit_sha failed - $parent_commit_sha"
    return 4;
  fi

  # Fetch historic test coverage data
  fetch_output=$(fetch_test_coverage_data $remote)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to fetch test coverage data - $fetch_output"
    return 5
  fi

  parent_commits_test_coverage=$(read_test_coverage ${parent_commit_sha})
  retval=$?
  if [ $retval -eq 1 ]; then
    # parent test coverage doesn't exist, return notifying caller
    echo -n "${current_test_coverage} ${current_commit_sha}"
    return 1
  elif [ $retval -eq 0 ]; then
    if [ "$(echo "${current_test_coverage} < $parent_commits_test_coverage" | bc)" -eq 1 ]; then
      # test coverage decreased, return notifying caller
      echo -n "${current_test_coverage} ${current_commit_sha} ${parent_commits_test_coverage} ${parent_commit_sha}"
      return 2
    else
      # test coverage maintained or increased, return notifying caller
      echo -n "${current_test_coverage} ${current_commit_sha} ${parent_commits_test_coverage} ${parent_commit_sha}"
      return 0
    fi
  else
    echo "Some undhandled failure - get parent commits test coverage exited with $retval - $parent_commits_test_coverage"
    return 6
  fi
}

# usage: store_and_push_test_coverage <coverage> <commit-sha>
# $?: return code
#   0 = successfully stored and push code coverage
#   positive non-zero = failure
# stdout: on failure contains message describing the failure, on success none
store_and_push_test_coverage() {
  test_coverage=$1
  commit_sha=$2
  remote=$3

  # Store the current code coverage
  store_test_coverage_output=$(store_test_coverage $test_coverage $commit_sha)
  if [ $? -ne 0 ]; then
    echo "Failed to store current test coverage! ${store_test_coverage_output}"
    return 1
  fi

  # Sync test coverage with the remote
  push_output=$(push_commit_test_coverage_data "${commit_sha}" "${remote}")
  if [ $? -ne 0 ]; then
    echo "Failed to push test coverage data! $push_output"
    return 2
  fi

  return 0
}
