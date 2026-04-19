-- =========================================
-- File: 14_mode_summary_table.sql
-- Purpose: Create shipment mode-level summary of cost, performance, and risk
-- Business Context: Compare logistics efficiency and delivery reliability
-- across transportation modes (Air, Truck, Ocean, etc.)
-- Grain: one row per shipment_mode
--
-- KPIs:
-- - Total shipments
-- - Delayed shipments
-- - Late shipment percentage
-- - Average delay days
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
-- - Total freight cost (measurable only)
-- - Average freight cost per kilogram
--
-- Notes:
-- - Includes all shipments with valid shipment_mode and line_item_value
-- - Freight cost metrics include only rows with freight_cost_type = 'NUMERIC'
-- - Uses NULLIF to prevent division by zero in freight per kg calculation
--
-- Output Usage:
-- - Primary data source for executive overview dashboard (Page 1)
-- - Enables comparison of cost vs performance tradeoffs across shipment modes
-- =========================================

DROP TABLE IF EXISTS mode_summary_table;

CREATE TABLE mode_summary_table AS
SELECT
    shipment_mode,

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
    ) AS delayed_value_pct,

    ROUND(
        COALESCE(SUM(freight_cost_clean) FILTER (WHERE freight_cost_type = 'NUMERIC'), 0),
        2
    ) AS total_freight_cost,

    ROUND(
        COALESCE(SUM(freight_cost_clean) FILTER (WHERE freight_cost_type = 'NUMERIC'), 0)
        / NULLIF(SUM(weight_clean) FILTER (WHERE freight_cost_type = 'NUMERIC'), 0),
        2
    ) AS avg_freight_per_kg
FROM stg_scms_delivery
WHERE shipment_mode IS NOT NULL
  AND line_item_value IS NOT NULL
GROUP BY shipment_mode
ORDER BY delayed_shipment_value DESC;

-- Check data type
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'mode_summary_table';
