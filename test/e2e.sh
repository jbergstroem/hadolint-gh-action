#!/usr/bin/env bash_unit

HL="../hadolint.sh"

test_default_path() {
  # This should fail since we can't find a Dockerfile in this directory
  assert_status_code 1 "${HL}"
}

test_default_path_with_dockerfile() {
  cd fixtures/default-path || exit 1
  assert_status_code 0 "../../${HL}"
}

test_custom_hadolint_path() {
  # Since test runners should have jq installed, lets find path and set it
  assert_status_code 0 "hadolint_path=$(which hadolint) dockerfile=fixtures/default-path/Dockerfile ${HL}"
}

test_custom_dockerfile_path() {
  assert_status_code 0 "dockerfile=fixtures/default-path/Dockerfile ${HL}"
}

test_version_output() {
  # this basically runs a "happy path" and captures output
  assert "dockerfile=fixtures/default-path/Dockerfile ${HL} | grep hadolint_version"
}

test_output_with_nonzero_exit() {
  assert "dockerfile=fixtures/Dockerfile-error ${HL} | grep 'MAINTAINER is deprecated'"
  assert_fail "dockerfile=fixtures/Dockerfile-error ${HL}"
}

test_override_errorlevel() {
  assert "error_level=-1 dockerfile=fixtures/Dockerfile-error ${HL}"
  assert_fail "dockerfile=fixtures/Dockerfile-error ${HL}"
  assert_fail "error_level=2 dockerfile=fixtures/Dockerfile-error ${HL}"
  assert "dockerfile=fixtures/Dockerfile-warning ${HL}"
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
  assert "dockerfile=fixtures/Dockerfile-error ${HL} | grep '::error'"
}

test_disable_annotate() {
  assert_status_code 1 "annotate=false dockerfile=fixtures/Dockerfile-error ${HL} | grep '::error'"
}

test_custom_output_format() {
  assert "output_format=tty dockerfile=fixtures/Dockerfile-error ${HL} | grep '::set-output'"
  # gitlab seems to output a fingerprint for errors
  assert "output_format=gitlab_codeclimate dockerfile=fixtures/Dockerfile-error ${HL} | grep fingerprint"
}