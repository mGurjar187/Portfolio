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

SELECT * from product_sales WHERE model = 'Bat' ORDER BY sales_transaction_date;

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

-- Activity 19 Analyzing the Difference in Sales Price Hypothesis