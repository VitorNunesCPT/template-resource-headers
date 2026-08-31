#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/branding-header.sh <check|apply> [--json] [--force] [--no-restart]
USAGE
}

COMMAND="${1:-}"
shift || true

case "${COMMAND}" in
  check|apply) ;;
  "")
    usage
    exit 2
    ;;
  *)
    echo "Unknown command: ${COMMAND}" >&2
    usage
    exit 2
    ;;
esac

OUTPUT_FORMAT="text"
FORCE=0
NO_RESTART=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) OUTPUT_FORMAT="json" ;;
    --force) FORCE=1 ;;
    --no-restart) NO_RESTART=1 ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
  shift
done

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  set -o allexport
  # shellcheck disable=SC1091
  if ! source "${REPO_ROOT}/.env"; then
    echo "invalid project configuration: ${REPO_ROOT}/.env" >&2
    exit 2
  fi
  set +o allexport
fi

CONFIG="${CONFIG:-${HOME}/.jitsi-meet-cfg}"
LOGOS_SOURCE_DIR="${BRANDING_HEADER_LOGOS_DIR:-${REPO_ROOT}/resources/branding-header/logos}"
CHECK_NAMES=()
CHECK_STATUSES=()
CHECK_MESSAGES=()
MESSAGES=()
FORCE_APPLIED=0

add_check() {
  local name="$1"
  local check_status="$2"
  local message="$3"

  CHECK_NAMES+=("${name}")
  CHECK_STATUSES+=("${check_status}")
  CHECK_MESSAGES+=("${message}")
  if [[ "${check_status}" != "pass" ]]; then
    MESSAGES+=("${message}")
  fi
}

die_config() {
  echo "invalid branding configuration: $1" >&2
  exit 2
}

require_config_value() {
  local name="$1"
  local value="${2:-}"

  [[ -n "${value}" ]] || die_config "${name} is required"
}

