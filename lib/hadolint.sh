#!/usr/bin/env bash

HADOLINT_PATH=${hadolint_path:-"hadolint"}

function output_hadolint_version() {
  local OUTPUT=""
  OUTPUT=$(eval "${HADOLINT_PATH}" --version | cut -d " " -f 4)
  echo "::set-output name=hadolint_version::${OUTPUT}"
}
