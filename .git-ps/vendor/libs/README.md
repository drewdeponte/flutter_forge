# project-shell-libs

Collection of various shell libs that we use with our various projects to facilate scripting, especially when creating git-ps-rs hooks.

This collection includes the following libraries.

* `ticket_id_verification.zsh` - facilitate verifying that a commit message contains a ticket identifier
* `messaging.zsh` - facilitate semantically styled messaging, e.g. `good_msg()`, `warning_msg()`, `bad_msg()`
* `lcov_test_coverage.zsh` - facilitate extracting test coverage values from `lcov.info` report
* `flutter_test_coverage.zsh` - facilitate generating a test coverage helper file so flutter will evaluate all coverage
* `git.zsh` - facilitate interacting with Git in various ways, e.g. `get_current_commit_sha()`, `get_uncommitted_files_count()`, etc.
* `git_backend_test_coverage.zsh` - facilitate storing & syncing test coverage values in the Git repositories key/value store while also supporting evaluating test coverage relative to previous commits test coverage
* `general.zsh` - general utilities, e.g. `exit_nonzero()` to exit non zero with a semantic message, `exit_if_cmd_missing()` abort with semantic message if requried command is missing, `current_git_commit_message_contains()` check if current Git commit contains a value
* `fvm.zsh` - allow us to support FVM and non-FVM users by providing an `fvm` proxy function to handle both cases

It also contains the following scripts to aid in debugging around the functionality of these libraries.

* `echo_lcov_test_coverage` - prints out the current test coverage value obtained from the `lcov.info` report using `lcov_test_coverage.zsh`
* `list_historic_code_coverage` - fetch code coverage data from Git repo, iterate over all the commits between HEAD and the SHA, the first and only argument, and show the code coverage for each commit
* `show_commit_code_coverage` - obtains and prints test coverage for the given SHA using `git_backend_test_coverage.zsh`

This repository also contains [Git Patch Stack - Hooks](https://book.git-ps.sh/tool/hooks.html) examples within the `hooks` folder.

* `sample_flutter_integrate_post_push` - example `integrate_post_push` hook for a Flutter application
* `sample_flutter_isolate_post_checkout` - example `isolate_post_checkout` hook for a Flutter application
* `sample_ts_backend_integrate_post_push` - example `integrate_post_push` hook for a TypeScript Backend application
* `sample_ts_backend_isolate_post_checkout` - example `isolate_post_checkout` hook for a TypeScript Backend application
* `sample_ts_backend_isolate_post_cleanup` - example `isolate_post_cleanup` hook for a TypeScript Backend application
* `sample_ts_library_isolate_post_checkout` - example `isolate_post_checkout` hook for a TypeScript library
* `sample_ts_library_isolate_post_cleanup` - example `isolate_post_cleanup` hook for a TypeScript library
* `sample_ts_library_integrate_post_push` - example `integrate_post_push` hook for a TypeScript library

## Initial Setup

Run the following to initially setup the project shell library directory structure.

```
mkdir -p .git-ps/vendor
```

## Install/Update

Run the following to install/update the project shell libraries and git-ps-rs hook examples.

```
rm -rf .git-ps/vendor/libs && git clone --depth 1 git@github.com:uptech/jumpstart_project_shell_libs.git .git-ps/vendor/libs && rm -rf .git-ps/vendor/libs/.git
```
