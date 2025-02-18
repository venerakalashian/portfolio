-- The top 5 clients by total amount of purchases over the last 6 months

SELECT 
    o.client_id, c.name, SUM(o.amount) as orders_amount
FROM 
    orders o 
JOIN 
    clients c ON o.client_id = c.client_id
WHERE 
    o.order_date >= date_trunc('month', CURRENT_DATE - INTERVAL '6 month') 
    AND o.order_date < date_trunc('month', CURRENT_DATE)
GROUP BY 
    o.client_id, c.name
ORDER BY 
    orders_amount DESC
LIMIT 5

-- Sales peaks by month over the last year 

SELECT
    TO_CHAR(order_date, 'Mon') as month, 
    COUNT(order_id) as order_count,
    SUM(amount) as total_amount
FROM 
    orders 
WHERE 
    order_date >= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year' 
    AND order_date < DATE_TRUNC('year', CURRENT_DATE)
GROUP BY 
    DATE_TRUNC('month', order_date), month
ORDER BY
    total_amount DESC

-- Top 3 categories with the most revenue.

SELECT 
    p.category, 
    SUM(p.price) as total_amount
FROM
    products p 
JOIN 
    orders o ON (p.order_id = o.order_id)
WHERE 
    DATE_TRUNC('year', o.order_date) = DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year'
GROUP BY 
    p.category
ORDER BY
    total_amount DESC
LIMIT 3

-- Determine the customers who registered more than 6 months ago but have not made a single order in the last 3 months. 
-- What is the % of such customers out of the total number of registered customers?

WITH inactive_clients as (
    SELECT 
        c.client_id 
    FROM clients c
    LEFT JOIN orders o 
        ON c.client_id = o.client_id 
        AND o.order_date >= CURRENT_DATE - INTERVAL '3 months'
    WHERE 
        o.client_id IS NULL
        AND c.signup_date < CURRENT_DATE - INTERVAL '6 months')
)
SELECT 
    COUNT(ic.client_id) / COUNT(c.client_id) * 100.0 as inactive_persentage
FROM 
    clients c
LEFT JOIN 
    inactive_clients ic ON c.client_id = ic.client_id
