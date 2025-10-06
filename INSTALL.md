# 📦 Instalação do AtlasStack

Guia de instalação rápida do AtlasStack.

## 🔧 Pré-requisitos

Antes de iniciar a instalação, certifique-se de que seu sistema possui:

- **git**: Para clonar o repositório
- **bash**: Shell padrão (disponível na maioria dos sistemas Linux)
- **logger**: Utilitário de logging do sistema (pacote `bsdutils` no Debian/Ubuntu)

## ⚡ Instalação Rápida

### Opção 1: Instalação Direta (Recomendada)

Execute o comando abaixo para iniciar a instalação automaticamente:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/devopsvanilla/AtlasStack/main/scripts/install_atlas.sh)
```

Este comando irá:
- Fazer o download do script de instalação
- Executá-lo diretamente no seu sistema
- Verificar e instalar dependências necessárias
- Iniciar o menu principal do AtlasStack

### Opção 2: Instalação Manual

Se preferir ter mais controle sobre o processo:

```bash
# Clone o repositório
git clone https://github.com/devopsvanilla/AtlasStack.git

# Entre no diretório
cd AtlasStack

# Execute o script de instalação
bash scripts/install_atlas.sh
```

## 📋 O que faz o script de instalação?

O script `install_atlas.sh` realiza as seguintes operações:

1. **Verificação de Dependências**: Checa se as ferramentas necessárias estão instaladas
2. **Instalação Automática**: Instala automaticamente as dependências mínimas em sistemas Debian/Ubuntu
3. **Menu Principal**: Após a configuração inicial, executa o menu principal do AtlasStack

## ⚠️ Observações Importantes

### Ambientes Não Debian/Ubuntu

Se você estiver usando uma distribuição Linux diferente de Debian/Ubuntu (como Red Hat, CentOS, Fedora, Arch, etc.), o script de instalação:

- Identificará as dependências ausentes
- **Não** tentará instalá-las automaticamente
- Solicitará que você instale manualmente usando o gerenciador de pacotes da sua distribuição

Exemplos de instalação manual de dependências:

**Red Hat/CentOS/Fedora:**
```bash
sudo dnf install git bash util-linux
```

**Arch Linux:**
```bash
sudo pacman -S git bash util-linux
```

## 🎯 Próximos Passos

Após a instalação, você terá acesso ao:

- **Menu Principal**: Interface interativa para acessar todas as funcionalidades do AtlasStack
- **Modo Avançado**: Opções adicionais para usuários experientes
- **Documentação**: Acesso a guias e exemplos de uso

## 🆘 Solução de Problemas

### Erro de permissão ao executar o script

Se encontrar erro de permissão, certifique-se de executar o script com as permissões adequadas:

```bash
chmod +x scripts/install_atlas.sh
bash scripts/install_atlas.sh
```

### Dependências não encontradas

Se o script reportar dependências ausentes, instale-as manualmente usando o gerenciador de pacotes da sua distribuição antes de executar o script novamente.

## 📚 Documentação Adicional

Para mais informações sobre o projeto, consulte:

- [README.md](README.md) - Visão geral do projeto
- [LICENSE](LICENSE) - Informações de licenciamento

## 💬 Suporte

Se encontrar problemas durante a instalação:

1. Verifique os logs de erro exibidos pelo script
2. Consulte a documentação no [README.md](README.md)
3. Abra uma [issue](https://github.com/devopsvanilla/AtlasStack/issues) descrevendo o problema

---

⭐ **Gostou do AtlasStack?** Considere dar uma estrela no repositório!
