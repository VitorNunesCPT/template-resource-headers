#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HEADER_TEMPLATE="${REPO_ROOT}/resources/branding-header/header.js.tpl"
WELCOME_TEMPLATE="${REPO_ROOT}/resources/branding-header/welcome.js.tpl"

if grep -q "isWelcomeRoute" "${HEADER_TEMPLATE}"; then
  echo "FAIL: header.js.tpl still restricts the branding header to welcome routes" >&2
  exit 1
fi

if ! grep -q "isWelcomeRoute" "${WELCOME_TEMPLATE}"; then
  echo "FAIL: welcome.js.tpl must keep the welcome page customization route-scoped" >&2
  exit 1
fi

echo "PASS: branding header is global and welcome customization remains route-scoped"
