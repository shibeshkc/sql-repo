-- list all orders above 200 and number of orders above 200

WITH ORDERS AS (
  SELECT O.order_id, sum(units * unit_price) as total_amt_spent
  FROM sqlbootcamp.orders O
  JOIN sqlbootcamp.products P
  ON O.product_id = P.product_id
  group by O.order_id
  having total_amt_spent > 200
  ORDER BY total_amt_spent desc
)
select COUNT(1) from ORDERS


-- recursive cte

with recursive cte2 as (
  select 2 as two_table
  union all
  select two_table+2 from cte2
  where two_table + 2 <= 20
)
select * from cte2 order by 1

-- temp table
BEGIN
  CREATE TEMP TABLE happiness_index_india AS (
    SELECT * FROM `sqlbootcamp.happiness_scores`
    WHERE country = 'India'
  );

  -- Example usage:
  SELECT * FROM happiness_index_india;

END;

-- crate views

SELECT * FROM happiness_index_india;

CREATE VIEW sqlbootcamp.happiness_index_india as(

  SELECT * except(region) FROM `sqlbootcamp.happiness_scores`
    WHERE country = 'India'
    union all
  SELECT 2024,hsc.* FROM sqlbootcamp.happiness_scores_current hsc
    WHERE country = 'India'
)

-- windowing

select customer_id, order_id, order_date, transaction_id, 
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as transaction_number

from compact-scene-463014-f8.sqlbootcamp.orders
order by customer_id