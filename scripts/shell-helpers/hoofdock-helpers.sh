#!/usr/bin/env bash
# HoofDock - Docker helpers for OpenHoof
# Inspired by Simon Willison's "Running OpenHoof in Docker"
# https://til.simonwillison.net/llms/openhoof-docker
#
# Installation:
#   mkdir -p ~/.hoofdock && curl -sL https://raw.githubusercontent.com/openhoof/openhoof/main/scripts/shell-helpers/hoofdock-helpers.sh -o ~/.hoofdock/hoofdock-helpers.sh
#   echo 'source ~/.hoofdock/hoofdock-helpers.sh' >> ~/.zshrc
#
# Usage:
#   hoofdock-help    # Show all available commands

# =============================================================================
# Colors
# =============================================================================
_CLR_RESET='\033[0m'
_CLR_BOLD='\033[1m'
_CLR_DIM='\033[2m'
_CLR_GREEN='\033[0;32m'
_CLR_YELLOW='\033[1;33m'
_CLR_BLUE='\033[0;34m'
_CLR_MAGENTA='\033[0;35m'
_CLR_CYAN='\033[0;36m'
_CLR_RED='\033[0;31m'

# Styled command output (green + bold)
_clr_cmd() {
  echo -e "${_CLR_GREEN}${_CLR_BOLD}$1${_CLR_RESET}"
}

# Inline command for use in sentences
_cmd() {
  echo "${_CLR_GREEN}${_CLR_BOLD}$1${_CLR_RESET}"
}

# =============================================================================
# Config
# =============================================================================
HOOFDOCK_CONFIG="${HOME}/.hoofdock/config"

# Common paths to check for OpenHoof
HOOFDOCK_COMMON_PATHS=(
  "${HOME}/openhoof"
  "${HOME}/workspace/openhoof"
  "${HOME}/projects/openhoof"
  "${HOME}/dev/openhoof"
  "${HOME}/code/openhoof"
  "${HOME}/src/openhoof"
)

_hoofdock_filter_warnings() {
  grep -v "^WARN\|^time="
}

_hoofdock_trim_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  printf "%s" "$value"
}

_hoofdock_read_config_dir() {
  if [[ ! -f "$HOOFDOCK_CONFIG" ]]; then
    return 1
  fi
  local raw
  raw=$(sed -n 's/^HOOFDOCK_DIR=//p' "$HOOFDOCK_CONFIG" | head -n 1)
  if [[ -z "$raw" ]]; then
    return 1
  fi
  _hoofdock_trim_quotes "$raw"
}

# Ensure HOOFDOCK_DIR is set and valid
_hoofdock_ensure_dir() {
  # Already set and valid?
  if [[ -n "$HOOFDOCK_DIR" && -f "${HOOFDOCK_DIR}/docker-compose.yml" ]]; then
    return 0
  fi

  # Try loading from config
  local config_dir
  config_dir=$(_hoofdock_read_config_dir)
  if [[ -n "$config_dir" && -f "${config_dir}/docker-compose.yml" ]]; then
    HOOFDOCK_DIR="$config_dir"
    return 0
  fi

  # Auto-detect from common paths
  local found_path=""
  for path in "${HOOFDOCK_COMMON_PATHS[@]}"; do
    if [[ -f "${path}/docker-compose.yml" ]]; then
      found_path="$path"
      break
    fi
  done

  if [[ -n "$found_path" ]]; then
    echo ""
    echo "🐴 Found OpenHoof at: $found_path"
    echo -n "   Use this location? [Y/n] "
    read -r response
    if [[ "$response" =~ ^[Nn] ]]; then
      echo ""
      echo "Set HOOFDOCK_DIR manually:"
      echo "  export HOOFDOCK_DIR=/path/to/openhoof"
      return 1
    fi
    HOOFDOCK_DIR="$found_path"
  else
    echo ""
    echo "❌ OpenHoof not found in common locations."
    echo ""
    echo "Clone it first:"
    echo ""
    echo "  git clone https://github.com/openhoof/openhoof.git ~/openhoof"
    echo "  cd ~/openhoof && ./docker-setup.sh"
    echo ""
    echo "Or set HOOFDOCK_DIR if it's elsewhere:"
    echo ""
    echo "  export HOOFDOCK_DIR=/path/to/openhoof"
    echo ""
    return 1
  fi

  # Save to config
  if [[ ! -d "${HOME}/.hoofdock" ]]; then
    /bin/mkdir -p "${HOME}/.hoofdock"
  fi
  echo "HOOFDOCK_DIR=\"$HOOFDOCK_DIR\"" > "$HOOFDOCK_CONFIG"
  echo "✅ Saved to $HOOFDOCK_CONFIG"
  echo ""
  return 0
}

