-- =========================================
-- File: 16_product_summary_table.sql
-- Purpose: Create product group-level summary of delivery performance and financial risk
-- Business Context: Identify product categories most exposed to delivery delays
-- and financial impact
-- Grain: one row per product_group
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
-- - Includes only rows with valid product_group, delay_days, and line_item_value
-- - COALESCE ensures product groups with no delayed value are represented as 0
-- - Optional HAVING clause can be applied to exclude low-volume categories
--
-- Output Usage:
-- - Supports product-level risk prioritization
-- - Identifies high-value product groups requiring logistics attention
-- =========================================

DROP TABLE IF EXISTS product_summary_table;

CREATE TABLE product_summary_table AS
SELECT
    product_group,

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
WHERE product_group IS NOT NULL
  AND line_item_value IS NOT NULL
  AND delay_days IS NOT NULL
GROUP BY product_group
ORDER BY delayed_shipment_value DESC;