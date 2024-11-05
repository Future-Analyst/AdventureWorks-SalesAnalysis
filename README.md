


# Comprehensive Sales and Return Analysis for Adventure Works: A Data-Driven Approach to Profitability and Performance

Dashboard Link:  https://app.powerbi.com/groups/me/reports/b530045b-4ac7-48d6-939b-3d1102713a10/7cc6786e16b229aa3a47?experience=power-bi&bookmarkGuid=2fc0cb5e3909bc709d98

## Problem Statement

The Power BI report is designed to analyse the sales and returns data for Adventure Works products, providing insights into revenue generation, customer transactions, and the impact of product returns on profitability. The report leverages a comprehensive dataset including product details, sales territories, and customer demographics to address the following key objectives:  

### Sales Performance Evaluation:  
•	Assess overall revenue, total transactions, and quantity sold across various product categories, subcategories, and individual products.

•	Identify top-performing products and product categories based on total quantity sold and profit margins.

### Return Analysis:
•	Examine returned products and their impact on the business through metrics such as total returned quantity, total refund amounts, and the return transaction rate.

•	Highlight the products, categories, and territories with the highest return rates, allowing for targeted insights into areas of improvement.

### Profitability and Cost Management:

•	Evaluate the total cost of goods sold (COGS) and the resulting profit margins, focusing on high-revenue and high-margin products.

•	Analyze product profitability by key attributes such as product color and category, helping identify trends in profitable product features.

### KPI Tracking:

•	Key metrics such as total revenue, total transactions, profit margin, and return rates are tracked and visualized to monitor overall business performance.

•	Comparative analysis is conducted to determine the best-selling products and those with the highest return rates, providing actionable insights for improving sales and reducing returns.



### Steps followed for the first Report (Detailed View) 


-	Step 1 : Load all data into Power BI Desktop, dataset is a csv file.
-	Step 2 : Open power query editor & in view tab under Data preview section, check "column distribution", "column quality" & "column profile" options.
-	Step 3 : Also since by default, profile will be opened only for 1000 rows so you need to select "column profiling based on entire dataset".
-	Step 4 : It was observed that in none of the columns errors & empty values were present.
-	Step 5: Creating Data Model by creating star schema and snownflask relationship.

