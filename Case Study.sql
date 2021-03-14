-- Case Study: Why did the sales drop by 20% after two weeks? 

-- Exercise 34 Preliminary data collection using SQL techniques

-- 1. List model, base_msrp, production start date of all scooters in products.

SELECT
	model,
	base_msrp,
	production_start_date
FROM products
WHERE product_type = 'scooter';

-- 2. Get model and product id of scooters get sales info of this scooters

SELECT 
	model,
	product_id
FROM products
WHERE product_type = 'scooter';

-- 3. Insert the above result into table product_names

SELECT 
	model,
	product_id
INTO product_names
FROM products
WHERE product_type = 'scooter';


-- Exercise 35 Extract Sales Information

-- 1. Use join on product names and sales tables to extract information

SELECT
	p.model,
	s.customer_id,
	s.sales_transaction_date,
	s.sales_amount,
	s.channel,
	s.dealership_id
INTO product_sales
FROM product_names p
INNER JOIN sales s
ON p.product_id = s.product_id;

-- 2. Looking at the first 5 rows of product_sales table.

SELECT * FROM product_sales LIMIT 5;

-- 3. Extract all the info for Bat scooter and order by sales transaction date.

SELECT * INTO bat_sales 
from product_sales
WHERE model = 'Bat' 
ORDER BY sales_transaction_date;

-- 4. Count the no. of records available for above query

SELECT COUNT(model) from product_sales WHERE model = 'Bat';

-- We have 7328 sales beginning from 10th October 2016.

-- 5. Find the last sale date of the scooter.

SELECT MAX(sales_transaction_date) FROM product_sales WHERE model = 'Bat';

-- Last sale occured on 31st May 2019.

-- 6. Create a new table bat_sales_daily with daily sales count of Bat Scooter

SELECT 
	sales_transaction_date::DATE,
	COUNT(model)
INTO bat_sales_daily
FROM product_sales
WHERE model = 'Bat'
GROUP BY 1
ORDER BY 1;

-- 7. Examine first 3 weeks(approx 22 days) of the newly created table

SELECT * FROM bat_sales_daily LIMIT 22;

-- We see drop in sales from 20th October

-- Activity 18 Quantify the sales drop

-- 1. Compute daily commulative sales and put into bat_sales_growth

SELECT
	*, SUM(count) OVER (ORDER BY sales_transaction_date)
INTO bat_sales_growth
FROM bat_sales_daily;

-- 2. Find 7 day delay of the sum column and insert into new delay table.

SELECT 
	*, LAG(sum, 7) OVER (ORDER BY sales_transaction_date)
INTO bat_sales_daily_delay
FROM bat_sales_growth;

-- 3. Inspect the first 15 rows of the new table

SELECT * FROM bat_sales_daily_delay LIMIT 15;

-- 4. Compute sales growth as a percentage from current sales and sales 1 week prior

SELECT 
	*, (sum-lag)/lag AS volume
INTO bat_sales_delay_vol 
FROM bat_sales_daily_delay;

-- 5. Inspect first 3 weeks from new created table

SELECT * FROM bat_sales_delay_vol LIMIT 22;

-- Exericse 36 Launch Time Analysis

-- 1. Examine products table

SELECT * FROM products;

-- 2. List only scooters from the products table

SELECT * FROM products WHERE product_type = 'scooter'; 

-- 3. List first 5 customers from sales table

SELECT * FROM sales LIMIT 5;

-- 4. Extract model and sales transaction date for Bat Limited Edition

SELECT 
	model,
	sales_transaction_date
INTO bat_ltd_sales
FROM products p
JOIN sales s 
ON p.product_id = s.product_id
WHERE model = 'Bat Limited Edition'
ORDER BY 2;

-- 5. Select first 5 lines of new table

SELECT * FROM bat_ltd_sales LIMIT 5;

-- 6. Check the total sales for Bat Limited Edition

SELECT COUNT(model) FROM bat_ltd_sales;

-- 7. Fetch the transaction detail of last scooter sold.

SELECT MAX(sales_transaction_date) FROM bat_ltd_sales;

-- 8. Adjust the above table to cast the timestamp column to date.

ALTER TABLE bat_ltd_sales
ALTER COLUMN sales_transaction_date TYPE DATE;

-- 9. Again, Select first 5 lines of new table

SELECT * FROM bat_ltd_sales LIMIT 5;

-- 10. Count the sales on daily basis

