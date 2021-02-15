
# WINDOW FUNCTION

SELECT customer_id, store_id, first_name, last_name, email, active, COUNT(*) OVER (PARTITION BY active) AS total_customers
FROM customer 
ORDER BY customer_id;

SELECT customer_id, store_id, first_name, last_name, email, active, COUNT(*) OVER (PARTITION BY active ORDER BY customer_id) AS total_customers
FROM customer 
ORDER BY customer_id;

UPDATE customer 
SET 
    email = NULL
WHERE
    active = 0;

SELECT customer_id, create_date, email, 
COUNT(CASE WHEN email IS NOT null THEN customer_id ELSE null END) over (ORDER BY create_date) AS total_customers_filled_email
FROM customer 
ORDER BY create_date;

