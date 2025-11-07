# METODOLOGIAS EMPREGADAS

Este documento descreve as principais metodologias adotadas no projeto AtlasStack para orientar a arquitetura, desenvolvimento e operações.

## Introdução

O AtlasStack é uma plataforma DevOps que integra práticas modernas de desenvolvimento, segurança e operações para simplificar a gestão de infraestrutura e aplicações. A adoção de metodologias consolidadas e reconhecidas pela indústria é fundamental para garantir que o projeto atinja seus objetivos de forma eficiente, escalável e sustentável.

Este documento apresenta as principais metodologias empregadas no projeto, detalhando seus fundamentos, objetivos e aplicações práticas no contexto do AtlasStack. As metodologias selecionadas refletem as melhores práticas da engenharia de software, operações de TI e gestão de infraestrutura, proporcionando uma base sólida para o desenvolvimento contínuo da plataforma.

A estruturação metodológica do projeto busca equilibrar aspectos técnicos, organizacionais e de negócio, promovendo a colaboração entre equipes, a automação de processos e a entrega de valor de forma consistente e confiável.

## Solution Design Canvas

### Descrição

O Solution Design Canvas é um modelo colaborativo para design de soluções de TI que facilita o alinhamento entre necessidades de negócio, capacidades tecnológicas e objetivos estratégicos. Desenvolvido por Hamish Sheild, este framework visual permite que equipes multidisciplinares trabalhem de forma estruturada na concepção e planejamento de soluções tecnológicas.

### Objetivos

- Promover o entendimento compartilhado entre stakeholders técnicos e de negócio
- Garantir o equilíbrio entre viabilidade técnica, desejabilidade do negócio e sustentabilidade operacional
- Facilitar a documentação visual e colaborativa de decisões arquiteturais
- Reduzir riscos através do mapeamento antecipado de dependências e restrições

### Aplicação no Projeto

No AtlasStack, o Solution Design Canvas é utilizado para:

- Estruturar sessões de design colaborativo com stakeholders
- Documentar decisões arquiteturais e suas justificativas
- Mapear integrações entre componentes da plataforma
- Alinhar requisitos funcionais e não-funcionais
- Visualizar o fluxo de valor das funcionalidades implementadas

A plataforma Miro é utilizada como ferramenta de apoio para facilitar a colaboração remota e a manutenção viva da documentação de design.

## Technology Radar

### Descrição

O Technology Radar é uma ferramenta criada pela ThoughtWorks para análise e comunicação de tendências tecnológicas. Organizado em quatro quadrantes (Técnicas, Ferramentas, Plataformas e Linguagens & Frameworks) e quatro anéis (Adotar, Experimentar, Avaliar e Evitar), o radar fornece orientações sobre a maturidade e adequação de tecnologias para uso em projetos.

### Objetivos

- Orientar decisões tecnológicas baseadas em análise de tendências e maturidade
- Promover a inovação controlada através da experimentação consciente
- Reduzir riscos tecnológicos ao evitar soluções imaturas ou inadequadas
- Facilitar a comunicação sobre escolhas tecnológicas com stakeholders

### Aplicação no Projeto

O AtlasStack mantém seu próprio Technology Radar interno para:

- Avaliar novas ferramentas e tecnologias para integração na plataforma
- Documentar o nível de maturidade e recomendação de uso de cada tecnologia
- Orientar decisões de arquitetura e seleção de componentes
- Promover discussões estruturadas sobre adoção tecnológica
- Manter a equipe atualizada sobre tendências relevantes para o contexto DevOps

## Day 0/1/2 Operations Framework

### Descrição

O framework Day 0/1/2 Operations é um modelo conceitual que organiza as operações de infraestrutura e aplicações em três fases distintas: Day 0 (planejamento e design), Day 1 (implantação e configuração inicial) e Day 2 (operação contínua e manutenção). Esta abordagem sistemática facilita o gerenciamento do ciclo de vida completo de sistemas e serviços.

### Objetivos

- Estruturar as atividades operacionais em fases claras e bem definidas
- Garantir que considerações operacionais sejam incorporadas desde o design
- Facilitar a transição suave entre as fases de implantação e operação
- Promover a automação e a padronização em cada fase operacional

### Aplicação no Projeto

**Day 0 - Design e Planejamento:**
- Definição de requisitos de infraestrutura e aplicações
- Planejamento de capacidade e dimensionamento
- Design de arquitetura e topologia de rede
- Definição de políticas de segurança e compliance

**Day 1 - Implantação e Configuração:**
- Provisionamento automatizado de infraestrutura
- Configuração inicial de componentes e serviços
- Implantação de aplicações e dependências
- Validação e testes de integração

**Day 2 - Operação e Manutenção:**
- Monitoramento contínuo de saúde e performance
- Aplicação de patches e atualizações
- Resposta a incidentes e troubleshooting
- Otimização e ajustes de capacidade
- Backup, recuperação e disaster recovery

## DevSecOps

### Descrição

DevSecOps é uma evolução da cultura DevOps que integra práticas de segurança em todas as etapas do ciclo de desenvolvimento e operações. Esta abordagem reconhece que a segurança não pode ser tratada como uma etapa isolada, mas deve ser incorporada desde o início do processo de desenvolvimento, promovendo a colaboração entre equipes de desenvolvimento, operações e segurança.

### Objetivos

