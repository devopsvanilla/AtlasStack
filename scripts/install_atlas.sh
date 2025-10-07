#!/bin/bash
# install_atlas.sh - Script de instalação do AtlasStack
# Usa common.sh para padronização, idempotência e modo não-interativo por padrão

set -euo pipefail

# ==========================
# Importa funções comuns
# ==========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SH="${SCRIPT_DIR}/common.sh"

if [[ -f "$COMMON_SH" ]]; then
    # shellcheck source=./common.sh
    source "$COMMON_SH"
else
    echo "ERRO: Arquivo common.sh não encontrado em ${SCRIPT_DIR}" >&2
    exit 1
fi

# ==========================
# Configurações e constantes
# ==========================

# Força modo não-interativo por padrão (pode ser sobrescrito via --interactive)
export AUTO_YES=true

# Dependências mínimas (comando:pacote)
declare -A DEPENDENCIES=(
    ["git"]="git"
    ["bash"]="bash"
    ["logger"]="bsdutils"
    ["curl"]="curl"
)

# ==========================
# Funções auxiliares
# ==========================

show_usage() {
    cat <<EOF
Uso: $0 [OPÇÕES]

Script de instalação do AtlasStack

OPÇÕES:
    --interactive    Habilita prompts interativos (padrão: não-interativo)
    --yes            Força modo não-interativo (padrão)
    -h, --help       Exibe esta mensagem de ajuda

EXEMPLOS:
    $0                      # Instala com padrões não-interativos
    $0 --interactive        # Habilita confirmações interativas
    $0 --yes                # Força modo não-interativo (redundante, já é padrão)
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --interactive)
                export AUTO_YES=false
                log_info "Modo interativo habilitado"
                shift
                ;;
            --yes|-y)
                export AUTO_YES=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Opção desconhecida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# ==========================
# Funções de instalação modularizadas
# ==========================

check_dependencies() {
    log_info "Verificando dependências mínimas..."
    local missing=0
    
    for cmd in "${!DEPENDENCIES[@]}"; do
        local pkg="${DEPENDENCIES[$cmd]}"
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_warn "✗ $cmd não encontrado"
            missing=1
        else
            log_info "✓ $cmd disponível"
        fi
    done
    
    return $missing
}

install_dependencies() {
    log_info "Instalando dependências necessárias..."
    
    for cmd in "${!DEPENDENCIES[@]}"; do
        local pkg="${DEPENDENCIES[$cmd]}"
        ensure_cmd "$cmd" "$pkg"
    done
    
    log_success "Todas as dependências foram instaladas!"
}

verify_installation() {
    log_info "Verificando instalação..."
    local all_ok=0
    
    for cmd in "${!DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Falha: $cmd ainda não está disponível"
            all_ok=1
        fi
    done
    
    if [[ $all_ok -eq 0 ]]; then
        log_success "Todas as dependências verificadas com sucesso!"
        return 0
    else
        log_error "Algumas dependências falharam na verificação"
        return 1
    fi
}

install_atlas_components() {
    log_info "Instalando componentes do AtlasStack..."
    
    # TODO: Implementar a instalação dos componentes específicos do AtlasStack
    # Exemplos de componentes que podem ser adicionados:
    # - Docker/Podman
    # - Kubernetes (kubectl, minikube, k3s, etc.)
    # - Terraform
    # - Ansible
    # - Prometheus/Grafana
    # - CI/CD tools
    
    log_info "Componentes do AtlasStack serão implementados aqui"
    
    # Placeholder - remove quando implementar componentes reais
    sleep 1
}

# ==========================
# Função principal
# ==========================

main() {
    # Parse argumentos
    parse_args "$@"
    
    # Banner
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "    🗺️  AtlasStack - Script de Instalação"
    log_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # 1. Verifica dependências
    if ! check_dependencies; then
        log_warn "Algumas dependências estão faltando"
    fi
    echo ""
    
    # 2. Instala dependências faltantes
    install_dependencies
    echo ""
    
    # 3. Verifica instalação das dependências
    if ! verify_installation; then
        log_error "Falha na verificação das dependências. Abortando."
        exit 1
    fi
    echo ""
    
    # 4. Instala componentes do AtlasStack
    log_info "═══════════════════════════════════════════════════════════════"
    install_atlas_components
    echo ""
    
    # 5. Finalização
    log_success "Instalação concluída com sucesso!"
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "    ✓ AtlasStack instalado"
    log_info "═══════════════════════════════════════════════════════════════"
}

# Executa main
main "$@"
