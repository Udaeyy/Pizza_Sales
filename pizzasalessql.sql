-- Pizza Sales Analysis SQL Queries
-- This file contains a collection of SQL queries designed to analyze pizza sales data from a relational database
-- with tables: orders, order_details, pizzas, and pizza_types.

-- -----------------------------------
-- Table Exploration Queries
-- These queries retrieve all data from the main tables for initial exploration.
-- -----------------------------------

-- 1. View All Order Details
-- Retrieves all columns from the `order_details` table to inspect order items.
SELECT * FROM order_details;

-- 2. View All Orders
-- Fetches all columns from the `orders` table to see order metadata.
SELECT * FROM orders;

-- 3. View All Pizza Types
-- Displays all pizza type details from the `pizza_types` table.
SELECT * FROM pizza_types;

-- 4. View All Pizzas
-- Shows all pizza records with details like size and price.
SELECT * FROM pizzas;

-- -----------------------------------
-- Basic Analytical Queries
-- These queries perform simple aggregations and calculations.
-- -----------------------------------

-- 5. Rolling Total Price by Pizza
-- Calculates a cumulative total of pizza prices, ordered by price, using a window function.
SELECT 
    pizza_id, 
    pizza_type_id, 
    size, 
    price, 
    SUM(price) OVER (ORDER BY price) AS rolling_total 
FROM pizzas;

-- 6. Detailed Order Report
-- Joins all tables to create a comprehensive report of orders, including pizza names, quantities, and total prices.
SELECT 
    od.order_details_id,
    o.order_id,
    o.order_date,
    o.order_time,
    od.pizza_id,
    pti.pizza_type_id,
    pti.name,
    pti.category,
    p.size,
    od.quantity,
    p.price,
    od.quantity * p.price AS total_price
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pti ON p.pizza_type_id = pti.pizza_type_id;

-- -----------------------------------
-- CTE-Based Queries
-- These queries use Common Table Expressions (CTEs) for complex analysis.
-- -----------------------------------

-- 7. Count of Order Details with Rolling Total
-- Uses a CTE to compute a rolling total of sales and counts the number of order detail records.
WITH od_count AS (
    SELECT 
        od.order_details_id,
        o.order_id,
        o.order_date,
        o.order_time,
        od.pizza_id,
        pti.pizza_type_id,
        pti.name,
        pti.category,
        p.size,
        od.quantity,
        p.price,
        od.quantity * p.price AS total_price,
        SUM(od.quantity * p.price) OVER (ORDER BY p.price) AS rolling_total
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pti ON p.pizza_type_id = pti.pizza_type_id
)
SELECT COUNT(order_details_id) FROM od_count;

-- 8. Distinct Order Details with Row Numbers
-- Assigns row numbers to distinct `order_details_id` values from the CTE.
WITH cte AS (
    SELECT 
        od.order_details_id,
        o.order_id,
        o.order_date,
        o.order_time,
        od.pizza_id,
        pti.pizza_type_id,
        pti.name,
        pti.category,
        p.size,
        od.quantity,
        p.price,
        od.quantity * p.price AS total_price,
        SUM(od.quantity * p.price) OVER (ORDER BY p.price) AS rolling_total
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pti ON p.pizza_type_id = pti.pizza_type_id
)
SELECT DISTINCT(order_details_id), ROW_NUMBER() OVER (ORDER BY order_details_id)
FROM cte;

-- 9. Distinct Orders with Row Numbers
-- Assigns row numbers to distinct `order_id` values from the CTE.
WITH cte2 AS (
    SELECT 
        od.order_details_id,
        o.order_id,
        o.order_date,
        o.order_time,
        od.pizza_id,
        pti.pizza_type_id,
        pti.name,
        pti.category,
        p.size,
        od.quantity,
        p.price,
        od.quantity * p.price AS total_price,
        SUM(od.quantity * p.price) OVER (ORDER BY p.price) AS rolling_total
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pti ON p.pizza_type_id = pti.pizza_type_id
)
SELECT DISTINCT(order_id), ROW_NUMBER() OVER (ORDER BY order_id)
FROM cte2;

