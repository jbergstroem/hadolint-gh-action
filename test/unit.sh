#!/usr/bin/env bash_unit

# shellcheck disable=SC2016
HADOLINT_JSON_RESPONSE='[{"line":2,"code":"DL4000","message":"MAINTAINER is deprecated","column":1,"file":"Dockerfile","level":"error"},{"line":9,"code":"DL3018","message":"Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>`","column":1,"file":"Dockerfile","level":"warning"}]'

# shellcheck disable=SC1091
. ../lib/hadolint.sh
# shellcheck disable=SC1091
. ../lib/jq.sh
# shellcheck disable=SC1091
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
  assert "validate_output_format tty"
}

test_validate_invalid_output_format() {
  assert_fail "validate_output_format bitbucket"
}

# mock a hadolint command so we don't rely on real output
function test_output_hadolint_version() {
  fake hadolint echo "Haskell Dockerfile Linter 1.23.0-no-git"
  local VER=""
  VER=$(output_hadolint_version)
  assert_equals "::set-output name=hadolint_version::1.23.0-no-git" "${VER}"
}

# we don't really validate data we pass to jq :'(
function test_json_to_annotation() {
  local RES=""
  RES=$(echo "${HADOLINT_JSON_RESPONSE}" | json_to_annotation)
  assert_equals "${RES}" '::error file=Dockerfile,line=2,col=1::MAINTAINER is deprecated ([DL4000](https://github.com/hadolint/hadolint/wiki/DL4000))
::warning file=Dockerfile,line=9,col=1::Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>` ([DL3018](https://github.com/hadolint/hadolint/wiki/DL3018))'
}

function test_exit_if_found_in_json() {
  assert_status_code 1 'echo ${HADOLINT_JSON_RESPONSE} | exit_if_found_in_json "error"'
  assert_status_code 0 'echo ${HADOLINT_JSON_RESPONSE} | exit_if_found_in_json "notice"'
}