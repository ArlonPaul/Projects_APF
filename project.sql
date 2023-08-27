/* WELCOME TO MY FIRST SQL PROJECT
This is a beginner project. I am an aspiring data analyst and this is my first project using SQL for data analysis.
I am open for comments and discussions on how to improve this.


BUSINESS PROBLEM
------------------------------------------
A company named Hotwheels is interested in checking their data regarding their model cars to 

1. Check which are the ones in need of restocking and ,
2. How can they use their marketing strategies to garner more reach and interest?

To answer these business questions, let's look at the brief description of each table from their database.
------------------------------------------------------------------------------------------------------------
TABLE DESCRIPTION
-----------------------
CUSTOMERS - customer data
EMPLOYEES - all employee information
OFFICES - sales office information
ORDERS - customers' sales orders
ORDERDETAILS - sales order line for each sales order
PAYMENTS - customers' payment records
PRODUCTS - a list of scale model cars
PRODUCTLINES - types of model cars

To check for the overview for each of the tables, please check the following queries: 
*/

SELECT	'Customers',
		13 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	customers
  
 UNION	ALL 
 
SELECT	'Products',
		9 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	products
  
 UNION	ALL	
 
SELECT	'Productlines',
		4 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	productlines
  
 UNION	ALL	
 
SELECT	'Orders',
		7 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	orders
  
 UNION	ALL	
 
SELECT	'OrderDetails',
		5 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	orderdetails
  
 UNION	ALL	
 
SELECT	'Payments',
		4 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	payments
  
 UNION	ALL	
 
SELECT	'Employees',
		8 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	employees
  
 UNION	ALL	
 
SELECT	'Offices',
		9 AS number_of_attributes,
		COUNT(*) AS number_of_rows
  FROM	offices;
  
/*Which products do we prioritize in ordering more of or less of?  

Let's write a query to determine the top 10 
products that are getting low in stock due to multiple orders*/

SELECT 	o.productCode, 
		ROUND(SUM(o.quantityOrdered)*1.0/
		
		(SELECT	quantityInStock
		   FROM	products AS p
		  WHERE	o.productCode=p.productCode),2) 
		  
		AS low_stock
		
  FROM	orderdetails AS o 
 GROUP	BY o.productCode
 ORDER	BY low_stock DESC
 LIMIT	10;
/*
productCode low_stock
S24_2000	67.67
S12_1099	13.72
S32_4289	7.15
S32_1374	5.7
S72_3212	2.31
S700_3167	1.9
S50_4713	1.65
S18_2795	1.61
S18_2248	1.54
S700_1938	1.22

Now, we will write a query to check the top 10 highest performing products*/

SELECT	productCode,SUM(quantityOrdered*priceEach) AS product_performance
  FROM	orderdetails
 GROUP	BY productCode
 ORDER	BY product_performance DESC
 LIMIT	10;

/*
productCode product_performance
S18_3232	276839.98
S12_1108	190755.86
S10_1949	190017.96
S10_4698	170686.0
S12_1099	161531.48 <---- 1968 Ford Mustang 
S12_3891	152543.02
S18_1662	144959.91
S18_2238	142530.63
S18_1749	140535.6
S12_2823	135767.03

Now, combining those two queries above using CTE(Combined Table Expression) to check which products that are high-performing
but low on stock*/

  WITH 	low_stock_p AS (
SELECT 	o.productCode, 
		ROUND(SUM(o.quantityOrdered)*1.0/
		
		(SELECT	quantityInStock
		   FROM	products AS p
		  WHERE	o.productCode=p.productCode),2) 
		  
		AS low_stock
		
  FROM	orderdetails AS o 
 GROUP	BY o.productCode
 ORDER	BY low_stock DESC
 LIMIT	20),
 
high_perf_p AS (
SELECT	productCode, SUM(quantityOrdered*priceEach) AS product_performance
  FROM	orderdetails
 GROUP	BY productCode
 ORDER	BY product_performance DESC
 LIMIT	20),

