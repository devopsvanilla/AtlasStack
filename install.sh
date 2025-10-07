#!/bin/bash
# install.sh - Script principal de instalação do AtlasStack
# Oferece menu de múltipla escolha para instalação de soluções específicas
# Comportamento não-interativo por padrão, com opções para modo interativo

set -euo pipefail

# ============================================================================
# CONFIGURAÇÕES GLOBAIS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="${SCRIPT_DIR}/scripts/common.sh"

# Modo de operação (default: não-interativo)
INTERACTIVE_MODE=false
AUTO_YES=true

# ============================================================================
# ESTRUTURA ASSOCIATIVA DE SOLUÇÕES
# ============================================================================

# Declarar array associativo para registrar soluções disponíveis
declare -A SOLUTIONS
declare -A SOLUTION_DESCRIPTIONS
declare -A SOLUTION_SCRIPTS

# Registrar soluções disponíveis
SOLUTIONS["atlas"]="AtlasStack Core"
SOLUTION_DESCRIPTIONS["atlas"]="Instalação base do AtlasStack com dependências essenciais"
SOLUTION_SCRIPTS["atlas"]="${SCRIPT_DIR}/scripts/install_atlas.sh"

SOLUTIONS["monitoring"]="Monitoramento"
SOLUTION_DESCRIPTIONS["monitoring"]="Stack de monitoramento (Prometheus, Grafana)"
SOLUTION_SCRIPTS["monitoring"]="${SCRIPT_DIR}/scripts/install_monitoring.sh"

SOLUTIONS["logging"]="Logging"
SOLUTION_DESCRIPTIONS["logging"]="Stack de logs (ELK/Loki)"
SOLUTION_SCRIPTS["logging"]="${SCRIPT_DIR}/scripts/install_logging.sh"

SOLUTIONS["cicd"]="CI/CD"
SOLUTION_DESCRIPTIONS["cicd"]="Pipeline CI/CD (Jenkins/GitLab Runner)"
SOLUTION_SCRIPTS["cicd"]="${SCRIPT_DIR}/scripts/install_cicd.sh"

SOLUTIONS["security"]="Security Audit"
SOLUTION_DESCRIPTIONS["security"]="Ferramentas de auditoria de segurança"
SOLUTION_SCRIPTS["security"]="${SCRIPT_DIR}/scripts/install_security.sh"

SOLUTIONS["cmdb"]="CMDB"
SOLUTION_DESCRIPTIONS["cmdb"]="Sistema de gestão de configuração"
SOLUTION_SCRIPTS["cmdb"]="${SCRIPT_DIR}/scripts/install_cmdb.sh"

# ============================================================================
# CARREGAR FUNÇÕES COMUNS
# ============================================================================

if [[ -f "${COMMON_SCRIPT}" ]]; then
    # shellcheck source=scripts/common.sh
    source "${COMMON_SCRIPT}"
else
    # Fallback: definir funções básicas se common.sh não existir
    log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
    log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }
    log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
fi

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

# Exibir banner
show_banner() {
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                     🗺️  AtlasStack Installer                         ║
║                                                                      ║
║          logs decifrados, falhas diagnosticadas,                    ║
║                servidores configurados                              ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
}

# Exibir uso do script
show_usage() {
    cat << EOF

Uso: $0 [OPÇÕES] [SOLUÇÕES...]

OPÇÕES:
  -i, --interactive     Modo interativo com menu de seleção
  -a, --all            Instalar todas as soluções disponíveis
  -y, --yes            Responder 'sim' automaticamente (não-interativo)
  -h, --help           Exibir esta mensagem de ajuda
  -l, --list           Listar soluções disponíveis

SOLUÇÕES:
$(list_solutions_short)

EXEMPLOS:
  # Instalação não-interativa da solução base
  $0 atlas

  # Instalação não-interativa de múltiplas soluções
  $0 atlas monitoring logging

  # Modo interativo com menu
  $0 --interactive

  # Instalação de todas as soluções (não-interativo)
  $0 --all --yes

EOF
}

# Listar soluções disponíveis (formato curto)
list_solutions_short() {
    for key in "${!SOLUTIONS[@]}"; do
        echo "  $key - ${SOLUTIONS[$key]}"
    done | sort
}

# Listar soluções disponíveis (formato detalhado)
list_solutions_detailed() {
    echo ""
    log_info "Soluções disponíveis:"
    echo ""
    local i=1
    for key in $(echo "${!SOLUTIONS[@]}" | tr ' ' '\n' | sort); do
        printf "  %d) %-15s - %s\n" "$i" "${SOLUTIONS[$key]}" "${SOLUTION_DESCRIPTIONS[$key]}"
        printf "     Script: %s\n\n" "${SOLUTION_SCRIPTS[$key]}"
        ((i++))
    done
}

# Verificar se solução existe
solution_exists() {
    local solution="$1"
    [[ -n "${SOLUTIONS[$solution]:-}" ]]
}

