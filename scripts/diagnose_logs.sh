#!/bin/bash

# AtlasStack - Script de Diagnóstico de Logs
# Analisa logs do sistema em busca de erros, warnings e padrões de falha

set -euo pipefail

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Diretórios de logs
LOG_DIRS=("/var/log" "/var/log/syslog" "/var/log/auth.log")
OUTPUT_FILE="diagnose_report_$(date +%Y%m%d_%H%M%S).txt"

echo "🔍 AtlasStack - Iniciando diagnóstico de logs..."
echo "" > "$OUTPUT_FILE"

# Função para análise de erros
analyze_errors() {
    echo -e "${YELLOW}Analisando erros críticos...${NC}"
    echo "=== ERROS CRÍTICOS ===" >> "$OUTPUT_FILE"
    
    for log_dir in "${LOG_DIRS[@]}"; do
        if [ -r "$log_dir" ]; then
            grep -i "error\|critical\|fail" "$log_dir" 2>/dev/null | tail -n 50 >> "$OUTPUT_FILE" || true
        fi
    done
}

# Função para análise de warnings
analyze_warnings() {
    echo -e "${YELLOW}Analisando warnings...${NC}"
    echo "" >> "$OUTPUT_FILE"
    echo "=== WARNINGS ===" >> "$OUTPUT_FILE"
    
    grep -i "warning\|warn" /var/log/syslog 2>/dev/null | tail -n 30 >> "$OUTPUT_FILE" || true
}

# Função para análise de autenticação
analyze_auth() {
    echo -e "${YELLOW}Analisando tentativas de autenticação...${NC}"
    echo "" >> "$OUTPUT_FILE"
    echo "=== AUTENTICAÇÃO ===" >> "$OUTPUT_FILE"
    
    grep -i "failed\|failure" /var/log/auth.log 2>/dev/null | tail -n 20 >> "$OUTPUT_FILE" || true
}

# Função para estatísticas
generate_stats() {
    echo -e "${YELLOW}Gerando estatísticas...${NC}"
    echo "" >> "$OUTPUT_FILE"
    echo "=== ESTATÍSTICAS ===" >> "$OUTPUT_FILE"
    
    local error_count=$(grep -ic "error" /var/log/syslog 2>/dev/null || echo "0")
    local warning_count=$(grep -ic "warning" /var/log/syslog 2>/dev/null || echo "0")
    
    echo "Total de erros encontrados: $error_count" >> "$OUTPUT_FILE"
    echo "Total de warnings encontrados: $warning_count" >> "$OUTPUT_FILE"
}

# Execução principal
main() {
    analyze_errors
    analyze_warnings
    analyze_auth
    generate_stats
    
    echo -e "${GREEN}✅ Diagnóstico concluído!${NC}"
    echo -e "${GREEN}Relatório salvo em: $OUTPUT_FILE${NC}"
}

main "$@"
