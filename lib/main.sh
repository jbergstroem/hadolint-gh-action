#!/usr/bin/env bash

DOCKERFILE=${dockerfile:-"Dockerfile"}
CONFIG_FILE=${config_file:-}
ERRORLEVEL=${error_level:-0}
ANNOTATE=${annotate:-"true"}
OUTPUT_FORMAT=${output_format:-}
HADOLINT_PATH=${hadolint_path:-"hadolint"}

function exit_with_error() {
  echo "${1}"
  exit 1
}

function run() {
  # Check for dependencies
  for executable in "${HADOLINT_PATH}" jq; do
    if ! command -v "${executable}" &> /dev/null; then
      echo "Cannot find required binary ${executable}. Is it in \$PATH?"
      exit 1
    fi
  done

  # Set version
  output_hadolint_version
  
  validate_error_level "${ERRORLEVEL}" || exit_with_error "Provided error level is not supported. Valid values: -1, 0, 1, 2"
  validate_annotate "${ANNOTATE}" || exit_with_error "Annotate needs to be set to true or false"
  [[ -z "${OUTPUT_FORMAT}" ]] || (validate_output_format "${OUTPUT_FORMAT}" || exit_with_error "Invalid format. If set, output format needs to be one of: tty, json, checkstyle, codeclimate, gitlab_codeclimate")
  
  local CONFIG=""
  [[ -z "${CONFIG_FILE}" ]] || CONFIG="-c ${CONFIG_FILE}"

  # If output_format is passed, we unfortunately need to run hadolint twice due
  # to how output formatting works.
  if [[ -n "${OUTPUT_FORMAT}" ]]; then
    local OUTPUT=""
    OUTPUT=$(eval "${HADOLINT_PATH}" --no-fail --no-color "${CONFIG}" -f "${OUTPUT_FORMAT}" "${DOCKERFILE}")
    # https://github.com/actions/toolkit/issues/403
    echo "::set-output name=hadolint_output::${OUTPUT//$'\n'/'%0A'}"
  fi

  # Eval to remove empty vars
  # Don't care about output if annotate is set to false - exit code is still passed
  local OUTPUT=""
  OUTPUT=$(eval "${HADOLINT_PATH}" --no-fail --no-color "${CONFIG}" -f json "${DOCKERFILE}")
  [[ "${ANNOTATE}" == "true" ]] && echo "${OUTPUT}" | json_to_annotation
  
  # Different exit depending on verbosity
  # Ignore all errors
  [[ "${ERRORLEVEL}" == "-1" ]] && exit 0

  # Only bail with type error
  [[ "${ERRORLEVEL}" == "0" ]] && echo "${OUTPUT}" | exit_if_found_in_json "error"

  # Only bail with type error, warning
  # @TODO: get to to handle this once
  [[ "${ERRORLEVEL}" == "1" ]] && echo "${OUTPUT}" | exit_if_found_in_json "warning"
  [[ "${ERRORLEVEL}" == "1" ]] && echo "${OUTPUT}" | exit_if_found_in_json "error"
  
  # Any output would imply an error
  [[ "${ERRORLEVEL}" == "2" && "${OUTPUT}" != "" ]] && exit 1
  
  # You either did well or chose to become a better person
  exit 0
}
