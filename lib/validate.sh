#!/usr/bin/env bash

function validate_error_level() {
  for error_level in -1 0 1 2; do
    [[ "${error_level}" == "${1}" ]] && return 0
  done
  return 1
}

function validate_annotate() {
  [[ "${1}" == "true" || "${1}" == "false" ]] && return 0 || return 1
}

function validate_output_format() {
  local -a output_formats=(tty json checkstyle codeclimate gitlab_codeclimate)
  for format in "${output_formats[@]}"; do
    [[ "${format}" == "${1}" ]] && return 0
  done
  return 1
}