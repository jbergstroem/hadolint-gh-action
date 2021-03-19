#!/usr/bin/env bash

function output_hadolint_version() {
  local HADOLINT_VERSION=""
  HADOLINT_VERSION="$(hadolint --version | cut -d " " -f 4)"
  echo "::set-output name=hadolint_version::${HADOLINT_VERSION}"
}