-- =========================================
-- File: 01_data_audit.sql
-- Purpose: Perform initial data quality checks on raw SCMS delivery data
-- Business Context: Validate data integrity before building staging tables
-- Grain: one row per raw shipment line
--
-- Key Checks:
-- - Identify non-numeric values in freight_cost_usd and weight_kilograms
-- - Detect malformed or inconsistent data entries
-- - Assess readiness for numeric casting and transformation
--
-- Output Usage:
-- - Guides cleaning logic in staging table
-- - Identifies data quality risks and limitations
-- =========================================


-- Check data sanity, identify duplicates
SELECT 
	COUNT(*) AS total_rows_count,
	COUNT (DISTINCT ID) AS id_count
FROM scms_delivery_history;

SELECT ID
FROM scms_delivery_history
GROUP BY ID
HAVING COUNT(*) > 1;

-- Null exposure audit
SELECT 
    'Delivered Date' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE delivered_to_client_date IS NULL) AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE delivered_to_client_date IS NULL) * 100.0 / COUNT(*),
        2
    ) AS null_pct
FROM scms_delivery_history

UNION ALL

SELECT 
    'Scheduled Delivery Date' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE scheduled_delivery_date IS NULL) AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE scheduled_delivery_date IS NULL) * 100.0 / COUNT(*),
        2
    ) AS null_pct
FROM scms_delivery_history

UNION ALL

SELECT 
    'Freight Cost' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE freight_cost_usd IS NULL) AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE freight_cost_usd IS NULL) * 100.0 / COUNT(*),
        2
    ) AS null_pct
FROM scms_delivery_history

UNION ALL

SELECT 
    'Line Item Value' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE line_item_value IS NULL) AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE line_item_value IS NULL) * 100.0 / COUNT(*),
        2
    ) AS null_pct
FROM scms_delivery_history

UNION ALL

SELECT 
    'Weight' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE weight_kilograms IS NULL) AS null_count,
    ROUND(
        COUNT(*) FILTER (WHERE weight_kilograms IS NULL) * 100.0 / COUNT(*),
        2
    ) AS null_pct
FROM scms_delivery_history;

-- Inspect the distinct non-numeric values, this shows every value that is not a clean number.
SELECT DISTINCT freight_cost_usd
FROM scms_delivery_history
WHERE freight_cost_usd !~ '^[0-9,]+(\.[0-9]+)?$';

SELECT DISTINCT weight_kilograms
FROM scms_delivery_history
WHERE weight_kilograms !~ '^[0-9,]+(\.[0-9]+)?$';


	