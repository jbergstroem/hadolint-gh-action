#!/usr/bin/env bash

[[ -n "${DEBUG}" ]] && set -x
set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# shellcheck disable=SC1090 # this is intentional
. "${DIR}/lib/hadolint.sh"
# shellcheck disable=SC1090 # this is intentional
. "${DIR}/lib/main.sh"
# shellcheck disable=SC1090 # this is intentional
. "${DIR}/lib/jq.sh"
# shellcheck disable=SC1090 # this is intentional
. "${DIR}/lib/validate.sh"

run