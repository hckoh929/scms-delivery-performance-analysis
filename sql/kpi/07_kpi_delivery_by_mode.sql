-- =========================================
-- File: 07_kpi_delivery_by_mode.sql
-- Purpose: Measure late shipment risk by shipment mode
-- Business Context: Compare delivery reliability across transport methods
-- Grain: one row per shipment_mode
--
-- KPIs:
-- - Total shipments
-- - Delayed shipments
-- - Late shipment percentage
-- - Average delay days for delayed shipments
--
-- Notes:
-- - Uses cleaned date fields from staging table
-- - Includes only rows with valid delivered and scheduled dates
--
-- Output Usage:
-- - Supports service-level performance analysis
-- - Identifies shipment modes with high delivery risk
-- =========================================

SELECT 
    shipment_mode,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE delay_days > 0) AS delayed_shipments,
    ROUND(COUNT(*) FILTER (WHERE delay_days > 0) * 100.0 / COUNT(*), 2) AS late_shipment_pct,
    ROUND(AVG(delay_days) FILTER (WHERE delay_days > 0), 2) AS avg_delay_days
FROM stg_scms_delivery
WHERE delivered_date IS NOT NULL
  AND scheduled_date IS NOT NULL
GROUP BY shipment_mode
ORDER BY late_shipment_pct DESC;