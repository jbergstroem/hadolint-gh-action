#!/usr/bin/env bash

DOCKERFILE=${dockerfile:-"Dockerfile"}
CONFIG_FILE=${config_file:-}
ERRORLEVEL=${error_level:-0}
ANNOTATE=${annotate:-"true"}
OUTPUT_FORMAT=${output_format:-}
HADOLINT_PATH=${hadolint_path:-"hadolint"}
ADVANCED_SECURITY=${advanced_security:-"false"}
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
  command -v "${HADOLINT_PATH}" &>/dev/null && command -v jq &>/dev/null ||
    exit_with_error "Cannot find required binary hadolint or jq. Is it in \$PATH?"

  # Export version [if we're running in CI]
  if [[ "${CI}" == "true" ]]; then
    output_hadolint_version >>"${GITHUB_OUTPUT}"
  fi

  validate_error_level "${ERRORLEVEL}" || exit_with_error "Provided error level is not supported. Valid values: -1, 0, 1, 2"
  validate_boolean "${ANNOTATE}" || exit_with_error "Annotate needs to be set to true or false"
  validate_boolean "${ADVANCED_SECURITY}" || exit_with_error "advanced_security needs to be set to true or false"
  [[ -z "${OUTPUT_FORMAT}" ]] || validate_output_format "${OUTPUT_FORMAT}" ||
    exit_with_error "Invalid format. If set, output format needs to be one of: tty, json, checkstyle, codeclimate, gitlab_codeclimate, gnu, codacy, sonarqube, sarif"

  local CONFIG=""
  [[ -z "${CONFIG_FILE}" ]] || CONFIG="-c ${CONFIG_FILE}"

  [[ "${ANNOTATE}" == "true" ]] && [[ "${CI}" == "true" ]] && echo "::add-matcher::${MATCHER_PREFIX}/.github/problem-matcher.json"

  # If output_format is passed, we unfortunately need to run hadolint twice due
  # to how output formatting works.
  if [[ -n "${OUTPUT_FORMAT}" ]]; then
    OUTPUT=$("${HADOLINT_PATH}" --no-fail --no-color ${CONFIG} -f "${OUTPUT_FORMAT}" ${DOCKERFILE})
    local HADOLINT_OUTPUT_LINE="hadolint_output=\"${OUTPUT//$'\n'/'%0A'}\""
    echo "${HADOLINT_OUTPUT_LINE}"
    [[ "${CI}" == "true" ]] && echo "${HADOLINT_OUTPUT_LINE}" >>"${GITHUB_OUTPUT}"
  fi

  # If advanced_security is enabled, generate SARIF output to a file
  if [[ "${ADVANCED_SECURITY}" == "true" ]]; then
    local SARIF_FILE
    SARIF_FILE=$(mktemp -t hadolint-sarif.XXXXXX)
    "${HADOLINT_PATH}" --no-fail --no-color ${CONFIG} -f sarif ${DOCKERFILE} >"${SARIF_FILE}"
    [[ "${CI}" == "true" ]] && echo "sarif_file=${SARIF_FILE}" >>"${GITHUB_OUTPUT}"
  fi

  # Don't care about output if annotate is set to false - exit code is still passed
  OUTPUT=$("${HADOLINT_PATH}" --no-fail --no-color ${CONFIG} -f tty ${DOCKERFILE})

  # Always write output
  echo "${OUTPUT}"

  local EXITCODE=0
  case "${ERRORLEVEL}" in
  -1) : ;; # Ignore all errors
  0) [[ "${OUTPUT}" =~ DL[0-9]+[[:space:]]error: ]] && EXITCODE=1 ;;
  1) [[ "${OUTPUT}" =~ (warning|error): ]] && EXITCODE=1 ;;
  2) [[ -n "${OUTPUT}" ]] && EXITCODE=1 ;;
  esac
  exit ${EXITCODE}
}
