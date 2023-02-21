/* Goal is to answer business related questions
   Some things to consider:
   1. Is the data accurate? 
   2. What are the top sellers / What are the worst sellers
   3. What region has the most purchasers
   4. What age group orders the most products
*/ 

--Modifying the tables to change datatypes---

ALTER TABLE ecom.dbo.product 
ALTER COLUMN prices DECIMAL(18,2)
ALTER TABLE ecom.dbo.product 
ALTER COLUMN inventory INT
ALTER TABLE ecom.dbo.orders
ALTER COLUMN total DECIMAL(18,2)
ALTER TABLE ecom.dbo.orders 
ALTER COLUMN created_at DATETIME
ALTER TABLE ecom.dbo.invoices
ALTER COLUMN quantity INT
ALTER TABLE ecom.dbo.users
ALTER COLUMN age DECIMAL(18,2)

--id numbers that start with zero are pulling incorrectly 
--Example: 0035 = 35 
--Created a temp table and testing updates before updating original
SELECT product_id
INTO #temp
FROM ecom.dbo.product

SELECT *
FROM #temp

UPDATE #temp
	SET product_id = CASE
		WHEN LEN(product_id) = 3
		THEN CONCAT('0',product_id)
		WHEN LEN(product_id) = 2
		THEN CONCAT('00',product_id)
		ELSE product_id
		END
DROP TABLE #temp

UPDATE ecom.dbo.product
	SET product_id = CASE
		WHEN LEN(product_id) = 3
		THEN CONCAT('0',product_id)
		WHEN LEN(product_id) = 2
		THEN CONCAT('00',product_id)
		ELSE product_id
		END

UPDATE ecom.dbo.invoices
	SET product_id = CASE
		WHEN LEN(product_id) = 3
		THEN CONCAT('0',product_id)
		WHEN LEN(product_id) = 2
		THEN CONCAT('00',product_id)
		ELSE product_id
		END


--What are the total sales?--
SELECT iv.product_id, iv.quantity, p.names, p.prices, p.prices*iv.quantity AS total_sale
FROM ecom.dbo.invoices AS iv
INNER JOIN ecom.dbo.product AS p
ON iv.product_id = p.product_id

/*If we find the total using the orders table only and then check against the invoices table we see there is a difference.
  It if we assume the ordered quantities are correct it seems that the order totals are not populating correctly
*/

SELECT SUM(os.total)
FROM ecom.dbo.orders AS os

SELECT SUM(p.prices * iv.quantity)
FROM ecom.dbo.invoices AS iv
FULL JOIN ecom.dbo.product AS p
ON iv.product_id = p.product_id

/*We can create a new table that will be account for the correct sales */

CREATE TABLE ecom.dbo.sales (
    invoice_id VARCHAR(50),
    order_id VARCHAR(50),
    order_quantity int,
	price DECIMAL(18,2),
	total_sale DECIMAL(18,2)
);

ALTER TABLE ecom.dbo.sales
ADD product_id VARCHAR(50);



INSERT INTO ecom.dbo.sales (invoice_id,order_id,order_quantity,price,total_sale,product_id)
SELECT iv.invoice_id, iv.order_id, iv.quantity,p.prices, p.prices * iv.quantity, iv.product_id
FROM ecom.dbo.invoices AS iv
INNER JOIN ecom.dbo.product AS P
ON iv.product_id = p.product_id



--check Total Sales: 122749.61--
SELECT SUM(total_sale) as all_sales
FROM ecom.dbo.sales

--What were the top 5 products sold and how many were sold--
--There are 97 products but some have the same name

SELECT TOP 5 p.names, SUM(s.order_quantity) AS total_sold
FROM ecom.dbo.sales AS s
INNER JOIN ecom.dbo.product AS p
ON s.product_id = p.product_id
GROUP BY p.names
ORDER BY total_sold DESC

--What products are worst selling products?
--Revrese order by
SELECT TOP 5 p.names, SUM(s.order_quantity) AS total_sold
FROM ecom.dbo.sales AS s
INNER JOIN ecom.dbo.product AS p
ON s.product_id = p.product_id
GROUP BY p.names
ORDER BY total_sold ASC

--What region has the highest sales-- 
----Mid Atlantic--
SELECT u.region, SUM(s.total_sale) as total_sales, AVG(s.total_sale) as avg_sale
FROM ecom.dbo.users AS u
INNER JOIN ecom.dbo.orders as os
ON u.user_id = os.user_id
INNER JOIN ecom.dbo.sales as s
ON os.order_id = s.order_id
GROUP BY u.region
ORDER BY total_sales DESC

-- What are the sales by region for users under 40

SELECT u.region, SUM(CASE WHEN u.age < 40 THEN s.total_sale ELSE 0 END) AS sale_under_40,
AVG(CASE WHEN u.age < 40 THEN s.total_sale ELSE 0 END) AS avgsale_under_40
FROM ecom.dbo.users AS u
INNER JOIN ecom.dbo.orders as os
ON u.user_id = os.user_id
INNER JOIN ecom.dbo.sales as s
ON os.order_id = s.order_id
GROUP BY u.region

--sales by customer age segment
SELECT u.region,
SUM(CASE WHEN u.age < 20 THEN s.total_sale ELSE 0 END) AS sale_under_20,
SUM(CASE WHEN u.age < 30 and u.age > 20 THEN s.total_sale ELSE 0 END) AS sale_under_30,
SUM(CASE WHEN u.age < 40 and u.age > 30 THEN s.total_sale ELSE 0 END) AS sale_under_40,
SUM(CASE WHEN u.age < 50 and u.age > 40 THEN s.total_sale ELSE 0 END) AS sale_under_50,
SUM(CASE WHEN u.age > 50 THEN s.total_sale ELSE 0 END) AS sale_over_50
FROM ecom.dbo.users AS u
INNER JOIN ecom.dbo.orders as os
ON u.user_id = os.user_id
INNER JOIN ecom.dbo.sales as s
ON os.order_id = s.order_id
GROUP BY u.region



