# CONTRIBUTING-install.md

Guia de contribuição para criação, padronização, segurança e testes de scripts de instalação no AtlasStack. Este documento consolida o modelo e as recomendações anteriores do projeto.

Sumário
- Objetivos e princípios
- Estrutura obrigatória do repositório e scripts
- Uso obrigatório do common.sh
- Padrões de logging e rastreabilidade
- Idempotência e reentrância
- Convenções de interface (CLI, flags e variáveis)
- Segurança: entrada, arquivos, rede, privilégios
- Testes: unitários, integração e validação pós-instalação
- Exemplos práticos
- Checklist de Pull Request

Objetivos e princípios
- Confiabilidade: scripts determinísticos, idempotentes e com rollback. 
- Observabilidade: logs padronizados, claros e com contexto. 
- Segurança por padrão: menor privilégio, validações estritas, verificações de integridade. 
- Portabilidade: suportar distribuições-alvo definidas, detectar OS e adaptar. 
- Manutenibilidade: funções pequenas, reutilizáveis, documentadas e testáveis. 

Estrutura obrigatória
install/
  common/
    common.sh              # Funções utilitárias obrigatórias (log, check, os, retry, etc.)
    lib.sh                 # Funções compartilhadas específicas (opcional)
    config/
      defaults.env         # Valores padrão de ambiente (opcional)
  components/
    <componente>/
      install.sh           # Script de instalação do componente
      validate.sh          # Validações pós-instalação do componente
      uninstall.sh         # Desinstalação/rollback (quando aplicável)
      README.md            # Notas do componente (pré-reqs, suporte, limites)
  scripts/
    setup.sh               # Orquestra instalação de múltiplos componentes
    validate.sh            # Orquestra validações globais
  tests/
    unit/
    integration/
    scripts/
      test_runner.sh
      test_common.sh

Uso obrigatório do common.sh
- Todos os scripts executáveis devem:
  - Iniciar com shebang e modo estrito: 
    #!/bin/bash
    set -euo pipefail
    IFS=$'\n\t'
  - Carregar common.sh via caminho robusto:
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    source "${REPO_ROOT}/common/common.sh" || {
      echo "[ERROR] Não foi possível carregar common.sh" >&2
      exit 1
    }
- Funções mínimas esperadas em common.sh (referência):
  - log_{info,success,warning,error,debug}
  - die "mensagem" (log_error e exit não-zero)
  - command_exists, detect_os, check_root, require_root, require_cmd
  - file_{exists,readable,writable}, dir_{exists,create}
  - verify_checksum <arquivo> <sha256>, secure_download <url> <dest> <sha256>
  - with_retry <tentativas> <intervalo> -- comando args...
  - run_as_user <user> -- comando args...
  - set_sysctl, set_permissions, render_template (quando aplicável)

Padrões de logging e rastreabilidade
- Níveis: DEBUG, INFO, WARNING, ERROR, SUCCESS.
- Formato: [UTC-ISO8601] [NÍVEL] [script:linha função] mensagem
- Exemplos:
  log_info "Instalando docker-ce"
  log_warning "Variável XYZ não definida; usando padrão"
  log_error "Falha ao iniciar serviço docker"
- Direcionamento:
  - stdout: INFO/SUCCESS
  - stderr: WARNING/ERROR
  - DEBUG controlado por env DEBUG=true
- Artefatos:
  - Sempre que possível, salvar logs em /var/log/atlasstack/<componente>.log (quando root) ou $HOME/.atlasstack/logs/

Idempotência e reentrância
- Antes de alterar estado, verificar condição atual.
  if command_exists docker; then
    log_info "Docker já instalado"
    exit 0
  fi