validate_css_color() {
  local name="$1"
  local value="$2"

  [[ "${value}" =~ ^(#[0-9A-Fa-f]{3}|#[0-9A-Fa-f]{4}|#[0-9A-Fa-f]{6}|#[0-9A-Fa-f]{8}|[A-Za-z]+)$ ]] || \
    die_config "${name}=${value}"
}

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[&|]/\\&/g'
}

check_repo_contract() {
  local failures=0

  if [[ -f "${REPO_ROOT}/web/rootfs/etc/cont-init.d/10-config" ]]; then
    add_check "repo.10_config" "pass" "startup script exists"
  else
    add_check "repo.10_config" "fail" "missing 10-config"
    ((failures += 1))
  fi

  if grep -q '/config/nginx/custom-meet.conf' "${REPO_ROOT}/web/rootfs/etc/cont-init.d/10-config" 2>/dev/null; then
    add_check "repo.custom_meet_hook" "pass" "repository startup script loads /config/nginx/custom-meet.conf"
  else
    add_check "repo.custom_meet_hook" "fail" "missing custom-meet hook"
    ((failures += 1))
  fi

  if [[ -f "${REPO_ROOT}/docker-compose.yml" ]]; then
    add_check "repo.compose_file" "pass" "docker-compose.yml exists"
  else
    add_check "repo.compose_file" "fail" "missing docker-compose.yml"
    ((failures += 1))
  fi

  if grep -q '\${CONFIG}/web:/config' "${REPO_ROOT}/docker-compose.yml" 2>/dev/null; then
    add_check "repo.config_mount" "pass" "web service mounts ${CONFIG}/web at /config"
  else
    add_check "repo.config_mount" "fail" "missing /config mount"
    ((failures += 1))
  fi

  ((failures == 0))
}

detect_runtime_state() {
  local ps_output
  local failures=0

  if ! ps_output="$(docker compose ps web --format json 2>/dev/null)"; then
    add_check "runtime.web_container" "fail" "unable to inspect web container state"
    return 1
  fi

  if ! grep -q '"State":"running"' <<< "${ps_output}"; then
    add_check "runtime.web_container" "pending" "runtime validation pending: web container is not running"
    add_check "runtime.config_dir" "pending" "runtime validation pending for /config"
    add_check "runtime.jitsi_dir" "pending" "runtime validation pending for /usr/share/jitsi-meet"
    add_check "runtime.meet_conf" "pending" "runtime validation pending for /config/nginx/meet.conf"
    add_check "runtime.custom_meet_hook" "pending" "runtime validation pending for custom-meet hook"
    return 0
  fi

  add_check "runtime.web_container" "pass" "web container is running"

  if docker compose exec -T web test -d /config; then
    add_check "runtime.config_dir" "pass" "/config exists in running container"
  else
    add_check "runtime.config_dir" "fail" "runtime check failed: test -d /config"
    ((failures += 1))
  fi

  if docker compose exec -T web test -d /usr/share/jitsi-meet; then
    add_check "runtime.jitsi_dir" "pass" "/usr/share/jitsi-meet exists in running container"
  else
    add_check "runtime.jitsi_dir" "fail" "runtime check failed: test -d /usr/share/jitsi-meet"
    ((failures += 1))
  fi

  if docker compose exec -T web test -f /config/nginx/meet.conf; then
    add_check "runtime.meet_conf" "pass" "/config/nginx/meet.conf exists in running container"
  else
    add_check "runtime.meet_conf" "fail" "runtime check failed: test -f /config/nginx/meet.conf"
    ((failures += 1))
  fi

  if docker compose exec -T web sh -c \
    'test -f /etc/cont-init.d/10-config && grep -Fq -- /config/nginx/custom-meet.conf /etc/cont-init.d/10-config'; then
    add_check "runtime.custom_meet_hook" "pass" "running image loads /config/nginx/custom-meet.conf"
  else
    add_check "runtime.custom_meet_hook" "fail" "running image does not load /config/nginx/custom-meet.conf"
    ((failures += 1))
  fi

  ((failures == 0))
}

json_escape() {
  local value="$1"

  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "${value}"
}

emit_result() {
  local result_status="$1"
  local index
  local separator=""

  if [[ "${OUTPUT_FORMAT}" == "json" ]]; then
    printf '{"status":"%s","checks":[' "${result_status}"
    for index in "${!CHECK_NAMES[@]}"; do
      printf '%s{"name":"%s","status":"%s","message":"%s"}' \
        "${separator}" \
        "$(json_escape "${CHECK_NAMES[${index}]}")" \
        "$(json_escape "${CHECK_STATUSES[${index}]}")" \
        "$(json_escape "${CHECK_MESSAGES[${index}]}")"
      separator=","
    done
    printf '],"messages":['
    separator=""
    for index in "${!MESSAGES[@]}"; do
      printf '%s"%s"' "${separator}" "$(json_escape "${MESSAGES[${index}]}")"
      separator=","
    done
    printf ']}\n'
  else
    printf 'status=%s\n' "${result_status}"
    for index in "${!CHECK_NAMES[@]}"; do
      printf '[%s] %s: %s\n' \
        "${CHECK_STATUSES[${index}]}" "${CHECK_NAMES[${index}]}" "${CHECK_MESSAGES[${index}]}"
    done
  fi
}

run_check() {
  local result_status="compatible"
  local check_status

  check_repo_contract || true
  detect_runtime_state || true

  for check_status in "${CHECK_STATUSES[@]}"; do
    if [[ "${check_status}" == "fail" ]]; then
      result_status="incompatible"
      break
    fi
    if [[ "${check_status}" == "pending" ]]; then
      result_status="partial"
    fi
  done

  emit_result "${result_status}"

  case "${result_status}" in
    compatible|partial) return 0 ;;
    incompatible) return 1 ;;
  esac
}

