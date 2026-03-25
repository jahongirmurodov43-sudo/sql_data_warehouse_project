/*
================================================================
Create Database and schemas
================================================================
Script purpose:
	This script creates a new database named "project_with_baraa" after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the databse:"bronze", "silver", "gold"

WARNING:
	Running this script will drop the entire "project_with_baraa" database if it exists.
	All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.

*/
 
USE MASTER;

GO

--Drop and recreate the "project_with_baraa" databse

IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = 'project_with_baraa')
BEGIN 
	ALTER DATABASE project_with_baraa SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE project_with_baraa;
END;

GO

-- Create the 'project_with_baraa' databse
create database project_with_baraa;

GO

use project_with_baraa;

GO

CREATE SCHEMA bronze;

GO

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;
