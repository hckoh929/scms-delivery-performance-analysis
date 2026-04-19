-- =========================================
-- File: 15_country_summary_table.sql
-- Purpose: Create country-level summary of delivery performance and financial risk
-- Business Context: Identify geographic concentration of delayed shipment exposure
-- Grain: one row per country
--
-- KPIs:
-- - Total shipments
-- - Delayed shipments
-- - Late shipment percentage
-- - Average delay days
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
--
-- Notes:
-- - Includes only rows with valid country, delay_days, and line_item_value
-- - COALESCE ensures countries with no delayed value are represented as 0
--
-- Output Usage:
-- - Supports geographic analysis of logistics performance
-- - Helps identify countries with high delay risk and financial exposure
-- =========================================

DROP TABLE IF EXISTS country_summary_table;

CREATE TABLE country_summary_table AS
SELECT
    country,

    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE delay_days > 0) AS delayed_shipments,

    ROUND(
        COUNT(*) FILTER (WHERE delay_days > 0) * 100.0 / COUNT(*),
        2
    ) AS late_shipment_pct,

    ROUND(
        AVG(delay_days) FILTER (WHERE delay_days > 0),
        2
    ) AS avg_delay_days,

    ROUND(SUM(line_item_value), 2) AS total_shipment_value,

    ROUND(
        COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0),
        2
    ) AS delayed_shipment_value,

    ROUND(
        COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0) * 100.0
        / SUM(line_item_value),
        2
    ) AS delayed_value_pct
FROM stg_scms_delivery
WHERE country IS NOT NULL
  AND line_item_value IS NOT NULL
  AND delay_days IS NOT NULL
GROUP BY country
ORDER BY delayed_shipment_value DESC;