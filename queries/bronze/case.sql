-- ================================================================
-- BRONZE LAYER: Case (Solicitações de Ouvidoria)
-- ================================================================
-- Descrição: Deduplicação da tabela salesforce_case filtrando
--            apenas casos de Ouvidoria a partir de 2021-01-01
--
-- Fonte: AwsDataCatalog.salesforce.salesforce_case
-- Destino: auditoria.bronze_case
-- Formato: Parquet + Snappy compression
--
-- Lógica de Deduplicação:
--   - PARTITION BY id (identificador único do caso)
--   - ORDER BY systemmodstamp DESC (registro mais recente)
--   - Mantém apenas rn = 1 (última versão)
--
-- Filtros Aplicados:
--   - subject = 'Ouvidoria > Ouvidoria'
--   - data_recebimento_ouvidoria__c >= 2021-01-01
--
-- Autor: [Seu Nome]
-- Data Criação: 2026-02-09
-- Última Modificação: 2026-02-09
-- ================================================================

DROP TABLE IF EXISTS auditoria.bronze_case;

CREATE TABLE auditoria.bronze_case
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://seu-bucket/data/bronze/case/'
) AS
SELECT * FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER(
            PARTITION BY id 
            ORDER BY systemmodstamp DESC
        ) as rn 
    FROM "AwsDataCatalog"."salesforce"."salesforce_case" 
    WHERE subject = 'Ouvidoria > Ouvidoria' 
      AND data_recebimento_ouvidoria__c >= CAST('2021-01-01' AS TIMESTAMP)
) deduplicado
WHERE rn = 1;

-- ================================================================
-- VALIDAÇÕES PÓS-EXECUÇÃO
-- ================================================================
-- Execute estas queries após criar a tabela para validar:

-- 1. Contar registros
-- SELECT COUNT(*) as total_registros FROM auditoria.bronze_case;

-- 2. Verificar duplicados (deve retornar 0)
-- SELECT COUNT(*) - COUNT(DISTINCT id) as duplicados 
-- FROM auditoria.bronze_case;

-- 3. Verificar intervalo de datas
-- SELECT 
--     MIN(data_recebimento_ouvidoria__c) as data_mais_antiga,
--     MAX(data_recebimento_ouvidoria__c) as data_mais_recente
-- FROM auditoria.bronze_case;

-- 4. Verificar campos nulos críticos
-- SELECT 
--     COUNT(*) - COUNT(id) as sem_id,
--     COUNT(*) - COUNT(casenumber) as sem_casenumber
-- FROM auditoria.bronze_case;

-- ================================================================
-- MÉTRICAS ESPERADAS
-- ================================================================
-- Registros: ~50k-100k (dependendo do período)
-- Duplicados: 0
-- Data mais antiga: >= 2021-01-01
-- Campos nulos (id, casenumber): 0
-- Tempo de execução: ~30-60 segundos
-- Dados escaneados: ~500 MB
-- ================================================================
