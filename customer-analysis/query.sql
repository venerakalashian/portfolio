-- The total amount of purchases (total_amount) for each customer who signed up in 2023.

SELECT 
    c.client_id, 
    SUM(o.amount) AS total_amount
FROM 
    clients c
JOIN 
    orders o ON c.client_id = o.client_id
WHERE 
    DATE_PART('year', c.signup_date) = 2023
GROUP BY 
    c.client_id
ORDER BY 
    total_amount DESC;

-- The three product categories that customers most frequently purchased in the last month.

SELECT 
    p.category, 
    COUNT(p.product_id) as product_count
FROM 
    products p
JOIN 
    orders o ON p.order_id = o.order_id
WHERE 
    o.order_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
    and o.order_date <  date_trunc('month', CURRENT_DATE)
GROUP BY 
    p.category 
ORDER BY 
    product_count desc
LIMIT 3

-- The average order amount for each customer who placed more than three orders.

SELECT
    o.client_id,
	  c.name,
	  AVG(amount) AS avg_order_amount
FROM
	  orders o 
JOIN 
	  clients c ON o.client_id = c.client_id
GROUP BY 
	  o.client_id, c.name
HAVING
	  COUNT(o.order_id) > 3

-- The customer conversion rate for the last three months. The conversion rate refers to the ratio of the number of customers 
-- who made at least one order to the total number of registered customers for that period.

WITH 
active_clients AS (
    SELECT DISTINCT client_id
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '3 months'), 
    
registered_clients AS (
    SELECT client_id
    FROM clients 
    WHERE signup_date >= CURRENT_DATE - INTERVAL '3 months')
        
SELECT 
    COUNT(ac.client_id) / COUNT(rc.client_id)::DECIMAL AS conversion_rate
FROM 
    active_clients ac
CROSS JOIN
    registered_clients rc;
