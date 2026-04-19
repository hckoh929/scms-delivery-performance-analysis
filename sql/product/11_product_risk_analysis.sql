-- =========================================
-- File: 11_product_risk_analysis.sql
-- Purpose: Identify product groups with the highest delivery-risk exposure
-- Business Context: Quantify which product categories have the greatest
-- financial value tied up in delayed shipments
-- Grain: one row per product_group
--
-- KPIs:
-- - Total shipments
-- - Delayed shipments
-- - Late shipment percentage
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
-- - Average delay days for delayed shipments
--
-- Notes:
-- - Uses delay_days derived in staging
-- - Includes only rows with valid delay_days and line_item_value
-- - COALESCE is used so groups with no delayed value show as 0
--
-- Output Usage:
-- - Supports product-level risk prioritization
-- - Identifies high-value categories exposed to delivery delays
-- =========================================

SELECT
    product_group,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE delay_days > 0) AS delayed_shipments,

    ROUND(
        COUNT(*) FILTER (WHERE delay_days > 0) * 100.0 / COUNT(*),
        2
    ) AS late_shipment_pct,

    ROUND(SUM(line_item_value), 2) AS total_shipment_value,

    ROUND(
        COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0),
        2
    ) AS delayed_shipment_value,

    ROUND(
        COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0) * 100.0
        / SUM(line_item_value),
        2
    ) AS delayed_value_pct,

    ROUND(
        AVG(delay_days) FILTER (WHERE delay_days > 0),
        2
    ) AS avg_delay_days
FROM stg_scms_delivery
WHERE delay_days IS NOT NULL
  AND line_item_value IS NOT NULL
  AND product_group IS NOT NULL
GROUP BY product_group
ORDER BY delayed_shipment_value DESC;