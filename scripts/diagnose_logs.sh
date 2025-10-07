#!/bin/bash
# AtlasStack - Script de Diagnóstico de Logs
# Analisa logs do sistema em busca de erros, warnings e padrões de falha
# Agora usando common.sh para padronização

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
# Configurações do script
# ==========================
LOG_DIRS=("/var/log" "/var/log/syslog" "/var/log/auth.log")
OUTPUT_FILE="diagnose_report_$(date +%Y%m%d_%H%M%S).txt"

# ==========================
# Funções de análise
# ==========================

analyze_errors() {
    log_info "Analisando erros críticos..."
    echo "=== ERROS CRÍTICOS ===" >> "$OUTPUT_FILE"
    
    for log_dir in "${LOG_DIRS[@]}"; do
        if [[ -r "$log_dir" ]]; then
            grep -i "error\|critical\|fail" "$log_dir" 2>/dev/null | tail -n 50 >> "$OUTPUT_FILE" || true
        fi
    done
}

analyze_warnings() {
    log_info "Analisando warnings..."
    echo "" >> "$OUTPUT_FILE"
    echo "=== WARNINGS ===" >> "$OUTPUT_FILE"
    
    if [[ -r "/var/log/syslog" ]]; then
        grep -i "warning\|warn" /var/log/syslog 2>/dev/null | tail -n 30 >> "$OUTPUT_FILE" || true
    fi
}

analyze_auth() {
    log_info "Analisando tentativas de autenticação..."
    echo "" >> "$OUTPUT_FILE"
    echo "=== AUTENTICAÇÃO ===" >> "$OUTPUT_FILE"
    
    if [[ -r "/var/log/auth.log" ]]; then
        grep -i "failed\|failure" /var/log/auth.log 2>/dev/null | tail -n 20 >> "$OUTPUT_FILE" || true
    fi
}

generate_stats() {
    log_info "Gerando estatísticas..."
    echo "" >> "$OUTPUT_FILE"
    echo "=== ESTATÍSTICAS ===" >> "$OUTPUT_FILE"
    
    local error_count=0
    local warning_count=0
    
    if [[ -r "/var/log/syslog" ]]; then
        error_count=$(grep -ic "error" /var/log/syslog 2>/dev/null || echo "0")
        warning_count=$(grep -ic "warning" /var/log/syslog 2>/dev/null || echo "0")
    fi
    
    echo "Total de erros encontrados: $error_count" >> "$OUTPUT_FILE"
    echo "Total de warnings encontrados: $warning_count" >> "$OUTPUT_FILE"
}

# ==========================
# Função principal
# ==========================

main() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "    🔍 AtlasStack - Iniciando diagnóstico de logs"
    log_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Inicializa arquivo de saída
    echo "" > "$OUTPUT_FILE"
    
    # Executa análises
    analyze_errors
    analyze_warnings
    analyze_auth
    generate_stats
    
    echo ""
    log_success "Diagnóstico concluído!"
    log_info "Relatório salvo em: $OUTPUT_FILE"
    log_info "═══════════════════════════════════════════════════════════════"
}

# Executa main
main "$@"
