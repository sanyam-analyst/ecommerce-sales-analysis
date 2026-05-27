-- ============================================================
-- E-Commerce Company: Sales Analysis
-- Dataset: Customers, Products, Orders, OrderDetails
-- Tool: MySQL
-- ============================================================


-- ------------------------------------------------------------
-- 1. Analyze the Data
-- Description: Describe the structure of all 4 tables
-- ------------------------------------------------------------

DESC Customers;
DESC Products;
DESC Orders;
DESC OrderDetails;


-- ------------------------------------------------------------
-- 2. Market Segmentation Analysis
-- Description: Identify top 3 cities with highest number of
-- customers for targeted marketing and logistics optimization
-- ------------------------------------------------------------

SELECT location, COUNT(*) AS number_of_customers
FROM Customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;


-- ------------------------------------------------------------
-- 3. Engagement Depth Analysis
-- Description: Determine how many customers fall into each
-- order frequency category based on number of orders placed
-- ------------------------------------------------------------

WITH CustomerOrders AS (
    SELECT customer_id, COUNT(order_id) AS NumberOfOrders
    FROM Orders
    GROUP BY customer_id
)
SELECT NumberOfOrders, COUNT(*) AS CustomerCount
FROM CustomerOrders
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders;


-- ------------------------------------------------------------
-- 4. Purchase High-Value Products
-- Description: Identify products where average purchase
-- quantity per order is 2 but with high total revenue,
-- suggesting premium product trends
-- ------------------------------------------------------------

SELECT Product_id, AVG(quantity) AS AvgQuantity,
SUM(price_per_unit * Quantity) AS TotalRevenue
FROM OrderDetails
GROUP BY Product_id
HAVING AvgQuantity = 2
ORDER BY TotalRevenue DESC;


-- ------------------------------------------------------------
-- 5. Category-wise Customer Reach
-- Description: For each product category, calculate unique
-- number of customers to understand category-level reach
-- ------------------------------------------------------------

SELECT p.category, COUNT(DISTINCT o.customer_id) AS unique_customers
FROM Products AS p
JOIN OrderDetails AS od ON p.product_id = od.product_id
JOIN Orders AS o ON od.order_id = o.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;


-- ------------------------------------------------------------
-- 6. Sales Trend Analysis
-- Description: Analyze month-on-month percentage change in
-- total sales to identify growth trends
-- ------------------------------------------------------------

WITH CTE_Orders AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(Total_amount) AS TotalSales
    FROM Orders
    GROUP BY Month
)
SELECT *, ROUND(((TotalSales - LAG(TotalSales, 1) OVER (ORDER BY Month)) /
LAG(TotalSales, 1) OVER (ORDER BY Month)) * 100, 2) AS PercentChange
FROM CTE_Orders;


-- ------------------------------------------------------------
-- 7. Average Order Value Fluctuation
-- Description: Examine how average order value changes
-- month-on-month to guide pricing and promotional strategies
-- ------------------------------------------------------------

WITH CTE_Orders AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month,
    ROUND(AVG(total_amount), 2) AS AvgOrderValue
    FROM Orders
    GROUP BY Month
)
SELECT *,
ROUND(AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY Month), 2)
AS ChangeInValue
FROM CTE_Orders
ORDER BY ChangeInValue DESC;


-- ------------------------------------------------------------
-- 8. Inventory Refresh Rate
-- Description: Identify top 5 products with fastest turnover
-- rates indicating high demand and frequent restocking need
-- ------------------------------------------------------------

SELECT product_id, COUNT(price_per_unit) AS SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;


-- ------------------------------------------------------------
-- 9. Low Engagement Products
-- Description: List products purchased by less than 40% of
-- the customer base indicating inventory-demand mismatch
-- ------------------------------------------------------------

SELECT p.product_id, p.name,
COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
FROM Products AS p
JOIN OrderDetails AS od ON p.product_id = od.product_id
JOIN Orders AS o ON od.order_id = o.order_id
JOIN Customers AS c ON o.customer_id = c.customer_id
GROUP BY p.product_id, p.name
HAVING UniqueCustomerCount < 40;


-- ------------------------------------------------------------
-- 10. Customer Acquisition Trends
-- Description: Evaluate month-on-month growth in customer
-- base to measure marketing campaign effectiveness
-- ------------------------------------------------------------

WITH FirstTimeOrders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM Orders
    GROUP BY customer_id
)
SELECT DATE_FORMAT(first_order_date, '%Y-%m') AS FirstPurchaseMonth,
COUNT(DISTINCT Customer_id) AS TotalNewCustomers
FROM FirstTimeOrders
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;


-- ------------------------------------------------------------
-- 11. Peak Sales Period Identification
-- Description: Identify top 3 months with highest sales
-- volume for stock planning and marketing efforts
-- ------------------------------------------------------------

SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month,
SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;