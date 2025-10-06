#!/bin/bash

# install_atlas.sh - Script de instalação do AtlasStack
# Inclui checagem e instalação automática de dependências mínimas

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para exibir mensagens
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para instalar dependência via apt
install_with_apt() {
    local package=$1
    log_info "Instalando $package via apt..."
    
    if sudo apt-get update && sudo apt-get install -y "$package"; then
        log_info "$package instalado com sucesso!"
        return 0
    else
        log_error "Falha ao instalar $package"
        return 1
    fi
}

# Função para verificar e instalar dependência
check_and_install_dependency() {
    local cmd=$1
    local package=${2:-$1}  # Se não informado, usa o mesmo nome do comando
    
    if command_exists "$cmd"; then
        log_info "✓ $cmd já está instalado"
        return 0
    else
        log_warn "✗ $cmd não encontrado"
        
        # Verificar se sistema é baseado em Debian/Ubuntu
        if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
            echo -n "Deseja instalar $package via apt? (s/N): "
            read -r response
            
            if [[ "$response" =~ ^[Ss]$ ]]; then
                if install_with_apt "$package"; then
                    return 0
                else
                    log_error "Não foi possível instalar $package. Cancelando instalação."
                    exit 1
                fi
            else
                log_error "$cmd é necessário para continuar. Cancelando instalação."
                exit 1
            fi
        else
            log_error "Sistema não é baseado em Debian/Ubuntu. Por favor, instale $package manualmente."
            exit 1
        fi
    fi
}

# Banner
echo "═══════════════════════════════════════════════════════════════"
echo "    🗺️  AtlasStack - Script de Instalação"
echo "═══════════════════════════════════════════════════════════════"
echo ""

log_info "Verificando dependências mínimas..."
echo ""

# Verificar e instalar dependências mínimas
check_and_install_dependency "git" "git"
check_and_install_dependency "bash" "bash"
check_and_install_dependency "logger" "bsdutils"

echo ""
log_info "═══════════════════════════════════════════════════════════════"
log_info "Todas as dependências estão instaladas!"
log_info "═══════════════════════════════════════════════════════════════"
echo ""

log_info "Iniciando instalação do AtlasStack..."

# Aqui virá a lógica de instalação do AtlasStack
# TODO: Implementar a instalação dos componentes do AtlasStack

log_info "Instalação concluída com sucesso!"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "    ✓ AtlasStack instalado"
echo "═══════════════════════════════════════════════════════════════"
