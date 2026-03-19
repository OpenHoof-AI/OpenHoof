#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"
EXTRA_COMPOSE_FILE="$ROOT_DIR/docker-compose.extra.yml"
IMAGE_NAME="${OPENHOOF_IMAGE:-openhoof:local}"
EXTRA_MOUNTS="${OPENHOOF_EXTRA_MOUNTS:-}"
HOME_VOLUME_NAME="${OPENHOOF_HOME_VOLUME:-}"
RAW_SANDBOX_SETTING="${OPENHOOF_SANDBOX:-}"
SANDBOX_ENABLED=""
DOCKER_SOCKET_PATH="${OPENHOOF_DOCKER_SOCKET:-}"
TIMEZONE="${OPENHOOF_TZ:-}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

is_truthy_value() {
  local raw="${1:-}"
  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  case "$raw" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

read_config_gateway_token() {
  local config_path="$OPENHOOF_CONFIG_DIR/openhoof.json"
  if [[ ! -f "$config_path" ]]; then
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$config_path" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    raise SystemExit(0)

gateway = cfg.get("gateway")
if not isinstance(gateway, dict):
    raise SystemExit(0)
auth = gateway.get("auth")
if not isinstance(auth, dict):
    raise SystemExit(0)
token = auth.get("token")
if isinstance(token, str):
    token = token.strip()
    if token:
        print(token)
PY
    return 0
  fi
  if command -v node >/dev/null 2>&1; then
    node - "$config_path" <<'NODE'
const fs = require("node:fs");
const configPath = process.argv[2];
try {
  const cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));
  const token = cfg?.gateway?.auth?.token;
  if (typeof token === "string" && token.trim().length > 0) {
    process.stdout.write(token.trim());
  }
} catch {
  // Keep docker-setup resilient when config parsing fails.
}
NODE
  fi
}

read_env_gateway_token() {
  local env_path="$1"
  local line=""
  local token=""
  if [[ ! -f "$env_path" ]]; then
    return 0
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" == OPENHOOF_GATEWAY_TOKEN=* ]]; then
      token="${line#OPENHOOF_GATEWAY_TOKEN=}"
    fi
  done <"$env_path"
  if [[ -n "$token" ]]; then
    printf '%s' "$token"
  fi
}

ensure_control_ui_allowed_origins() {
  if [[ "${OPENHOOF_GATEWAY_BIND}" == "loopback" ]]; then
    return 0
  fi

  local allowed_origin_json
  local current_allowed_origins
  allowed_origin_json="$(printf '["http://127.0.0.1:%s"]' "$OPENHOOF_GATEWAY_PORT")"
  current_allowed_origins="$(
    docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli \
      config get gateway.controlUi.allowedOrigins 2>/dev/null || true
  )"
  current_allowed_origins="${current_allowed_origins//$'\r'/}"

  if [[ -n "$current_allowed_origins" && "$current_allowed_origins" != "null" && "$current_allowed_origins" != "[]" ]]; then
    echo "Control UI allowlist already configured; leaving gateway.controlUi.allowedOrigins unchanged."
    return 0
  fi

  docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli \
    config set gateway.controlUi.allowedOrigins "$allowed_origin_json" --strict-json >/dev/null
  echo "Set gateway.controlUi.allowedOrigins to $allowed_origin_json for non-loopback bind."
}

sync_gateway_mode_and_bind() {
  docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli \
    config set gateway.mode local >/dev/null
  docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli \
    config set gateway.bind "$OPENHOOF_GATEWAY_BIND" >/dev/null
  echo "Pinned gateway.mode=local and gateway.bind=$OPENHOOF_GATEWAY_BIND for Docker setup."
}

contains_disallowed_chars() {
  local value="$1"
  [[ "$value" == *$'\n'* || "$value" == *$'\r'* || "$value" == *$'\t'* ]]
}

