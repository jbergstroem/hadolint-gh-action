#!/usr/bin/env bash

# hadolint has four types of statuses: error, warning, info and style.
# github has four different: error, warning, notice and debug.
# in our case, we stick with error, warning and notice; so we remap the rest with jq
function json_to_annotation() {
  # note: assumes input is piped
  jq -r '.[] | (select(.level == ("info", "style")) .level |= "notice") |
         "::\(.level) file=\(.file),line=\(.line),col=\(.column)::\(.message) ([\(.code)](https://github.com/hadolint/hadolint/wiki/\(.code)))"'
}

function exit_if_found_in_json() {
  # A bit finicky - we lean on jq to pass an error code. If this happens,
  # bash will simply exit since we use `set -o pipefail`
  # @TODO: support passing needle as array to avoid calling twice via "warning, error"
  jq -e --arg needle "${1}" \
     -r 'def count(s): reduce s as $_ (0;.+1); count(.[] |
         select(.level == $needle)) | . == 0'  &> /dev/null
}