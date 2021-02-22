-- Query to find number of sales in each month.

SELECT DATE_TRUNC('month', sales_transaction_date) month_date, count(1) number_of_sales
FROM sales
WHERE EXTRACT(YEAR FROM sales_transaction_date) = 2018
GROUP BY 1
ORDER BY 1;

-- Query to find number of new customers added each month

SELECT DATE_TRUNC('month', date_added) month_date, count(1) number_of_new_customers
FROM customers
WHERE EXTRACT(YEAR FROM date_added) = 2018
GROUP BY 1
ORDER BY 1;



