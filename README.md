# scms-delivery-performance-analysis
End-to-end supply chain analysis of SCMS delivery data using SQL and Power BI. Identifies $250M+ in delayed shipment risk concentrated in specific transport modes, vendors, regions, and product categories, delivering actionable insights for logistics optimization.

## 📂 Data Source
Dataset: SCMS Delivery History Dataset  
Source: Kaggle  
Link: [https://www.kaggle.com/datasets/sawandikirby/supply-chain-shipment-pricing-data]

This dataset contains historical shipment records used to analyze delivery performance and supply chain risk.

## Project Overview

This project analyzes global shipment performance using the SCMS Delivery History dataset to identify key drivers of delivery delays and quantify operational risk across transportation modes, vendors, geographies, and product categories.

The objective is to move beyond descriptive reporting and deliver actionable insights that can support logistics optimization and risk mitigation decisions.

---

## Business Problem

A significant portion of shipment value is exposed to delivery delays, impacting supply chain reliability and operational efficiency.

This analysis answers:

* Where are delays occurring?
* What is the financial impact?
* Who and what are driving the risk?

---

## Tools & Technologies

* **SQL (PostgreSQL)** → Data cleaning, transformation, KPI modeling
* **Power BI** → Interactive dashboard and executive reporting

---

## 🏗️ Data Pipeline

### 1. Raw Data

* Source: SCMS Delivery History Dataset (Kaggle)
* Grain: One row per shipment line

---

### 2. Staging Layer (SQL)

Key transformations:

* Cleaned freight cost and weight fields (text → numeric)
* Standardized date fields
* Derived metrics:

  * `delay_days`
  * `is_late`
* Classified freight types (numeric, bundled, invoice-based)

---

### 3. Analytical Layer

Created aggregated tables for:

* Shipment mode analysis
* Vendor-level risk
* Country-level risk
* Product-level risk

---

## Key Insights

### 1. Transportation Mode

* ~16% of total shipment value is delayed
* **Truck and Ocean** exhibit the highest delay rates
* **Air** is more reliable but significantly more expensive

---

### 2. Vendor Risk

* Delay exposure is highly concentrated
* **SCMS from RDC** accounts for the majority of delayed shipment value
* Indicates a vendor-specific operational issue

---

### 3. Geographic Risk

* Delay exposure is concentrated in **Sub-Saharan Africa**
* **Mozambique** represents the highest combined risk (high value + high delay rate)
* **Nigeria** contributes large exposure due to shipment volume

---

### 4. Product Risk

* **ARV products dominate delay exposure (~90%+)**
* Also exhibit higher delay rates compared to other categories
* Suggests product mix is a key driver of risk

---

## Final Conclusion

Delivery delays are not evenly distributed across the supply chain. Instead, risk is highly concentrated:

* **Mode:** Truck
* **Vendor:** SCMS from RDC
* **Geography:** Sub-Saharan Africa
* **Product:** ARV

This indicates that targeted interventions—rather than broad system changes—would yield the highest impact.

---

## Recommendations

* Prioritize operational review of SCMS from RDC
* Investigate logistics constraints in high-risk countries (e.g., Mozambique, Nigeria)
* Reevaluate transport mode allocation for high-value shipments
* Optimize handling and routing for ARV products

---

## Dashboard

Power BI dashboard includes:

* Executive summary KPIs
* Mode performance analysis
* Vendor root-cause analysis
* Geographic risk distribution
* Product-level risk insights

---

## Repository Structure

```
sql/
├── staging/
│   ├── 01_data_audit.sql
│   ├── 02_staging_table.sql
│   ├── 03_staging_validation.sql
│   ├── 04_freight_classification.sql
│   └── 05_date_and_delivery_flags.sql
│
├── kpi/
│   ├── 06_kpi_freight_by_mode.sql
│   ├── 07_kpi_delivery_by_mode.sql
│   ├── 08_kpi_value_at_risk_by_mode.sql
│
├── root_cause/
│   ├── 09_root_cause_truck_country.sql
│   └── 10_root_cause_truck_vendor.sql
│
├── product/
│   ├── 11_product_risk_analysis.sql
│   └── 13_product_subclassification_risk.sql
│
├── summary/
│   ├── 12_exec_summary_table.sql
│   ├── 14_mode_summary_table.sql
│   ├── 15_country_summary_table.sql
│   └── 16_product_summary_table.sql
│
powerbi/
├── scms_dashboard.pbix
├── scms_dashboard.pdf
│
README.md


---

## Key Skills Demonstrated

* SQL data transformation and modeling
* Analytical thinking and KPI design
* Data storytelling for executive audiences
* Dashboard development in Power BI

---

## Author

Jenny Koh
SQL • Power BI • Analytics

---

