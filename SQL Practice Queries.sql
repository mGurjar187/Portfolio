-- WINDOW FUNCTION

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

-- Calculate the 7 day rolling average of payments overtime.
SELECT
    payment_date,
    (CASE WHEN (row_number >= 7) THEN sales_moving_average_7 ELSE NULL
END) AS sales_moving_average_7
FROM
    (
    SELECT
        payment_date,
        total_amount,
        AVG(total_amount) OVER(
        ORDER BY
            payment_date ROWS BETWEEN 7 PRECEEDING AND CURRENT ROW
    ) AS sales_moving_average_7,
    ROW_NUMBER() OVER(
ORDER BY
    payment_date
) AS row_number
FROM
    (
    SELECT
        CAST(payment_date AS DATE) AS payment_date,
        SUM(amount) AS total_amount
    FROM
        payment
    GROUP BY
        1
) AS daily_sales
ORDER BY
    payment_date) AS moving_average_calculation_7;
