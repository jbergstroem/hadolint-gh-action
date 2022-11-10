#!/usr/bin/env bash

HADOLINT_PATH=${hadolint_path:-"hadolint"}
HADOLINT_GH_ACTION_VERSION="1.11.0"

function output_hadolint_version() {
  local OUTPUT=""
  OUTPUT=$(eval "${HADOLINT_PATH}" --version | cut -d " " -f 4)
  echo "hadolint_gh_action_version=${HADOLINT_GH_ACTION_VERSION}"
  echo "hadolint_version=${OUTPUT}"
}
