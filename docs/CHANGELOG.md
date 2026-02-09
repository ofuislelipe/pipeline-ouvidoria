# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planejado
- Implementação da camada Bronze (10 tabelas)
- Implementação da camada Silver
- Implementação de tabelas dimensão
- Implementação da camada Gold
- Setup do Apache Airflow
- DAG de orquestração completa
- Testes automatizados
- Documentação completa

## [0.1.0] - 2026-02-09

### Adicionado
- Estrutura inicial do projeto
- README.md com visão geral e arquitetura
- Documentação de validação (docs/VALIDACAO.md)
- .gitignore configurado
- requirements.txt com dependências
- .env.example com variáveis de ambiente
- Estrutura de diretórios (queries/, airflow/, utils/, tests/)

### Contexto
- **Migração:** De query SQL monolítica para arquitetura em camadas
- **Origem:** Pipeline local via Docker → AWS Cloud (Athena + S3)
- **Objetivo:** Modernizar arquitetura seguindo padrão Medallion (Bronze→Silver→Gold)

---

## Notas de Versão

### Versão 0.1.0 - Setup Inicial
Esta é a versão inicial do projeto após migração para AWS. A query monolítica original foi consolidada em um único arquivo durante a migração. Este projeto documenta a refatoração para uma arquitetura profissional em camadas.

**Decisões Técnicas:**
- Formato: Parquet com compressão Snappy (otimização de custo e performance)
- Orquestração: Apache Airflow (flexibilidade e visibilidade)
- Versionamento: Git para queries SQL (rastreabilidade de mudanças)
- Validação: Checkpoints em cada camada (qualidade dos dados)

**Próximos Passos:**
1. Implementar camada Bronze (Semana 2)
2. Implementar camada Silver + Dimensões (Semana 3)
3. Implementar camada Gold (Semana 4)
4. Configurar Airflow e automação
