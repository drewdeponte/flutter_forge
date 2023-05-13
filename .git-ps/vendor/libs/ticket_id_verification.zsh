
verify_ticket_id_present() {
  PATTERN="(?:\s+|^|\[|[,])(\b\w+\-\d+\b|\B#\d+\b)|(?:.*)atlassian\.net\/browse\/(\b\w+\-\d+\b)"
  git rev-list --format=%B --max-count=1 head | tail +2 | grep -E "$PATTERN"
  if [ $? -ne 0 ]; then
    return 1
  fi

  return 0
}
