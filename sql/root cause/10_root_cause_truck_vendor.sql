-- =========================================
-- File: 10_root_cause_truck_vendor.sql
-- Purpose: Identify vendors driving delayed shipment value in Truck mode
-- Business Context: Isolate supplier concentration of financial delay exposure
-- Grain: one row per vendor within Truck shipments
--
-- KPIs:
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
--
-- Notes:
-- - Focuses only on Truck shipments
-- - Includes only rows with valid delay and shipment value
-- - COALESCE is used so vendors with no delayed value appear as 0 instead of NULL
--
-- Output Usage:
-- - Supports supplier performance analysis
-- - Identifies vendors contributing most to Truck delay risk
-- =========================================

SELECT 
    vendor,
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
WHERE shipment_mode = 'Truck'
  AND delay_days IS NOT NULL
  AND line_item_value IS NOT NULL
GROUP BY vendor
ORDER BY delayed_value_pct DESC;