# Wrapper to run docker compose commands
_hoofdock_compose() {
  _hoofdock_ensure_dir || return 1
  local compose_args=(-f "${HOOFDOCK_DIR}/docker-compose.yml")
  if [[ -f "${HOOFDOCK_DIR}/docker-compose.extra.yml" ]]; then
    compose_args+=(-f "${HOOFDOCK_DIR}/docker-compose.extra.yml")
  fi
  command docker compose "${compose_args[@]}" "$@"
}

_hoofdock_read_env_token() {
  _hoofdock_ensure_dir || return 1
  if [[ ! -f "${HOOFDOCK_DIR}/.env" ]]; then
    return 1
  fi
  local raw
  raw=$(sed -n 's/^OPENHOOF_GATEWAY_TOKEN=//p' "${HOOFDOCK_DIR}/.env" | head -n 1)
  if [[ -z "$raw" ]]; then
    return 1
  fi
  _hoofdock_trim_quotes "$raw"
}

# Basic Operations
hoofdock-start() {
  _hoofdock_compose up -d openhoof-gateway
}

hoofdock-stop() {
  _hoofdock_compose down
}

hoofdock-restart() {
  _hoofdock_compose restart openhoof-gateway
}

hoofdock-logs() {
  _hoofdock_compose logs -f openhoof-gateway
}

hoofdock-status() {
  _hoofdock_compose ps
}

# Navigation
hoofdock-cd() {
  _hoofdock_ensure_dir || return 1
  cd "${HOOFDOCK_DIR}"
}

hoofdock-config() {
  cd ~/.openhoof
}

hoofdock-workspace() {
  cd ~/.openhoof/workspace
}

# Container Access
hoofdock-shell() {
  _hoofdock_compose exec openhoof-gateway \
    bash -c 'echo "alias openhoof=\"./openhoof.mjs\"" > /tmp/.bashrc_openhoof && bash --rcfile /tmp/.bashrc_openhoof'
}

hoofdock-exec() {
  _hoofdock_compose exec openhoof-gateway "$@"
}

hoofdock-cli() {
  _hoofdock_compose run --rm openhoof-cli "$@"
}

# Maintenance
hoofdock-rebuild() {
  _hoofdock_compose build openhoof-gateway
}

hoofdock-clean() {
  _hoofdock_compose down -v --remove-orphans
}

# Health check
hoofdock-health() {
  _hoofdock_ensure_dir || return 1
  local token
  token=$(_hoofdock_read_env_token)
  if [[ -z "$token" ]]; then
    echo "❌ Error: Could not find gateway token"
    echo "   Check: ${HOOFDOCK_DIR}/.env"
    return 1
  fi
  _hoofdock_compose exec -e "OPENHOOF_GATEWAY_TOKEN=$token" openhoof-gateway \
    node dist/index.js health
}

# Show gateway token
hoofdock-token() {
  _hoofdock_read_env_token
}

