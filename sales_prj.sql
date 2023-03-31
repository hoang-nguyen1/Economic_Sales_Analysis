/* Sales Data for Economic Project

Skills applied: Aggregate functions, GROUP BY, Window functions, Subqueries, JOIN, and CTE

*/

-- Create Table
CREATE TABLE sales_project(
	index int NOT NULL PRIMARY KEY,
	Date date,
	Year int,
	Month varchar(50),
	Age int,
	"Customer Gender" varchar(50),
	Country varchar(50),
	State varchar(50),
	"Product Category" varchar(50),
	"Sub Category" varchar(50),
	Quantity int,
	"Unit Cost" numeric,
	"Unit Price" numeric,
	Cost int,
	Revenue numeric)
	
--- 1. Data Cleaning
-- Check for missing values in the data
SELECT * FROM sales_project
WHERE date IS NULL
	OR year IS NULL
	OR month IS NULL
	OR age IS NULL
	OR "Customer Gender" IS NULL
	OR country IS NULL
	OR state IS NULL
	OR "Product Category" IS NULL
	OR "Sub Category" IS NULL
	OR quantity IS NULL
	OR "Unit Cost" IS NULL
	OR "Unit Price" IS NULL
	OR cost IS NULL
	OR revenue IS NULL

-- Since most of the attributes for Index 34866 are missing, let's remove it

-- Remove Index 34866
DELETE FROM sales_project
WHERE index = 34866




--- 2. Data Analysis

-- First, let's look at unique countries, product categories, and sub categories
SELECT DISTINCT country
FROM sales_project

SELECT DISTINCT "Product Category"
FROM sales_project

SELECT DISTINCT "Sub Category"
FROM sales_project


-- ANALYSIS 1: Find purchases pattern in products between Males and Females
SELECT "Customer Gender", "Product Category", COUNT(index) AS Total
FROM sales_project
GROUP BY 1,2
ORDER BY Total DESC


-- ANALYSIS 2: Break down transactions total based on countries
SELECT country, COUNT(index) AS total 
FROM sales_project
GROUP BY 1
ORDER BY total DESC


-- ANALYSIS 3: Find the states that have transactions occured in 2015 but not in 2016
SELECT DISTINCT state
FROM sales_project
WHERE year = 2015 AND state NOT IN (
	SELECT DISTINCT state
	FROM sales_project
	WHERE year = 2016)


-- ANALYSIS 4: Find the states that have transactions occured in 2016 but not in 2015
SELECT DISTINCT state
FROM sales_project
WHERE year = 2016 AND state NOT IN (
	SELECT DISTINCT state
	FROM sales_project
	WHERE year = 2015)



-- ANALYSIS 5: Split ages into groups and find total transactions based on groups and sub categories
SELECT
	CASE 
		WHEN age >= 65 THEN 'Old Age'
		WHEN age >= 40 AND age < 65 THEN 'Middle Age'
		WHEN age < 40 THEN 'Young Age'
		END AS age_group,
		"Sub Category",
		COUNT(index) AS total_transactions
FROM sales_project
GROUP BY
	CASE 
		WHEN age >= 65 THEN 'Old Age'
		WHEN age >= 40 AND age < 65 THEN 'Middle Age'
		WHEN age < 40 THEN 'Young Age'
		END,
		"Sub Category"
ORDER BY total_transactions DESC


-- ANALYSIS 6: Find the highest revenue and lowest revenue for all product categories by country
SELECT
	country,
	"Product Category",
	revenue,
	FIRST_VALUE(revenue) OVER(PARTITION BY country, "Product Category" ORDER BY revenue DESC),
	LAST_VALUE(revenue) OVER(PARTITION BY country, "Product Category" ORDER BY revenue DESC ROWS BETWEEN
							UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM sales_project



-- ANALYSIS 7: Find the total product (any product categories) sold for each month during 2015 and 2016

SELECT EXTRACT(month FROM date) AS month, year, SUM(total) AS total_product_sold
FROM
	(SELECT date,
	 		year,
	 		SUM(quantity) AS total
	 FROM sales_project
     GROUP BY 1,2) sub
GROUP BY 1,2
ORDER BY 1,2


-- ANALYSIS 8: Create a ranking of total purchased items based on sub-category for each country
SELECT
	country,
	"Sub Category",
	COUNT(index),
	RANK() OVER(PARTITION BY country ORDER BY COUNT(index) DESC)
FROM sales_project
GROUP BY 1,2


-- ANALYSIS 9: Return the average unit cost, average unit price, average cost, and average revenue of product category for each country
SELECT
	country,
	"Product Category",
	ROUND(AVG("Unit Cost"),2) AS avg_unit_cost,
	ROUND(AVG("Unit Price"),2) AS avg_unit_price,
	ROUND(AVG(cost),2) AS avg_cost,
	ROUND(AVG(revenue),2) AS avg_revenue
FROM sales_project
GROUP BY 1,2
ORDER BY avg_revenue DESC



-- ANALYSIS 10: Use CTE to calculate gross profit and return all countries, then join them to find the gross profit of each country

WITH profit AS (
	SELECT
		index,
		(revenue - cost) AS gross_profit
	FROM sales_project
	GROUP BY index, revenue, cost
	),
	country AS (
	SELECT
		index,
		country
	FROM sales_project)

SELECT
	country,
	SUM(gross_profit) AS sum_profit
FROM profit p
JOIN country c
ON p.index = c.index
GROUP BY 1
ORDER BY sum_profit DESC

