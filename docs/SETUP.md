# 🚀 Guia de Setup - GitHub + Notion

Este guia te ajuda a configurar o ambiente completo do projeto.

---

## PARTE 1: Setup do GitHub

### **Passo 1: Criar repositório no GitHub**

1. Acesse: https://github.com/new
2. Nome do repositório: `pipeline-ouvidoria`
3. Descrição: `Modernização do pipeline de dados Ouvidoria - Bronze→Silver→Gold`
4. Visibilidade: **Private** (recomendado) ou Public
5. ✅ Marque: "Add a README file" → **NÃO** (vamos fazer upload do nosso)
6. ✅ Marque: "Add .gitignore" → **NÃO** (já temos o nosso)
7. Escolha licença: **MIT License**
8. Clique em **"Create repository"**

### **Passo 2: Fazer upload dos arquivos**

**Opção A: Via linha de comando (recomendado)**

```bash
# No seu SageMaker Notebook ou terminal local

# 1. Navegar para onde você salvou os arquivos do GitHub
cd /caminho/para/github-project

# 2. Inicializar Git
git init

# 3. Adicionar arquivos
git add .

# 4. Primeiro commit
git commit -m "feat: setup inicial do projeto - estrutura e documentação"

# 5. Adicionar remote (substitua SEU-USUARIO)
git remote add origin https://github.com/SEU-USUARIO/pipeline-ouvidoria.git

# 6. Fazer push
git branch -M main
git push -u origin main
```

**Opção B: Via interface web do GitHub**

1. No repositório criado, clique em **"uploading an existing file"**
2. Arraste todos os arquivos e pastas
3. Commit message: `feat: setup inicial do projeto`
4. Clique em **"Commit changes"**

### **Passo 3: Configurar GitHub para trabalho diário**

```bash
# Configurar seu nome e email
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Criar branch para desenvolvimento
git checkout -b develop

# Workflow recomendado:
# - main: código em produção
# - develop: desenvolvimento ativo
# - feature/nome-da-feature: features específicas
```

---

## PARTE 2: Setup do Notion

### **Passo 1: Criar workspace no Notion**

1. Acesse: https://notion.so
2. Se não tiver conta, crie uma (é grátis!)
3. Crie um novo workspace ou use o existente

### **Passo 2: Importar template**

Vou criar o template em formato CSV que você pode importar:

1. No Notion, clique em **"Import"** (menu lateral)
2. Escolha **"CSV"**
3. Faça upload do arquivo `notion_template.csv` que vou criar
4. O Notion vai criar automaticamente:
   - Database com todas as tarefas
   - Views: Kanban, Tabela, Timeline

### **Passo 3: Configurar estrutura no Notion**

Crie uma página principal chamada **"Pipeline Ouvidoria - Modernização"**

Dentro dela, adicione:

#### **1. 📊 Database de Tarefas (Board view)**
- Importar do CSV
- Configurar filtros por Bucket (Semana)
- Adicionar propriedades: Status, Prioridade, Tempo Estimado

#### **2. 📖 Página de Documentação**
Adicione seções:
- **Visão Geral do Projeto**
- **Arquitetura** (copie diagrama do README.md)
- **Links Importantes:**
  - Link para GitHub: `https://github.com/seu-usuario/pipeline-ouvidoria`
  - Link para Athena Console
  - Link para S3 Bucket

#### **3. 🔍 Queries de Validação**
- Copie o conteúdo de `docs/VALIDACAO.md`
- Use code blocks para SQL
- Adicione checkboxes para marcar quando executadas

#### **4. 📝 Learnings & Troubleshooting**
- Página em branco para documentar:
  - Problemas encontrados e soluções
  - Dicas e truques
  - Decisões técnicas tomadas

#### **5. 📅 Timeline**
- Database view do tipo Timeline
- Agrupar por Semana
- Marcar datas de início e fim

---

## PARTE 3: Integração GitHub ↔ Notion

### **Adicionar links entre as duas plataformas:**

#### No Notion:
```
🔗 Links Rápidos
├─ 📁 Repositório GitHub: [https://github.com/seu-usuario/pipeline-ouvidoria]
├─ 📋 Issues: [https://github.com/seu-usuario/pipeline-ouvidoria/issues]
└─ 📊 Projects: [https://github.com/seu-usuario/pipeline-ouvidoria/projects]
```

