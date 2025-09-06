#!/usr/bin/env bash_unit

HL="../hadolint.sh"
MKDIR_PREFIX="hadolint.tmp.XXXXX"

teardown_suite() {
  # if asserts in a test function fail no more code is run which require us to
  # clean up globally instead of tests cleaning up on their own
  rm -f "${MKDIR_PREFIX%.*}".*
}

test_default_path() {
  # This should fail since we can't find a Dockerfile in this directory
  assert_status_code 1 "${HL}"
}

test_default_path_with_dockerfile() {
  cd fixtures/default-path || exit 1
  assert_status_code 0 "../../${HL}"
}

test_custom_hadolint_path() {
  # Since test runners should have hadolint installed, lets find path and set it
  assert_status_code 0 "hadolint_path=$(which hadolint) dockerfile=fixtures/default-path/Dockerfile ${HL}"
}

test_custom_dockerfile_path() {
  assert_status_code 0 "dockerfile=fixtures/default-path/Dockerfile ${HL}"
}

test_multiple_dockerfiles() {
  local TMPFILE=""
  TMPFILE="$(mktemp ${MKDIR_PREFIX})"
  cp fixtures/Dockerfile-valid "${TMPFILE}"
  assert_status_code 0 "dockerfile=\"fixtures/Dockerfile-valid ${TMPFILE}\" ${HL}"
}

test_version_output() {
  # We have to control our own file stream in order to pick up what we're sending to github outputs
  local TMPFILE=""
  TMPFILE="$(mktemp ${MKDIR_PREFIX})"
  GITHUB_OUTPUT="${TMPFILE}" GITHUB_ACTIONS=true dockerfile=fixtures/default-path/Dockerfile ${HL} &>/dev/null
  assert "cat ${TMPFILE} | grep -q hadolint_version" "hadolint should show the version as a github output"
}

test_output_with_nonzero_exit() {
  assert "dockerfile=fixtures/Dockerfile-error ${HL} | grep 'MAINTAINER is deprecated'" "hadolint warnings should surface"
  assert_fail "dockerfile=fixtures/Dockerfile-error ${HL}"
}

test_override_errorlevel() {
  assert "error_level=-1 dockerfile=fixtures/Dockerfile-error ${HL}" "changes to error level should be respected"
  assert_fail "dockerfile=fixtures/Dockerfile-error ${HL}"
  assert_fail "error_level=2 dockerfile=fixtures/Dockerfile-error ${HL}"
  assert "error_level=2 dockerfile=fixtures/Dockerfile-valid ${HL}" "changes to error level should be respected"
  assert "dockerfile=fixtures/Dockerfile-warning ${HL}" "changes to error level should be respected"
  assert_fail "error_level=1 dockerfile=fixtures/Dockerfile-warning ${HL}"
}

test_custom_config() {
  assert_status_code 0 "config_file=fixtures/ignore-DL4000.yml dockerfile=fixtures/Dockerfile-error ${HL}"
}

test_default_hadolint_config() {
  cd fixtures/default-hadolint-path || exit 1
  assert_status_code 0 "dockerfile=../Dockerfile-error ../../${HL}"
}

test_annotate() {
  # assume that we're in a github action environment
  assert "GITHUB_ACTIONS=true dockerfile=fixtures/Dockerfile-error ${HL} | grep '::add-matcher::'" "output format should follow annotation rules"
}

test_disable_annotate() {
  assert_status_code 1 "annotate=false dockerfile=fixtures/Dockerfile-error ${HL} | grep '::add-matcher::'"
}

test_custom_output_format() {
  assert "output_format=json dockerfile=fixtures/Dockerfile-error ${HL} | grep hadolint_output" "output format should be changeable"
  # gitlab seems to output a fingerprint for errors
  assert "output_format=gitlab_codeclimate dockerfile=fixtures/Dockerfile-error ${HL} | grep fingerprint"
}

test_bash_glob_expansion() {
  assert "output_format=tty dockerfile=fixtures/**/Dockerfile-glob* ${HL}" "expand shell globs before passing to hadolint"
}

test_ci_vs_non_ci_hadolint_version_output() {
  local TMPFILE=""
  TMPFILE="$(mktemp ${MKDIR_PREFIX})"
  # Test CI behavior - should write version to GITHUB_OUTPUT
  GITHUB_OUTPUT="${TMPFILE}" GITHUB_ACTIONS=true dockerfile=fixtures/default-path/Dockerfile ${HL} &>/dev/null
  assert "cat ${TMPFILE} | grep -q hadolint_version" "CI mode should write version to GITHUB_OUTPUT"
  # Clear the file
  > "${TMPFILE}"
  # Test non-CI behavior - should NOT write version to output file
  GITHUB_OUTPUT="${TMPFILE}" GITHUB_ACTIONS=false dockerfile=fixtures/default-path/Dockerfile ${HL} &>/dev/null
  assert_status_code 1 "cat ${TMPFILE} | grep -q hadolint_version" "non-CI mode should not write version to GITHUB_OUTPUT"
}

test_ci_vs_non_ci_annotation_behavior() {
  # Test CI with annotation enabled (default) - should add matcher
  assert "GITHUB_ACTIONS=true dockerfile=fixtures/Dockerfile-error ${HL} | grep '::add-matcher::'" "CI mode with annotate=true should add matcher"
  # Test non-CI - should not add matcher even with annotate=true
  assert_status_code 1 "GITHUB_ACTIONS=false dockerfile=fixtures/Dockerfile-error ${HL} | grep '::add-matcher::'" "non-CI mode should not add matcher"
}
