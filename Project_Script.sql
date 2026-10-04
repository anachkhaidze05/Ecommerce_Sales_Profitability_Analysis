
----------------------------------------------------------------------------
/* E-COMMERCE DATA ANALYSIS SCRIPT
   Analysis of Sales Performance, Profitability, 
   Customer Behavior, Discount Impact, and Product Returns */
----------------------------------------------------------------------------

CREATE TABLE Customers(
    CustomerID NVARCHAR(10) primary key,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Country NVARCHAR(50),
    JoinDate DATE);

BULK INSERT dbo.Customers
FROM 'D:\Project\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK);

CREATE TABLE Products(
    ProductID NVARCHAR(10) primary key,
    ProductName NVARCHAR(50),
    Category NVARCHAR(50),
    SubCategory NVARCHAR(50),
    UnitCost numeric(8, 2));

BULK INSERT dbo.Products
FROM 'D:\Project\Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK);

CREATE TABLE Orders(
    OrderID NVARCHAR(10) primary key,
    CustomerID NVARCHAR(50),
    OrderDate Date,
    country nvarchar(50));

BULK INSERT dbo.Orders
FROM 'D:\Project\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK);

CREATE TABLE OrderItems(
    OrderItem NVARCHAR(50) PRIMARY KEY,
    OrderID NVARCHAR(50),  
    ProductID NVARCHAR(50),
    Quantity int,            
    UnitPrice numeric(8, 2),
    Discount numeric(5, 2));

BULK INSERT dbo.OrderItems
FROM 'D:\Project\OrderItems.csv' 
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK);

CREATE TABLE Returns(
    ReturnID NVARCHAR(50) primary key,
    OrderID NVARCHAR(50),
    ProductID NVARCHAR(50),
    ReturnDate Date,
    ReturnReason nvarchar(50));

BULK INSERT dbo.Returns
FROM 'D:\Project\Returns.csv'
WITH (
    FIRSTROW = 2,
    FieldTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK);


-------------------------------------------
-- SECTION 1: SALES & REVENUE PERFORMANCE
-------------------------------------------

-- 1. Total Revenue and Total Units Sold
Select
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue,
	Sum(OrderItems.Quantity) as Units_Sold
from OrderItems

-- 2. Monthly Revenue Trend Analysis
Select
	Year(Orders.OrderDate) as Year,
	Datename(Month, Orders.OrderDate) as Month,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue
From Orders
Join OrderItems
	On Orders.OrderID = OrderItems.OrderID
Group by 
	Year(Orders.OrderDate),
	Datename(Month, Orders.OrderDate)
Order by 
	Year,
	Month;

-- 3. Market Performance: Revenue and Total Orders by Country
Select
	Orders.country,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue,
	Count(distinct OrderS.OrderID) as Total_Orders
From Orders
Join OrderItems
	On Orders.OrderID = OrderItems.OrderID
Group by Orders.country
Order by Total_Orders Desc;

-- 4. Product Performance: Revenue by Category and Subcategory 
Select
	Products.Category,
	Products.SubCategory,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue
From Products
Join OrderItems
	On Products.ProductID = OrderItems.ProductID
Group by 
	Products.Category,
	Products.SubCategory
Order by Revenue Desc;

-- 5. Top 15 Products By Revenue
Select top 15
	Products.ProductName,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue
From Products
Join OrderItems
	On Products.ProductID = OrderItems.ProductID
Group by Products.ProductName
Order by Revenue Desc;


-----------------------------------------------------
-- SECTION 2: Profitability And Product Performance
-----------------------------------------------------

-- 1. Overall Business Profitability
Select
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount) 
		- OrderItems.Quantity * Products.UnitCost) as Profit
From OrderItems
Join Products
	On OrderItems.ProductID = Products.ProductID;

-- 2. Profitability Breakdown by Product Category
Select
	Products.Category,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount) 
		- OrderItems.Quantity * Products.UnitCost) as Profit
From Products
Join OrderItems
	On Products.ProductID = OrderItems.ProductID
Group by Products.Category
Order by Profit Desc;

-- 3. Top 15 Most Profitable Products
Select top 15
	Products.ProductName,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount) 
		- OrderItems.Quantity * Products.UnitCost) as Profit
From Products
Join OrderItems
	On Products.ProductID = OrderItems.ProductID
Group by Products.ProductName
Order by Profit Desc;


----------------------------------------------------
-- SECTION 3: CUSTOMER ANALYSIS & DISCount IMPACT
----------------------------------------------------

-- 1. Customer Geographic Distribution (Customer Count by Country)
Select 
	Customers.Country,
	Count(distinct Customers.CustomerID) as Total_Customers
From Customers
Group by Customers.Country
Order by Total_Customers Desc;

-- 2. Total Revenue Contribution by Customer Country
Select
	Customers.Country,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue
From Customers
Join Orders
	On Customers.CustomerID = Orders.CustomerID
Join OrderItems
	On Orders.OrderID = OrderItems.OrderID
Group by Customers.Country
Order by Revenue Desc;

-- 3. Top 15 High-Value Customers by Revenue Contribution
Select top 15
	Customers.CustomerID,
	Customers.FirstName,
	Customers.LastName,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue
From Customers
Join Orders
	On Customers.CustomerID = Orders.CustomerID
Join OrderItems
	On Orders.OrderID = OrderItems.OrderID
Group by
	Customers.CustomerID,
	Customers.FirstName,
	Customers.LastName
Order by Revenue Desc;

-- 4. Top 15 Most Demanded Products by Total Units Sold
Select top 15
	Products.ProductID,
	Products.ProductName,
	Sum(OrderItems.Quantity) Total_Units
From Products
Join OrderItems
	On Products.ProductID = OrderItems.ProductID
Group by 
	Products.ProductID,
	Products.ProductName
Order by Total_Units Desc;

-- 5. Discount Impact on Revenue and Profitability
Select top 15
	OrderItems.Discount,
	Sum(OrderItems.Quantity) as Unit_Sold,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount)) as Revenue,
	Sum(OrderItems.Quantity * OrderItems.UnitPrice * (1 - OrderItems.Discount) 
		- OrderItems.Quantity * Products.UnitCost) as Profit
From OrderItems
Join Products
	On OrderItems.ProductID = Products.ProductID
Group by OrderItems.Discount
Order by Profit Desc;


---------------------------------------------
-- SECTION 4: PRODUCT RETURNS & OPERATIONS
---------------------------------------------

-- 1. Top 15 Most Frequently Returned Products
Select top 15
	Products.ProductID,
	Products.ProductName,
	Count(distinct Returns.ReturnID) Returned
From Products
Join Returns
	On Products.ProductID = Returns.ProductID
Group by 
	Products.ProductID,
	Products.ProductName
Order by Returned Desc;

-- 2. Breakdown of Order Returns By Country
Select 
	Orders.country,
	Count(distinct Returns.ReturnID) Returned
From ORDERS
Join Returns
	On ORDERS.OrderID = Returns.OrderID
Group by Orders.country
Order by Returned Desc;

-- 3. Primary Return Reasons
Select
	Returns.ReturnReason,
	Count(Returns.ReturnReason) as Top_Reasons
From Returns
Group by Returns.ReturnReason
Order by Top_Reasons Desc;

-- 4. Monthly Trend of Order Returns
Select
	Year(Returns.ReturnDate) as Year,
	Datename(Month, Returns.ReturnDate) as Month,
	Count(Returns.ReturnDate) as Monthly_Returns
From Returns
Group by 
	Year(Returns.ReturnDate),
	Datename(Month, Returns.ReturnDate)
Order by
	Year,
	Month;