-- Create a dedicated database for this project. Does not modify ProductFunnelDB.
IF DB_ID(N'FinancialOpsDB') IS NULL
BEGIN
    CREATE DATABASE FinancialOpsDB;
END;
GO
USE FinancialOpsDB;
GO
SELECT DB_NAME() AS current_database;
GO
