-- 1. DATABASE SETUP
CREATE DATABASE food_delivery;
USE food_delivery;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    cuisine VARCHAR(50),
    rating DECIMAL(2,1),
    city VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    restaurant_id INT,
    order_time DATETIME,
    delivery_time DATETIME,
    order_amount VARCHAR(20),
    city VARCHAR(50)
);

DESCRIBE orders;

-- ==============================
-- 2. DATA VALIDATION
-- ==============================

-- Check total row count to verify successful data import
SELECT COUNT(*) AS total_orders FROM orders;

-- Check for missing values (NULLs)
-- During import, NULLs may have been converted to 0
SELECT COUNT(*) AS missing_values
FROM orders
WHERE order_amount IS NULL OR order_amount = 0;

-- Check for invalid delivery times
-- Delivery time should always be after order time
SELECT COUNT(*) AS invalid_delivery_rows
FROM orders
WHERE delivery_time < order_time;

-- Identify duplicate orders
-- Same order_id appearing multiple times
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Detect outliers in order amount
-- Very low (<50) or very high (>2000) values
SELECT COUNT(*) AS outlier_rows
FROM orders
WHERE order_amount < 50 OR order_amount > 2000;

-- Check city inconsistencies (case-sensitive)
-- MySQL is case-insensitive by default, so use BINARY
SELECT 
    COUNT(DISTINCT city) AS normal_distinct,
    COUNT(DISTINCT BINARY city) AS case_sensitive_distinct
FROM orders;

-- Check for orders with invalid customer_id
-- These are orders that do not match any customer
SELECT COUNT(*) AS invalid_customer_refs
FROM orders o
LEFT JOIN customers c 
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check for orders with invalid restaurant_id
-- These are orders that do not match any restaurant
SELECT COUNT(*) AS invalid_restaurant_refs
FROM orders o
LEFT JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
WHERE r.restaurant_id IS NULL;

-- =========================================
-- 3. DATA CLEANING
-- =========================================

-- 1. Remove rows with missing order_amount
-- These represent incomplete transactions and cannot be used for revenue analysis
DELETE FROM orders
WHERE order_amount = 0 OR order_amount IS NULL;

-- 2. Handle outliers
-- Remove extremely low values (likely errors)
DELETE FROM orders
WHERE order_amount < 50 OR order_amount > 2000;

-- 3. Standardize city names
-- Convert all city values to uppercase for consistency
UPDATE orders
SET city = UPPER(city);

-- 4. Convert order_amount to DECIMAL
-- This enables correct aggregation and financial calculations
ALTER TABLE orders
MODIFY order_amount DECIMAL(10,2);

--  Check after cleaning
SELECT COUNT(*) AS final_row_count FROM orders;

-- Adding primary key after cleaning
ALTER TABLE orders ADD PRIMARY KEY (order_id);

-- Adding foreign key to connect orders with customers
ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Adding foreign key to connect orders with restaurants
ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id);

-- =========================================
-- 3. ANSWERING BUSINESS QUESTIONS
-- =========================================

-- 1. Total revenue per city
SELECT 
    city,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM orders
GROUP BY city
ORDER BY total_revenue DESC;

-- 2. Top 5 cities by revenue
SELECT 
    city,
    SUM(order_amount) AS revenue
FROM orders
GROUP BY city
ORDER BY revenue DESC
LIMIT 5;

-- 3. Average delivery time per city
SELECT 
    city,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, delivery_time)), 2) AS avg_delivery_time_minutes
FROM orders
GROUP BY city
ORDER BY avg_delivery_time_minutes;

-- 4. Cities with highest delivery delays 
SELECT 
    city,
    MAX(TIMESTAMPDIFF(MINUTE, order_time, delivery_time)) AS max_delay
FROM orders
GROUP BY city
ORDER BY max_delay DESC;

-- 5. Top 10 restaurants by revenue
SELECT 
    r.restaurant_name,
    SUM(o.order_amount) AS revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY revenue DESC
LIMIT 10;

-- 6. Average rating vs revenue (Do highly rated restaurants earn more?)
SELECT 
    r.rating,
    SUM(o.order_amount) AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.rating
ORDER BY r.rating DESC;

-- 7. Top customers by total spend
SELECT 
    c.customer_name,
    SUM(o.order_amount) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spend DESC
LIMIT 10;

-- 8. Repeat vs new customers analysis
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders,
    CASE 
        WHEN COUNT(order_id) > 1 THEN 'Repeat'
        ELSE 'New'
    END AS customer_type
FROM orders
GROUP BY customer_id;

-- 9. Monthly revenue trend
SELECT 
    DATE_FORMAT(order_time, '%Y-%m') AS month,
    SUM(order_amount) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- 10. Peak order hours (when most orders happen)
SELECT 
    HOUR(order_time) AS hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY hour
ORDER BY total_orders DESC;

-- ADVANCED QUERIES
-- Rank restaurants within each city based on revenue
SELECT 
    city,
    restaurant_id,
    SUM(order_amount) AS revenue,
    RANK() OVER (PARTITION BY city ORDER BY SUM(order_amount) DESC) AS rank_in_city
FROM orders
GROUP BY city, restaurant_id;

-- Using Case; categorize orders based on value for segmentation analysis
SELECT 
    order_id,
    order_amount,
    CASE 
        WHEN order_amount > 500 THEN 'High Value'
        WHEN order_amount BETWEEN 200 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category
FROM orders;

-- Improve query performance on city-based queries
CREATE INDEX idx_city ON orders(city);

