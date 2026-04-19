-- =========================================
-- File: 08_kpi_value_at_risk_by_mode.sql
-- Purpose: Measure shipment value exposure to delivery delays by shipment mode
-- Business Context: Quantify financial risk associated with delayed deliveries
-- Grain: one row per shipment_mode
--
-- KPIs:
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
--
-- Notes:
-- - Includes only rows with non-null delay_days and line_item_value
--
-- Output Usage:
-- - Supports financial risk analysis
-- - Identifies shipment modes with the highest value-at-risk
-- =========================================

SELECT 
    shipment_mode,
    ROUND(SUM(line_item_value), 2) AS total_shipment_value,
    ROUND(SUM(line_item_value) FILTER (WHERE delay_days > 0), 2) AS delayed_shipment_value,
    ROUND(
        SUM(line_item_value) FILTER (WHERE delay_days > 0) * 100.00 / SUM(line_item_value),
        2
    ) AS delayed_value_pct
FROM stg_scms_delivery
WHERE delay_days IS NOT NULL
  AND line_item_value IS NOT NULL
GROUP BY shipment_mode
ORDER BY delayed_value_pct DESC;