-- =========================================
-- File: 06_kpi_freight_by_mode.sql
-- Purpose: Measure freight cost efficiency by shipment mode
-- Business Context: Compare logistics cost structure across transport methods
-- Grain: one row per shipment_mode
--
-- KPIs:
-- - Total shipments
-- - Average freight cost per shipment
-- - Average freight cost per kilogram
-- - Total freight cost
--
-- Notes:
-- - Includes only shipments with directly measurable freight cost
-- - Excludes rows with missing weight from freight-per-kg calculation
--
-- Output Usage:
-- - Supports shipment mode cost comparison
-- - Helps identify expensive or inefficient logistics modes
-- =========================================

SELECT
    shipment_mode,
    COUNT(id) AS total_shipment,
    ROUND(AVG(freight_cost_clean), 2) AS avg_freight_cost,
    ROUND(SUM(freight_cost_clean) / NULLIF(SUM(weight_clean), 0), 2) AS avg_freight_per_kg,
    ROUND(SUM(freight_cost_clean), 2) AS total_freight_cost
FROM stg_scms_delivery
WHERE freight_cost_type = 'NUMERIC'
  AND weight_clean IS NOT NULL
GROUP BY shipment_mode
ORDER BY total_freight_cost DESC;