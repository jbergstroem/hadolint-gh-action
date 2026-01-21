#!/usr/bin/env bash

function validate_error_level() {
  case "${1}" in -1 | 0 | 1 | 2) return 0 ;; *) return 1 ;; esac
}

function validate_boolean() {
  case "${1}" in true | false) return 0 ;; *) return 1 ;; esac
}

function validate_output_format() {
  case "${1}" in
  tty | json | checkstyle | codeclimate | gitlab_codeclimate | gnu | codacy | sonarqube | sarif) return 0 ;;
  *) return 1 ;;
  esac
}
