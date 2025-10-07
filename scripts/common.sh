#!/bin/bash
# common.sh - Funções comuns e utilitários para scripts do AtlasStack
# Objetivo: fornecer logging consistente, checagens idempotentes e instalação
#           de dependências sem prompts interativos por padrão.

set -euo pipefail

# ==========================
# Cores e logging padronizado
# ==========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" 1>&2; }
log_debug()   { echo -e "${BLUE}[DEBUG]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# ==========================
# Detecção de SO e pacote
# ==========================
OS_FAMILY=""
PKG_MGR=""

_detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "${ID_LIKE:-$ID}" in
      *debian*|*ubuntu*) OS_FAMILY="debian"; PKG_MGR="apt" ;;
      *rhel*|*fedora*|*centos*|*rocky*|*almalinux*) OS_FAMILY="rhel"; PKG_MGR="dnf" ;;
      *suse*) OS_FAMILY="suse"; PKG_MGR="zypper" ;;
      *) OS_FAMILY="unknown"; PKG_MGR="" ;;
    esac
  else
    OS_FAMILY="unknown"
  fi
}

_detect_os

# ==========================
# Execução segura de comandos
# ==========================
run() {
  # Executa comando mostrando-o antes
  log_info "Executando: $*"
  "$@"
}

# ==========================
# Instalação idempotente de pacotes (não interativa)
# ==========================
# Flags globais que podem ser honradas por scripts chamadores
: "${AUTO_YES:=true}"

_pkg_update_once() {
  case "$PKG_MGR" in
    apt)
      # Usa marcadores de lock e cache_valid_time-like com heurística simples
      local marker="/var/lib/apt/periodic/update-success-stamp"
      if [[ ! -f "$marker" ]] || find "$marker" -mmin +60 >/dev/null 2>&1; then
        sudo apt-get update -y -o=Dpkg::Use-Pty=0 || sudo apt-get update -o=Dpkg::Use-Pty=0
      fi
      ;;
    dnf)
      sudo dnf makecache -y || true
      ;;
    zypper)
      sudo zypper -n refresh || true
      ;;
    *) ;;
  esac
}

install_pkg() {
  local pkg="$1"
  local assume_yes_flag=""
  if [[ "${AUTO_YES}" == "true" ]]; then
    case "$PKG_MGR" in
      apt) assume_yes_flag="-y -o=Dpkg::Use-Pty=0 -o=APT::Get::Assume-Yes=true -o=APT::Get::force-yes=true" ;;
      dnf) assume_yes_flag="-y" ;;
      zypper) assume_yes_flag="-n" ;;
    esac
  fi

  case "$PKG_MGR" in
    apt)
      _pkg_update_once
      if dpkg -s "$pkg" >/dev/null 2>&1; then
        log_info "✓ Pacote '$pkg' já instalado (apt)"
      else
        run sudo apt-get install $assume_yes_flag "$pkg"
      fi
      ;;
    dnf)
      if rpm -q "$pkg" >/dev/null 2>&1; then
        log_info "✓ Pacote '$pkg' já instalado (dnf)"
      else
        run sudo dnf install $assume_yes_flag "$pkg"
      fi
      ;;
    zypper)
      if rpm -q "$pkg" >/dev/null 2>&1; then
        log_info "✓ Pacote '$pkg' já instalado (zypper)"
      else
        run sudo zypper $assume_yes_flag install "$pkg"
      fi
      ;;
    *)
      log_warn "Gerenciador de pacotes não suportado. Instale '$pkg' manualmente."
      return 1
      ;;
  esac
}

ensure_cmd() {
  # Garante que um comando exista, instalando o pacote correspondente se possível
  local cmd="$1"; shift || true
  local pkg="${1:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    log_info "✓ Comando '$cmd' disponível"
    return 0
  fi
  log_warn "✗ Comando '$cmd' não encontrado. Tentando instalar pacote '$pkg'..."
  if [[ -n "$PKG_MGR" ]]; then
    install_pkg "$pkg"
  else
    log_error "Não foi possível determinar gerenciador de pacotes para instalar '$pkg'"
    return 1
  fi
}

# ==========================
# Helpers de idempotência
# ==========================
file_has_line() {
  local file="$1" line="$2"
  [[ -f "$file" ]] && grep -Fqx -- "$line" "$file"
}

ensure_line_in_file() {
  local file="$1" line="$2"
  if file_has_line "$file" "$line"; then
    log_info "Linha já presente em $file"
  else
    sudo mkdir -p "$(dirname "$file")"
    echo "$line" | sudo tee -a "$file" >/dev/null
    log_info "Linha adicionada em $file"
  fi
}

ensure_service_enabled_started() {
  local svc="$1"
  if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
    :
  else
    run sudo systemctl enable "$svc"
  fi
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    log_info "Serviço '$svc' já em execução"
  else
    run sudo systemctl start "$svc"
  fi
}

# ==========================
# Ambiente padrão para não interativo
# ==========================
export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}
export NEEDRESTART_MODE=${NEEDRESTART_MODE:-a}
export APT_LISTCHANGES_FRONTEND=${APT_LISTCHANGES_FRONTEND:-none}

# ==========================
# Funções utilitárias diversas
# ==========================
confirm() {
  # Uso: confirm "Mensagem"; respeita AUTO_YES
  local msg="${1:-Confirma?}"
  if [[ "${AUTO_YES}" == "true" ]]; then
    log_info "AUTO_YES ativo - assumindo 'sim' para: $msg"
    return 0
  fi
  read -r -p "$msg [s/N]: " resp
  [[ "$resp" =~ ^[sSyY]$ ]]
}
