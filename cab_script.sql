#Customer Churn And Behavioral Analysis

#Creating a database
CREATE DATABASE IF NOT EXISTS uci_db;

#Using the created database(here, rfm_db)
USE uci_db;

#Configurations
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE "secure_file_priv";

#Deleting rows when needed
DELETE FROM raw_online_retail;

#Creating Raw Table for online_retail data
CREATE TABLE IF NOT EXISTS raw_online_retail (
    InvoiceNo VARCHAR(255),
    StockCode VARCHAR(255),
    Description TEXT,
    Quantity VARCHAR(255),
    InvoiceDate VARCHAR(255),
    UnitPrice VARCHAR(255),
    CustomerID VARCHAR(255),
    Country VARCHAR(255)
);

#Importing Data to raw_online_retail via infile
LOAD DATA LOCAL INFILE "g:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\online_retail.csv"
INTO TABLE raw_online_retail
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Describing Table
DESCRIBE raw_online_retail;

#Data at a glance
SELECT * FROM raw_online_retail LIMIT 10;

#Column names
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'uci_db'
  AND TABLE_NAME = 'raw_online_retail';
  
#Number Of Columns
SELECT COUNT(*) FROM (#Column names
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'uci_db'
  AND TABLE_NAME = 'raw_online_retail') AS temp;
  
#Number Of Rows
SELECT COUNT(*) FROM raw_online_retail;