load_branding_config() {
  BRANDING_CONFIG_FILE="${CONFIG}/web/branding/branding-header.env"

  if [[ ! -f "${BRANDING_CONFIG_FILE}" ]]; then
    cp -f "${REPO_ROOT}/resources/branding-header/branding-header.env.example" "${BRANDING_CONFIG_FILE}"
  fi

  set -o allexport
  # shellcheck disable=SC1090
  if ! source "${BRANDING_CONFIG_FILE}"; then
    set +o allexport
    die_config "unable to load ${BRANDING_CONFIG_FILE}"
  fi
  set +o allexport

  local variable
  for variable in \
    HEADER_BG HEADER_HEIGHT HEADER_MOBILE_BREAKPOINT \
    HEADER_DESKTOP_GAP HEADER_MOBILE_GAP \
    HEADER_DESKTOP_PADDING_X HEADER_MOBILE_PADDING_X \
    HEADER_DESKTOP_LOGOS HEADER_MOBILE_LOGOS \
    WELCOME_TITLE WELCOME_SUBTITLE WELCOME_PROMPT \
    WELCOME_PLACEHOLDER WELCOME_BUTTON_LABEL \
    WELCOME_PRIMARY_COLOR WELCOME_TEXT_COLOR \
    WELCOME_MUTED_COLOR WELCOME_BACKGROUND_START \
    WELCOME_BACKGROUND_END WELCOME_FEATURE_1_TITLE \
    WELCOME_FEATURE_1_BODY WELCOME_FEATURE_2_TITLE \
    WELCOME_FEATURE_2_BODY WELCOME_FEATURE_3_TITLE \
    WELCOME_FEATURE_3_BODY WELCOME_STEPS_TITLE \
    WELCOME_STEP_1_NUMBER WELCOME_STEP_1_TITLE \
    WELCOME_STEP_1_BODY WELCOME_STEP_2_NUMBER \
    WELCOME_STEP_2_TITLE WELCOME_STEP_2_BODY \
    WELCOME_STEP_3_NUMBER WELCOME_STEP_3_TITLE \
    WELCOME_STEP_3_BODY; do
    require_config_value "${variable}" "${!variable:-}"
  done

  validate_css_color "HEADER_BG" "${HEADER_BG}"
  [[ "${HEADER_MOBILE_BREAKPOINT}" =~ ^[0-9]+$ ]] || \
    die_config "HEADER_MOBILE_BREAKPOINT=${HEADER_MOBILE_BREAKPOINT}"
  validate_css_color "WELCOME_PRIMARY_COLOR" "${WELCOME_PRIMARY_COLOR}"
  validate_css_color "WELCOME_TEXT_COLOR" "${WELCOME_TEXT_COLOR}"
  validate_css_color "WELCOME_MUTED_COLOR" "${WELCOME_MUTED_COLOR}"
  validate_css_color "WELCOME_BACKGROUND_START" "${WELCOME_BACKGROUND_START}"
  validate_css_color "WELCOME_BACKGROUND_END" "${WELCOME_BACKGROUND_END}"

  for variable in \
    HEADER_HEIGHT HEADER_DESKTOP_GAP HEADER_MOBILE_GAP \
    HEADER_DESKTOP_PADDING_X HEADER_MOBILE_PADDING_X; do
    validate_css_length "${variable}" "${!variable}"
  done

  LOGO_FILES=()
  LOGO_MAX_HEIGHTS=()
  LOGO_WIDTHS=()
  register_logo_list "HEADER_DESKTOP_LOGOS" "${HEADER_DESKTOP_LOGOS}"
  register_logo_list "HEADER_MOBILE_LOGOS" "${HEADER_MOBILE_LOGOS}"
  validate_logo_assets
}

validate_css_length() {
  local name="$1"
  local value="$2"

  [[ "${value}" =~ ^(0|[0-9]+([.][0-9]+)?(px|rem|em|vh|vw|%))$ ]] || \
    die_config "${name}=${value}"
}

