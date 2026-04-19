-- =========================================
-- File: 12_exec_summary_table.sql
-- Purpose: Create a consolidated executive summary table across shipment mode and vendor
-- Business Context: Combine logistics cost, delivery performance, and value-at-risk
-- into one reusable analytical layer for dashboarding and executive review
-- Grain: one row per shipment_mode and vendor
--
-- KPIs:
-- - Total shipments
-- - Delayed shipments
-- - Late shipment percentage
-- - Average delay days
-- - Total shipment value
-- - Delayed shipment value
-- - Percentage of shipment value delayed
-- - Total freight cost
-- - Average freight cost per kilogram
--
-- Notes:
-- - Delay metrics use rows with non-null delay_days
-- - Freight metrics use only rows with directly measurable freight cost
-- - LEFT JOIN preserves performance/value rows even when freight is not measurable
-- - COALESCE is used to avoid NULLs where appropriate
--
-- Output Usage:
-- - Serves as the backbone for Power BI dashboarding
-- - Supports executive-level review of vendor and shipment-mode performance
-- =========================================

DROP TABLE IF EXISTS exec_summary_table;

CREATE TABLE exec_summary_table AS
WITH performance_value AS (
    SELECT
        shipment_mode,
        vendor,

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
    WHERE delay_days IS NOT NULL
      AND line_item_value IS NOT NULL
      AND shipment_mode IS NOT NULL
      AND vendor IS NOT NULL
    GROUP BY shipment_mode, vendor
),

freight AS (
    SELECT
        shipment_mode,
        vendor,

        ROUND(SUM(freight_cost_clean), 2) AS total_freight_cost,

        ROUND(
            SUM(freight_cost_clean) / NULLIF(SUM(weight_clean), 0),
            2
        ) AS avg_freight_per_kg
    FROM stg_scms_delivery
    WHERE freight_cost_type = 'NUMERIC'
      AND weight_clean IS NOT NULL
      AND shipment_mode IS NOT NULL
      AND vendor IS NOT NULL
    GROUP BY shipment_mode, vendor
)

SELECT
    pv.shipment_mode,
    pv.vendor,
    pv.total_shipments,
    pv.delayed_shipments,
    pv.late_shipment_pct,
    pv.avg_delay_days,
    pv.total_shipment_value,
    pv.delayed_shipment_value,
    pv.delayed_value_pct,
    COALESCE(f.total_freight_cost, 0) AS total_freight_cost,
    f.avg_freight_per_kg
FROM performance_value pv
LEFT JOIN freight f
    ON pv.shipment_mode = f.shipment_mode
   AND pv.vendor = f.vendor
ORDER BY pv.delayed_shipment_value DESC;