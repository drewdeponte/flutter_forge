
# This is a patch to add the fvm function if fvm isn't found. This effectively
# allows us to support fvm users and non-fvm users by the fvm() stub function
# just proxying to the flutter command.

# Patch for us non-fvm peasants
if ! command -v fvm &> /dev/null
then
  fvm() {
    # Starts with flutter
    if [[ $@ == flutter* ]]; then
      command $@
    else
      command echo "fvm is for flutter only"
    fi
  }
fi