- Integrar segurança como responsabilidade compartilhada em todas as equipes
- Automatizar testes e validações de segurança no pipeline de CI/CD
- Identificar e remediar vulnerabilidades o mais cedo possível no ciclo de desenvolvimento
- Promover a cultura de segurança por design (security by design)
- Manter conformidade com requisitos regulatórios e melhores práticas

### Aplicação no Projeto

No AtlasStack, o DevSecOps é implementado através de:

- Análise estática de código (SAST) integrada ao pipeline de CI/CD
- Escaneamento de vulnerabilidades em dependências e containers
- Políticas de segurança como código (Policy as Code)
- Testes de segurança automatizados
- Monitoramento contínuo de eventos de segurança
- Gestão de secrets e credenciais com ferramentas especializadas
- Controle de acesso baseado em papéis (RBAC)
- Auditoria e logging de operações sensíveis

## SRE (Site Reliability Engineering)

### Descrição

Site Reliability Engineering (SRE) é uma disciplina que aplica princípios de engenharia de software para resolver problemas operacionais e construir sistemas altamente confiáveis e escaláveis. Originada no Google, a abordagem SRE enfatiza a automação, o uso de métricas objetivas (SLIs, SLOs, SLAs) e o equilíbrio entre velocidade de inovação e estabilidade operacional.

### Objetivos

- Garantir confiabilidade e disponibilidade dos sistemas através de práticas de engenharia
- Estabelecer objetivos mensuráveis de nível de serviço (SLOs)
- Promover a automação para reduzir trabalho operacional manual (toil)
- Implementar práticas de observabilidade e monitoramento eficazes
- Equilibrar inovação e estabilidade através de orçamentos de erro (error budgets)

### Aplicação no Projeto

O AtlasStack adota princípios SRE para:

- Definir e monitorar Service Level Indicators (SLIs) e Service Level Objectives (SLOs)
- Implementar observabilidade através de logs, métricas e traces distribuídos
- Automatizar respostas a incidentes através de runbooks e auto-remediação
- Realizar análises post-mortem sem culpa (blameless postmortems)
- Medir e reduzir toil através de automação progressiva
- Implementar práticas de chaos engineering para validar resiliência
- Gerenciar orçamentos de erro para balancear inovação e confiabilidade
- Estabelecer on-call rotations e procedimentos de escalação

## Developer Experience (DX)

### Descrição

Developer Experience (DX) refere-se ao conjunto de práticas, ferramentas e processos que impactam a experiência dos desenvolvedores ao interagir com sistemas, ferramentas e plataformas. Uma DX positiva resulta em maior produtividade, satisfação e qualidade do código, enquanto uma DX negativa pode levar a frustração, ineficiência e aumento de erros.

### Objetivos

- Otimizar ferramentas e processos para maximizar a produtividade dos desenvolvedores
- Reduzir fricções e obstáculos no fluxo de trabalho de desenvolvimento
- Promover o bem-estar e a satisfação dos desenvolvedores
- Facilitar onboarding e reduzir a curva de aprendizado
- Fornecer feedback rápido e contexto relevante durante o desenvolvimento

### Aplicação no Projeto

No AtlasStack, o foco em Developer Experience se manifesta através de:

- Ambientes de desenvolvimento padronizados e facilmente reproduzíveis
- Documentação clara, atualizada e facilmente acessível
- Ferramentas de CLI intuitivas e bem documentadas
- Feedback rápido através de pipelines de CI/CD otimizados
- Automação de tarefas repetitivas e propensas a erros
- Templates e scaffolding para facilitar a criação de novos componentes
- Ambientes de desenvolvimento local que espelham produção (dev containers)
- Ferramentas de diagnóstico e debugging integradas
- Portal de auto-serviço para operações comuns
- Coleta e análise de métricas de DX para melhoria contínua

## REFERÊNCIAS

BEYER, B. et al. **Site Reliability Engineering**: How Google Runs Production Systems. Sebastopol: O'Reilly Media, 2016.

FORSGREN, N.; HUMBLE, J.; KIM, G. **Accelerate**: The Science of Lean Software and DevOps: Building and Scaling High Performing Technology Organizations. Portland: IT Revolution Press, 2018.

KIM, G. et al. **The DevOps Handbook**: How to Create World-Class Agility, Reliability, and Security in Technology Organizations. Portland: IT Revolution Press, 2016.

MIRO. **Canvas de Soluções para Aplicativos de Negócios**. Disponível em: https://miro.com/pt/modelos/solution-canvas-business-applications/. Acesso em: 07 nov. 2025.

MURPHY, N. R.; BEYER, B.; JONES, C.; PETOFF, J. **Site Reliability Workbook**: Practical Ways to Implement SRE. Sebastopol: O'Reilly Media, 2018.

SHEILD, H. **Solution Design Canvas**: A Collaborative Framework for Designing Business Applications. Miro Platform, 2020. Disponível em: https://miro.com/pt/modelos/solution-canvas-business-applications/. Acesso em: 07 nov. 2025.

THOUGHTWORKS. **Technology Radar**: An opinionated guide to technology frontiers. Disponível em: https://www.thoughtworks.com/en-br/radar. Acesso em: 07 nov. 2025.

WILLIS, J. **DevOps Culture** (Part 1). IT Revolution, 2012. Disponível em: https://itrevolution.com/articles/devops-culture-part-1/. Acesso em: 07 nov. 2025.

---

*Documento elaborado em conformidade com as normas ABNT NBR 6023 (Informação e documentação — Referências — Elaboração) e NBR 6028 (Informação e documentação — Resumo — Apresentação).*
