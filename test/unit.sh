#!/usr/bin/env bash_unit

# shellcheck source=lib/hadolint.sh
. ../lib/hadolint.sh
# shellcheck source=lib/validate.sh
. ../lib/validate.sh
# shellcheck source=lib/main.sh
. ../lib/main.sh

test_validate_error_level() {
  assert "validate_error_level 2"
  assert "validate_error_level -1"
}

test_validate_invalid_error_level() {
  assert_fail "validate_error_level 3"
  assert_fail "validate_error_level foo"
}

test_validate_boolean() {
  assert "validate_boolean true"
  assert "validate_boolean false"
}

test_validate_invalid_boolean() {
  assert_fail "validate_boolean /dev/null"
}

test_validate_output_format() {
  assert "validate_output_format gitlab_codeclimate"
  assert "validate_output_format sarif"
  assert "validate_output_format sonarqube"
  assert_fail "validate_output_format bbs"
}

test_validate_invalid_output_format() {
  assert_fail "validate_output_format bitbucket"
}

# mock a hadolint command so we don't rely on real output
function test_output_hadolint_version() {
  fake hadolint echo "Haskell Dockerfile Linter 2.10.0"
  local VER=""
  VER=$(output_hadolint_version)
  assert_matches ".*hadolint_version=2.10.0.*" "${VER}"
}

test_exit_with_error() {
  assert_status_code 1 "exit_with_error 'test error message'"
}

test_missing_hadolint_binary() {
  # Mock command -v to return false for hadolint
  fake "command" "return 1"
  HADOLINT_PATH="nonexistent_hadolint" assert_status_code 1 "run"
}

test_missing_jq_binary() {
  # Mock command -v to return false only for jq (hadolint exists)
  function command() {
    case "$2" in
    "jq") return 1 ;;
    *) /usr/bin/command "$@" ;;
    esac
  }
  export -f command
  assert_status_code 1 "run"
}
