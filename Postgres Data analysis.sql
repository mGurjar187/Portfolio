-- Query to find number of sales in each month.

SELECT 
	DATE_TRUNC('month', sales_transaction_date) month_date,
	count(1) number_of_sales
FROM sales
WHERE EXTRACT(YEAR FROM sales_transaction_date) = 2018
GROUP BY 1
ORDER BY 1;

-- Query to find number of new customers added each month

SELECT 
	DATE_TRUNC('month', date_added) month_date,
	count(1) number_of_new_customers
FROM customers
WHERE EXTRACT(YEAR FROM date_added) = 2018
GROUP BY 1
ORDER BY 1;

-- Installing packages to find distance between location points

CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

-- Exercise #23
-- 1. Create a Temp Table with location point for each customer.

CREATE TEMP TABLE customer_points AS(
	SELECT 
		customer_id,
		point(longitude, latitude) AS long_lat_point
FROM customers
WHERE longitude IS NOT NULL
AND latitude IS NOT NULL
);

-- 2. Create temp table for each dealership as well.

CREATE TEMP TABLE dealership_points AS(
	SELECT 
		dealership_id,
		point(longitude, latitude) AS long_lat_point
FROM dealerships
);

-- 3. Cross Join these two tables to find distance between each customer and each dealership.

CREATE TEMP TABLE customer_dealership_distance AS(
	SELECT 
		c.customer_id,
		d.dealership_id,
		c.long_lat_point <@> d.long_lat_point AS distance_in_miles
FROM customer_points c CROSS JOIN dealership_points d
);

-- 4. Find closest dealership for each customer.

CREATE TEMP TABLE closest_dealerships AS(
	SELECT
		DISTINCT ON (customer_id) 
		customer_id,
		dealership_id,
		distance_in_miles 
FROM customer_dealership_distance
ORDER BY customer_id, distance_in_miles
);

-- 5. Calculating average distance and median distance from each customer to their closest dealership.

SELECT 
	AVG(distance_in_miles), 
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY distance_in_miles)
FROM closest_dealerships;

