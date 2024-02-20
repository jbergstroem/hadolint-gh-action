#!/usr/bin/env bash

DOCKERFILE=${dockerfile:-"Dockerfile"}
CONFIG_FILE=${config_file:-}
ERRORLEVEL=${error_level:-0}
ANNOTATE=${annotate:-"true"}
OUTPUT_FORMAT=${output_format:-}
HADOLINT_PATH=${hadolint_path:-"hadolint"}
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
CI=${GITHUB_ACTIONS:-"false"}
# This variable is magic in workflows; it intercepts output and makes it available across jobs
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}
MATCHER_PREFIX=${GITHUB_ACTION_PATH:-"."}

function exit_with_error() {
  echo "${1}"
  exit 1
}

function run() {
  local OUTPUT=""
  # Check for dependencies
  for executable in "${HADOLINT_PATH}" jq; do
    if ! command -v "${executable}" &>/dev/null; then
      echo "Cannot find required binary ${executable}. Is it in \$PATH?"
      exit 1
    fi
  done

  # Export version [if we're running in CI]
  if [[ "${CI}" == "true" ]]; then
    # The trick here is to intercept the variable output,
    # then pass it to something github parses
    local ret
    ret="$(output_hadolint_version)"
    echo "${ret}" >>"${GITHUB_OUTPUT}"
  fi

  validate_error_level "${ERRORLEVEL}" || exit_with_error "Provided error level is not supported. Valid values: -1, 0, 1, 2"
  validate_annotate "${ANNOTATE}" || exit_with_error "Annotate needs to be set to true or false"
  [[ -z "${OUTPUT_FORMAT}" ]] || (validate_output_format "${OUTPUT_FORMAT}" || exit_with_error "Invalid format. If set, output format needs to be one of: tty, json, checkstyle, codeclimate, gitlab_codeclimate, gnu, tty, json")

  local CONFIG=""
  [[ -z "${CONFIG_FILE}" ]] || CONFIG="-c ${CONFIG_FILE}"

  [[ "${ANNOTATE}" == "true" ]] && [[ "${CI}" == "true" ]] && echo "::add-matcher::${MATCHER_PREFIX}/.github/problem-matcher.json"

  # If output_format is passed, we unfortunately need to run hadolint twice due
  # to how output formatting works.
  if [[ -n "${OUTPUT_FORMAT}" ]]; then
    OUTPUT=$(eval "${HADOLINT_PATH}" --no-fail --no-color "${CONFIG}" -f "${OUTPUT_FORMAT}" "${DOCKERFILE}")
    echo "hadolint_output=${OUTPUT//$'\n'/'%0A'} >> ${GITHUB_OUTPUT}"
  fi

  # Eval to remove empty vars
  # Don't care about output if annotate is set to false - exit code is still passed
  OUTPUT=$(eval "${HADOLINT_PATH}" --no-fail --no-color "${CONFIG}" -f tty "${DOCKERFILE}")

  # Always write output
  echo "${OUTPUT}"

  local EXITCODE=0
  # Different exit depending on verbosity
  # Ignore all errors
  [[ "${ERRORLEVEL}" == "-1" ]] && exit ${EXITCODE}

  # Exit if errors occur
  [[ "${ERRORLEVEL}" == "0" ]] && [[ "${OUTPUT}" =~ .*DL[[:digit:]]+[[:space:]]error\:.* ]] && EXITCODE=1

  # ..also with warnings
  [[ "${ERRORLEVEL}" == "1" ]] && [[ "${OUTPUT}" =~ .*(warning)|(error)\:.* ]] && EXITCODE=1

  # ..also with style nits
  [[ "${ERRORLEVEL}" == "2" ]] && [[ -n "${OUTPUT}" ]] && exit 1

  exit ${EXITCODE}
}