is_valid_timezone() {
  local value="$1"
  [[ -e "/usr/share/zoneinfo/$value" && ! -d "/usr/share/zoneinfo/$value" ]]
}

validate_mount_path_value() {
  local label="$1"
  local value="$2"
  if [[ -z "$value" ]]; then
    fail "$label cannot be empty."
  fi
  if contains_disallowed_chars "$value"; then
    fail "$label contains unsupported control characters."
  fi
  if [[ "$value" =~ [[:space:]] ]]; then
    fail "$label cannot contain whitespace."
  fi
}

validate_named_volume() {
  local value="$1"
  if [[ ! "$value" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]]; then
    fail "OPENHOOF_HOME_VOLUME must match [A-Za-z0-9][A-Za-z0-9_.-]* when using a named volume."
  fi
}

validate_mount_spec() {
  local mount="$1"
  if contains_disallowed_chars "$mount"; then
    fail "OPENHOOF_EXTRA_MOUNTS entries cannot contain control characters."
  fi
  # Keep mount specs strict to avoid YAML structure injection.
  # Expected format: source:target[:options]
  if [[ ! "$mount" =~ ^[^[:space:],:]+:[^[:space:],:]+(:[^[:space:],:]+)?$ ]]; then
    fail "Invalid mount format '$mount'. Expected source:target[:options] without spaces."
  fi
}

require_cmd docker
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose not available (try: docker compose version)" >&2
  exit 1
fi

