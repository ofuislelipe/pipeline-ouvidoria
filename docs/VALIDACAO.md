# ✅ Guia de Validação

Este documento contém todas as queries de validação para cada camada do pipeline.

## 📋 Índice

1. [Checkpoint 1 - Bronze](#checkpoint-1---bronze)
2. [Checkpoint 2 - Silver](#checkpoint-2---silver)
3. [Checkpoint 3 - Gold](#checkpoint-3---gold)
4. [Validações de Integridade](#validações-de-integridade)

---

## Checkpoint 1 - Bronze

### ✅ Validar que todas as tabelas foram criadas

```sql
-- Listar todas as tabelas Bronze
SHOW TABLES IN auditoria LIKE 'bronze_%';

-- Resultado esperado: 10 tabelas
-- bronze_account, bronze_case, bronze_fato, bronze_lead, 
-- bronze_produto, bronze_protocolo, bronze_recordtype, 
-- bronze_task, bronze_unidade, bronze_user
```

### ✅ Validar contagens por tabela

```sql
-- Contagens de registros em cada tabela
SELECT 'bronze_case' as tabela, COUNT(*) as total FROM auditoria.bronze_case
UNION ALL
SELECT 'bronze_task', COUNT(*) FROM auditoria.bronze_task
UNION ALL
SELECT 'bronze_account', COUNT(*) FROM auditoria.bronze_account
UNION ALL
SELECT 'bronze_lead', COUNT(*) FROM auditoria.bronze_lead
UNION ALL
SELECT 'bronze_protocolo', COUNT(*) FROM auditoria.bronze_protocolo
UNION ALL
SELECT 'bronze_fato', COUNT(*) FROM auditoria.bronze_fato
UNION ALL
SELECT 'bronze_unidade', COUNT(*) FROM auditoria.bronze_unidade
UNION ALL
SELECT 'bronze_produto', COUNT(*) FROM auditoria.bronze_produto
UNION ALL
SELECT 'bronze_user', COUNT(*) FROM auditoria.bronze_user
UNION ALL
SELECT 'bronze_recordtype', COUNT(*) FROM auditoria.bronze_recordtype
ORDER BY tabela;

-- Resultado esperado: Todas as contagens > 0
```

### ✅ Validar que não há duplicados (CRÍTICO!)

```sql
-- Validar bronze_case (deve retornar 0)
SELECT COUNT(*) - COUNT(DISTINCT id) as duplicados 
FROM auditoria.bronze_case;

-- Validar bronze_task (deve retornar 0)
SELECT COUNT(*) - COUNT(DISTINCT id) as duplicados 
FROM auditoria.bronze_task;

-- Validar bronze_account (deve retornar 0)
SELECT COUNT(*) - COUNT(DISTINCT id) as duplicados 
FROM auditoria.bronze_account;

-- Se retornar qualquer valor diferente de 0, há problema na deduplicação!
```

### ✅ Validar intervalo de datas

```sql
-- Verificar range de datas em bronze_case
SELECT 
    MIN(data_recebimento_ouvidoria__c) as data_mais_antiga,
    MAX(data_recebimento_ouvidoria__c) as data_mais_recente,
    COUNT(*) as total_registros
FROM auditoria.bronze_case;

-- Resultado esperado: data_mais_antiga >= 2021-01-01
```

### ✅ Validar qualidade dos dados

```sql
-- Verificar campos nulos em bronze_case
SELECT 
    COUNT(*) as total,
    COUNT(id) as com_id,
    COUNT(casenumber) as com_casenumber,
    COUNT(data_recebimento_ouvidoria__c) as com_dt_recebimento,
    COUNT(*) - COUNT(id) as sem_id,
    COUNT(*) - COUNT(casenumber) as sem_casenumber
FROM auditoria.bronze_case;

-- Resultado esperado: sem_id e sem_casenumber devem ser 0
```

---

## Checkpoint 2 - Silver

### ✅ Validar criação das tabelas

```sql
-- Listar tabelas Silver e Dimensões
SHOW TABLES IN auditoria LIKE 'silver_%';
SHOW TABLES IN auditoria LIKE 'dim_%';

-- Resultado esperado:
-- silver_ouvidoria_base
-- dim_canal, dim_empresa, dim_regiao
```

### ✅ Validar contagem Silver vs Bronze

```sql
-- Comparar contagem
SELECT 
    (SELECT COUNT(*) FROM auditoria.silver_ouvidoria_base) as count_silver,
    (SELECT COUNT(*) FROM auditoria.bronze_case WHERE casenumber IS NOT NULL) as count_bronze_case;

-- Resultado esperado: Valores próximos (documentar diferenças se houver)
```

### ✅ Validar merge Account + Lead

```sql
-- Verificar merge de nome_cliente
SELECT 
    COUNT(*) as total,
    COUNT(nome_cliente) as com_nome,
    COUNT(CASE WHEN nome_cliente IS NULL THEN 1 END) as sem_nome,
    ROUND(100.0 * COUNT(nome_cliente) / COUNT(*), 2) as percentual_com_nome
FROM auditoria.silver_ouvidoria_base;

-- Resultado esperado: percentual_com_nome > 90%
```

### ✅ Validar dimensões

```sql
-- dim_canal: validar valores únicos
SELECT 
    COUNT(*) as total_canais,
    COUNT(DISTINCT canal_raw) as canais_unicos,
    COUNT(DISTINCT tp_canal) as tipos_canal
FROM auditoria.dim_canal;

-- dim_empresa: validar valores únicos
SELECT 
    COUNT(*) as total_empresas,
    COUNT(DISTINCT diretoria_raw) as diretorias_unicas,
    COUNT(DISTINCT ds_empresa) as empresas_unicas
FROM auditoria.dim_empresa;

-- dim_regiao: deve ter exatamente 27 registros (27 UFs)
SELECT COUNT(*) as total_ufs FROM auditoria.dim_regiao;

-- Resultado esperado: 27
```

### ✅ Validar conversões de timezone

```sql
-- Verificar se datas foram convertidas corretamente (GMT-3)
SELECT 
    dt_criacao,
    dt_fechamento,
    dt_recebimento,
    dt_fechamento_date
FROM auditoria.silver_ouvidoria_base
WHERE dt_fechamento IS NOT NULL
LIMIT 10;

-- Validar manualmente se as datas fazem sentido
```

---

## Checkpoint 3 - Gold (CRÍTICO!)

### ✅ Comparar contagens Gold nova vs antiga

```sql
-- COMPARAÇÃO CRÍTICA
SELECT 
    (SELECT COUNT(*) FROM auditoria.gold_ouvidoria_analitica) as count_nova,
    (SELECT COUNT(*) FROM auditoria.tb_ouvidoria_analitica) as count_antiga,
    ABS((SELECT COUNT(*) FROM auditoria.gold_ouvidoria_analitica) - 
        (SELECT COUNT(*) FROM auditoria.tb_ouvidoria_analitica)) as diferenca;

-- Resultado esperado: diferenca = 0 (ou próximo, com justificativa)
```

### ✅ Validar cálculo de dias corridos

```sql
-- Amostragem de dias corridos
SELECT 
    numero_solicitacao,
    dt_recebimento,
    dt_fechamento_date,
    qtd_dias_corridos,
    DATE_DIFF('day', dt_recebimento, dt_fechamento_date) as calculado_manualmente
FROM auditoria.gold_ouvidoria_analitica
WHERE dt_fechamento IS NOT NULL
  AND qtd_dias_corridos IS NOT NULL
LIMIT 20;

-- Resultado esperado: qtd_dias_corridos = calculado_manualmente (sempre)
```

### ✅ Validar cálculo de dias úteis

```sql
-- Validar que dias úteis <= dias corridos (sempre!)
SELECT 
    COUNT(*) as total_com_fechamento,
    COUNT(CASE WHEN qtd_dias_uteis <= qtd_dias_corridos THEN 1 END) as validos,
    COUNT(CASE WHEN qtd_dias_uteis > qtd_dias_corridos THEN 1 END) as invalidos
FROM auditoria.gold_ouvidoria_analitica
WHERE dt_fechamento IS NOT NULL;

-- Resultado esperado: invalidos = 0 (SEMPRE!)
```

### ✅ Validar casos em andamento (NULL)

```sql
-- Verificar que casos sem fechamento têm prazo NULL
SELECT 
    COUNT(*) as total_sem_fechamento,
    COUNT(CASE WHEN qtd_dias_corridos IS NULL THEN 1 END) as com_prazo_null,
    COUNT(CASE WHEN qtd_dias_corridos IS NOT NULL THEN 1 END) as com_prazo_preenchido
FROM auditoria.gold_ouvidoria_analitica
WHERE dt_fechamento IS NULL;

-- Resultado esperado: com_prazo_preenchido = 0
```

### ✅ Validar JOINs com dimensões

```sql
-- Verificar se todos os registros têm dimensões associadas
SELECT 
    COUNT(*) as total,
    COUNT(tp_canal) as com_tp_canal,
    COUNT(ds_canal) as com_ds_canal,
    COUNT(ds_empresa) as com_ds_empresa,
    COUNT(cliente_regiao) as com_regiao
FROM auditoria.gold_ouvidoria_analitica;

-- Resultado esperado: maioria dos registros com dimensões preenchidas
```

### ✅ Validar campos derivados

```sql
-- Amostragem de segmento_ajustado
SELECT 
    diretoria_protocolo,
    segmento,
    produto_raw,
    segmento_ajustado,
    COUNT(*) as qtd
FROM auditoria.gold_ouvidoria_analitica
GROUP BY 1,2,3,4
ORDER BY qtd DESC
LIMIT 20;

-- Validar manualmente se as regras de negócio foram aplicadas
```

---

## Validações de Integridade

### ✅ Validar performance de queries

```sql
-- Verificar tamanho das tabelas (dados escaneados)
SELECT 
    table_name,
    ROUND(SUM(size) / 1024.0 / 1024.0 / 1024.0, 2) as size_gb
FROM information_schema.table_storage
WHERE table_schema = 'auditoria'
  AND table_name IN ('bronze_case', 'bronze_task', 'silver_ouvidoria_base', 'gold_ouvidoria_analitica')
GROUP BY table_name
ORDER BY size_gb DESC;
```

### ✅ Validar formato Parquet

```sql
-- Confirmar que tabelas estão em Parquet
SHOW CREATE TABLE auditoria.bronze_case;
SHOW CREATE TABLE auditoria.silver_ouvidoria_base;
SHOW CREATE TABLE auditoria.gold_ouvidoria_analitica;

-- Resultado esperado: format = 'PARQUET', parquet_compression = 'SNAPPY'
```

---

## 🎯 Checklist de Validação Completa

### Checkpoint 1 - Bronze
- [ ] 10 tabelas criadas
- [ ] Todas com registros > 0
- [ ] Sem duplicados em nenhuma tabela
- [ ] Intervalo de datas correto (>= 2021-01-01)
- [ ] Campos chave não nulos

### Checkpoint 2 - Silver
- [ ] silver_ouvidoria_base criada
- [ ] 3 dimensões criadas (canal, empresa, regiao)
- [ ] Contagem similar ao Bronze
- [ ] Merge Account+Lead com >90% preenchimento
- [ ] 27 UFs na dim_regiao
- [ ] Conversões de timezone corretas

### Checkpoint 3 - Gold
- [ ] gold_ouvidoria_analitica criada
- [ ] Contagem igual (ou próxima com justificativa) à tabela antiga
- [ ] Dias corridos calculados corretamente
- [ ] Dias úteis <= dias corridos (sempre)
- [ ] Casos em andamento com prazo NULL
- [ ] Dimensões associadas
- [ ] Campos derivados corretos

---

## 📊 Script de Validação Automatizada

Salve este script como `run_all_validations.sql` e execute via Athena:

```sql
-- SCRIPT COMPLETO DE VALIDAÇÃO
-- Execute e salve os resultados

-- 1. Contagens gerais
SELECT 'CONTAGENS' as checkpoint, 'bronze_case' as item, COUNT(*) as valor FROM auditoria.bronze_case
UNION ALL SELECT 'CONTAGENS', 'bronze_task', COUNT(*) FROM auditoria.bronze_task
UNION ALL SELECT 'CONTAGENS', 'silver_ouvidoria_base', COUNT(*) FROM auditoria.silver_ouvidoria_base
UNION ALL SELECT 'CONTAGENS', 'gold_ouvidoria_analitica', COUNT(*) FROM auditoria.gold_ouvidoria_analitica
UNION ALL SELECT 'CONTAGENS', 'tb_ouvidoria_analitica_ANTIGA', COUNT(*) FROM auditoria.tb_ouvidoria_analitica

UNION ALL

-- 2. Validações Bronze
SELECT 'DUPLICADOS_BRONZE', 'bronze_case', COUNT(*) - COUNT(DISTINCT id) FROM auditoria.bronze_case
UNION ALL SELECT 'DUPLICADOS_BRONZE', 'bronze_task', COUNT(*) - COUNT(DISTINCT id) FROM auditoria.bronze_task

UNION ALL

-- 3. Validações Gold
SELECT 'DIAS_UTEIS_VALIDOS', 'qtd_invalidos', 
       COUNT(CASE WHEN qtd_dias_uteis > qtd_dias_corridos THEN 1 END)
FROM auditoria.gold_ouvidoria_analitica
WHERE dt_fechamento IS NOT NULL

ORDER BY checkpoint, item;
```

---

**⚠️ IMPORTANTE:** Execute todas as validações após cada camada. Não prossiga para a próxima camada se houver falhas críticas!
