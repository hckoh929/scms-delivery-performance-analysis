-- =========================================
-- File: 04_freight_classification.sql
-- Purpose: Classify freight cost recording methods
-- Business Context: Understand how logistics costs are captured across shipments
-- Grain: one row per shipment line
--
-- Logic:
-- - NUMERIC: explicit freight cost available
-- - BUNDLED: freight included in commodity cost
-- - SEPARATE_INVOICE: freight billed externally
-- - REFERENCE: freight referenced in external documents (ASN/DN)
-- - OTHER: unclassified values
--
-- Output Usage:
-- - Enables accurate freight cost analysis
-- - Quantifies visibility gaps in logistics cost tracking
-- =========================================

ALTER TABLE stg_scms_delivery
ADD COLUMN freight_cost_type TEXT;

UPDATE stg_scms_delivery
SET freight_cost_type =
    CASE
        WHEN freight_cost_clean IS NOT NULL THEN 'NUMERIC'
        WHEN UPPER(TRIM(freight_cost_usd)) = 'FREIGHT INCLUDED IN COMMODITY COST' THEN 'BUNDLED'
        WHEN UPPER(TRIM(freight_cost_usd)) LIKE 'INVOICED SEPARATELY%' THEN 'SEPARATE_INVOICE'
        WHEN UPPER(TRIM(freight_cost_usd)) LIKE 'SEE %' THEN 'REFERENCE'
        ELSE 'OTHER'
    END;

SELECT
    freight_cost_type,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM stg_scms_delivery
GROUP BY freight_cost_type
ORDER BY row_count DESC;