if [[ -z "$DOCKER_SOCKET_PATH" && "${DOCKER_HOST:-}" == unix://* ]]; then
  DOCKER_SOCKET_PATH="${DOCKER_HOST#unix://}"
fi
if [[ -z "$DOCKER_SOCKET_PATH" ]]; then
  DOCKER_SOCKET_PATH="/var/run/docker.sock"
fi
if is_truthy_value "$RAW_SANDBOX_SETTING"; then
  SANDBOX_ENABLED="1"
fi

OPENHOOF_CONFIG_DIR="${OPENHOOF_CONFIG_DIR:-$HOME/.openhoof}"
OPENHOOF_WORKSPACE_DIR="${OPENHOOF_WORKSPACE_DIR:-$HOME/.openhoof/workspace}"

validate_mount_path_value "OPENHOOF_CONFIG_DIR" "$OPENHOOF_CONFIG_DIR"
validate_mount_path_value "OPENHOOF_WORKSPACE_DIR" "$OPENHOOF_WORKSPACE_DIR"
if [[ -n "$HOME_VOLUME_NAME" ]]; then
  if [[ "$HOME_VOLUME_NAME" == *"/"* ]]; then
    validate_mount_path_value "OPENHOOF_HOME_VOLUME" "$HOME_VOLUME_NAME"
  else
    validate_named_volume "$HOME_VOLUME_NAME"
  fi
fi
if contains_disallowed_chars "$EXTRA_MOUNTS"; then
  fail "OPENHOOF_EXTRA_MOUNTS cannot contain control characters."
fi
if [[ -n "$SANDBOX_ENABLED" ]]; then
  validate_mount_path_value "OPENHOOF_DOCKER_SOCKET" "$DOCKER_SOCKET_PATH"
fi
if [[ -n "$TIMEZONE" ]]; then
  if contains_disallowed_chars "$TIMEZONE"; then
    fail "OPENHOOF_TZ contains unsupported control characters."
  fi
  if [[ ! "$TIMEZONE" =~ ^[A-Za-z0-9/_+\-]+$ ]]; then
    fail "OPENHOOF_TZ must be a valid IANA timezone string (e.g. Asia/Shanghai)."
  fi
  if ! is_valid_timezone "$TIMEZONE"; then
    fail "OPENHOOF_TZ must match a timezone in /usr/share/zoneinfo (e.g. Asia/Shanghai)."
  fi
fi

mkdir -p "$OPENHOOF_CONFIG_DIR"
mkdir -p "$OPENHOOF_WORKSPACE_DIR"
# Seed directory tree eagerly so bind mounts work even on Docker Desktop/Windows
# where the container (even as root) cannot create new host subdirectories.
mkdir -p "$OPENHOOF_CONFIG_DIR/identity"
mkdir -p "$OPENHOOF_CONFIG_DIR/agents/main/agent"
mkdir -p "$OPENHOOF_CONFIG_DIR/agents/main/sessions"

export OPENHOOF_CONFIG_DIR
export OPENHOOF_WORKSPACE_DIR
export OPENHOOF_GATEWAY_PORT="${OPENHOOF_GATEWAY_PORT:-18789}"
export OPENHOOF_BRIDGE_PORT="${OPENHOOF_BRIDGE_PORT:-18790}"
export OPENHOOF_GATEWAY_BIND="${OPENHOOF_GATEWAY_BIND:-lan}"
export OPENHOOF_IMAGE="$IMAGE_NAME"
export OPENHOOF_DOCKER_APT_PACKAGES="${OPENHOOF_DOCKER_APT_PACKAGES:-}"
export OPENHOOF_EXTENSIONS="${OPENHOOF_EXTENSIONS:-}"
export OPENHOOF_EXTRA_MOUNTS="$EXTRA_MOUNTS"
export OPENHOOF_HOME_VOLUME="$HOME_VOLUME_NAME"
export OPENHOOF_ALLOW_INSECURE_PRIVATE_WS="${OPENHOOF_ALLOW_INSECURE_PRIVATE_WS:-}"
export OPENHOOF_SANDBOX="$SANDBOX_ENABLED"
export OPENHOOF_DOCKER_SOCKET="$DOCKER_SOCKET_PATH"
export OPENHOOF_TZ="$TIMEZONE"

# Detect Docker socket GID for sandbox group_add.
DOCKER_GID=""
if [[ -n "$SANDBOX_ENABLED" && -S "$DOCKER_SOCKET_PATH" ]]; then
  DOCKER_GID="$(stat -c '%g' "$DOCKER_SOCKET_PATH" 2>/dev/null || stat -f '%g' "$DOCKER_SOCKET_PATH" 2>/dev/null || echo "")"
fi
export DOCKER_GID

if [[ -z "${OPENHOOF_GATEWAY_TOKEN:-}" ]]; then
  EXISTING_CONFIG_TOKEN="$(read_config_gateway_token || true)"
  if [[ -n "$EXISTING_CONFIG_TOKEN" ]]; then
    OPENHOOF_GATEWAY_TOKEN="$EXISTING_CONFIG_TOKEN"
    echo "Reusing gateway token from $OPENHOOF_CONFIG_DIR/openhoof.json"
  else
    DOTENV_GATEWAY_TOKEN="$(read_env_gateway_token "$ROOT_DIR/.env" || true)"
    if [[ -n "$DOTENV_GATEWAY_TOKEN" ]]; then
      OPENHOOF_GATEWAY_TOKEN="$DOTENV_GATEWAY_TOKEN"
      echo "Reusing gateway token from $ROOT_DIR/.env"
    elif command -v openssl >/dev/null 2>&1; then
      OPENHOOF_GATEWAY_TOKEN="$(openssl rand -hex 32)"
    else
      OPENHOOF_GATEWAY_TOKEN="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
)"
    fi
  fi
fi
export OPENHOOF_GATEWAY_TOKEN

COMPOSE_FILES=("$COMPOSE_FILE")
COMPOSE_ARGS=()

write_extra_compose() {
  local home_volume="$1"
  shift
  local mount
  local gateway_home_mount
  local gateway_config_mount
  local gateway_workspace_mount

  cat >"$EXTRA_COMPOSE_FILE" <<'YAML'
services:
  openhoof-gateway:
    volumes:
YAML

  if [[ -n "$home_volume" ]]; then
    gateway_home_mount="${home_volume}:/home/node"
    gateway_config_mount="${OPENHOOF_CONFIG_DIR}:/home/node/.openhoof"
    gateway_workspace_mount="${OPENHOOF_WORKSPACE_DIR}:/home/node/.openhoof/workspace"
    validate_mount_spec "$gateway_home_mount"
    validate_mount_spec "$gateway_config_mount"
    validate_mount_spec "$gateway_workspace_mount"
    printf '      - %s\n' "$gateway_home_mount" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s\n' "$gateway_config_mount" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s\n' "$gateway_workspace_mount" >>"$EXTRA_COMPOSE_FILE"
  fi

  for mount in "$@"; do
    validate_mount_spec "$mount"
    printf '      - %s\n' "$mount" >>"$EXTRA_COMPOSE_FILE"
  done

  cat >>"$EXTRA_COMPOSE_FILE" <<'YAML'
  openhoof-cli:
    volumes:
YAML

  if [[ -n "$home_volume" ]]; then
    printf '      - %s\n' "$gateway_home_mount" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s\n' "$gateway_config_mount" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s\n' "$gateway_workspace_mount" >>"$EXTRA_COMPOSE_FILE"
  fi

  for mount in "$@"; do
    validate_mount_spec "$mount"
    printf '      - %s\n' "$mount" >>"$EXTRA_COMPOSE_FILE"
  done

  if [[ -n "$home_volume" && "$home_volume" != *"/"* ]]; then
    validate_named_volume "$home_volume"
    cat >>"$EXTRA_COMPOSE_FILE" <<YAML
volumes:
  ${home_volume}:
YAML
  fi
}

# When sandbox is requested, ensure Docker CLI build arg is set for local builds.
# Docker socket mount is deferred until sandbox prerequisites are verified.
if [[ -n "$SANDBOX_ENABLED" ]]; then
  if [[ -z "${OPENHOOF_INSTALL_DOCKER_CLI:-}" ]]; then
    export OPENHOOF_INSTALL_DOCKER_CLI=1
  fi
fi

VALID_MOUNTS=()
if [[ -n "$EXTRA_MOUNTS" ]]; then
  IFS=',' read -r -a mounts <<<"$EXTRA_MOUNTS"
  for mount in "${mounts[@]}"; do
    mount="${mount#"${mount%%[![:space:]]*}"}"
    mount="${mount%"${mount##*[![:space:]]}"}"
    if [[ -n "$mount" ]]; then
      VALID_MOUNTS+=("$mount")
    fi
  done
fi

if [[ -n "$HOME_VOLUME_NAME" || ${#VALID_MOUNTS[@]} -gt 0 ]]; then
  # Bash 3.2 + nounset treats "${array[@]}" on an empty array as unbound.
  if [[ ${#VALID_MOUNTS[@]} -gt 0 ]]; then
    write_extra_compose "$HOME_VOLUME_NAME" "${VALID_MOUNTS[@]}"
  else
    write_extra_compose "$HOME_VOLUME_NAME"
  fi
  COMPOSE_FILES+=("$EXTRA_COMPOSE_FILE")
fi
for compose_file in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=("-f" "$compose_file")
done
# Keep a base compose arg set without sandbox overlay so rollback paths can
# force a known-safe gateway service definition (no docker.sock mount).
BASE_COMPOSE_ARGS=("${COMPOSE_ARGS[@]}")
COMPOSE_HINT="docker compose"
for compose_file in "${COMPOSE_FILES[@]}"; do
  COMPOSE_HINT+=" -f ${compose_file}"
done

ENV_FILE="$ROOT_DIR/.env"
upsert_env() {
  local file="$1"
  shift
  local -a keys=("$@")
  local tmp
  tmp="$(mktemp)"
  # Use a delimited string instead of an associative array so the script
  # works with Bash 3.2 (macOS default) which lacks `declare -A`.
  local seen=" "

  if [[ -f "$file" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      local key="${line%%=*}"
      local replaced=false
      for k in "${keys[@]}"; do
        if [[ "$key" == "$k" ]]; then
          printf '%s=%s\n' "$k" "${!k-}" >>"$tmp"
          seen="$seen$k "
          replaced=true
          break
        fi
      done
      if [[ "$replaced" == false ]]; then
        printf '%s\n' "$line" >>"$tmp"
      fi
    done <"$file"
  fi

  for k in "${keys[@]}"; do
    if [[ "$seen" != *" $k "* ]]; then
      printf '%s=%s\n' "$k" "${!k-}" >>"$tmp"
    fi
  done

  mv "$tmp" "$file"
}

upsert_env "$ENV_FILE" \
  OPENHOOF_CONFIG_DIR \
  OPENHOOF_WORKSPACE_DIR \
  OPENHOOF_GATEWAY_PORT \
  OPENHOOF_BRIDGE_PORT \
  OPENHOOF_GATEWAY_BIND \
  OPENHOOF_GATEWAY_TOKEN \
  OPENHOOF_IMAGE \
  OPENHOOF_EXTRA_MOUNTS \
  OPENHOOF_HOME_VOLUME \
  OPENHOOF_DOCKER_APT_PACKAGES \
  OPENHOOF_EXTENSIONS \
  OPENHOOF_SANDBOX \
  OPENHOOF_DOCKER_SOCKET \
  DOCKER_GID \
  OPENHOOF_INSTALL_DOCKER_CLI \
  OPENHOOF_ALLOW_INSECURE_PRIVATE_WS \
  OPENHOOF_TZ

if [[ "$IMAGE_NAME" == "openhoof:local" ]]; then
  echo "==> Building Docker image: $IMAGE_NAME"
  docker build \
    --build-arg "OPENHOOF_DOCKER_APT_PACKAGES=${OPENHOOF_DOCKER_APT_PACKAGES}" \
    --build-arg "OPENHOOF_EXTENSIONS=${OPENHOOF_EXTENSIONS}" \
    --build-arg "OPENHOOF_INSTALL_DOCKER_CLI=${OPENHOOF_INSTALL_DOCKER_CLI:-}" \
    -t "$IMAGE_NAME" \
    -f "$ROOT_DIR/Dockerfile" \
    "$ROOT_DIR"
else
  echo "==> Pulling Docker image: $IMAGE_NAME"
  if ! docker pull "$IMAGE_NAME"; then
    echo "ERROR: Failed to pull image $IMAGE_NAME. Please check the image name and your access permissions." >&2
    exit 1
  fi
fi

# Ensure bind-mounted data directories are writable by the container's `node`
# user (uid 1000). Host-created dirs inherit the host user's uid which may
# differ, causing EACCES when the container tries to mkdir/write.
# Running a brief root container to chown is the portable Docker idiom --
# it works regardless of the host uid and doesn't require host-side root.
echo ""
echo "==> Fixing data-directory permissions"
# Use -xdev to restrict chown to the config-dir mount only — without it,
# the recursive chown would cross into the workspace bind mount and rewrite
# ownership of all user project files on Linux hosts.
# After fixing the config dir, only the OpenHoof metadata subdirectory
# (.openhoof/) inside the workspace gets chowned, not the user's project files.
docker compose "${COMPOSE_ARGS[@]}" run --rm --user root --entrypoint sh openhoof-cli -c \
  'find /home/node/.openhoof -xdev -exec chown node:node {} +; \
   [ -d /home/node/.openhoof/workspace/.openhoof ] && chown -R node:node /home/node/.openhoof/workspace/.openhoof || true'

echo ""
echo "==> Onboarding (interactive)"
echo "Docker setup pins Gateway mode to local."
echo "Gateway runtime bind comes from OPENHOOF_GATEWAY_BIND (default: lan)."
echo "Current runtime bind: $OPENHOOF_GATEWAY_BIND"
echo "Gateway token: $OPENHOOF_GATEWAY_TOKEN"
echo "Tailscale exposure: Off (use host-level tailnet/Tailscale setup separately)."
echo "Install Gateway daemon: No (managed by Docker Compose)"
echo ""
docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli onboard --mode local --no-install-daemon

echo ""
echo "==> Docker gateway defaults"
sync_gateway_mode_and_bind

echo ""
echo "==> Control UI origin allowlist"
ensure_control_ui_allowed_origins

echo ""
echo "==> Provider setup (optional)"
echo "WhatsApp (QR):"
echo "  ${COMPOSE_HINT} run --rm openhoof-cli channels login"
echo "Telegram (bot token):"
echo "  ${COMPOSE_HINT} run --rm openhoof-cli channels add --channel telegram --token <token>"
echo "Discord (bot token):"
echo "  ${COMPOSE_HINT} run --rm openhoof-cli channels add --channel discord --token <token>"
echo "Docs: https://docs.openhoof.ai/channels"

echo ""
echo "==> Starting gateway"
docker compose "${COMPOSE_ARGS[@]}" up -d openhoof-gateway

# --- Sandbox setup (opt-in via OPENHOOF_SANDBOX=1) ---
if [[ -n "$SANDBOX_ENABLED" ]]; then
  echo ""
  echo "==> Sandbox setup"

  # Build sandbox image if Dockerfile.sandbox exists.
  if [[ -f "$ROOT_DIR/Dockerfile.sandbox" ]]; then
    echo "Building sandbox image: openhoof-sandbox:bookworm-slim"
    docker build \
      -t "openhoof-sandbox:bookworm-slim" \
      -f "$ROOT_DIR/Dockerfile.sandbox" \
      "$ROOT_DIR"
  else
    echo "WARNING: Dockerfile.sandbox not found in $ROOT_DIR" >&2
    echo "  Sandbox config will be applied but no sandbox image will be built." >&2
    echo "  Agent exec may fail if the configured sandbox image does not exist." >&2
  fi

  # Defense-in-depth: verify Docker CLI in the running image before enabling
  # sandbox. This avoids claiming sandbox is enabled when the image cannot
  # launch sandbox containers.
  if ! docker compose "${COMPOSE_ARGS[@]}" run --rm --entrypoint docker openhoof-gateway --version >/dev/null 2>&1; then
    echo "WARNING: Docker CLI not found inside the container image." >&2
    echo "  Sandbox requires Docker CLI. Rebuild with --build-arg OPENHOOF_INSTALL_DOCKER_CLI=1" >&2
    echo "  or use a local build (OPENHOOF_IMAGE=openhoof:local). Skipping sandbox setup." >&2
    SANDBOX_ENABLED=""
  fi
fi

# Apply sandbox config only if prerequisites are met.
if [[ -n "$SANDBOX_ENABLED" ]]; then
  # Mount Docker socket via a dedicated compose overlay. This overlay is
  # created only after sandbox prerequisites pass, so the socket is never
  # exposed when sandbox cannot actually run.
  if [[ -S "$DOCKER_SOCKET_PATH" ]]; then
    SANDBOX_COMPOSE_FILE="$ROOT_DIR/docker-compose.sandbox.yml"
    cat >"$SANDBOX_COMPOSE_FILE" <<YAML
services:
  openhoof-gateway:
    volumes:
      - ${DOCKER_SOCKET_PATH}:/var/run/docker.sock
YAML
    if [[ -n "${DOCKER_GID:-}" ]]; then
      cat >>"$SANDBOX_COMPOSE_FILE" <<YAML
    group_add:
      - "${DOCKER_GID}"
YAML
    fi
    COMPOSE_ARGS+=("-f" "$SANDBOX_COMPOSE_FILE")
    echo "==> Sandbox: added Docker socket mount"
  else
    echo "WARNING: OPENHOOF_SANDBOX enabled but Docker socket not found at $DOCKER_SOCKET_PATH." >&2
    echo "  Sandbox requires Docker socket access. Skipping sandbox setup." >&2
    SANDBOX_ENABLED=""
  fi
fi

if [[ -n "$SANDBOX_ENABLED" ]]; then
  # Enable sandbox in OpenHoof config.
  sandbox_config_ok=true
  if ! docker compose "${COMPOSE_ARGS[@]}" run --rm --no-deps openhoof-cli \
    config set agents.defaults.sandbox.mode "non-main" >/dev/null; then
    echo "WARNING: Failed to set agents.defaults.sandbox.mode" >&2
    sandbox_config_ok=false
  fi
  if ! docker compose "${COMPOSE_ARGS[@]}" run --rm --no-deps openhoof-cli \
    config set agents.defaults.sandbox.scope "agent" >/dev/null; then
    echo "WARNING: Failed to set agents.defaults.sandbox.scope" >&2
    sandbox_config_ok=false
  fi
  if ! docker compose "${COMPOSE_ARGS[@]}" run --rm --no-deps openhoof-cli \
    config set agents.defaults.sandbox.workspaceAccess "none" >/dev/null; then
    echo "WARNING: Failed to set agents.defaults.sandbox.workspaceAccess" >&2
    sandbox_config_ok=false
  fi

  if [[ "$sandbox_config_ok" == true ]]; then
    echo "Sandbox enabled: mode=non-main, scope=agent, workspaceAccess=none"
    echo "Docs: https://docs.openhoof.ai/gateway/sandboxing"
    # Restart gateway with sandbox compose overlay to pick up socket mount + config.
    docker compose "${COMPOSE_ARGS[@]}" up -d openhoof-gateway
  else
    echo "WARNING: Sandbox config was partially applied. Check errors above." >&2
    echo "  Skipping gateway restart to avoid exposing Docker socket without a full sandbox policy." >&2
    if ! docker compose "${BASE_COMPOSE_ARGS[@]}" run --rm --no-deps openhoof-cli \
      config set agents.defaults.sandbox.mode "off" >/dev/null; then
      echo "WARNING: Failed to roll back agents.defaults.sandbox.mode to off" >&2
    else
      echo "Sandbox mode rolled back to off due to partial sandbox config failure."
    fi
    if [[ -n "${SANDBOX_COMPOSE_FILE:-}" ]]; then
      rm -f "$SANDBOX_COMPOSE_FILE"
    fi
    # Ensure gateway service definition is reset without sandbox overlay mount.
    docker compose "${BASE_COMPOSE_ARGS[@]}" up -d --force-recreate openhoof-gateway
  fi
else
  # Keep reruns deterministic: if sandbox is not active for this run, reset
  # persisted sandbox mode so future execs do not require docker.sock by stale
  # config alone.
  if ! docker compose "${COMPOSE_ARGS[@]}" run --rm openhoof-cli \
    config set agents.defaults.sandbox.mode "off" >/dev/null; then
    echo "WARNING: Failed to reset agents.defaults.sandbox.mode to off" >&2
  fi
  if [[ -f "$ROOT_DIR/docker-compose.sandbox.yml" ]]; then
    rm -f "$ROOT_DIR/docker-compose.sandbox.yml"
  fi
fi

echo ""
echo "Gateway running with host port mapping."
echo "Access from tailnet devices via the host's tailnet IP."
echo "Config: $OPENHOOF_CONFIG_DIR"
echo "Workspace: $OPENHOOF_WORKSPACE_DIR"
echo "Token: $OPENHOOF_GATEWAY_TOKEN"
echo ""
echo "Commands:"
echo "  ${COMPOSE_HINT} logs -f openhoof-gateway"
echo "  ${COMPOSE_HINT} exec openhoof-gateway node dist/index.js health --token \"$OPENHOOF_GATEWAY_TOKEN\""
