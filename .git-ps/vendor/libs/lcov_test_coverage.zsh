
# usage: get_current_test_coverage
# $?: return code, 0 = success, non-zero = failure
# stdout: test coverage value, eg. "52.3" when command is successful, output of failed command when failure
get_current_lcov_test_coverage() {
  which_output=$(which lcov)
  if [ $? -ne 0 ]; then
    echo "evalute_test_coverage depends on lcov being installed. Please brew install lcov."
    return 1
  fi

  coverage=$(lcov --summary coverage/lcov.info | grep "lines......" | cut -d ' ' -f 4 | cut -d '%' -f 1)
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "failed to get test coverage from lcov - exited ${retval}: ${coverage}"
    return 2
  fi

  echo -n $coverage
  return 0
}