register_logo() {
  local logo="$1"
  local existing_index
  local index
  local max_height_variable
  local width_variable
  local max_height
  local width

  [[ "${logo}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die_config "invalid logo name: ${logo}"

  for ((existing_index = 0; existing_index < ${#LOGO_FILES[@]}; existing_index += 1)); do
    [[ "${LOGO_FILES[${existing_index}]}" == "${logo}" ]] && return 0
  done

  index=$((${#LOGO_FILES[@]} + 1))
  max_height_variable="LOGO_${index}_MAX_HEIGHT"
  width_variable="LOGO_${index}_WIDTH"
  max_height="${!max_height_variable:-}"
  width="${!width_variable:-}"

  [[ -n "${max_height}" ]] || die_config "${max_height_variable} is required for ${logo}"
  validate_css_length "${max_height_variable}" "${max_height}"
  if [[ -n "${width}" ]]; then
    validate_css_length "${width_variable}" "${width}"
  fi

  LOGO_FILES+=("${logo}")
  LOGO_MAX_HEIGHTS+=("${max_height}")
  LOGO_WIDTHS+=("${width}")
}

register_logo_list() {
  local name="$1"
  local list="$2"
  local logo
  local logos=()

  [[ "${list}" != ,* && "${list}" != *, && "${list}" != *,,* ]] || \
    die_config "${name} contains an empty logo"
  IFS=',' read -r -a logos <<< "${list}"
  ((${#logos[@]} > 0)) || die_config "${name} must contain at least one logo"
  for logo in "${logos[@]}"; do
    [[ -n "${logo}" ]] || die_config "${name} contains an empty logo"
    register_logo "${logo}"
  done
}

validate_logo_assets() {
  local index
  local logo

  for index in "${!LOGO_FILES[@]}"; do
    logo="${LOGO_FILES[${index}]}"
    [[ -f "${LOGOS_SOURCE_DIR}/${logo}" ]] || die_config "missing logo: ${logo}"
  done
}

render_header_css() {
  sed \
    -e "s|__HEADER_BG__|$(escape_sed_replacement "${HEADER_BG}")|g" \
    -e "s|__HEADER_HEIGHT__|$(escape_sed_replacement "${HEADER_HEIGHT}")|g" \
    -e "s|__HEADER_MOBILE_BREAKPOINT__|$(escape_sed_replacement "${HEADER_MOBILE_BREAKPOINT}")|g" \
    -e "s|__HEADER_DESKTOP_GAP__|$(escape_sed_replacement "${HEADER_DESKTOP_GAP}")|g" \
    -e "s|__HEADER_MOBILE_GAP__|$(escape_sed_replacement "${HEADER_MOBILE_GAP}")|g" \
    -e "s|__HEADER_DESKTOP_PADDING_X__|$(escape_sed_replacement "${HEADER_DESKTOP_PADDING_X}")|g" \
    -e "s|__HEADER_MOBILE_PADDING_X__|$(escape_sed_replacement "${HEADER_MOBILE_PADDING_X}")|g" \
    "${REPO_ROOT}/resources/branding-header/header.css.tpl" > "${CONFIG}/web/branding/header.css"
}

logo_list_to_js() {
  local list="$1"
  local logo
  local logos=()
  local separator=""
  local result="["

  IFS=',' read -r -a logos <<< "${list}"
  for logo in "${logos[@]}"; do
    result+="${separator}\"${logo}\""
    separator=","
  done
  printf '%s]' "${result}"
}

logo_styles_to_js() {
  local index
  local separator=""
  local width
  local result="{"

  for index in "${!LOGO_FILES[@]}"; do
    width="null"
    if [[ -n "${LOGO_WIDTHS[${index}]}" ]]; then
      width="\"${LOGO_WIDTHS[${index}]}\""
    fi
    result+="${separator}\"${LOGO_FILES[${index}]}\":{\"maxHeight\":\"${LOGO_MAX_HEIGHTS[${index}]}\",\"width\":${width}}"
    separator=","
  done
  printf '%s}' "${result}"
}

render_header_js() {
  local desktop_logos mobile_logos logo_styles
  desktop_logos="$(logo_list_to_js "${HEADER_DESKTOP_LOGOS}")"
  mobile_logos="$(logo_list_to_js "${HEADER_MOBILE_LOGOS}")"
  logo_styles="$(logo_styles_to_js)"

  sed \
    -e "s|__HEADER_DESKTOP_LOGOS__|$(escape_sed_replacement "${desktop_logos}")|g" \
    -e "s|__HEADER_MOBILE_LOGOS__|$(escape_sed_replacement "${mobile_logos}")|g" \
    -e "s|__LOGO_STYLES__|$(escape_sed_replacement "${logo_styles}")|g" \
    -e "s|__HEADER_MOBILE_BREAKPOINT__|$(escape_sed_replacement "${HEADER_MOBILE_BREAKPOINT}")|g" \
    "${REPO_ROOT}/resources/branding-header/header.js.tpl" > "${CONFIG}/web/branding/header.js"
}

welcome_config_to_js() {
  cat <<EOF
{"title":"$(json_escape "${WELCOME_TITLE}")","subtitle":"$(json_escape "${WELCOME_SUBTITLE}")","prompt":"$(json_escape "${WELCOME_PROMPT}")","placeholder":"$(json_escape "${WELCOME_PLACEHOLDER}")","buttonLabel":"$(json_escape "${WELCOME_BUTTON_LABEL}")","features":[{"icon":"video","title":"$(json_escape "${WELCOME_FEATURE_1_TITLE}")","body":"$(json_escape "${WELCOME_FEATURE_1_BODY}")"},{"icon":"clock","title":"$(json_escape "${WELCOME_FEATURE_2_TITLE}")","body":"$(json_escape "${WELCOME_FEATURE_2_BODY}")"},{"icon":"lock","title":"$(json_escape "${WELCOME_FEATURE_3_TITLE}")","body":"$(json_escape "${WELCOME_FEATURE_3_BODY}")"}],"steps":{"title":"$(json_escape "${WELCOME_STEPS_TITLE}")","items":[{"number":"$(json_escape "${WELCOME_STEP_1_NUMBER}")","title":"$(json_escape "${WELCOME_STEP_1_TITLE}")","body":"$(json_escape "${WELCOME_STEP_1_BODY}")"},{"number":"$(json_escape "${WELCOME_STEP_2_NUMBER}")","title":"$(json_escape "${WELCOME_STEP_2_TITLE}")","body":"$(json_escape "${WELCOME_STEP_2_BODY}")"},{"number":"$(json_escape "${WELCOME_STEP_3_NUMBER}")","title":"$(json_escape "${WELCOME_STEP_3_TITLE}")","body":"$(json_escape "${WELCOME_STEP_3_BODY}")"}]}}
EOF
}

render_welcome_css() {
  sed \
    -e "s|__WELCOME_PRIMARY_COLOR__|$(escape_sed_replacement "${WELCOME_PRIMARY_COLOR}")|g" \
    -e "s|__WELCOME_TEXT_COLOR__|$(escape_sed_replacement "${WELCOME_TEXT_COLOR}")|g" \
    -e "s|__WELCOME_MUTED_COLOR__|$(escape_sed_replacement "${WELCOME_MUTED_COLOR}")|g" \
    -e "s|__WELCOME_BACKGROUND_START__|$(escape_sed_replacement "${WELCOME_BACKGROUND_START}")|g" \
    -e "s|__WELCOME_BACKGROUND_END__|$(escape_sed_replacement "${WELCOME_BACKGROUND_END}")|g" \
    -e "s|__HEADER_MOBILE_BREAKPOINT__|$(escape_sed_replacement "${HEADER_MOBILE_BREAKPOINT}")|g" \
    "${REPO_ROOT}/resources/branding-header/welcome.css.tpl" > "${CONFIG}/web/branding/welcome.css"
}

render_welcome_js() {
  local welcome_config
  welcome_config="$(welcome_config_to_js)"

  sed \
    -e "s|__WELCOME_CONFIG__|$(escape_sed_replacement "${welcome_config}")|g" \
    "${REPO_ROOT}/resources/branding-header/welcome.js.tpl" > "${CONFIG}/web/branding/welcome.js"
}

copy_logo_assets() {
  local index
  local logo

  for index in "${!LOGO_FILES[@]}"; do
    logo="${LOGO_FILES[${index}]}"
    [[ -f "${LOGOS_SOURCE_DIR}/${logo}" ]] || die_config "missing logo: ${logo}"
    cp -f "${LOGOS_SOURCE_DIR}/${logo}" "${CONFIG}/web/branding/${logo}"
  done
}

run_apply() {
  if ! run_check; then
    (( FORCE == 1 )) || return 1
    FORCE_APPLIED=1
  fi

  mkdir -p "${CONFIG}/web/nginx" "${CONFIG}/web/branding"
  load_branding_config
  render_header_css
  render_header_js
  render_welcome_css
  render_welcome_js
  cp -f "${REPO_ROOT}/resources/branding-header/custom-meet.conf" "${CONFIG}/web/nginx/custom-meet.conf"
  copy_logo_assets

  if (( NO_RESTART == 0 )); then
    docker compose restart web
  fi

  if (( FORCE_APPLIED == 1 )); then
    echo "applied with force"
  else
    echo "applied"
  fi
}

case "${COMMAND}" in
  check) run_check ;;
  apply) run_apply ;;
esac
