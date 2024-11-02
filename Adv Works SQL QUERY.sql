USE Adventure_Work_DB;

SELECT * FROM AdventureWorks_Calendar; -- Dates

SELECT * FROM AdventureWorks_Customers; -- CustomerKey, Prefix, FirstName, LastName, BirthDate, MaritalStatus
										-- Gender, EmailAdress, AnnualIncome, TotalChildren, EducationLevel, Occupation
										-- Homeowner

SELECT * FROM AdventureWorks_Product_Categories; -- ProductCategorykey, CategoryName

SELECT * FROM AdventureWorks_Product_Subcategories; -- ProductSubcategoryKey, SubcategoryName, ProductCategoryKey

SELECT * FROM AdventureWorks_Products; -- ProductKey, ProductSubcategoryKey, ProductSKU, ProductName, ModelName, ProductDescription,
									   -- ProductColor, ProductSize, ProductStyle, ProductCost, ProductPrice

SELECT * FROM AdventureWorks_Returns; -- ReturnDate, TerritoryKey, ProductKey, ReturnQuanity

SELECT * FROM AdventureWorks_Territories;  -- SalesTerritoryKey, Region, Country, Continent

SELECT * FROM FactTable;  -- OrderDtate, StockDate, orderNumber, ProductKey, CustomerKey, TerritoryKey
						  -- OrderLineItem, OrderQuantity


----------------------------------- Details View -------------------------------------------------=------

-- Total Revenue 

SELECT 
	ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) AS total_revenue
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey;

-- Total Transaction

SELECT 
	COUNT(*) AS total_transaction
FROM
	FactTable;

-- Total Quantity Sold

SELECT
	SUM(OrderQuantity) AS  total_quantity
FROM
	FactTable;

-- Total Returned Quantity

SELECT
	SUM(ReturnQuantity) AS total_returned_qty
FROM
	AdventureWorks_Returns;

-- Total Cost 

SELECT 
	ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0) AS total_cost
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey;

-- Profit Margin 

SELECT
	(ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) - ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0)) AS profit_margin
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey;


-- Highest Ordered Product

SELECT TOP 1
	pr.ProductName,
	SUM(OrderQuantity) AS total_quantity_ordered
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
GROUP BY
	pr.ProductName
ORDER BY
	total_quantity_ordered DESC;


----- Product with Highest Profit

SELECT TOP 1
	pr.ProductName,
	ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) - ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0) AS profit_margin
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
GROUP BY
	pr.ProductName
ORDER BY
	profit_margin DESC;
	
--- Top 3 product category with Highest profit

SELECT 
	pc.CategoryName,
	ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) - ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0) AS profit_margin
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
JOIN
	AdventureWorks_Product_Subcategories ps ON pr.ProductSubcategoryKey = ps.ProductCategoryKey
JOIN 
	AdventureWorks_Product_Categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY 
	pc.CategoryName
ORDER BY
	profit_margin DESC;

-- Profit Margin by Product Color

SELECT 
	pr.ProductColor,
	ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) - ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0) AS profit_margin
FROM
	FactTable ft
JOIN
	AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
GROUP BY
	pr.ProductColor
ORDER BY
	profit_margin DESC;	


-- TOp 10 Best Selling ProductsSELECT TOP 10

SELECT TOP 10
    pr.ProductName,
    (SUM(re.ReturnQuantity) / NULLIF(SUM(ft.OrderQuantity), 0)) * 100 AS ReturnRate,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT ft.CustomerKey) AS total_customers,
    SUM(ft.OrderQuantity) AS quantity_sold
FROM
    FactTable ft
JOIN
    AdventureWorks_Returns re ON ft.ProductKey = re.ProductKey
JOIN 
    AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
GROUP BY
    pr.ProductName
ORDER BY
    quantity_sold DESC,
    total_transactions DESC,
    total_customers DESC;




--------------------------------------Returned Analysis Query----------------------------------

-- Total Returned Transactions

SELECT 
	COUNT(*) AS total_return_transactions
FROM
	AdventureWorks_Returns

-- Total Returned Quantity

SELECT 
	SUM(ReturnQuantity) AS total_returned_quantity
