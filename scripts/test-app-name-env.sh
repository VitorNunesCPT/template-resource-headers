#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREPARE_SCRIPT="${REPO_ROOT}/scripts/prepare-config.sh"
ENV_EXAMPLE="${REPO_ROOT}/env.example"

if ! grep -q "JITSI_APP_NAME" "${ENV_EXAMPLE}"; then
  echo "FAIL: env.example does not document JITSI_APP_NAME" >&2
  exit 1
fi

if ! grep -q '#JITSI_APP_NAME="Consultorio Virtual"' "${ENV_EXAMPLE}"; then
  echo "FAIL: env.example must quote JITSI_APP_NAME because app names may contain spaces" >&2
  exit 1
fi

if ! grep -q "JITSI_APP_NAME" "${PREPARE_SCRIPT}"; then
  echo "FAIL: prepare-config.sh does not read JITSI_APP_NAME" >&2
  exit 1
fi

if ! grep -q "interfaceConfig.APP_NAME" "${PREPARE_SCRIPT}"; then
  echo "FAIL: prepare-config.sh does not override APP_NAME" >&2
  exit 1
fi

if ! grep -q "interfaceConfig.NATIVE_APP_NAME" "${PREPARE_SCRIPT}"; then
  echo "FAIL: prepare-config.sh does not override NATIVE_APP_NAME" >&2
  exit 1
fi

echo "PASS: JITSI_APP_NAME is documented and handled by prepare-config.sh"