#### No GitHub (README.md):
Adicione na seção de links:
```markdown
## 📚 Documentação

- 📘 [Notion - Project Tracker](https://notion.so/seu-workspace/...)
- 📐 [Arquitetura](docs/ARCHITECTURE.md)
- ✅ [Validações](docs/VALIDACAO.md)
```

---

## PARTE 4: Workflow Diário Recomendado

### **🌅 Início do Dia**

1. **Notion**: Abrir página do projeto
   - Ver tarefas do dia em "My Day"
   - Ler checklist da tarefa atual
   
2. **GitHub**: Pull das últimas mudanças
   ```bash
   git pull origin develop
   ```

3. **Trabalhar na tarefa**
   - Criar/editar arquivos SQL
   - Testar no Athena
   - Documentar problemas no Notion

### **🌆 Fim do Dia**

1. **Commit no GitHub**
   ```bash
   git add queries/bronze/case.sql
   git commit -m "feat(bronze): adiciona query de deduplicação de case"
   git push origin develop
   ```

2. **Atualizar Notion**
   - Marcar checklist items concluídos
   - Mover card para "In Progress" ou "Done"
   - Adicionar notas/learnings

3. **Planejar amanhã**
   - Marcar próximas tarefas no Notion

### **📅 Semanal (Sexta-feira)**

1. **Retrospectiva**
   - O que foi bem?
   - O que pode melhorar?
   - Bloqueios?

2. **Atualizar documentação**
   - Atualizar CHANGELOG.md
   - Atualizar % de progresso no README

3. **Planejar próxima semana**
   - Revisar tarefas da próxima semana no Notion
   - Estimar tempo necessário

---

## PARTE 5: Comandos Git Essenciais

### **Comandos do dia a dia:**

```bash
# Ver status dos arquivos
git status

# Adicionar arquivo específico
git add queries/bronze/case.sql

# Adicionar todos os arquivos modificados
git add .

# Commit com mensagem
git commit -m "feat(bronze): adiciona query case"

# Push para GitHub
git push origin develop

# Ver histórico
git log --oneline --graph

# Criar nova branch para feature
git checkout -b feature/adicionar-silver

# Voltar para branch develop
git checkout develop

# Merge de branch
git merge feature/adicionar-silver
```

### **Convenção de Commits:**

Use prefixos descritivos:

```
feat(bronze): adiciona query de deduplicação
fix(silver): corrige merge de Account e Lead  
docs: atualiza documentação de validação
test: adiciona testes para bronze_case
refactor(gold): melhora performance do cálculo de dias úteis
```

---

## PARTE 6: Estrutura de Pastas no SageMaker

```bash
# Criar estrutura completa
cd /home/sagemaker-user

# Clonar repositório
git clone https://github.com/seu-usuario/pipeline-ouvidoria.git

# Estrutura resultante:
/home/sagemaker-user/
└── pipeline-ouvidoria/
    ├── queries/
    │   ├── bronze/
    │   ├── silver/
    │   ├── gold/
    │   └── dimensions/
    ├── airflow/
    ├── utils/
    ├── tests/
    ├── docs/
    └── ...
```

---

## ✅ Checklist de Setup Completo

### GitHub
- [ ] Repositório criado
- [ ] Arquivos commitados
- [ ] README.md visível
- [ ] .gitignore funcionando
- [ ] Branch develop criada

### Notion
- [ ] Workspace criado
- [ ] Template importado
- [ ] Tarefas visíveis em Kanban
- [ ] Documentação adicionada
- [ ] Links para GitHub configurados

### Integração
- [ ] Link do Notion no README.md do GitHub
- [ ] Link do GitHub no Notion
- [ ] Workflow diário definido

### Ambiente Local
- [ ] Git configurado (nome + email)
- [ ] Repositório clonado no SageMaker
- [ ] Variáveis de ambiente configuradas (.env)

---

## 🆘 Troubleshooting

### "Não consigo fazer push para o GitHub"
```bash
# Configure credenciais
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Ou use Personal Access Token
# GitHub → Settings → Developer settings → Personal access tokens
```

### "Notion não está importando o CSV"
- Verifique se o arquivo está em UTF-8
- Tente importar via Google Sheets primeiro, depois copiar para Notion

### "Git está pedindo senha toda hora"
```bash
# Configure SSH keys ou use credential helper
git config --global credential.helper store
```

---

**🎉 Setup completo! Agora você está pronto para começar a trabalhar no projeto!**