# Fix token configuration (run this once after setup)
hoofdock-fix-token() {
  _hoofdock_ensure_dir || return 1

  echo "🔧 Configuring gateway token..."
  local token
  token=$(hoofdock-token)
  if [[ -z "$token" ]]; then
    echo "❌ Error: Could not find gateway token"
    echo "   Check: ${HOOFDOCK_DIR}/.env"
    return 1
  fi

  echo "📝 Setting token: ${token:0:20}..."

  _hoofdock_compose exec -e "TOKEN=$token" openhoof-gateway \
    bash -c './openhoof.mjs config set gateway.remote.token "$TOKEN" && ./openhoof.mjs config set gateway.auth.token "$TOKEN"' 2>&1 | _hoofdock_filter_warnings

  echo "🔍 Verifying token was saved..."
  local saved_token
  saved_token=$(_hoofdock_compose exec openhoof-gateway \
    bash -c "./openhoof.mjs config get gateway.remote.token 2>/dev/null" 2>&1 | _hoofdock_filter_warnings | tr -d '\r\n' | head -c 64)

  if [[ "$saved_token" == "$token" ]]; then
    echo "✅ Token saved correctly!"
  else
    echo "⚠️  Token mismatch detected"
    echo "   Expected: ${token:0:20}..."
    echo "   Got: ${saved_token:0:20}..."
  fi

  echo "🔄 Restarting gateway..."
  _hoofdock_compose restart openhoof-gateway 2>&1 | _hoofdock_filter_warnings

  echo "⏳ Waiting for gateway to start..."
  sleep 5

  echo "✅ Configuration complete!"
  echo -e "   Try: $(_cmd hoofdock-devices)"
}

# Open dashboard in browser
hoofdock-dashboard() {
  _hoofdock_ensure_dir || return 1

  echo "🐴 Getting dashboard URL..."
  local output exit_status url
  output=$(_hoofdock_compose run --rm openhoof-cli dashboard --no-open 2>&1)
  exit_status=$?
  url=$(printf "%s\n" "$output" | _hoofdock_filter_warnings | grep -o 'http[s]\?://[^[:space:]]*' | head -n 1)
  if [[ $exit_status -ne 0 ]]; then
    echo "❌ Failed to get dashboard URL"
    echo -e "   Try restarting: $(_cmd hoofdock-restart)"
    return 1
  fi

  if [[ -n "$url" ]]; then
    echo "✅ Opening: $url"
    open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || echo "   Please open manually: $url"
    echo ""
    echo -e "${_CLR_CYAN}💡 If you see 'pairing required' error:${_CLR_RESET}"
    echo -e "   1. Run: $(_cmd hoofdock-devices)"
    echo "   2. Copy the Request ID from the Pending table"
    echo -e "   3. Run: $(_cmd 'hoofdock-approve <request-id>')"
  else
    echo "❌ Failed to get dashboard URL"
    echo -e "   Try restarting: $(_cmd hoofdock-restart)"
  fi
}

# List device pairings
hoofdock-devices() {
  _hoofdock_ensure_dir || return 1

  echo "🔍 Checking device pairings..."
  local output exit_status
  output=$(_hoofdock_compose exec openhoof-gateway node dist/index.js devices list 2>&1)
  exit_status=$?
  printf "%s\n" "$output" | _hoofdock_filter_warnings
  if [ $exit_status -ne 0 ]; then
    echo ""
    echo -e "${_CLR_CYAN}💡 If you see token errors above:${_CLR_RESET}"
    echo -e "   1. Verify token is set: $(_cmd hoofdock-token)"
    echo "   2. Try manual config inside container:"
    echo -e "      $(_cmd hoofdock-shell)"
    echo -e "      $(_cmd 'openhoof config get gateway.remote.token')"
    return 1
  fi

  echo ""
  echo -e "${_CLR_CYAN}💡 To approve a pairing request:${_CLR_RESET}"
  echo -e "   $(_cmd 'hoofdock-approve <request-id>')"
}

