#!/usr/bin/env bash

[[ -n "${DEBUG}" ]] && set -x
set -euo pipefail
shopt -s nullglob globstar

CI=${GITHUB_ACTIONS:-}
VERSION=${version:-}
EXTRACT_VERSION_CMD="hadolint --version | sed 's/-no-git//' | cut -d ' ' -f 4"

[[ -z ${CI} ]] && echo "Will only run in Github Actions" && exit 1

DOWNLOAD="false"
# Check if hadolint is installed and compare versions to decide
# if we should download a new version
if [ -x "$(command -v hadolint)" ]; then
  INSTALLED_VERSION=$(eval "${EXTRACT_VERSION_CMD}" 2>&1)
  echo "::debug::Found existing Hadolint version: ${INSTALLED_VERSION}"
  if [ "${INSTALLED_VERSION}" != "${VERSION}" ]; then
    echo "::info::Hadolint version (${INSTALLED_VERSION}) does not match requested version (${VERSION})"
    DOWNLOAD="true"
  fi
else
  DOWNLOAD="true"
fi

# Download hadolint if necessary
if [ "${DOWNLOAD}" == "true" ]; then
  echo "::debug::Downloading Hadolint ${VERSION}"
  curl -s -L --fail -w 1 -o /tmp/hadolint \
    "https://github.com/hadolint/hadolint/releases/download/v${VERSION}/hadolint-Linux-x86_64" ||
    (echo "::error::Hadolint (version: ${VERSION}) could not be found. Exiting." && exit 1)
  chmod +x /tmp/hadolint
  # https://github.com/actions/runner-images/issues/3727
  # /usr/local/bin exists and is writable by any user
  # but some self hosted runners requires superpowers to write there
  # https://github.com/jbergstroem/hadolint-gh-action/issues/144
  sudo mv /tmp/hadolint /usr/local/bin/hadolint
fi

new_version=$(eval "${EXTRACT_VERSION_CMD}" 2>&1)
echo "::debug::Hadolint ${new_version} installed successfully"
