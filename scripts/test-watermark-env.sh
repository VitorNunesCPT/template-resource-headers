#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREPARE_SCRIPT="${REPO_ROOT}/scripts/prepare-config.sh"
ENV_EXAMPLE="${REPO_ROOT}/env.example"

if ! grep -q "DISABLE_JITSI_WATERMARK" "${ENV_EXAMPLE}"; then
  echo "FAIL: env.example does not document DISABLE_JITSI_WATERMARK" >&2
  exit 1
fi

if ! grep -q "DISABLE_JITSI_WATERMARK" "${PREPARE_SCRIPT}"; then
  echo "FAIL: prepare-config.sh does not read DISABLE_JITSI_WATERMARK" >&2
  exit 1
fi

if ! grep -q "interfaceConfig.SHOW_JITSI_WATERMARK = false" "${PREPARE_SCRIPT}"; then
  echo "FAIL: prepare-config.sh does not disable SHOW_JITSI_WATERMARK" >&2
  exit 1
fi

echo "PASS: DISABLE_JITSI_WATERMARK is documented and handled by prepare-config.sh"
