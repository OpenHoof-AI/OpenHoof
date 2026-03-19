#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${OPENHOOF_IMAGE:-${HOOFBOT_IMAGE:-openhoof:local}}"
LIVE_IMAGE_NAME="${OPENHOOF_LIVE_IMAGE:-${HOOFBOT_LIVE_IMAGE:-${IMAGE_NAME}-live}}"
CONFIG_DIR="${OPENHOOF_CONFIG_DIR:-${HOOFBOT_CONFIG_DIR:-$HOME/.openhoof}}"
WORKSPACE_DIR="${OPENHOOF_WORKSPACE_DIR:-${HOOFBOT_WORKSPACE_DIR:-$HOME/.openhoof/workspace}}"
PROFILE_FILE="${OPENHOOF_PROFILE_FILE:-${HOOFBOT_PROFILE_FILE:-$HOME/.profile}}"

PROFILE_MOUNT=()
if [[ -f "$PROFILE_FILE" ]]; then
  PROFILE_MOUNT=(-v "$PROFILE_FILE":/home/node/.profile:ro)
fi

EXTERNAL_AUTH_MOUNTS=()
for auth_dir in .claude .codex .minimax .qwen; do
  host_path="$HOME/$auth_dir"
  if [[ -d "$host_path" ]]; then
    EXTERNAL_AUTH_MOUNTS+=(-v "$host_path":/host-auth/"$auth_dir":ro)
  fi
done

read -r -d '' LIVE_TEST_CMD <<'EOF' || true
set -euo pipefail
[ -f "$HOME/.profile" ] && source "$HOME/.profile" || true
for auth_dir in .claude .codex .minimax .qwen; do
  if [ -d "/host-auth/$auth_dir" ]; then
    mkdir -p "$HOME/$auth_dir"
    cp -R "/host-auth/$auth_dir/." "$HOME/$auth_dir"
    chmod -R u+rwX "$HOME/$auth_dir" || true
  fi
done
tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT
tar -C /src \
  --exclude=.git \
  --exclude=node_modules \
  --exclude=dist \
  --exclude=ui/dist \
  --exclude=ui/node_modules \
  -cf - . | tar -C "$tmp_dir" -xf -
ln -s /app/node_modules "$tmp_dir/node_modules"
ln -s /app/dist "$tmp_dir/dist"
cd "$tmp_dir"
pnpm test:live
EOF

echo "==> Build live-test image: $LIVE_IMAGE_NAME (target=build)"
docker build --target build -t "$LIVE_IMAGE_NAME" -f "$ROOT_DIR/Dockerfile" "$ROOT_DIR"

echo "==> Run live model tests (profile keys)"
docker run --rm -t \
  --entrypoint bash \
  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -e HOME=/home/node \
  -e NODE_OPTIONS=--disable-warning=ExperimentalWarning \
  -e OPENHOOF_LIVE_TEST=1 \
  -e OPENHOOF_LIVE_MODELS="${OPENHOOF_LIVE_MODELS:-${HOOFBOT_LIVE_MODELS:-modern}}" \
  -e OPENHOOF_LIVE_PROVIDERS="${OPENHOOF_LIVE_PROVIDERS:-${HOOFBOT_LIVE_PROVIDERS:-}}" \
  -e OPENHOOF_LIVE_MAX_MODELS="${OPENHOOF_LIVE_MAX_MODELS:-${HOOFBOT_LIVE_MAX_MODELS:-48}}" \
  -e OPENHOOF_LIVE_MODEL_TIMEOUT_MS="${OPENHOOF_LIVE_MODEL_TIMEOUT_MS:-${HOOFBOT_LIVE_MODEL_TIMEOUT_MS:-}}" \
  -e OPENHOOF_LIVE_REQUIRE_PROFILE_KEYS="${OPENHOOF_LIVE_REQUIRE_PROFILE_KEYS:-${HOOFBOT_LIVE_REQUIRE_PROFILE_KEYS:-}}" \
  -e OPENHOOF_LIVE_GATEWAY_MODELS="${OPENHOOF_LIVE_GATEWAY_MODELS:-${HOOFBOT_LIVE_GATEWAY_MODELS:-}}" \
  -e OPENHOOF_LIVE_GATEWAY_PROVIDERS="${OPENHOOF_LIVE_GATEWAY_PROVIDERS:-${HOOFBOT_LIVE_GATEWAY_PROVIDERS:-}}" \
  -e OPENHOOF_LIVE_GATEWAY_MAX_MODELS="${OPENHOOF_LIVE_GATEWAY_MAX_MODELS:-${HOOFBOT_LIVE_GATEWAY_MAX_MODELS:-}}" \
  -v "$ROOT_DIR":/src:ro \
  -v "$CONFIG_DIR":/home/node/.openhoof \
  -v "$WORKSPACE_DIR":/home/node/.openhoof/workspace \
  "${EXTERNAL_AUTH_MOUNTS[@]}" \
  "${PROFILE_MOUNT[@]}" \
  "$LIVE_IMAGE_NAME" \
  -lc "$LIVE_TEST_CMD"