# Verificar se script de solução existe
script_exists() {
    local solution="$1"
    local script="${SOLUTION_SCRIPTS[$solution]:-}"
    [[ -n "$script" ]] && [[ -f "$script" ]]
}

# Instalar solução específica
install_solution() {
    local solution="$1"
    
    if ! solution_exists "$solution"; then
        log_error "Solução '$solution' não encontrada."
        return 1
    fi
    
    local script="${SOLUTION_SCRIPTS[$solution]}"
    
    if ! script_exists "$solution"; then
        log_warn "Script de instalação não encontrado: $script"
        log_warn "Criando placeholder para desenvolvimento futuro..."
        return 1
    fi
    
    log_info "Instalando: ${SOLUTIONS[$solution]}"
    log_info "Script: $script"
    echo ""
    
    # Executar script de instalação
    # Passar flag --yes se em modo não-interativo
    if [[ "$AUTO_YES" == true ]]; then
        bash "$script" --yes
    else
        bash "$script"
    fi
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "${SOLUTIONS[$solution]} instalado com sucesso!"
        return 0
    else
        log_error "Falha ao instalar ${SOLUTIONS[$solution]} (código: $exit_code)"
        return 1
    fi
}

# Menu interativo de seleção
show_interactive_menu() {
    echo ""
    log_info "Selecione as soluções para instalar:"
    echo ""
    
    local i=1
    local -a solution_keys=()
    
    # Criar array ordenado de chaves
    for key in $(echo "${!SOLUTIONS[@]}" | tr ' ' '\n' | sort); do
        solution_keys+=( "$key" )
        printf "  %d) %s\n" "$i" "${SOLUTIONS[$key]}"
        printf "     %s\n\n" "${SOLUTION_DESCRIPTIONS[$key]}"
        ((i++))
    done
    
    printf "  0) Instalar TODAS as soluções\n"
    printf "  q) Sair\n\n"
    
    # Ler seleção do usuário
    read -rp "Digite os números das soluções (separados por espaço) ou 0 para todas: " selection
    
    # Processar seleção
    if [[ "$selection" =~ ^[qQ]$ ]]; then
        log_info "Instalação cancelada pelo usuário."
        exit 0
    elif [[ "$selection" == "0" ]]; then
        # Instalar todas
        for key in "${solution_keys[@]}"; do
            install_solution "$key" || log_warn "Continuando após falha..."
        done
    else
        # Instalar soluções selecionadas
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -gt 0 ]] && [[ $num -le ${#solution_keys[@]} ]]; then
                local idx=$((num - 1))
                install_solution "${solution_keys[$idx]}" || log_warn "Continuando após falha..."
            else
                log_warn "Seleção inválida ignorada: $num"
            fi
        done
    fi
}

# ============================================================================
# PROCESSAMENTO DE ARGUMENTOS
# ============================================================================

parse_arguments() {
    local -a solutions_to_install=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interactive)
                INTERACTIVE_MODE=true
                AUTO_YES=false
                shift
                ;;
            -a|--all)
                for key in "${!SOLUTIONS[@]}"; do
                    solutions_to_install+=("$key")
                done
                shift
                ;;
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            -l|--list)
                list_solutions_detailed
                exit 0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Opção desconhecida: $1"
                show_usage
                exit 1
                ;;
            *)
                # Assumir que é nome de solução
                if solution_exists "$1"; then
                    solutions_to_install+=("$1")
                else
                    log_error "Solução desconhecida: $1"
                    echo ""
                    list_solutions_short
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Retornar array via echo (workaround para Bash)
    echo "${solutions_to_install[@]}"
}

# ============================================================================
# FUNÇÃO PRINCIPAL
# ============================================================================

main() {
    show_banner
    
    # Parse argumentos
    local -a solutions_to_install
    if [[ $# -eq 0 ]]; then
        # Sem argumentos: modo interativo por padrão
        INTERACTIVE_MODE=true
        AUTO_YES=false
    else
        # Processar argumentos
        read -ra solutions_to_install <<< "$(parse_arguments "$@")"
    fi
    
    # Modo interativo
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        show_interactive_menu
    elif [[ ${#solutions_to_install[@]} -eq 0 ]]; then
        log_warn "Nenhuma solução especificada."
        show_usage
        exit 1
    else
        # Modo não-interativo: instalar soluções especificadas
        echo ""
        log_info "Instalando ${#solutions_to_install[@]} solução(ões)..."
        echo ""
        
        local failed=0
        for solution in "${solutions_to_install[@]}"; do
            install_solution "$solution" || ((failed++))
            echo ""
        done
        
        # Resumo final
        echo "═══════════════════════════════════════════════════════════════"
        if [[ $failed -eq 0 ]]; then
            log_success "Todas as soluções foram instaladas com sucesso!"
        else
            log_warn "Instalação concluída com $failed falha(s)."
        fi
        echo "═══════════════════════════════════════════════════════════════"
    fi
}

# ============================================================================
# PONTO DE ENTRADA
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
