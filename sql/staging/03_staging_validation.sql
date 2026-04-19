-- =========================================
-- File: 03_staging_validation.sql
-- Purpose: Validate accuracy and completeness of staging transformations
-- Business Context: Ensure cleaned data is reliable before analysis
-- Grain: aggregated checks on staging table
--
-- Key Validations:
-- - Row count parity between raw and staging tables
-- - Count of successfully converted freight and weight values
-- - Identification of unclassified or invalid freight entries
-- - Identification of unclassified or invalid weight entries
--
-- Output Usage:
-- - Confirms data integrity for KPI calculations
-- - Highlights residual data quality issues requiring attention
-- =========================================

-- Check row count parity
SELECT COUNT(*) AS raw_rows FROM scms_delivery_history;
SELECT COUNT(*) AS staging_rows FROM stg_scms_delivery;

-- Check freight cleaning outcomes
SELECT
    COUNT(*) AS total_rows,
    COUNT(freight_cost_clean) AS clean_freight_rows,
    SUM(is_freight_included) AS bundled_freight_rows
FROM stg_scms_delivery;

-- Check unclassified freight values
SELECT freight_cost_usd, COUNT(*) AS row_count
FROM stg_scms_delivery
WHERE freight_cost_usd IS NOT NULL
  AND TRIM(freight_cost_usd) <> ''
  AND freight_cost_clean IS NULL
  AND is_freight_included = 0
GROUP BY freight_cost_usd
ORDER BY row_count DESC;

-- Check unclassified weight values
SELECT weight_kilograms, COUNT(*) AS row_count
FROM stg_scms_delivery
WHERE weight_kilograms IS NOT NULL
  AND TRIM(weight_kilograms) <> ''
  AND weight_clean IS NULL
GROUP BY weight_kilograms
ORDER BY row_count DESC;