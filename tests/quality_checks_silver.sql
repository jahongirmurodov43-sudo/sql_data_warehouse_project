/*
===============================================================================
Quality Checks
===============================================================================
Script purpose:
    This script performs various quality checks for data consistency, accuracy,  
    and standardization across 'Silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    -Unwanted spaces in string fields.
    -Data Standardization and consistency.
    -Invalid date ranges and orders.
    -Data consistency between realted fields.

Usage Notes:
    - Run these checks after data loading Silver layer.
    -Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


--Check for Nulls or Duplicates in Primary Key
--Expectation: No Result

select 
cst_id,
count(*)
from bronze.crm_customers_info
group by cst_id
having COUNT(*) > 1 or cst_id is NULL

-- Check for Unwanted Spaces 
-- Expectations: No Results 
SELECT cst_key 
FROM bronze.crm_customers_info
WHERE cst_key != TRIM(cst_key)

-- Data Standardization & Consistency 
SELECT DISTINCT cst_material_status
from bronze.crm_customers_info
 

 --Check for Nulls or Duplicates in Primary Key
--Expectation: No Result

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check for Unwanted Spaces 
-- Expectations: No Results 
SELECT prd_mm
FROM silver.crm_prd_info
WHERE prd_mm != TRIM(prd_mm)

--Chek for NULLS or Negative Numbers
--Expectation: No Results 
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency 
SELECT DISTINCT prd_line
from silver.crm_prd_info

-- Chek for invalid Date Orders

select 
prd_start,
prd_end
from silver.crm_prd_info
where  prd_end < prd_start



-- IDENTIFY OUT OF RANGE DATES

select distinct 
bdate 
from silver.erp_cust_az12
where bdate < '1924-01-01' or bdate > GETDATE()


-- DATA STANDARDIZATION ADN CONSISTENCY

select gen from silver.erp_cust_az12
where gen is null or gen in ('m','M','f','F')



-- DATA STANDARDIZATION AND CONSISTENCY

SELECT 
cid
FROM	silver.erp_loc_a101
WHERE  REPLACE(cid,'-','')  NOT  IN (SELECT cst_key FROM silver.crm_customers_info)

-- Data Standardization & Consistency

SELECT DISTINCT
cntry,
CASE WHEN cntry IS NULL OR cntry = '' THEN 'n/a'
	 WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
	 WHEN UPPER(TRIM(cntry)) IN ('GERMANY','DE') THEN 'Germany'
	 ELSE TRIM(cntry)
END AS cntry1
FROM silver.erp_loc_a101


-- Data Standardization & Consistency
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (
SELECT pdr_key FROM silver.crm_prd_info)

-- Data Standardization & Consistency
SELECT cat FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

-- Data Standardization & Consistency

SELECT  subcat FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)


-- Data Standardization & Consistency
SELECT DISTINCT  maintenance FROM bronze.erp_px_cat_g1v2

SELECT maintenance FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)





