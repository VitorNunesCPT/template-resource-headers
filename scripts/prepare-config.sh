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
CONFIG_PROSODY_CUSTOM_PLUGINS_DIR="${CONFIG}/prosody/prosody-plugins-custom"
CUSTOM_CONFIG_FILE="${CONFIG_WEB_DIR}/custom-config.js"
CUSTOM_INTERFACE_CONFIG_FILE="${CONFIG_WEB_DIR}/custom-interface_config.js"
BRANDING_SCRIPT="${SCRIPT_DIR}/branding-header.sh"
CUSTOM_PROSODY_PLUGINS_SRC_DIR="${REPO_ROOT}/resources/prosody-plugins-custom"
WATERMARK_MARKER_BEGIN="// BEGIN managed jitsi watermark"
WATERMARK_MARKER_END="// END managed jitsi watermark"
APP_NAME_MARKER_BEGIN="// BEGIN managed jitsi app name"
APP_NAME_MARKER_END="// END managed jitsi app name"

remove_managed_block() {
    local file="$1"
    local begin="$2"
    local end="$3"
    local tmp_file

    [[ -f "${file}" ]] || return 0

    tmp_file="$(mktemp)"
    awk \
        -v begin="${begin}" \
        -v end="${end}" \
        '$0 == begin { skip = 1; next } $0 == end { skip = 0; next } skip != 1 { print }' \
        "${file}" > "${tmp_file}"
    mv "${tmp_file}" "${file}"
}

escape_js_single_quoted_string() {
    printf '%s' "$1" | sed -e "s/\\\\/\\\\\\\\/g" -e "s/'/\\\\'/g"
}

apply_watermark_config() {
    if [[ ! -f "${CUSTOM_INTERFACE_CONFIG_FILE}" ]]; then
        : > "${CUSTOM_INTERFACE_CONFIG_FILE}"
    fi

    remove_managed_block "${CUSTOM_INTERFACE_CONFIG_FILE}" "${WATERMARK_MARKER_BEGIN}" "${WATERMARK_MARKER_END}"

    if [[ "${DISABLE_JITSI_WATERMARK:-0}" == "1" ]]; then
        cat >> "${CUSTOM_INTERFACE_CONFIG_FILE}" <<EOF

${WATERMARK_MARKER_BEGIN}
interfaceConfig.SHOW_JITSI_WATERMARK = false;
${WATERMARK_MARKER_END}
EOF
        echo "Jitsi watermark disabled -> ${CUSTOM_INTERFACE_CONFIG_FILE}"
    fi
}

apply_app_name_config() {
    local app_name

    if [[ ! -f "${CUSTOM_INTERFACE_CONFIG_FILE}" ]]; then
        : > "${CUSTOM_INTERFACE_CONFIG_FILE}"
    fi

    remove_managed_block "${CUSTOM_INTERFACE_CONFIG_FILE}" "${APP_NAME_MARKER_BEGIN}" "${APP_NAME_MARKER_END}"

    if [[ -n "${JITSI_APP_NAME:-}" ]]; then
        app_name="$(escape_js_single_quoted_string "${JITSI_APP_NAME}")"
        cat >> "${CUSTOM_INTERFACE_CONFIG_FILE}" <<EOF

${APP_NAME_MARKER_BEGIN}
interfaceConfig.APP_NAME = '${app_name}';
interfaceConfig.NATIVE_APP_NAME = '${app_name}';
${APP_NAME_MARKER_END}
EOF
        echo "Jitsi app name set to '${JITSI_APP_NAME}' -> ${CUSTOM_INTERFACE_CONFIG_FILE}"
    fi
}

apply_custom_prosody_plugins() {
    local plugin

    [[ -d "${CUSTOM_PROSODY_PLUGINS_SRC_DIR}" ]] || return 0

    mkdir -p "${CONFIG_PROSODY_CUSTOM_PLUGINS_DIR}"

    for plugin in "${CUSTOM_PROSODY_PLUGINS_SRC_DIR}"/mod_*.lua; do
        [[ -f "${plugin}" ]] || continue
        cp -f "${plugin}" "${CONFIG_PROSODY_CUSTOM_PLUGINS_DIR}/"
        echo "$(basename "${plugin}") -> ${CONFIG_PROSODY_CUSTOM_PLUGINS_DIR}/"
    done
}

mkdir -p "${CONFIG_WEB_DIR}"

if [[ -f "${REPO_ROOT}/config.js" ]]; then
    cp -f "${REPO_ROOT}/config.js" "${CUSTOM_CONFIG_FILE}"
    echo "config.js -> ${CUSTOM_CONFIG_FILE}"
fi

if [[ -f "${REPO_ROOT}/interface_config.js" ]]; then
    cp -f "${REPO_ROOT}/interface_config.js" "${CUSTOM_INTERFACE_CONFIG_FILE}"
    echo "interface_config.js -> ${CUSTOM_INTERFACE_CONFIG_FILE}"
fi

apply_watermark_config
apply_app_name_config
apply_custom_prosody_plugins

if [[ "${ENABLE_BRANDING_HEADER:-0}" == "1" ]]; then
    "${BRANDING_SCRIPT}" apply --no-restart
fi

COMPOSE_ARGS=("$@")
if [[ ${#COMPOSE_ARGS[@]} -eq 0 ]]; then
    COMPOSE_ARGS=("up" "-d")
fi

cd "${REPO_ROOT}"
docker compose "${COMPOSE_ARGS[@]}"
