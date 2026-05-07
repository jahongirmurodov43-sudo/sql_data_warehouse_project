/*
======================================================================================================
Stored Procedure: Load Silver Layer (Bronze  -> Silver)
======================================================================================================
Script Purpose:
    This stored procedure performs the ETL(Extract, Transform,Load) process to
    populate the Silver 'schema' tables from the 'bronze' schema.
  Actions performed:
    -Truncate Silver tables 
    -Insert transformed and cleansed data from bronze into Silver tables.

  Parameters:
    None
    This stored porcedure does not accept any parameters or return any values. 

  Usage Example:
    EXEC silver.load_silver;
========================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '================================================================================';

		PRINT '--------------------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_customers_info';
		TRUNCATE TABLE silver.crm_customers_info;
		PRINT('>>Inserting Data Into: silver.crm_customers_info');

		INSERT INTO silver.crm_customers_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date)
		select
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_fisrtname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			 ELSE 'N/A'
		END AS cst_material_status,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 ELSE 'N/A'
		END AS cst_gndr,
		cst_create_date
		from (
			select 
			*,
			ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_customers_info
			where cst_id is not NULL) as t
		where flag_last =1 
		SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT('>>Inserting Data Into: silver.crm_prd_info');

		INSERT INTO silver.crm_prd_info(
			prd_id ,
			cat_id ,
			pdr_key ,
			prd_mm ,
			prd_cost ,
			prd_line ,
			prd_start ,
			prd_end 
 
		)
		SELECT 
		prd_id,
		pdr_key,
		REPLACE(SUBSTRING(pdr_key,1,5),'-','_') AS cat_id,
		SUBSTRING(pdr_key,7,LEN(pdr_key))
		prd_mm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE WHEN TRIM(UPPER(prd_line)) = 'M' THEN 'Mountain'
			 WHEN TRIM(UPPER(prd_line)) = 'R' THEN 'Rpad'
			 WHEN TRIM(UPPER(prd_line)) = 'S' THEN 'Other Sales'
			 WHEN TRIM(UPPER(prd_line)) = 'T' THEN 'Touring'
			 ELSE 'N/A'
		END AS prd_line,
		CAST(prd_start AS DATE) AS prd_start,
		CAST(LEAD(prd_start) OVER(PARTITION BY pdr_key ORDER BY prd_start) - 1 AS DATE) AS prd_end
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT('>>Inserting Data Into: silver.crm_sales_details');

		INSERT INTO silver.crm_sales_details(
			sld_ord_num ,
			sls_prd_key, 
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quant ,
			sls_price
		)
		select 
		sld_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quant*ABS(sls_price)
			THEN sls_quant * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quant,
		CASE WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales/NULLIF(sls_quant,0)
			ELSE sls_price
		END AS sls_price
		from bronze.crm_sales_details

		SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');

		PRINT '--------------------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT('>>Inserting Data Into: silver.erp_cust_az12');

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
			 ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			 ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12

		SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT('>>Inserting Data Into: silver.erp_loc_a101');

		INSERT INTO silver.erp_loc_a101(cid,cntry)
		SELECT 
		REPLACE(cid,'-','') AS cid,
		CASE WHEN cntry IS NULL OR cntry = '' THEN 'n/a'
			 WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
			 WHEN UPPER(TRIM(cntry)) IN ('GERMANY','DE') THEN 'Germany'
			 ELSE TRIM(cntry)
		END AS cntry1
		FROM bronze.erp_loc_a101

		SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT('>>Inserting Data Into: silver.erp_px_cat_g1v2');

		 INSERT INTO silver.erp_px_cat_g1v2 (
		 id,
		 cat,
		 subcat,
		 maintenance
		 )
		 SELECT * FROM bronze.erp_px_cat_g1v2;

		 SET @end_time = GETDATE();
		PRINT('Loading time' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR));
		PRINT('>>------------------');
		SET @batch_end_time = GETDATE();
		PRINT '================================================================================';
		PRINT 'Loading Silver Layer is completed';
		PRINT '		-Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + ' seconds';
		PRINT '================================================================================';
	END TRY
	BEGIN CATCH 
	PRINT '=========================================================================================';
	PRINT 'Error message:' + ERROR_MESSAGE();
	PRINT 'Error message:' + CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error message:' + CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '=========================================================================================';
	END CATCH 
END