low_s_high_p AS ( 
SELECT	l.productCode, l.low_stock, h.product_performance
  FROM	high_perf_p AS h
  JOIN	low_stock_p AS l
	ON	l.productCode = h.productCode)
	

SELECT	p1.productName,lsp.*
  FROM	low_s_high_p AS lsp
  JOIN	products AS p1 
	ON	lsp.productCode = p1.productCode
	
/*
Using the two queries from above as two CTEs, the resulting table shows that the productCode 1968 Ford Mustang (S12_1099)
is the top most model with the highest low stock ratio which needs to be prioritized most in restocking
since it is also ranking 5th at the highest performing models

changing the limit in both CTEs from 10 to 20 will show additional models for consideration, such as 1928 Mercedes-Benz SSK. 

	productName					 productCode		low_stock		product_performance
	1968 Ford Mustang				S12_1099		13.72			161531.48      			<----- TOP PRIORITY FOR RESTOCKING
	1928 Mercedes-Benz SSK			S18_2795		1.61			132275.98
	1969 Ford Falcon				S12_3891		0.92			152543.02      
	1957 Corvette Convertible		S18_4721		0.81			130749.31         
	1958 Setra Bus					S12_1666		0.62			119085.25
*/

/*how should we match marketing and communication strategies to customer behaviors?
First, we write a query selecting customerNumbers with their respective profit generated:
*/

  WITH 	customer_profit AS (
SELECT	o.customerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM	orders AS o
  JOIN	orderdetails AS od
    ON	o.orderNumber = od.orderNumber
  JOIN	products AS p
	ON	od.productCode = p.productCode
 GROUP	BY o.customerNumber),

-- For the top five customers with the highest profit generated 
profit_generated AS(
SELECT	c.contactLastName,c.contactFirstName,c.city,c.country,cp.profit	
  FROM	customers AS c
  JOIN	customer_profit AS cp
	ON	c.customerNumber = cp.customerNumber
 ORDER	BY cp.profit DESC
 )
	
 /*
 TOP 5 CUSTOMERS  
	contactLastName		contactFirstName			city				country				profit
	Freyre				Diego 						Madrid				Spain				326519.66
	Nelson				Susan						San Rafael			USA					236769.39
	Young				Jeff						NYC					USA					72370.09
	Ferguson			Peter						Melbourne			Australia			70311.07
	Labrune				Janine 						Nantes				France				60875.3

  BOTTOM 5 CUSTOMERS -- removing DESC on the ORDER clause
	contactLastName		contactFirstName			city				country				profit
	Young				Mary						Glendale			USA					2610.87
	Taylor				Leslie						Brickhaven			USA					6586.02
	Ricotti				Franco						Milan				Italy				9532.93
	Schmitt				Carine 						Nantes				France				10063.8
	Smith				Thomas 						London				UK					10868.04 

Aside from checking the top customers, we should look into the average profit of the customers per country. 
Look at this query:
*/

SELECT	country,ROUND(SUM(profit)/COUNT(*),2) AS average_profit_per_country, COUNT(*) AS customers_per_country
  FROM	profit_generated
 GROUP	BY country
 ORDER	BY average_profit_per_country DESC
 LIMIT	10
 
 /*
	country					average_profit_per_country		customers_per_country
	Spain						88000.91						5
	Singapore					50891.28						2
	New Zealand					47376.64						4
	Australia					44441.44						5
	Switzerland					43393.75						1
	Denmark						42814.65						2
	Norway						41391.52						1
	Finland						39079.78						3
	USA							37394.73						35
	Austria						36541.4	2						2

These are the top 10 countries with the highest average profit. With Spain at the top with just 5 customers makes it the 
most recommended country to conduct marketing and communication strategies due to the potential profit that it will generate.


-----------------------------------------------------------------------------------------------------------------------------


CONCLUSION:

1. The model 1968 Ford Mustang was the top model in need of restocking.
   Other models for consideration is the 1928 Mercedes-Benz SSK.
   
2. The company should focus on marketing on Spain, Singapore, and New Zealand, since 
   those three countries have the highest average profit with just a few customers.
   Sparking the interest in those countries will generate more profit. 
*/


