-- Use the target database
USE `dbhihg38et4sgb`;

-- Drop the table if it already exists
DROP TABLE IF EXISTS df_sales;


-- Create the df_sales table. The data will be loaded from a Pandas DataFrame, 
-- but the Pandas default settings will not be utilized for table creation.
CREATE TABLE df_sales (
	ID INT AUTO_INCREMENT PRIMARY KEY,
	InvoiceNo VARCHAR(10), 
	StockCode VARCHAR(15), 
	Description VARCHAR(50), 
	Quantity SMALLINT, 
	InvoiceDate DATETIME, 
	UnitPrice FLOAT(53), 
	CustomerID INT, 
	Country VARCHAR(30), 
	TotalPrice DECIMAL(20, 3), 
	Year INT, 
	Month TINYINT, 
	DayOfWeek TINYINT, 
	Season VARCHAR(10)
);
-- Workbench automatically commits, but added as precaution
-- Use the code below in conjuction with the Python file, from time to time, you may need to use them if you abort a query
COMMIT;
ROLLBACK;

-- Validate column lengths in df_sales table
SELECT MAX(length(InvoiceNo)), 
	   MAX(length(StockCode)), 
	   MAX(length(Description)), 
       MAX(Quantity),
       MAX(length(Country)), 
       MAX(length(TotalPrice)), 
       MAX(length(CustomerID)), 
       MAX(Year), 
       MAX(Month), 
       MAX(length(CustomerID)), 
       MAX(length(Season)) 
FROM df_sales;

-- Retrieve all data from df_sales
SELECT *
FROM df_sales;


-- What are the unique countries?
SELECT DISTINCT c.Country
FROM df_sales_customers c;

--------------------------------------------------------------------------------------------------------------------------------------------
--														Creating Derived Tables
--------------------------------------------------------------------------------------------------------------------------------------------
-- Create df_sales_products table with distinct product records
CREATE TABLE df_sales_products AS 
WITH CTE AS (SELECT DISTINCT ID, StockCode, Description, UnitPrice
FROM df_sales) 
SELECT * 
FROM CTE;


-- Create df_sales_customers table with customer information
CREATE TABLE df_sales_customers AS 
SELECT 
	ID, 
    Country
FROM df_sales;

-- Create df_sales_products table with product details
CREATE TABLE df_sales_products AS 
SELECT 
	ID, 
    Country
FROM df_sales;

-- Create df_sales_invoice table with invoice details
CREATE TABLE df_sales_invoice AS 
SELECT 
	ID, 
    InvoiceNo, 
    InvoiceDate, 
    Quantity, 
    TotalPrice, 
    Year, 
    Month, 
    DayOfWeek, 
    Season
FROM df_sales;

-- Customer Purchasing Behavior:
SELECT 
	ID AS CustomerID, 
    COUNT(InvoiceNo) AS PurchaseCount, 
	ROUND(AVG(TotalPrice), 2) AS PurchaseValue 
FROM df_sales_invoice
GROUP BY ID
ORDER BY PurchaseValue desc;

-- Product Performance: Evaluate product sales, popularity, and revenue.
SELECT 
	sp.Description AS ProductDescription, 
	SUM(si.Quantity) AS TotalQuantitySold, 
	ROUND(SUM(si.TotalPrice), 2) AS TotalRevenue
FROM df_sales_invoice si
INNER JOIN df_sales_products sp ON si.ID = sp.ID
GROUP BY sp.Description
ORDER BY TotalRevenue;


-- Sales Trends: Identify trends over time, seasonal variations, and peak sales periods.
-- Find the most popular items based on the time of the year and season

SELECT 
	ID, 
    Year, 
    Month, 
    Season, 
    SUM(TotalPrice) AS TotalSales
FROM df_sales_invoice
GROUP BY Year, Season;

-- FIND THE MOST POPULAR ITEMS BASED ON THE CLIENT COUNTRY
SELECT 
	p.Description AS ProductDescription, 
	SUM(i.Quantity) AS TotalQuantitySold, 
	ROUND(SUM(i.TotalPrice), 2) AS TotalRevenue,
	c.Country
FROM df_sales_invoice i
INNER JOIN df_sales_products p ON i.ID = p.ID
INNER JOIN df_sales_customers c ON c.ID = p.ID
GROUP BY p.Description, c.Country
ORDER BY TotalRevenue DESC;

-- Monthly sales Growth
SELECT 
	Year, 
    Month, 
    SUM(TotalPrice) AS TotalSales,
    LAG(SUM(TotalPrice)) OVER (ORDER BY Year, Month) AS PreviousMonthSales, 
    ROUND((SUM(TotalPrice) - LAG(SUM(TotalPrice)) OVER (ORDER BY Year, Month)) / LAG(SUM(TotalPrice)) OVER (ORDER BY Year, Month) * 100, 2) AS GrowthRate
FROM
	df_sales_invoice
GROUP BY 
	Year, Month;
    
-- Time of Day for sales
SELECT 
	CASE
		WHEN HOUR(InvoiceDate) BETWEEN 5 AND 7 THEN 'EarlyMorning'
        WHEN HOUR(InvoiceDate) BETWEEN 8 AND 11 THEN 'Morning'
        WHEN HOUR(InvoiceDate) BETWEEN 12 AND 15 THEN 'Afternoon'
        WHEN HOUR(InvoiceDate) BETWEEN 16 AND 19 THEN 'Evening'
        WHEN HOUR(InvoiceDate) BETWEEN 20 AND 23 THEN 'LateNight'
        WHEN HOUR(InvoiceDate) BETWEEN 0 AND 4 THEN 'Midnight'
    END AS TimePeriod,
    SUM(TotalPrice) AS TotalSales
FROM df_sales_invoice
GROUP BY TimePeriod
ORDER BY TotalSales DESC;

-- Product Sales by Country
SELECT 
	i.InvoiceNo,
    c.Country,
    SUM(i.TotalPrice) AS TotalSales	
FROM df_sales_customers c
INNER JOIN df_sales_invoice i ON i.ID = c.ID
GROUP BY c.Country ;

-- Customer Purchase Frequency
SELECT 
	ID CustomerID, 
    COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
FROM df_sales_invoice
GROUP BY CustomerID
ORDER BY PurchaseFrequency DESC;

-- Find the most popular item per country
SELECT 
	p.Description AS ProductDescription,
	COUNT(i.InvoiceNo) AS NumberOfOrders,
	SUM(i.TotalPrice) AS TotalSales,
	i.Season, i.Year
FROM df_sales_products p
INNER JOIN df_sales_invoice i on i.ID = p.ID
GROUP BY p.Description,  i.Year, i.Season
ORDER BY NumberOfOrders DESC;

-- Most Popular Products
SELECT 
	p.Description AS ProductDescription,
	COUNT(i.InvoiceNo) AS NumberOfOrders,
	SUM(i.TotalPrice) AS TotalSales,
	i.Season, 
    i.Year
FROM df_sales_products p
INNER JOIN df_sales_invoice i on i.ID = p.ID
GROUP BY p.Description,  i.Year, i.Season
ORDER BY NumberOfOrders DESC;
















