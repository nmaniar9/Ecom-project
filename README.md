# Ecom-project
Created a sample database and explored the data in SQL Server

Goal: Create a sample relational database to explore using SQL and Tableau

Step 1: Create tables for database:
    
 Tables:
  1.Product
    a. product_id - unique 4 digit id created using random digits 
    b. names - product names scrapped from Lego website using Beautiful Soup library
    c. prices - product prics scrapped from Lego website using Beautiful Soup library
    d. inventory - created using a normal distribution with the mean of 35 units, represents on hand quantity
  2.Users
    a. user_id - unique random user ids 
    b. region - location of users:'Pacific','Mountain','South Atlantic','West South Central','East South Central','Mid Atlantic','New England','East North Central','West                                    North Central'
    c. age - age of the user, created using a normal distribution with 28 as the mean
  3.Order
    a.order_id - unique random order ids
    b.user_id - assigned using a random choice function from the users table
    c.total - random total of the order placed, created using a normal distribution with mean 85
    d.created_at - when the order was places, created using datetime
  4.Invoices (Ordered)
    a.invoice_id (ordered_id) - unique random id for each item within an order
    b.order_id - assigned using random choice from the order table
    c.product_id - what product was ordered, assigned using random choice from the product table
    d.quantity - how many of each product_id were ordered

Step 2: Download data to csv and upload to Microsoft SQL Server Management Studio

Step 3: Investigate tables using SQL, Altered tables and answered business related questions

