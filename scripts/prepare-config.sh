#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [[ -f "${ENV_FILE}" ]]; then
    # Export variables defined in .env so CONFIG (and others) are available.
    set -o allexport
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +o allexport
fi

CONFIG="${CONFIG:-${HOME}/.jitsi-meet-cfg}"
CONFIG_WEB_DIR="${CONFIG}/web"
CUSTOM_CONFIG_FILE="${CONFIG_WEB_DIR}/custom-config.js"
CUSTOM_INTERFACE_CONFIG_FILE="${CONFIG_WEB_DIR}/custom-interface_config.js"
#here
BRANDING_SCRIPT="${SCRIPT_DIR}/branding-header.sh"

mkdir -p "${CONFIG_WEB_DIR}"

if [[ -f "${REPO_ROOT}/config.js" ]]; then
    cp -f "${REPO_ROOT}/config.js" "${CUSTOM_CONFIG_FILE}"
    echo "config.js -> ${CUSTOM_CONFIG_FILE}"
fi

if [[ -f "${REPO_ROOT}/interface_config.js" ]]; then
    cp -f "${REPO_ROOT}/interface_config.js" "${CUSTOM_INTERFACE_CONFIG_FILE}"
    echo "interface_config.js -> ${CUSTOM_INTERFACE_CONFIG_FILE}"
fi
#here
if [[ "${ENABLE_BRANDING_HEADER:-0}" == "1" ]]; then
    "${BRANDING_SCRIPT}" apply --no-restart
fi
#tohere

COMPOSE_ARGS=("$@")
if [[ ${#COMPOSE_ARGS[@]} -eq 0 ]]; then
    COMPOSE_ARGS=("up" "-d")
fi

cd "${REPO_ROOT}"
docker compose "${COMPOSE_ARGS[@]}"
