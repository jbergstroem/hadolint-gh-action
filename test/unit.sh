#!/usr/bin/env bash_unit

# shellcheck source=lib/hadolint.sh
. ../lib/hadolint.sh
# shellcheck source=lib/validate.sh
. ../lib/validate.sh

test_validate_error_level() {
  assert "validate_error_level 2"
  assert "validate_error_level -1"
}

test_validate_invalid_error_level() {
  assert_fail "validate_error_level 3"
  assert_fail "validate_error_level foo"
}

test_validate_annotate() {
  assert "validate_annotate true"
  assert "validate_annotate false"
}

test_validate_invalid_annotate() {
  assert_fail "validate_annotate /dev/null"
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
