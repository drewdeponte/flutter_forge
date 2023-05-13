
# This is a collection of ZSH functions to help standardize different types of
# message outputs and formatting of them throughout our various hooks.

# usage: bad_msg "some bad message"
# $?: return code, 0 = success, non-zero = failure
# stdout: the message with formatting to communicate it is bad
bad_msg() {
  msg=$1
  echo -e "\e[1;31m \n${msg}\n \e[0m"
}

# usage: warning_msg "some warning message"
# $?: return code, 0 = success, non-zero = failure
# stdout: the message with formatting to communicate it is a warning message
warning_msg() {
  msg=$1
  echo -e "\e[1;33m \n${msg}\n \e[0m"
}

# usage: good_msg "some good message"
# $?: return code, 0 = success, non-zero = failure
# stdout: the message with formatting to communicate it is good
good_msg() {
  msg=$1
  echo -e "\e[1;32m \n${msg}\n \e[0m"
}
