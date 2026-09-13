create	database ecommerce_product_trend_detection;
drop database ecommerce_product_trend_detection;
CREATE DATABASE ecommerce_transactions
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_transactions;
select * from ecommerce_transactions;
describe ecommerce_transactions;
select count(*) from ecommerce_transactions;
DESC ecommerce_transactions;
SELECT *
FROM ecommerce_transactions
LIMIT 10;
DESCRIBE ecommerce_transactions;
ALTER TABLE ecommerce_transactions
ADD COLUMN Transaction_Date_New DATE;
UPDATE ecommerce_transactions
SET Transaction_Date_New = STR_TO_DATE(Transaction_Date, '%d-%m-%Y');
SELECT
    Transaction_Date,
    Transaction_Date_New
FROM ecommerce_transactions
LIMIT 10;
ALTER TABLE ecommerce_transactions
DROP COLUMN Transaction_Date;
ALTER TABLE ecommerce_transactions
CHANGE COLUMN Transaction_Date_New Transaction_Date DATE;
DESCRIBE ecommerce_transactions;

# Step 1 — Total Sales
SELECT
    ROUND(SUM(Purchase_Amount), 2) AS total_sales
FROM ecommerce_transactions;
#--------------------------------------------------------------------
# Total Transactions
select count(*) as total_transactions
from ecommerce_transactions;
#--------------------------------------------------------
# Average Purchase Amount
select round(avg(Purchase_Amount),2) as average_purcahe
from ecommerce_transactions;
#-------------------------------------------------------------
# Minimum and Maximum Purchase
select 
min(Purchase_Amount) as minimum_purchase,
max(Purchase_Amount) as maximum_purchase from ecommerce_transactions;
#--------------------------------------------------------------------
# Category-wise Sales
select Product_Category,
count(*) as total_transactions,
round(sum(Purchase_Amount),2) as total_sales,
round(avg(Purchase_Amount),2) as average_purchase from ecommerce_transactions
group by Product_Category
order by total_sales desc;
#----------------------------------------------------------------------------------
# Total transactions and sales by country
# Which country generates the highest sales?
select Country,
count(*) as total_transactions,
round(sum(Purchase_Amount),2) as total_sales,
round(avg(Purchase_Amount),2) as average_purchase from ecommerce_transactions
group by Country
order by total_sales desc;
#-------------------------------------------------------------------------------
# Which payment method is most popular and which generates the most revenue?
# Payment Method Analysis
select Payment_Method,
count(*) as total_transactions,
round(sum(Purchase_Amount),2) as total_sales,
round(avg(purchase_Amount),2) as average_purchase from ecommerce_transactions
group by Payment_Method
order by total_sales desc;
#----------------------------------------------------------------------------
# Payment method by country
select Country,Payment_Method,
count(*) as total_transactions,
round(sum(purchase_Amount),2) AS total_sales from  ecommerce_transactions
group by Country,Payment_Method
order by Country,total_sales desc;
#-------------------------------------------------------------------------
# Top 10 customers by spending
SELECT
    User_Name,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_spending,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY User_Name
ORDER BY total_spending DESC
LIMIT 10;
#-----------------------------------------------------------------
# Top 10 customers by number of transactions
SELECT
    User_Name,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_spending
FROM ecommerce_transactions
GROUP BY User_Name
ORDER BY total_transactions DESC
LIMIT 10;
#------------------------------------------------------------------------
# Which age group contributes the most revenue?
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY age_group
ORDER BY total_sales DESC;
#----------------------------------------------------------------
# Monthly Sales
SELECT
    YEAR(Transaction_Date) AS year,
    MONTH(Transaction_Date) AS month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales
FROM ecommerce_transactions
GROUP BY
    YEAR(Transaction_Date),
    MONTH(Transaction_Date)
ORDER BY
    year,
    month;
#-------------------------------------------------------------------------
# Yearly Sales
SELECT
    YEAR(Transaction_Date) AS year,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY YEAR(Transaction_Date)
ORDER BY year;
#------------------------------------------------------------------------------------
# Top Product Categories
SELECT
    Product_Category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY Product_Category
ORDER BY total_sales DESC;
#------------------------------------------------------------------------
# Who are the top 10 customers based on average purchase amount?
SELECT
    User_Name,
    COUNT(*) AS total_transactions,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY User_Name
ORDER BY average_purchase DESC
LIMIT 10;
#------------------------------------------------------------------------------------
# Rank countries according to their sales:
SELECT
    Country,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(Purchase_Amount) DESC
    ) AS sales_rank
FROM ecommerce_transactions
GROUP BY Country;
#---------------------------------------------------------------------------
# Rank Customers
SELECT
    User_Name,
    ROUND(SUM(Purchase_Amount), 2) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(Purchase_Amount) DESC
    ) AS customer_rank
FROM ecommerce_transactions
GROUP BY User_Name;
#------------------------------------------------------------------------------------------
# How can we categorize customers based on their total spending?
SELECT
    User_Name,
    ROUND(SUM(Purchase_Amount), 2) AS total_spending,
    CASE
        WHEN SUM(Purchase_Amount) >= 250000 THEN 'High Spender'
        WHEN SUM(Purchase_Amount) >= 150000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_category
FROM ecommerce_transactions
GROUP BY User_Name
ORDER BY total_spending DESC;
#---------------------------------------------------------------------------------------
# How many customers belong to each spending category?
SELECT
    spending_category,
    COUNT(*) AS customer_count
FROM (
    SELECT
        User_Name,
        CASE
            WHEN SUM(Purchase_Amount) >= 250000 THEN 'High Spender'
            WHEN SUM(Purchase_Amount) >= 150000 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spending_category
    FROM ecommerce_transactions
    GROUP BY User_Name
) AS customer_segments
GROUP BY spending_category
ORDER BY customer_count DESC;
#-------------------------------------------------------------------------------------------
# What percentage of customers belong to each spending category?
SELECT
    spending_category,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM (
    SELECT
        User_Name,
        CASE
            WHEN SUM(Purchase_Amount) >= 250000 THEN 'High Spender'
            WHEN SUM(Purchase_Amount) >= 150000 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spending_category
    FROM ecommerce_transactions
    GROUP BY User_Name
) AS customer_segments
GROUP BY spending_category
ORDER BY customer_percentage DESC;
#--------------------------------------------------------------------------------------
# Which countries generate the highest total sales and average purchase amount?
SELECT
    Country,
    COUNT(*) AS total_transactions,
    ROUND(SUM(Purchase_Amount), 2) AS total_sales,
    ROUND(AVG(Purchase_Amount), 2) AS average_purchase
FROM ecommerce_transactions
GROUP BY Country
ORDER BY total_sales DESC;
#--------------------------------------------------------------------------------------