#Data Cleaning Starts Here
#Checking missing, empty, or 'NULL' string for columns
#1. InvoiceNo
SELECT 
    COUNT(CASE WHEN InvoiceNo IS NULL OR TRIM(InvoiceNo) = '' OR LOWER(InvoiceNo) = 'null' THEN 1 END) AS total_missing_invoices,
    ROUND(
        COUNT(CASE WHEN InvoiceNo IS NULL OR TRIM(InvoiceNo) = '' OR LOWER(InvoiceNo) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN InvoiceNo IS NULL THEN 1 END) AS null_invoices,
    COUNT(CASE WHEN TRIM(InvoiceNo) = '' THEN 1 END) AS blank_invoices,
    COUNT(CASE WHEN LOWER(InvoiceNo) = 'null' THEN 1 END) AS null_string_invoices
FROM raw_online_retail;

#2. StockCode
SELECT 
    COUNT(CASE WHEN StockCode IS NULL OR TRIM(StockCode) = '' OR LOWER(StockCode) = 'null' THEN 1 END) AS total_missing_stock_codes,
    ROUND(
        COUNT(CASE WHEN StockCode IS NULL OR TRIM(StockCode) = '' OR LOWER(StockCode) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN StockCode IS NULL THEN 1 END) AS null_stock_codes,
    COUNT(CASE WHEN TRIM(StockCode) = '' THEN 1 END) AS blank_stock_codes,
    COUNT(CASE WHEN LOWER(StockCode) = 'null' THEN 1 END) AS null_string_stock_codes
FROM raw_online_retail;

#3. Description
SELECT 
    COUNT(CASE WHEN Description IS NULL OR TRIM(Description) = '' OR LOWER(Description) = 'null' THEN 1 END) AS total_missing_descriptions,
    ROUND(
        COUNT(CASE WHEN Description IS NULL OR TRIM(Description) = '' OR LOWER(Description) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN Description IS NULL THEN 1 END) AS null_descriptions,
    COUNT(CASE WHEN TRIM(Description) = '' THEN 1 END) AS blank_descriptions,
    COUNT(CASE WHEN LOWER(Description) = 'null' THEN 1 END) AS null_string_descriptions
FROM raw_online_retail;

#4. Quantity
SELECT 
    COUNT(CASE WHEN Quantity IS NULL OR TRIM(Quantity) = '' OR LOWER(Quantity) = 'null' THEN 1 END) AS total_missing_quantities,
    ROUND(
        COUNT(CASE WHEN Quantity IS NULL OR TRIM(Quantity) = '' OR LOWER(Quantity) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS null_quantities,
    COUNT(CASE WHEN TRIM(Quantity) = '' THEN 1 END) AS blank_quantities,
    COUNT(CASE WHEN LOWER(Quantity) = 'null' THEN 1 END) AS null_string_quantities
FROM raw_online_retail;

#5. InvoiceDate
SELECT 
    COUNT(CASE WHEN InvoiceDate IS NULL OR TRIM(InvoiceDate) = '' OR LOWER(InvoiceDate) = 'null' THEN 1 END) AS total_missing_invoice_dates,
    ROUND(
        COUNT(CASE WHEN InvoiceDate IS NULL OR TRIM(InvoiceDate) = '' OR LOWER(InvoiceDate) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN InvoiceDate IS NULL THEN 1 END) AS null_invoice_dates,
    COUNT(CASE WHEN TRIM(InvoiceDate) = '' THEN 1 END) AS blank_invoice_dates,
    COUNT(CASE WHEN LOWER(InvoiceDate) = 'null' THEN 1 END) AS null_string_invoice_dates
FROM raw_online_retail;

#6. UnitPrice
SELECT 
    COUNT(CASE WHEN UnitPrice IS NULL OR TRIM(UnitPrice) = '' OR LOWER(UnitPrice) = 'null' THEN 1 END) AS total_missing_unit_prices,
    ROUND(
        COUNT(CASE WHEN UnitPrice IS NULL OR TRIM(UnitPrice) = '' OR LOWER(UnitPrice) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN UnitPrice IS NULL THEN 1 END) AS null_unit_prices,
    COUNT(CASE WHEN TRIM(UnitPrice) = '' THEN 1 END) AS blank_unit_prices,
    COUNT(CASE WHEN LOWER(UnitPrice) = 'null' THEN 1 END) AS null_string_unit_prices
FROM raw_online_retail;

#7. CustomerID
SELECT 
    COUNT(CASE WHEN CustomerID IS NULL OR TRIM(CustomerID) = '' OR LOWER(CustomerID) = 'null' THEN 1 END) AS total_missing_customers,
    ROUND(
        COUNT(CASE WHEN CustomerID IS NULL OR TRIM(CustomerID) = '' OR LOWER(CustomerID) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN CustomerID IS NULL THEN 1 END) AS null_customers,
    COUNT(CASE WHEN TRIM(CustomerID) = '' THEN 1 END) AS blank_customers,
    COUNT(CASE WHEN LOWER(CustomerID) = 'null' THEN 1 END) AS null_string_customers
FROM raw_online_retail;

#8. Country
SELECT 
    COUNT(CASE WHEN Country IS NULL OR TRIM(Country) = '' OR LOWER(Country) = 'null' THEN 1 END) AS total_missing_countries,
    ROUND(
        COUNT(CASE WHEN Country IS NULL OR TRIM(Country) = '' OR LOWER(Country) = 'null' THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS percent_missing,
    COUNT(CASE WHEN Country IS NULL THEN 1 END) AS null_countries,
    COUNT(CASE WHEN TRIM(Country) = '' THEN 1 END) AS blank_countries,
    COUNT(CASE WHEN LOWER(Country) = 'null' THEN 1 END) AS null_string_countries
FROM raw_online_retail;
#Only table 3. Description and table 7. Customer ID contains blank

#Checking for invalids
#1. InvoiceNo
#Non-Standard InvoiceNo like cancelations, adjusments, etc
SELECT * FROM raw_online_retail WHERE InvoiceNo NOT REGEXP '^-?[0-9]+$'IJ8;
#Cancelations
SELECT * FROM (SELECT * FROM raw_online_retail WHERE InvoiceNo NOT REGEXP '^-?[0-9]+$') AS temp WHERE InvoiceNo LIKE 'C%';
#Adjustments
SELECT * FROM (SELECT * FROM raw_online_retail WHERE InvoiceNo NOT REGEXP '^-?[0-9]+$') AS temp WHERE InvoiceNo NOT LIKE 'C%';
#Standard values are all positive
SELECT * FROM raw_online_retail WHERE InvoiceNo REGEXP '^-?[0-9]+$' AND CAST(TRIM(InvoiceNo) AS SIGNED) > 0;
#The Non-Standard codes only included cancelations, adjustments and blanks

#2. StockCode
#Non-Product Codes
SELECT * FROM raw_online_retail WHERE StockCode NOT REGEXP '^([0-9]{1,10}[A-Za-z]{0,10}|[A-Za-z]{1,10}[0-9]{1,10})$';
#Product Codes
SELECT * FROM raw_online_retail WHERE StockCode REGEXP '^([0-9]{1,10}[A-Za-z]{0,10}|[A-Za-z]{1,10}[0-9]{1,10})$';
#StockCode contains some Non_Product Codes

#3. Description
#Only contains blank on some rows, no non-standard behavior

#4. Quantity
#Non-Numeric values
SELECT * FROM raw_online_retail WHERE Quantity NOT REGEXP '^(-|\\+)?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$';
#Numeric Negative values
SELECT * FROM raw_online_retail WHERE Quantity REGEXP '^(-|\\+)?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$' AND CAST(TRIM(Quantity) AS DECIMAL(10,2)) <= 0;
#Quantity only contains numeric values and some negative values

#5. InvoiceDate
#A detailed analysis shows only 1 datetime format is present
WITH dateTime_data AS (
	SELECT InvoiceDate AS raw_date,
    CASE
		WHEN STR_TO_DATE(`InvoiceDate`, '%m/%d/%Y %H:%i') IS NOT NULL THEN 'df1'
        WHEN STR_TO_DATE(`InvoiceDate`, '%d/%m/%Y %H:%i') IS NOT NULL THEN 'df2'
        WHEN STR_TO_DATE(`InvoiceDate`, '%Y-%m-%d %H:%i:%s') IS NOT NULL THEN 'df3'
        WHEN STR_TO_DATE(`InvoiceDate`, '%m/%d/%y %H:%i') IS NOT NULL THEN 'df4'
        ELSE NULL
	END AS date_format
    FROM raw_online_retail
    )
    SELECT * FROM datetime_data WHERE date_format != 'df3';
    
#6. UnitPrice
#Non-Numeric values
SELECT * FROM raw_online_retail WHERE UnitPrice NOT REGEXP '^(-|\\+)?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$';
#Numeric Negative values
SELECT * FROM raw_online_retail WHERE UnitPrice REGEXP '^(-|\\+)?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$' AND CAST(TRIM(UnitPrice) AS DECIMAL(10,2)) <= 0;
#UnitPrice only contains numeric values and some negative values

#7. CustomerID
#Only contains blank on some rows, no non-standard behavior

#8. Country
#Unspecified Countries
SELECT * FROM raw_online_retail WHERE TRIM(Country) = 'Unspecified';
#Country only contains some Unspecified Countries

#Creating Fact Tables
#Since we have some data that cannot be cleaned from raw tables like blank Customer Id for data loss for other
# future analysis, we will be creating fact tables that will not include inavalid values

#1. fact_cleaned_transactions
CREATE TABLE IF NOT EXISTS fact_cleaned_transactions AS
SELECT 
    TRIM(InvoiceNo) AS InvoiceNo,
    TRIM(StockCode) AS StockCode,
    TRIM(Description) AS Description,
    CAST(TRIM(Quantity) AS SIGNED) AS Quantity,
    STR_TO_DATE(TRIM(InvoiceDate), '%Y-%m-%d %H:%i:%s') AS InvoiceDate,
    CAST(TRIM(UnitPrice) AS DECIMAL(10, 2)) AS UnitPrice,
    TRIM(CustomerID) AS CustomerID,
    TRIM(Country) AS Country,
    ROUND(CAST(TRIM(Quantity) AS SIGNED) * CAST(TRIM(UnitPrice) AS DECIMAL(10, 2)), 2) AS LineTotal
FROM raw_online_retail
WHERE CustomerID IS NOT NULL 
  AND TRIM(CustomerID) != '' 
  AND LOWER(TRIM(CustomerID)) != 'null'
  AND CAST(TRIM(UnitPrice) AS DECIMAL(10, 2)) > 0
  AND UPPER(TRIM(StockCode)) REGEXP '^([0-9]{1,10}[A-Za-z]{0,10}|[A-Za-z]{1,10}[0-9]{1,10})$';

#Verifying rows
SELECT
	CAST(CustomerID AS SIGNED) AS CustomerID,
    InvoiceNo AS InvoiceNo,
    StockCode AS StockCode,
    Description AS Description,
    Quantity AS Quantity,
    InvoiceDate AS InvoiceDate,
    UnitPrice AS UnitPrice,
    Country AS Country,
    LineTotal as 'Line Total'
FROM fact_cleaned_transactions ORDER BY InvoiceDate;

#Quick audit on record count and date range
SELECT 
    COUNT(*) AS total_clean_line_items,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date
FROM fact_cleaned_transactions;

#2. fact_customer_orders
CREATE TABLE IF NOT EXISTS fact_customer_orders AS
SELECT 
    CustomerID,
    InvoiceNo,
    MIN(InvoiceDate) AS OrderDate,
    ROUND(SUM(LineTotal), 2) AS OrderTotal
FROM fact_cleaned_transactions
WHERE InvoiceNo REGEXP '^-?[0-9]+$'
  AND Quantity > 0
GROUP BY CustomerID, InvoiceNo;

#Indexing for fast window function partition queries
CREATE INDEX idx_customer_order ON fact_customer_orders(CustomerID, OrderDate);
#Verifying rows
SELECT
	CAST(CustomerID AS SIGNED) AS CustomerID,
    InvoiceNo AS InvoiceNo,
    OrderDate AS OrderDate,
    OrderTotal AS OrderTotal
FROM fact_customer_orders;

#3. fact_customer_order_intervals
CREATE TABLE IF NOT EXISTS fact_customer_order_intervals AS
SELECT 
    CustomerID,
    InvoiceNo,
    OrderDate,
    OrderTotal,
    MIN(OrderDate) OVER (PARTITION BY CustomerID) AS CohortDate,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, InvoiceNo) AS PrevOrderDate,
    DATEDIFF(
        OrderDate, 
        LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, InvoiceNo)
    ) AS DaysSinceLastOrder,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate, InvoiceNo) AS OrderSequenceNumber
FROM fact_customer_orders;

#Verifying rows
SELECT
	CAST(CustomerID AS SIGNED) AS CustomerID,
    InvoiceNo AS InvoiceNo,
    OrderDate AS OrderDate,
    OrderTotal AS OrderTotal,
    CohortDate AS CohortDate,
    PrevOrderDate AS 'Previous Order Date',
    DaysSinceLastOrder AS 'Current Inactivity Days',
    OrderSequenceNumber AS 'Order Sequence'
FROM fact_customer_order_intervals ORDER BY OrderDate, OrderSequenceNumber;

#4. fact_customer_summary
CREATE TABLE IF NOT EXISTS fact_customer_summary AS
WITH max_date_cte AS (
    SELECT MAX(OrderDate) AS max_dataset_date FROM fact_customer_orders
)
SELECT 
    s.CustomerID,
    MIN(s.CohortDate) AS FirstPurchaseDate,
    MAX(s.OrderDate) AS LastPurchaseDate,
    COUNT(DISTINCT s.InvoiceNo) AS TotalOrders,
    ROUND(SUM(s.OrderTotal), 2) AS TotalMonetaryValue,
    DATEDIFF(m.max_dataset_date, MAX(s.OrderDate)) AS RecencyDays,
    CASE 
        WHEN DATEDIFF(m.max_dataset_date, MAX(s.OrderDate)) > 30 THEN 1 
        ELSE 0 
    END AS IsChurned30
FROM fact_customer_order_intervals s
CROSS JOIN max_date_cte m
GROUP BY s.CustomerID, m.max_dataset_date;

#Verifying rows
SELECT
	CAST(CustomerID AS SIGNED) AS CustomerID,
    FirstPurchaseDate AS 'First Purchase Date',
    LastPurchaseDate AS 'Last Purchase Date',
    TotalOrders AS 'Total Orders',
    TotalMonetaryValue AS 'Total Monetary Value',
    RecencyDays AS 'Recency Days',
    IsChurned30 AS 'Monthly Churned Status'
FROM fact_customer_summary ORDER BY FirstPurchaseDate, LastPurchaseDate;

#Quick audit on customer summary
SELECT 
    COUNT(*) AS total_tracked_customers,
    SUM(IsChurned30) AS total_churned_customers,
    ROUND(AVG(RecencyDays), 1) AS avg_recency_days,
    ROUND(AVG(TotalOrders), 2) AS avg_orders_per_customer
FROM fact_customer_summary;
