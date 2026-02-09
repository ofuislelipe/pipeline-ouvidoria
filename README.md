# 🏗️ Pipeline Ouvidoria - Modernização

> Refatoração do pipeline de dados da Ouvidoria de arquitetura monolítica para Bronze→Silver→Gold com orquestração via Apache Airflow

## 📋 Visão Geral

Este projeto documenta a modernização completa do pipeline de dados de Ouvidoria, migrando de uma query SQL única para uma arquitetura em camadas profissional seguindo o padrão Medallion (Bronze→Silver→Gold).

### **Objetivos**
- ✅ Separar deduplicação (Bronze), limpeza (Silver) e métricas de negócio (Gold)
- ✅ Implementar orquestração com Apache Airflow
- ✅ Melhorar manutenibilidade e reusabilidade
- ✅ Criar tabelas dimensão para regras de negócio
- ✅ Adicionar validações automatizadas em cada camada

### **Status Atual**
🔄 **Em Progresso** - Semana 1: Setup e Fundação

[![Progress](https://img.shields.io/badge/Progresso-0%25-red)](https://github.com/seu-usuario/pipeline-ouvidoria)
[![Bronze](https://img.shields.io/badge/Bronze-Planejado-lightgrey)](queries/bronze/)
[![Silver](https://img.shields.io/badge/Silver-Planejado-lightgrey)](queries/silver/)
[![Gold](https://img.shields.io/badge/Gold-Planejado-lightgrey)](queries/gold/)

---

## 🏛️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                     FONTE DE DADOS                          │
│                  Salesforce (via Glue)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA BRONZE                            │
│              (Deduplicação - 10 tabelas)                    │
│  • bronze_case        • bronze_lead                         │
│  • bronze_task        • bronze_protocolo                    │
│  • bronze_account     • bronze_fato                         │
│  • bronze_user        • bronze_produto                      │
│  • bronze_unidade     • bronze_recordtype                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA SILVER                            │
│           (Limpeza + Merge Account/Lead)                    │
│              • silver_ouvidoria_base                        │
│                                                             │
│                  TABELAS DIMENSÃO                           │
│              • dim_canal                                    │
│              • dim_empresa                                  │
│              • dim_regiao                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     CAMADA GOLD                             │
│              (Métricas de Negócio)                          │
│          • gold_ouvidoria_analitica                         │
│            - Cálculos de prazo                              │
│            - Classificações                                 │
│            - Segmentações                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura do Projeto

```
pipeline-ouvidoria/
├── README.md                          # Este arquivo
├── docs/                              # Documentação
│   ├── ARCHITECTURE.md                # Arquitetura detalhada
│   ├── VALIDACAO.md                   # Queries de validação
│   ├── TROUBLESHOOTING.md             # Problemas comuns
│   └── CHANGELOG.md                   # Histórico de mudanças
│
├── queries/                           # Queries SQL por camada
│   ├── bronze/                        # Deduplicação
│   │   ├── case.sql
│   │   ├── task.sql
│   │   ├── account.sql
│   │   ├── lead.sql
│   │   ├── protocolo.sql
│   │   ├── fato.sql
│   │   ├── unidade.sql
│   │   ├── produto.sql
│   │   ├── user.sql
│   │   └── recordtype.sql
│   │
│   ├── silver/                        # Limpeza e merge
│   │   └── ouvidoria_base.sql
│   │
│   ├── gold/                          # Métricas de negócio
│   │   └── ouvidoria_analitica.sql
│   │
│   └── dimensions/                    # Tabelas dimensão
│       ├── dim_canal.sql
│       ├── dim_empresa.sql
│       └── dim_regiao.sql
│
├── airflow/                           # Orquestração
│   ├── dags/
│   │   └── ouvidoria_pipeline.py     # DAG principal
│   └── config/
│       └── airflow.cfg
│
├── utils/                             # Utilitários Python
│   ├── athena_helper.py               # Helper para Athena
│   └── logger.py                      # Configuração de logs
│
├── tests/                             # Testes e validações
│   ├── test_bronze.sql
│   ├── test_silver.sql
│   └── test_gold.sql
│
└── legacy/                            # Código antigo (referência)
    └── query_monolitica_original.sql
```

---

## 🚀 Quick Start

### **Pré-requisitos**
- AWS Account com acesso ao Athena
- SageMaker Notebook ou ambiente local com Python 3.8+
- Permissões S3 para bucket de dados

### **1. Clone o repositório**
```bash
git clone https://github.com/seu-usuario/pipeline-ouvidoria.git
cd pipeline-ouvidoria
```

### **2. Configure ambiente**
```bash
# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais
```

### **3. Executar camada Bronze**
```bash
# Executar todas as queries Bronze
python scripts/run_bronze.py

# Ou executar query individual
aws athena start-query-execution \
  --query-string file://queries/bronze/case.sql \
  --result-configuration OutputLocation=s3://seu-bucket/results/
```

### **4. Validar resultados**
```bash
# Rodar testes
python -m pytest tests/

# Ou validar manualmente
athena < tests/test_bronze.sql
```

---

## 📊 Métricas e Validação

### **Contadores por Camada**

| Camada | Tabelas | Status | Último Update |
|--------|---------|--------|---------------|
| Bronze | 10 | ⏳ Pendente | - |
| Silver | 1 + 3 dims | ⏳ Pendente | - |
| Gold | 1 | ⏳ Pendente | - |

### **Queries de Validação**

Veja [docs/VALIDACAO.md](docs/VALIDACAO.md) para queries completas de validação.

---

## 🛠️ Stack Tecnológico

- **Cloud:** AWS (Athena, S3, Glue, SageMaker)
- **Orquestração:** Apache Airflow 2.8.1
- **Formato de Dados:** Parquet + Snappy compression
- **Linguagens:** SQL (Presto/Athena dialect), Python 3.8+
- **Versionamento:** Git + GitHub

---

## 📖 Documentação Adicional

- [📐 Arquitetura Detalhada](docs/ARCHITECTURE.md)
- [✅ Guia de Validação](docs/VALIDACAO.md)
- [🐛 Troubleshooting](docs/TROUBLESHOOTING.md)
- [📝 Changelog](docs/CHANGELOG.md)

---

## 🤝 Contribuindo

Este é um projeto pessoal de refatoração, mas contribuições são bem-vindas!

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📅 Timeline

- **Semana 1:** Setup e Fundação ⏳
- **Semana 2:** Camada Bronze (10 tabelas)
- **Semana 3:** Camada Silver + Dimensões
- **Semana 4:** Camada Gold + Airflow
- **Validação:** Comparação com query antiga

---

## 📜 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## ✉️ Contato

**Projeto mantido por:** [Luis Felipe]

📧 Email: lu_isfelipe@outlook.com 
💼 LinkedIn: [Luis Felipe]([https://www.linkedin.com/in/luis-felipe-batista-de-carvalho-9a9a2713a/))  
🐙 GitHub: [@ofuislelipe]([(https://github.com/ofuislelipe))

---

⭐ **Se este projeto te ajudou, deixe uma estrela!**