- Utilizar marcadores (state files) quando apropriado: /var/lib/atlasstack/state/<componente>.installed
- Operações destrutivas devem ser condicionais e confirmadas por flags explícitas (ex.: --force, ATLAS_FORCE=true)
- Registrar trap para cleanup/rollback de passos parcialmente aplicados:
  CREATED_RESOURCES=()
  cleanup() {
    if [[ ${#CREATED_RESOURCES[@]} -gt 0 ]]; then
      log_warning "Rollback parcial: ${CREATED_RESOURCES[*]}"
      # reverter recursos 
    fi
  }
  trap cleanup EXIT

Convenções de interface (CLI)
- Uso: script [subcomando] [flags]
- Flags padrão:
  - --non-interactive | ATLAS_NON_INTERACTIVE=true
  - --yes | -y (assumir confirmações)
  - --debug | DEBUG=true
  - --component=<nome>
  - --version=<versão>
- Mensagem de help obrigatória (-h|--help), com exemplos.
- Retornos (exit codes): 0 sucesso, 1 erro genérico, 2 pré-requisito ausente, 3 validação falhou.

Segurança
Entrada e parâmetros
- Validar todos os parâmetros: vazio, tamanho, charset permitido, listas brancas.
- Nunca interpolar usuário diretamente em comandos; usar arrays e -- flags explícitas.
- Evitar eval. Usar case/if e mapeamentos seguros.

Arquivos e permissões
- Criar diretórios com umask 027; arquivos com 0640 (dados), 0750 (executáveis).
- set_secure_permissions <alvo> define owner:group e perms mínimas.
- Não armazenar segredos em texto plano; integrar com variáveis de ambiente e/ou gerenciadores de segredo quando aplicável.

Rede e downloads
- Sem HTTP sem TLS; usar HTTPS com verificação.
- Validar integridade por SHA256/PGP quando possível:
  secure_download "$url" "$dest" "$sha256"
- Limitar tempo de rede e retries (com backoff) via with_retry.

Privilégios
- Mínimo privilégio: executar como usuário comum quando possível.
- Verificações explícitas para ações que requerem root: require_root
- Evitar sudo encadeado; centralizar elevação quando necessário.

Testes
Estrutura
- tests/unit: validar funções de common.sh e lógicas puras.
- tests/integration: instalar componente em ambiente limpo (container/vm) e validar serviço/versão/ports.
- tests/scripts:
  - test_runner.sh: orquestra execução e coleta de resultados.
  - test_common.sh: asserções úteis (assert_command_exists, assert_service_running, assert_file_contains, assert_port_listening).

Exemplo de teste (integration)
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${REPO_ROOT}/install/common/common.sh"

test_docker_installation() {
  log_info "Executando instalação do Docker"
  "${REPO_ROOT}/install/components/docker/install.sh"
  assert_command_exists docker
  docker --version | grep -E "version" >/dev/null
  assert_service_running docker || die "Serviço docker não está ativo"
  log_success "Docker instalado e validado"
}

main() { test_docker_installation; }
main "$@"

Validação pós-instalação (validate.sh)
- Cada componente deve prover validate.sh com checagens objetivas:
  - comandos presentes e versões mínimas
  - serviços ativos, portas e sockets
  - arquivos de config renderizados e sintaxe válida
  - usuários/grupos criados, permissões aplicadas
- validate.sh deve retornar 0 apenas quando todas as checagens passarem.

Exemplos práticos
Cabeçalho e bootstrap
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${REPO_ROOT}/common/common.sh"

Detectar OS e decidir fluxo
detect_os
case "$OS_ID" in
  ubuntu|debian) install_debian_like ;;
  rhel|centos|rocky|almalinux) install_rhel_like ;;
  *) die "SO não suportado: $OS_ID" ;;
 esac

Logging com contexto
COMPONENT="docker"
log_info "[$COMPONENT] adicionando repositório oficial"

Idempotência simples
if systemctl is-active --quiet docker; then
  log_info "Docker já ativo"; exit 0; fi

Segurança em download
URL="https://download.docker.com/linux/static/stable/x86_64/docker-26.1.0.tgz"
SHA256="<sha256 esperado>"
secure_download "$URL" "/tmp/docker.tgz" "$SHA256"

Checklist de Pull Request
Estrutura e padrões
- [ ] Arquivo(s) em install/components/<componente>/ com install.sh (+ validate.sh e README.md)
- [ ] Shebang, set -euo pipefail e IFS ajustado
- [ ] Source de install/common/common.sh com caminho robusto
- [ ] Funções coesas, nomes descritivos e comentários sucintos

Logging e rastreabilidade
- [ ] Uso de log_info/log_error/log_success/log_warning/log_debug
- [ ] Mensagens com contexto do componente e ação
- [ ] Saída direcionada corretamente (stderr para erros)

Idempotência e rollback
- [ ] Verificações de estado antes de agir
- [ ] Marcadores/state files quando pertinente
- [ ] Trap de cleanup/rollback implementado para recursos temporários

Segurança
- [ ] Validação de entrada e listas brancas
- [ ] Sem eval; sem concatenação insegura de shell
- [ ] Downloads com verificação de integridade (SHA256/PGP)
- [ ] Permissões/ownership definidos para arquivos/dirs criados
- [ ] Execução com menor privilégio possível (require_root apenas quando necessário)

Compatibilidade e documentação
- [ ] detect_os e caminhos por distro implementados
- [ ] README do componente com pré-requisitos e limitações
- [ ] Variáveis de ambiente e flags documentadas

Testes e qualidade
- [ ] Testes unitários relevantes (quando aplicável)
- [ ] Teste de integração cobrindo caminho feliz e falhas comuns
- [ ] validate.sh cobrindo checagens essenciais
- [ ] shellcheck sem erros (permitido SC ignorado com justificativa)
- [ ] Pipeline local: ./tests/scripts/test_runner.sh verde

Notas finais
- Evite dependências desnecessárias; prefira comandos base do SO.
- Mensagens devem ser objetivas e em português.
- Todos os scripts devem passar por revisão de pares e lint (shellcheck). 
- Abra a PR com descrição clara, escopo, validações realizadas, plataformas testadas e logs relevantes.