SELECT 
	sales_transaction_date,
	COUNT(sales_transaction_date)
INTO bat_ltd_sales_count
FROM bat_ltd_sales
GROUP BY 1
ORDER BY 1;

-- 11. Compute cummulative sum of daily sales

SELECT 
	*, SUM(count) OVER (ORDER BY sales_transaction_date)
INTO bat_ltd_sales_growth
FROM bat_ltd_sales_count;

-- 12. Select the first 22 days from the above table

SELECT * FROM bat_ltd_sales_growth LIMIT 22;

-- 13. Compare the sales records of original Bat Scooter

SELECT * FROM bat_sales_growth LIMIT 22;

-- 14. Compute the 7 day lag function for sum column

SELECT *, LAG(sum, 7) OVER (ORDER BY sum)
INTO bat_ltd_sales_delay
FROM bat_ltd_sales_growth;

-- 15. Compute the sales growth volume

SELECT *, (sum-lag)/lag AS volume
INTO bat_ltd_sales_vol
FROM bat_ltd_sales_delay;

-- 16. List first 22 records of the new table

SELECT * FROM bat_ltd_sales_vol LIMIT 22;

-- Activity 19 Analyze difference in Sales Price Hypothesis

-- 1. List all the sales transaction dates for Lemon scooter for 2013

SELECT 
	sales_transaction_date 
INTO lemon_sales
FROM sales 
WHERE product_id = (
	SELECT product_id FROM products WHERE model = 'Lemon' AND year = 2013);
	
-- 2. Count the sales records for above table.

SELECT COUNT(sales_transaction_date) FROM lemon_sales;

-- 3. Latest sales transaction date

SELECT MAX(sales_transaction_date) FROM lemon_sales;

-- 4. Convert sales_transaction_date to Date Type

ALTER TABLE lemon_sales
ALTER COLUMN sales_transaction_date TYPE DATE;

-- 5. Count the no. of sales per day

SELECT
	sales_transaction_date,
	COUNT(sales_transaction_date)
INTO lemon_sales_count
FROM lemon_sales
GROUP BY 1
ORDER BY 1;

-- 6. Calculative the commulative sum OF count

SELECT 
	*, SUM(count) OVER (ORDER BY sales_transaction_date)
INTO lemon_sales_sum
FROM lemon_sales_count;

-- 7. Compute 7 day lag function on sum

SELECT 
	*, LAG(sum, 7) OVER (ORDER BY sales_transaction_date)
INTO lemon_sales_delay
FROM lemon_sales_sum;

-- 8. Calculate growth rate

SELECT 
	*, (sum-lag)/lag AS volume
INTO lemon_sales_growth
FROM lemon_sales_delay;

-- 9. Inspect first 22 records of the above table

SELECT * FROM lemon_sales_growth LIMIT 22;

-- Exercise 37 Analyzing sales growth by Email opening rate

-- 1. Let's have a look at the email table

SELECT * FROM emails LIMIT 5;

-- 2. Extract email sent information for customers who purchased Bat scooter

SELECT 
	e.email_subject,
	e.customer_id,
	e.opened,
	e.sent_date,
	e.opened_date, 
	s.sales_transaction_date
INTO bat_emails
FROM emails e
INNER JOIN bat_sales s
ON e.customer_id = s.customer_id
ORDER BY s.sales_transaction_date;

-- 3. Inspect first 10 rows of the above table

SELECT * FROM bat_emails LIMIT 10;

-- 4. Extract emails which were sent to before sales_transaction_date

SELECT * FROM bat_emails
WHERE sent_date < sales_transaction_date
ORDER BY customer_id LIMIT 22;

-- 5. Delete emails which were sent 6 months prior to production

DELETE FROM bat_emails
WHERE sent_date < '2016-04-10';

-- 6. Delete emails where sent date is after purchase date

DELETE FROM bat_emails 
WHERE sent_date > sales_transaction_date;

-- 7. Delete emails where difference bw transaction date and sent date exceeds 30

DELETE FROM bat_emails 
WHERE (sales_transaction_date - sent_date) > '30 days'; 

-- 8. EXAMINE FIRST 22 rows of above table

SELECT * FROM bat_emails ORDER BY customer_id LIMIT 22;

-- 9. List distict email subjects

SELECT DISTINCT(email_subject) FROM bat_emails;

-- 10. Delete records with Black friday in subject

DELETE FROM bat_emails 
WHERE position('Black Friday' in email_subject) > 0;