-- -----------------------------------
-- Sales and Order Insights
-- These queries analyze sales trends and customer behavior.
-- -----------------------------------

-- 10. Verify Row Count with Window Function
-- Assigns a row number to each record in `order_details` for verification.
SELECT 
    order_details_id, 
    order_id, 
    pizza_id, 
    quantity, 
    ROW_NUMBER() OVER () 
FROM order_details;

-- 11. Most Ordered Pizza
-- Identifies the most frequently ordered pizza by ID.
SELECT 
    pizza_id, 
    COUNT(*) AS count
FROM order_details
GROUP BY pizza_id
ORDER BY count DESC;

-- 12. Total Number of Orders
-- Calculates the total number of pizza items ordered across all orders.
WITH cte AS (
    SELECT 
        pizza_id, 
        COUNT(*) AS count
    FROM order_details
    GROUP BY pizza_id
    ORDER BY count
)
SELECT SUM(count) FROM cte;

-- 13. Top Orderers
-- Finds which orders had the highest total quantities of pizzas.
SELECT 
    order_id, 
    SUM(quantity) AS quantity_ordered
FROM order_details
GROUP BY order_id
ORDER BY quantity_ordered DESC;

-- 14. Monthly Sales
-- Aggregates orders by month to show monthly sales trends.
SELECT 
    MONTH(order_date), 
    COUNT(*) AS monthly_orders
FROM orders
GROUP BY MONTH(order_date);

-- 15. Weekday Sales
-- Shows order counts by weekday (0 = Monday, 6 = Sunday).
SELECT 
    WEEKDAY(order_date) AS weekday, 
    COUNT(*) AS weekday_orders
FROM orders
GROUP BY WEEKDAY(order_date)
ORDER BY weekday_orders;

-- 16. Day Name Sales
-- Aggregates orders by day name (e.g., "Monday") for readability.
SELECT 
    DAYNAME(order_date) AS weekday, 
    COUNT(*) AS dayname_orders
FROM orders
GROUP BY DAYNAME(order_date)
ORDER BY dayname_orders;

-- 17. Day of Month Sales
-- Counts orders by day of the month (1-31).
SELECT 
    DAY(order_date) AS date, 
    COUNT(*) AS date_orders
FROM orders
GROUP BY DAY(order_date);

-- 18. Peak Sales Hour
-- Identifies the busiest hours of the day for orders.
SELECT 
    HOUR(order_time) AS Hour_of_day, 
    COUNT(*) AS order_count
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;

-- -----------------------------------
-- Pizza Type and Pricing Analysis
-- These queries focus on pizza types, categories, and pricing.
-- -----------------------------------

-- 19. Pizza Type Varieties by Category
-- Counts the number of pizza varieties in each category.
SELECT 
    category, 
    COUNT(*) AS count
FROM pizza_types
GROUP BY category;

-- 20. Average Price by Pizza Type
-- Calculates the average price for each pizza type.
SELECT 
    pt.pizza_type_id, 
    AVG(p.price) AS avg_price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.pizza_type_id;

-- 21. Average Price by Category
-- Computes the average price per pizza category, rounded to 2 decimal places.
SELECT 
    pt.category, 
    ROUND(AVG(p.price), 2) AS avg_price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category;

-- 22. Average Price by Category (Window Function)
-- Alternative approach using a window function to compute average price per category.
SELECT 
    *, 
    ROUND(AVG(p.price) OVER (PARTITION BY pt.category), 2) AS avg_price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id;

-- 23. Pizza Sizes Available
-- Counts the number of pizzas available in each size.
SELECT 
    size, 
    COUNT(*) 
FROM pizzas
GROUP BY size;

-- 24. Best-Selling Pizza Types
-- Identifies the top-selling pizzas with a rolling total of order counts.
SELECT 
    od.pizza_id, 
    pizzas.pizza_type_id, 
    count, 
    SUM(count) OVER (ORDER BY count) AS rolling_total
FROM (
    SELECT 
        pizza_id, 
        COUNT(*) AS count
    FROM order_details
    GROUP BY pizza_id
    ORDER BY count DESC
) AS od
JOIN pizzas ON od.pizza_id = pizzas.pizza_id;