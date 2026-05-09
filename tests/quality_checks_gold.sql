/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 

SELECT DISTINCT 
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is master FOR gender info
		 ELSE COALESCE(ca.gen,'n/a')
	END AS new_gen
FROM silver.crm_customers_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON		  ci.cst_key = la.cid
ORDER BY 1,2

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 

SELECT pdr_key,count(*) from (
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.pdr_key,
	pn.prd_mm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON		  pn.cat_id = pc.id
WHERE pn.prd_end IS NULL) AS TR -- Filter out all historical data ) 
group by pdr_key 
HAVING COUNT(*) > 1

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions

SELECT * FROM gold.fact_sales AS f
LEFT JOIN	gold.dim_customers AS c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL



      

