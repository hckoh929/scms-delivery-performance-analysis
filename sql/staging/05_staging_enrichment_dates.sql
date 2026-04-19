-- =========================================
-- File: 05_date_and_delivery_flags.sql
-- Purpose: Standardize date fields and derive delivery performance metrics
-- Business Context: Enable accurate measurement of delivery timeliness
-- Grain: one row per shipment line
--
-- Transformations:
-- - Convert delivered_to_client_date and scheduled_delivery_date to DATE format
-- - Calculate delivery delay in days (delay_days)
-- - Create binary late delivery flag (is_late)
--
-- Notes:
-- - Records with missing or invalid dates are excluded from delay calculations
--
-- Output Usage:
-- - Supports KPI calculations for on-time delivery and delay analysis
-- =========================================

ALTER TABLE stg_scms_delivery
ADD COLUMN delivered_date DATE,
ADD COLUMN scheduled_date DATE;

UPDATE stg_scms_delivery
SET 
    delivered_date = CASE
        WHEN delivered_to_client_date IS NULL OR TRIM(delivered_to_client_date) = '' THEN NULL
        ELSE TO_DATE(delivered_to_client_date, 'DD-Mon-YYYY')
    END,
    scheduled_date = CASE
        WHEN scheduled_delivery_date IS NULL OR TRIM(scheduled_delivery_date) = '' THEN NULL
        ELSE TO_DATE(scheduled_delivery_date, 'DD-Mon-YYYY')
    END;

ALTER TABLE stg_scms_delivery
ADD COLUMN delay_days INT;

UPDATE stg_scms_delivery
SET delay_days = delivered_date - scheduled_date;

ALTER TABLE stg_scms_delivery
ADD COLUMN is_late INT;

UPDATE stg_scms_delivery
SET is_late = CASE 
    WHEN delay_days > 0 THEN 1
    ELSE 0
END;