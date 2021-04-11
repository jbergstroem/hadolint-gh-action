#!/usr/bin/env bash

function output_hadolint_version() {
  local HADOLINT_VERSION=""
  # I cannot pass path directly here; both tests and invoking `hadolint`
  # directly would fail.
  alias hadolint='${HADOLINT_PATH}'
  HADOLINT_VERSION="$(hadolint --version | cut -d " " -f 4)"
  echo "::set-output name=hadolint_version::${HADOLINT_VERSION}"
}