# Approve device pairing request
hoofdock-approve() {
  _hoofdock_ensure_dir || return 1

  if [[ -z "$1" ]]; then
    echo -e "❌ Usage: $(_cmd 'hoofdock-approve <request-id>')"
    echo ""
    echo -e "${_CLR_CYAN}💡 How to approve a device:${_CLR_RESET}"
    echo -e "   1. Run: $(_cmd hoofdock-devices)"
    echo "   2. Find the Request ID in the Pending table (long UUID)"
    echo -e "   3. Run: $(_cmd 'hoofdock-approve <that-request-id>')"
    echo ""
    echo "Example:"
    echo -e "   $(_cmd 'hoofdock-approve 6f9db1bd-a1cc-4d3f-b643-2c195262464e')"
    return 1
  fi

  echo "✅ Approving device: $1"
  _hoofdock_compose exec openhoof-gateway \
    node dist/index.js devices approve "$1" 2>&1 | _hoofdock_filter_warnings

  echo ""
  echo "✅ Device approved! Refresh your browser."
}

# Show all available hoofdock helper commands
hoofdock-help() {
  echo -e "\n${_CLR_BOLD}${_CLR_CYAN}🐴 HoofDock - Docker Helpers for OpenHoof${_CLR_RESET}\n"

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}⚡ Basic Operations${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-start)       ${_CLR_DIM}Start the gateway${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-stop)        ${_CLR_DIM}Stop the gateway${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-restart)     ${_CLR_DIM}Restart the gateway${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-status)      ${_CLR_DIM}Check container status${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-logs)        ${_CLR_DIM}View live logs (follows)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🐚 Container Access${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-shell)       ${_CLR_DIM}Shell into container (openhoof alias ready)${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-cli)         ${_CLR_DIM}Run CLI commands (e.g., hoofdock-cli status)${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-exec) ${_CLR_CYAN}<cmd>${_CLR_RESET}  ${_CLR_DIM}Execute command in gateway container${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🌐 Web UI & Devices${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-dashboard)   ${_CLR_DIM}Open web UI in browser ${_CLR_CYAN}(auto-guides you)${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-devices)     ${_CLR_DIM}List device pairings ${_CLR_CYAN}(auto-guides you)${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-approve) ${_CLR_CYAN}<id>${_CLR_RESET} ${_CLR_DIM}Approve device pairing ${_CLR_CYAN}(with examples)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}⚙️  Setup & Configuration${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-fix-token)   ${_CLR_DIM}Configure gateway token ${_CLR_CYAN}(run once)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🔧 Maintenance${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-rebuild)     ${_CLR_DIM}Rebuild Docker image${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-clean)       ${_CLR_RED}⚠️  Remove containers & volumes (nuclear)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🛠️  Utilities${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-health)      ${_CLR_DIM}Run health check${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-token)       ${_CLR_DIM}Show gateway auth token${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-cd)          ${_CLR_DIM}Jump to openhoof project directory${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-config)      ${_CLR_DIM}Open config directory (~/.openhoof)${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-workspace)   ${_CLR_DIM}Open workspace directory${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CLR_RESET}"
  echo -e "${_CLR_BOLD}${_CLR_GREEN}🚀 First Time Setup${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  1.${_CLR_RESET} $(_cmd hoofdock-start)          ${_CLR_DIM}# Start the gateway${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  2.${_CLR_RESET} $(_cmd hoofdock-fix-token)      ${_CLR_DIM}# Configure token${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  3.${_CLR_RESET} $(_cmd hoofdock-dashboard)      ${_CLR_DIM}# Open web UI${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  4.${_CLR_RESET} $(_cmd hoofdock-devices)        ${_CLR_DIM}# If pairing needed${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  5.${_CLR_RESET} $(_cmd hoofdock-approve) ${_CLR_CYAN}<id>${_CLR_RESET}   ${_CLR_DIM}# Approve pairing${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_GREEN}💬 WhatsApp Setup${_CLR_RESET}"
  echo -e "  $(_cmd hoofdock-shell)"
  echo -e "    ${_CLR_BLUE}>${_CLR_RESET} $(_cmd 'openhoof channels login --channel whatsapp')"
  echo -e "    ${_CLR_BLUE}>${_CLR_RESET} $(_cmd 'openhoof status')"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_CYAN}💡 All commands guide you through next steps!${_CLR_RESET}"
  echo -e "${_CLR_BLUE}📚 Docs: ${_CLR_RESET}${_CLR_CYAN}https://docs.openhoof.ai${_CLR_RESET}"
  echo ""
}
