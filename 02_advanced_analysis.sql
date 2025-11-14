/*
Change-Over-Time Analysis (Trends & Seasonality)
Total Sales, Orders, and Quantity by Year and Month
*/

WITH SalesPerOrder AS (
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS SalesPerOrder
    FROM Order_Items
    GROUP BY order_id
)
SELECT 
    YEAR(o.order_date) AS OrderYear,
    MONTH(o.order_date) AS OrderMonth,
    SUM(s.SalesPerOrder) AS TotalSales,
    COUNT(o.order_id) AS TotalOrders,
    SUM(oi.quantity) AS TotalQuantity
FROM SalesPerOrder AS s
JOIN Orders AS o
    ON s.order_id = o.order_id
JOIN Order_Items AS oi
    ON o.order_id = oi.order_id
WHERE o.shipped_date IS NOT NULL
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY OrderYear, OrderMonth 

--Total Orders by Month

/*
Cumulative Trend Analysis (Running Totals & Moving Average)
*/

WITH SalesPerOrder AS (
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS SalesPerOrder,
        AVG(list_price) AS AvgPrice
    FROM Order_Items
    GROUP BY order_id
),
MonthlySales AS (
    SELECT
        YEAR(o.order_date) AS OrderYear,
        MONTH(o.order_date) AS OrderMonth,
        SUM(s.SalesPerOrder) AS TotalSalesThisMonth,
        AVG(s.AvgPrice) AS AvgPriceThisMonth
    FROM SalesPerOrder AS s
    JOIN Orders AS o
        ON s.order_id = o.order_id
    WHERE o.shipped_date IS NOT NULL
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
)
SELECT
    OrderYear,
    OrderMonth,
    TotalSalesThisMonth,
    SUM(TotalSalesThisMonth) OVER (ORDER BY OrderYear, OrderMonth) AS RunningTotalSales,
    AVG(AvgPriceThisMonth) OVER (ORDER BY OrderYear, OrderMonth) AS MovingAveragePrice
FROM MonthlySales
ORDER BY OrderYear, OrderMonth;

/*
Performance Comparison: Current vs Average & Year-over-Year
*/

WITH YearlyProductSales AS (
    SELECT
        YEAR(o.order_date) AS OrderYear,
        oi.product_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS CurrentSalesPerProduct
    FROM Orders AS o
    JOIN Order_Items AS oi
        ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_date), oi.product_id
)
SELECT
    y.OrderYear,
    y.product_id,
    p.product_name,
    y.CurrentSalesPerProduct,
    AVG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id) AS AverageSalesPerProduct,
    y.CurrentSalesPerProduct 
        - AVG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id) AS DiffFromAverage,
    CASE 
        WHEN y.CurrentSalesPerProduct > AVG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id) THEN 'Above Average'
        WHEN y.CurrentSalesPerProduct < AVG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id) THEN 'Below Average'
        ELSE 'Average'
    END AS PerformanceStatus,
    LAG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id ORDER BY y.OrderYear) AS PriorYearSales,
    y.CurrentSalesPerProduct 
        - LAG(y.CurrentSalesPerProduct) OVER (PARTITION BY y.product_id ORDER BY y.OrderYear) AS YearChange
FROM YearlyProductSales AS y
JOIN Products AS p
    ON y.product_id = p.product_id
ORDER BY y.product_id, y.OrderYear;

/*
Part-to-Whole Analysis (Category Contribution to Sales)
*/

WITH CategorySales AS (
    SELECT
        c.category_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS TotalSalesPerCategory
    FROM Order_Items AS oi
    JOIN Products AS p
        ON oi.product_id = p.product_id
    JOIN Categories AS c
        ON p.category_id = c.category_id
    GROUP BY c.category_name
)
SELECT
    category_name,
    TotalSalesPerCategory,
    SUM(TotalSalesPerCategory) OVER () AS OverallSales,
    CONCAT(
        ROUND(TotalSalesPerCategory * 100.0 
            / SUM(TotalSalesPerCategory) OVER (), 2), '%'
    ) AS PercentageOfTotal
FROM CategorySales
ORDER BY TotalSalesPerCategory DESC;

/*
Price Segmentation (Product Distribution by Price Range)
*/

WITH ProductPriceSegments AS (
    SELECT
        product_id,
        product_name,
        list_price,
        CASE 
            WHEN list_price < 200 THEN 'Under 200'
            WHEN list_price < 500 THEN '200–499'
            WHEN list_price < 1000 THEN '500–999'
            WHEN list_price < 3000 THEN '1000–2999'
            WHEN list_price < 6000 THEN '3000–5999'
            ELSE '6000+'
        END AS PriceSegment,
        CASE 
            WHEN list_price < 200 THEN 1
            WHEN list_price < 500 THEN 2
            WHEN list_price < 1000 THEN 3
            WHEN list_price < 3000 THEN 4
            WHEN list_price < 6000 THEN 5
            ELSE 6
        END AS SegmentOrder
    FROM Products
)
SELECT
    PriceSegment,
    COUNT(product_id) AS TotalProducts
FROM ProductPriceSegments
GROUP BY PriceSegment, SegmentOrder
ORDER BY SegmentOrder;
