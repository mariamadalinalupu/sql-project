------------------------------------------------------------
-- DATABASE EXPLORATION & STRUCTURE
------------------------------------------------------------

-- List all tables
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

-- List columns for a specific table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'brands';


------------------------------------------------------------
-- DIMENSIONS EXPLORATION (Granularity and unique members)
------------------------------------------------------------

SELECT brand_name FROM dbo.brands;
SELECT category_name FROM dbo.categories;
SELECT DISTINCT product_name FROM dbo.products;

SELECT DISTINCT order_id FROM dbo.orders;
SELECT DISTINCT customer_id FROM dbo.customers;
SELECT DISTINCT state FROM dbo.customers;
SELECT DISTINCT city FROM dbo.customers;

SELECT staff_id FROM dbo.staffs;
SELECT store_name FROM dbo.stores;


------------------------------------------------------------
-- DATE RANGE EXPLORATION
------------------------------------------------------------

SELECT 
    MIN(order_date) AS FirstOrderDate,
    MAX(order_date) AS LastOrderDate,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS OrdersRangeMonths
FROM dbo.orders;


------------------------------------------------------------
-- MEASURES EXPLORATION (Key Metrics)
------------------------------------------------------------

-- Total Sales
SELECT 
    SUM(SalesPerOrder) AS TotalSales
FROM (
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS SalesPerOrder
    FROM dbo.order_items
    GROUP BY order_id
) t;

-- Total Items Sold
SELECT SUM(quantity) AS TotalItemsSold 
FROM dbo.order_items;

-- Average Selling Price
SELECT ROUND(AVG(list_price), 2) AS AvgSellingPrice 
FROM dbo.order_items;

-- Total Number of Orders
SELECT COUNT(DISTINCT order_id) AS TotalOrders 
FROM dbo.orders;

-- Total Number of Products
SELECT COUNT(DISTINCT product_id) AS TotalProducts 
FROM dbo.products;

-- Total Number of Customers
SELECT COUNT(DISTINCT customer_id) AS TotalNoCustomers 
FROM dbo.customers;

-- All customers have placed at least one order
SELECT COUNT(DISTINCT customer_id) AS CustomersWithOrder 
FROM dbo.orders;


------------------------------------------------------------
-- SUMMARY REPORT OF KEY METRICS
------------------------------------------------------------

SELECT 'TotalSales' AS MeasureName, ROUND(SUM(SalesPerOrder), 2) AS MeasureValue
FROM (
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS SalesPerOrder
    FROM dbo.order_items
    GROUP BY order_id
) t

UNION ALL
SELECT 'TotalQuantity', SUM(quantity)
FROM dbo.order_items

UNION ALL
SELECT 'AverageSellingPrice', ROUND(AVG(list_price), 2)
FROM dbo.order_items

UNION ALL
SELECT 'TotalOrders', COUNT(DISTINCT order_id)
FROM dbo.orders

UNION ALL
SELECT 'TotalProducts', COUNT(DISTINCT product_id)
FROM dbo.products

UNION ALL
SELECT 'TotalCustomers', COUNT(DISTINCT customer_id)
FROM dbo.customers;


------------------------------------------------------------
-- MAGNITUDE COMPARISON BY CATEGORIES
------------------------------------------------------------

-- Total Customers by State
SELECT 
    state, 
    COUNT(customer_id) AS CustomersPerState
FROM dbo.customers
GROUP BY state;

-- Total Customers per Store
SELECT 
    s.store_name, 
    COUNT(DISTINCT c.customer_id) AS TotalCustomersPerStore
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
JOIN dbo.stores s ON s.store_id = o.store_id
GROUP BY s.store_name;

-- Total Products & Avg Price per Category
SELECT 
    c.category_name,
    COUNT(p.product_id) AS ProductsPerCategory,
    ROUND(AVG(p.list_price), 2) AS AvgPricePerCategory
FROM dbo.categories c
JOIN dbo.products p ON c.category_id = p.category_id
GROUP BY c.category_name;


------------------------------------------------------------
-- TOTAL SALES BY CATEGORY & BRAND
------------------------------------------------------------

WITH SalesPerProduct AS (
    SELECT 
        oi.product_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
    FROM dbo.order_items oi
    GROUP BY oi.product_id
)
SELECT 
    'Category' AS dimension,
    c.category_name AS name,
    SUM(s.total_sales) AS total_sales
FROM SalesPerProduct s
JOIN dbo.products p ON s.product_id = p.product_id
JOIN dbo.categories c ON p.category_id = c.category_id
GROUP BY c.category_name

UNION ALL

SELECT 
    'Brand' AS dimension,
    b.brand_name,
    SUM(s.total_sales)
FROM SalesPerProduct s
JOIN dbo.products p ON s.product_id = p.product_id
JOIN dbo.brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name;


------------------------------------------------------------
-- RANKING ANALYSIS
------------------------------------------------------------

-- Top 5 Products by Sales
SELECT TOP 5 
    p.product_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM dbo.order_items oi
JOIN dbo.products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- Top 5 Products by Quantity Sold
SELECT TOP 5 
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM dbo.order_items oi
JOIN dbo.products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC;

-- Top 5 Customers by Revenue
WITH SalesOrder AS (
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS SalesPerOrder
    FROM dbo.order_items
    GROUP BY order_id
)
SELECT TOP 5
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(s.SalesPerOrder) AS total_sales
FROM SalesOrder s
JOIN dbo.orders o ON s.order_id = o.order_id
JOIN dbo.customers c ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_sales DESC;