-- 11. Delete all other irrelevant subject records

DELETE FROM bat_emails 
WHERE position('25% of all EV' in email_subject) > 0;

DELETE FROM bat_emails 
WHERE position('Some New EV' in email_subject) > 0;

-- 12. Count the number of rows left now

SELECT COUNT(sales_transaction_date) FROM bat_emails;

-- 13. Count the emails that were opened

SELECT COUNT(opened) FROM bat_emails WHERE opened = 't';

-- 14. Count the no. of customers who opened emails and made purchase

SELECT COUNT(DISTINCT(customer_id)) FROM bat_emails;

-- 15. Count the unique customers who made a purchase

SELECT COUNT(DISTINCT(customer_id)) FROM bat_sales;

-- 16. Calaculate percentage of customers who made purchase after receiving email

SELECT 396.0/6659.0 AS email_rate;

-- 17. Limit the scope of our analysis for three weeks only

SELECT * INTO bat_emails_threewks
FROM bat_emails 
WHERE sales_transaction_date < '2016-11-01';

-- 18 Count the emails opened during this period

SELECT COUNT(opened) FROM bat_emails_threewks;

-- 19. Count the emails open is true

SELECT COUNT(opened) FROM bat_emails_threewks WHERE opened = 't';

-- 20. Count unique customers who made purchase in first three weeks

SELECT COUNT(DISTINCT(customer_id)) FROM bat_emails_threewks;

-- 21. Calculate the percentage of customers who bought after opening emails

SELECT 15.0/82 AS sale_rate;

-- 22. Count unique customers who made purchase in first 3 weeks

SELECT COUNT(DISTINCT(customer_id)) 
FROM bat_sales 
WHERE sales_transaction_date < '2016-11-01';

-- Exercise 38 Analyze Email Marketing Campaign

-- 1. Drop the lemon_sales table

DROP TABLE lemon_sales;

-- 2. Extracting Lemon Scooter 2013 sales info 

SELECT customer_id, sales_transaction_date
INTO lemon_sales
FROM sales WHERE product_id = 3;

-- 3. Select info from emails for customers who purchased Lemon Scooter 2013

SELECT
	e.customer_id,
	e.email_subject,
	e.opened,
	e.sent_date,
	e.opened_date,
	ls.sales_transaction_date
INTO lemon_emails
FROM emails e
INNER JOIN lemon_sales ls
ON e.customer_id = ls.customer_id;

-- 4. Fetch the production date of Lemon Scooter 2013

SELECT production_start_date FROM products WHERE product_id = 3;

-- 5. Delete all emails sent before production date

DELETE FROM lemon_emails
WHERE sent_date < '2013-05-01';

-- 6. Remove all records where send date occured after sales

DELETE FROM lemon_emails
WHERE sent_date > sales_transaction_date;

-- 7. Remove all records where sent date occured than 30 days before sales

DELETE FROM lemon_emails
WHERE (sales_transaction_date - sent_date) > '30 days';

-- 8. Find all distinct email subjects

SELECT DISTINCT email_subject FROM lemon_emails;

-- 9. Delete email which are not related to Lemon Scooter

DELETE FROM lemon_emails
WHERE POSITION('25% off all EVs.' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('Like a Bat out of Heaven' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('Save the Planet' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('An Electric Car' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('We cut you a deal' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('Black Friday. Green Cars' in email_subject)> 0;

DELETE FROM lemon_emails
WHERE POSITION('Zoom' in email_subject)> 0;

-- 9. Check no. of emails were opened

SELECT COUNT(opened) FROM lemon_emails WHERE opened = 't';

-- 10. List the customers who received emails and made purchase

SELECT COUNT(DISTINCT(customer_id)) FROM lemon_emails;

-- 11. Calculate percentage of customers who opened the received emails and made a purchase

SELECT 128.0/506.0 AS email_rate;

-- 12. Find the no. of unique customers who made a purchase

SELECT COUNT(DISTINCT(customer_id)) FROM lemon_sales;

-- 13. Calculate percentage of customers who made purchase having received an email

SELECT 506.0/13854.0 AS email_sales;

-- 14. Select all records for which sale record in first 3 weeks

SELECT * INTO lemon_sales_threewks
FROM lemon_emails
WHERE sales_transaction_date < '2013-01-06';

-- 15. Count the no. of emails sent in first three weeks

SELECT COUNT(sales_transaction_date) FROM lemon_sales_threewks;