FROM
	AdventureWorks_Returns;

-- Total Refund

SELECT 
	 COALESCE(SUM(re.ReturnQuantity * pr.ProductPrice), 0) AS total_refund
FROM
    AdventureWorks_Returns re
JOIN 
    AdventureWorks_Products pr ON re.ProductKey = pr.ProductKey;


-- Returned Transaction Rate

WITH total_transaction AS (
    SELECT 
        COUNT(*) AS TotalTransactions
    FROM    
        FactTable
),
total_return AS (
    SELECT 
        COUNT(*) AS TotalReturns
    FROM    
        AdventureWorks_Returns
)
SELECT 
      ROUND(COALESCE(tr.TotalReturns * 100.0 / NULLIF(tt.TotalTransactions, 0), 0), 2) AS ReturnedTransactionRate
FROM 
    total_transaction tt, total_return tr;
	

-- Total Returned Quantity

SELECT 
	SUM(ReturnQuantity) AS total_returned_quanityt
FROM
	AdventureWorks_Returns;

-- Total Returned Rate

WITH total_sold_quantity AS (
    SELECT 
        SUM(OrderQuantity) AS TotalQuantitySold
    FROM    
        FactTable
),
total_return_quantity AS (
    SELECT 
        SUM(ReturnQuantity) AS TotalQuantity
    FROM    
        AdventureWorks_Returns
)
SELECT 
    ROUND(
        COALESCE(tr.TotalQuantity * 100.0 / NULLIF(tt.TotalQuantitySold, 0), 0), 
        2
    ) AS ReturnedQuantityRate
FROM 
    total_sold_quantity tt, 
    total_return_quantity tr;


-- Total Refund Transaction

WITH Refunds AS (
    SELECT 
        SUM(fr.ReturnQuantity * p.ProductPrice) AS TotalRefund
    FROM 
       AdventureWorks_Returns fr
    JOIN 
        AdventureWorks_Products p ON fr.ProductKey = p.ProductKey  
)
SELECT 
    COALESCE(TotalRefund, 0) AS TransactionRefund
FROM 
    Refunds;

-- Total Refund rate

WITH total_revenue AS (
    SELECT 
        SUM(ft.OrderQuantity * pr.ProductPrice) AS total_revenue  -- Calculate total revenue
    FROM 
        FactTable ft
    JOIN 
        AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
),
total_refund AS (
    SELECT 
        SUM(fr.ReturnQuantity * p.ProductPrice) AS TotalRefund
    FROM 
        AdventureWorks_Returns fr
    JOIN 
        AdventureWorks_Products p ON fr.ProductKey = p.ProductKey  -- Adjust the join condition based on your schema
)
SELECT 
    ROUND(
        COALESCE(tr.TotalRefund / NULLIF(trv.total_revenue, 0), 0), 
        2
    ) AS RefundRate
FROM 
    total_revenue trv,
    total_refund tr;


-- Product with Highest Returns

SELECT TOP 1
	pr.ProductName,
	SUM(re.ReturnQuantity) AS total_returned_quantity
FROM
	AdventureWorks_Returns re
JOIN
	AdventureWorks_Products pr ON re.ProductKey = pr.ProductKey
GROUP BY
	pr.ProductName
ORDER BY
	total_returned_quantity DESC;

-- category with Highest Returned Quantity

SELECT TOP 1
    pc.CategoryName,
    SUM(re.ReturnQuantity) AS total_returned_quantity
FROM
    AdventureWorks_Returns re
JOIN
    AdventureWorks_Products pr ON re.ProductKey = pr.ProductKey
JOIN
    AdventureWorks_Product_Subcategories ps ON pr.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN 
    AdventureWorks_Product_Categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY 
    pc.CategoryName
ORDER BY
    total_returned_quantity DESC;

-- Country with Highest returns

SELECT TOP 1
	te.Country,
	SUM(re.ReturnQuantity) AS total_returned_quantity
FROM
	AdventureWorks_Returns re
JOIN
	AdventureWorks_Territories te ON re.TerritoryKey = te.SalesTerritoryKey
GROUP BY
	te.Country
ORDER BY
	total_returned_quantity DESC;
