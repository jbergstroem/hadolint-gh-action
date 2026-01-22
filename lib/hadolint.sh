#!/usr/bin/env bash

HADOLINT_PATH=${hadolint_path:-"hadolint"}
HADOLINT_GH_ACTION_VERSION="1.15.0"

function output_hadolint_version() {
  local version
  read -r _ _ _ version < <("${HADOLINT_PATH}" --version)
  echo "hadolint_gh_action_version=${HADOLINT_GH_ACTION_VERSION}"
  echo "hadolint_version=${version%-no-git}"
}