![data model img](https://github.com/user-attachments/assets/7b112bf8-76b7-403d-87bd-7c5842a1a13a)

•	Step 6: Creating a Dynamic Calendar Table Using DAX.

![Date Table DAX img](https://github.com/user-attachments/assets/fadc6eaf-bd41-4b75-b4db-ff4de6d941a1)

•	Step 7: Customer Segmentation using calculated columns

![customer segmentation img](https://github.com/user-attachments/assets/bccbfbfc-8e56-47f1-b397-29ef327ad399)

•	Step 8: Creating Our dashboard Layout in Microsoft PowerPoint and Uploading into PowerBI

•	Step 9: Designing Dynamic KPI’s  for Total Revenue which shows us both previous month Revenue , Target and Percentage Increase or Decrease of Targeted Revenue.

The following DAX expression was written:

        SUMX(
        FactTable,
        FactTable[OrderQuantity] * RELATED(Dim_Products[ProductPrice])
        )

A card visual used to represent Total Revenue 

![Total Revenue KPI img](https://github.com/user-attachments/assets/a95fdc76-696f-48d2-bfa5-459e5923890b)

•	Step10: Designing Dynamic KPI’s  for Total Transaction which shows us both previous month Revenue , Target and Percentage Increase or Decrease of Targeted Transaction.

The following DAX expression was written:

        # Transaction = COUNTROWS(FactTable)

A card visual used to represent Total Transaction  

![Total Transaction KPI img](https://github.com/user-attachments/assets/5e070b71-5be5-4bda-a109-7cc8dc323eac)

•	Step11: Designing Dynamic KPI’s  for Total Quantity which shows us both previous month Revenue , Target and Percentage Increase or Decrease of Targeted Quantity.

The following DAX expression was written:

        Total Qty sold = SUM(FactTable[OrderQuantity])

A card visual used to represent Total Quantity ordered

![Total Qunatity KPi img](https://github.com/user-attachments/assets/01cb5a2c-bb91-439b-8229-8120d7cc41f1)

##   Secondary KPI’s in the Detailed View Dashboard Using SQL

###     -- Highest Ordered Product

        SELECT TOP 1  
                        pr. ProductName,
                        SUM(OrderQuantity) AS total_quantity_ordered
        FROM
                        FactTable ft
        JOIN
                        AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
        GROUP BY
                        pr.ProductName
        ORDER BY
                        total_quantity_ordered DESC;


![Highest Product oredered sql img](https://github.com/user-attachments/assets/bef96995-1876-4643-b6cd-51daf0535141)

### ----- Product with Highest Profit

        SELECT TOP 1
                pr.ProductName,
                ROUND(SUM(ft.OrderQuantity * pr.ProductPrice),0) -                 ROUND(SUM(ft.OrderQuantity * pr.ProductCost),0) AS profit_margin
        FROM
                FactTable ft
        JOIN
                        AdventureWorks_Products pr ON ft.ProductKey = pr.ProductKey
        GROUP BY
                        pr.ProductName
        ORDER BY
                        profit_margin DESC;

![Highest Profitable Product](https://github.com/user-attachments/assets/bbc80945-d0c8-4dbd-921d-158811dc05c0)

## Snapshot of Detailed view Dashboard (Power BI Service)
![Publishing snapshot](https://github.com/user-attachments/assets/9d0839c6-47fb-48e7-8462-78975c84aa3d)

![Details View img](https://github.com/user-attachments/assets/da1a8cc4-e4b2-480b-a734-3ef7519b7d6d)

### Primary KPI’s in the Returned Dashboard

•	Create a KPI visual that Calculate the Total Returned Transaction and Percentage of Returned Transaction over the overall Transaction:

The following measure was written

        Returned Transaction =  
        COUNTROWS(FactTable_Returns)

![Total Returned Transaction KPI](https://github.com/user-attachments/assets/392c86ba-2a99-4fdf-a8d0-cbcbf03ac399)

•	Create a KPI visual that Calculate the Total Returned Quanity and Percentage of Returned Quantity over the overall Quantity:

The following measure was written:

        Total returned  Qty = 
        SUM(FactTable_Returns[ReturnQuantity])

![Total Returned Quantity KPI](https://github.com/user-attachments/assets/d07b7d82-bf98-432a-bbd2-6c669398cadf)

•	Create a KPI visual that Calculate the Total Returned Refund and Percentage of Returned Refund over the overall Refund:

The following measure was written:

        Transaction Refund = 
        VAR _refund = 
        SUMX(FactTable_Returns,
        FactTable_Returns[ReturnQuantity] * RELATED(Dim_Products[ProductPrice]))
        RETURN
        IF(_refund<>BLANK(),_refund,0)

![Returned Refund KPI img](https://github.com/user-attachments/assets/4ebd76f2-4517-4e11-b1f5-33195e6c1e5c)

## Secondary KPI’s in Returned Dashboard Using SQL

###     -- Product with Highest Returns

        SELECT TOP 1
                pr. ProductName,
                SUM(re.ReturnQuantity) AS total_returned_quantity
        FROM
                AdventureWorks_Returns re
        JOIN
                AdventureWorks_Products pr ON re.ProductKey = pr.ProductKey
        GROUP BY
                pr.ProductName
        ORDER BY
                total_returned_quantity DESC;

![Product with Highest Returns KPI](https://github.com/user-attachments/assets/556fce02-55a1-4304-9849-220df5cc179d)

### -- category with Highest Returned Quantity

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


![category with Highest returned Quantity KPI](https://github.com/user-attachments/assets/ac1a9465-c29c-4c6d-987c-08c53220c7cb)

###     -- Country with Highest returns

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

![Country with highest Returns](https://github.com/user-attachments/assets/a1ea1cc7-ea34-4f89-9487-0aa38b4cfdcb)

## Snapshot of Returned View Report Visual (Power BI Service)

Link: https://app.powerbi.com/groups/me/reports/b530045b-4ac7-48d6-939b-3d1102713a10/6cf1c8b0a891ee9c4e37?experience=power-bi&bookmarkGuid=2fc0cb5e3909bc709d98

![Returned View img](https://github.com/user-attachments/assets/e5d36735-522a-4e2c-a428-736bd7dc27b6)

## Snapshot of Forecast View Report (Power BI Service)

We created a visual report in Power BI for forecasting concrete using various parameters, which is displayed below;
Link: https://app.powerbi.com/groups/me/reports/b530045b-4ac7-48d6-939b-3d1102713a10/3f14c99b62c003830bce?experience=power-bi&bookmarkGuid=2fc0cb5e3909bc709d98

![Forecast View img](https://github.com/user-attachments/assets/218f0468-4d60-488f-8181-cfc1321b33c9)


### WhAT-IF 1 ANALYSIS: We design three parameter CHANGE COST, UNIT ORDER CHANGE and POST CHANGE. 
This helps do more forecasting for us , by shifting the parameter slide to any unit we want and there will be a prediction of COST OF GOODS, REVENUE  and % PROFIT  In comparison to the original values.

Link: https://app.powerbi.com/groups/me/reports/b530045b-4ac7-48d6-939b-3d1102713a10/005ae4eacba65850403a?experience=power-bi&bookmarkGuid=2fc0cb5e3909bc709d98

## Snapshot of WHAT-IF 1 View Report (Power BI Service)
This allows us to enhance our forecasting by adjusting the parameter slider to any desired unit, providing predictions for the cost of goods, revenue, and profit percentage in comparison to the original values

![WHAT-IF view img](https://github.com/user-attachments/assets/344ca064-2418-4ea0-92d0-6ed91773da19)

#### WhAT-IF 2 ANALYSIS: We design three parameter CHANGE COST, UNIT ORDER CHANGE and POST CHANGE. 
This Forecast Dashboard also give predictive insight by adjusting any of the design parameters CHANGE COST, UNIT ORDER CHANGE and PRICE CHANGE. This change parameter when adjusted in the slide will result to an insight in the Top – 5 Profits by Old and New Products and also a Line chart showing the Old profit vs New Profit.

link: https://app.powerbi.com/groups/me/reports/b530045b-4ac7-48d6-939b-3d1102713a10/a186d05249c0f0c51eb2?experience=power-bi&bookmarkGuid=2fc0cb5e3909bc709d98

## Snapshot of WHAT-IF 2 View Report (Power BI Service)

![WHAT-IF 2 view img](https://github.com/user-attachments/assets/517fb9d0-fb05-46f3-bb72-fa1f52b0c4c3)

## Snapshot of TOOLTIPS VISUAL (Power BI Service)
![merged Tooltips](https://github.com/user-attachments/assets/584f0340-9dc5-4f79-8fdd-10d9cc8e0137)


### SUMMARY INSIGHT
-        Revenue and Profitability: The total revenue, total cost, and profit margin are calculated to evaluate business performance. Profit margins can be broken down by product, product category, and product color, identifying the most profitable products and categories.

-        Product Performance: The queries identify the best-selling products and most profitable ones. They also highlight the top 3 product categories with the highest profits, helping businesses focus on high-demand and high-margin items.

-        Return and Refund Analysis: Return-related metrics, including total returns, return rates, and refund rates, provide insights into customer dissatisfaction or product quality issues. Specific queries identify products and categories with the highest return quantities, enabling targeted improvements.

-        Market and Customer Insights: The analysis covers the total number of transactions, the best-selling products, and the countries or regions with the highest return rates. This information aids in market segmentation and strategic decision-making for targeted marketing and operational improvements.

Overall, these insights guide inventory management, marketing strategies, customer experience improvements, and profit optimization.
A two-page report, single forecast report and two WHAT-IF report was created on Power BI Desktop & it was then published to Power BI Service.
Following inferences can be drawn from the dashboard;

        a)	Total Revenue >>> $1.83M
        b)	Total Transaction >>> 5430
        c)	Total Quantity Solid >>> 8260
        d)	Total Revenue >>> $ 1.83M
        e)	Total Transaction >>> 5430
        f)	Total Quantity Solid >>> 8260

        Insight on Profit Margin by Product
        a)	Gross Profit (Bikes) >>> $9.7M
        b)	Gross Profit (Accessories) >>> $0.6M
        c)	Gross Profit (Clothing) >>> $0.2M

## Top 10 Best Selling Products

![10 Best Selling Product](https://github.com/user-attachments/assets/ea96e35b-5f87-4b3c-90e1-121808de8573)

## Returned Dashboard Summary Insight

        •	Total Returned Transaction >>>> 1809 (3.23% of 56.046 overall transaction were returned)
        •	Returned Quantity >>>> 1828 (2.17% of 1828 ordered quantity were returned by customers)
        •	Returned Refund >>>> $765k (3.07% of 1828 ordered quantity were refunded to customers).
        •	Product with Highest Returns >>>> water Bottle 30 oz.
        •	Product with highest Returns >>>> Accessories 1130
        •	Country with highest returns >>>> United State 633
