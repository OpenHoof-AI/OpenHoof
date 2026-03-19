#!/usr/bin/env bash
set -euo pipefail

cd /repo

export OPENHOOF_STATE_DIR="/tmp/openhoof-test"
export OPENHOOF_CONFIG_PATH="${OPENHOOF_STATE_DIR}/openhoof.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${OPENHOOF_STATE_DIR}/credentials"
mkdir -p "${OPENHOOF_STATE_DIR}/agents/main/sessions"
echo '{}' >"${OPENHOOF_CONFIG_PATH}"
echo 'creds' >"${OPENHOOF_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${OPENHOOF_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm openhoof reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${OPENHOOF_CONFIG_PATH}"
test ! -d "${OPENHOOF_STATE_DIR}/credentials"
test ! -d "${OPENHOOF_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${OPENHOOF_STATE_DIR}/credentials"
echo '{}' >"${OPENHOOF_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm openhoof uninstall --state --yes --non-interactive

test ! -d "${OPENHOOF_STATE_DIR}"

echo "OK"
