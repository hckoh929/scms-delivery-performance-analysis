-- =========================================
-- File: 09_root_cause_truck_country.sql
-- Purpose: Identify countries driving delayed shipment value in Truck mode
-- Business Context: Isolate geographic concentration of financial delay exposure
-- Grain: one row per country within Truck shipments
--
-- KPIs:
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
--
-- Notes:
-- - Focuses only on Truck shipments
-- - Includes only rows with valid delay and shipment value
--
-- Output Usage:
-- - Supports root-cause analysis for Truck-related delay exposure
-- - Helps identify countries requiring logistics intervention
-- =========================================

SELECT 
    country,
    ROUND(SUM(line_item_value), 2) AS total_shipment_value,
    ROUND(COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0), 2) AS delayed_shipment_value,
    ROUND(
        COALESCE(SUM(line_item_value) FILTER (WHERE delay_days > 0), 0) * 100.0
        / SUM(line_item_value),
        2
    ) AS delayed_value_pct
FROM stg_scms_delivery
WHERE shipment_mode = 'Truck'
  AND delay_days IS NOT NULL
  AND line_item_value IS NOT NULL
GROUP BY country
ORDER BY delayed_value_pct DESC;