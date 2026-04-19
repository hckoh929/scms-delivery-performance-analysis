-- =========================================
-- File: 02_staging_table.sql
-- Purpose: Create cleaned staging table from raw SCMS delivery history
-- Business Context: Standardize raw data into analysis-ready format
-- Grain: one row per shipment line
--
-- Transformations:
-- - Clean and convert freight_cost_usd from text to numeric (freight_cost_clean)
-- - Clean and convert weight_kilograms from text to numeric (weight_clean)
-- - Flag records where freight is bundled into commodity cost (is_freight_included)
--
-- Notes:
-- - Raw columns are preserved for traceability
-- - Invalid or non-numeric values are set to NULL to avoid calculation errors
--
-- Output Usage:
-- - Serves as the base table for all downstream KPI and analysis queries
-- =========================================

DROP TABLE IF EXISTS stg_scms_delivery;

CREATE TABLE stg_scms_delivery AS
SELECT
    *,

    CASE
        WHEN freight_cost_usd IS NULL OR TRIM(freight_cost_usd) = '' THEN NULL
        WHEN UPPER(TRIM(freight_cost_usd)) = 'FREIGHT INCLUDED IN COMMODITY COST' THEN NULL
        WHEN REPLACE(REPLACE(TRIM(freight_cost_usd), '$', ''), ',', '') ~ '^[0-9]+(\.[0-9]+)?$'
            THEN CAST(REPLACE(REPLACE(TRIM(freight_cost_usd), '$', ''), ',', '') AS NUMERIC)
        ELSE NULL
    END AS freight_cost_clean,

    CASE
        WHEN UPPER(TRIM(freight_cost_usd)) = 'FREIGHT INCLUDED IN COMMODITY COST' THEN 1
        ELSE 0
    END AS is_freight_included,

    CASE
        WHEN weight_kilograms IS NULL OR TRIM(weight_kilograms) = '' THEN NULL
        WHEN REPLACE(REPLACE(TRIM(weight_kilograms), '$', ''), ',', '') ~ '^[0-9]+(\.[0-9]+)?$'
            THEN CAST(REPLACE(REPLACE(TRIM(weight_kilograms), '$', ''), ',', '') AS NUMERIC)
        ELSE NULL
    END AS weight_clean

FROM scms_delivery_history;