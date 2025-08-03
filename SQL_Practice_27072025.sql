-- fifth highest value using the NTH VALUE window function

select * from (
SELECT
  emp_id,
  salary,
  NTH_VALUE(salary, 5) OVER (ORDER BY salary DESC) AS fifth_highest_salary
FROM compact-scene-463014-f8.dataset17072025.employee
) where salary = fifth_highest_salary;


-- ranking and filtering

select order_id, units, product_id from (
select order_id, product_id, units, DENSE_RANK() OVER (PARTITION BY ORDER_ID ORDER BY units desc) as popularity
from compact-scene-463014-f8.sqlbootcamp.orders order by order_id
)
where popularity = 2

-- 2ND Highest order unit using NTH_VALUE() window function

select order_id, units, product_id from (
select order_id, product_id, units, NTH_VALUE(product_id, 2) OVER (PARTITION BY ORDER_ID ORDER BY units desc) as popular_product
from compact-scene-463014-f8.sqlbootcamp.orders order by order_id
)
WHERE product_id = popular_product

-- LAG() window function - previous value in a partition

with stage1 as (

  select customer_id, order_id, units, LAG(units) over (partition by customer_id order by order_id) as previous_units
  from compact-scene-463014-f8.sqlbootcamp.orders 
)
select customer_id, order_id, units, previous_units, (previous_units - units) diff_units
from stage1

-- allocating quantiles

with cust_cte as (
  select customer_id, sum( units*unit_price) as total_spend
  from compact-scene-463014-f8.sqlbootcamp.orders o
  left join compact-scene-463014-f8.sqlbootcamp.products p
  on o.product_id = p.product_id
  group by customer_id
  order by total_spend desc
  )
  select customer_id, total_spend,
  NTILE(10) OVER (ORDER BY total_spend desc) AS customer_quantile
  from cust_cte
  order by total_spend desc

  -- numeric operations

WITH units_per_order AS (
  SELECT
    customer_id,
    order_id,
    order_date,
    SUM(units) AS total_units_in_order
  FROM sqlbootcamp.orders
  GROUP BY customer_id, order_id, order_date
),

units_with_diff AS (
  SELECT
    customer_id,
    order_id,
    order_date,
    total_units_in_order,
    LAG(total_units_in_order) OVER (
      PARTITION BY customer_id
      ORDER BY order_date
    ) AS previous_units
  FROM units_per_order
)

SELECT
  customer_id,
  order_id,
--  order_date,
--  total_units_in_order,
--  previous_units,
  total_units_in_order - IFNULL(previous_units, 0) AS units_change
FROM units_with_diff
ORDER BY customer_id, order_date;

-- string functions

select factory, product_id,
concat(replace(replace(factory,"'",'')," ",'-'),'-',product_id) as factory_product_id
 from sqlbootcamp.products

 -- removing duplicate in the output

with cte_dup as (
SELECT 
id,
student_name,	
email,
ROW_NUMBER() OVER (PARTITION BY student_name order by id desc) as rownum
 FROM `compact-scene-463014-f8.sqlbootcamp.students`
)
select 
id,
student_name,	
email
 from cte_dup where rownum = 1
 order by id

 -- ranking using window function

with cte_stu as (
SELECT 
id,
student_name,	
email,
class_name,
final_grade,
DENSE_RANK() OVER (PARTITION BY id order by final_grade desc ) as top_grade
 FROM `compact-scene-463014-f8.sqlbootcamp.students` stu
 join `compact-scene-463014-f8.sqlbootcamp.student_grades` grad 
 on stu.id = grad.student_id
)

select id, student_name, final_grade, class_name from cte_stu where top_grade = 1
order by id


-- pivoting with case statements

with cte_stu as (
select 
id,
department,
grade_level,
final_grade
from `sqlbootcamp.students` s
join `sqlbootcamp.student_grades` sg
on s.id = sg.student_id
)
select department,
round(avg(case when grade_level = 9 then final_grade end)) as freshmen,
round(avg(case when grade_level = 10 then final_grade  end)) as sophomore,
round(avg(case when grade_level = 11 then final_grade  end)) as junior,
round(avg(case when grade_level = 12 then final_grade end)) as senior
from cte_stu
group by department
order by department

----------------

SELECT 
  cust_id,
  SUM(order_value) AS subtotal
FROM dataset17072025.customer_orders
GROUP BY cust_id;

SELECT 
  cust_id,order_date,
  SUM(order_value) AS subtotal
FROM dataset17072025.customer_orders
GROUP BY cust_id,order_date;

select cust_id,order_date,
sum(order_value) over (partition by cust_id order by order_date) as cumulative_value
from dataset17072025.customer_orders

-- apply cumulative sum and six month moving avg
with cte_sale as (
select extract(year from order_date) as year,extract(month from order_date) as month, sum(units*unit_price) as sales_value
from sqlbootcamp.orders o
left join `sqlbootcamp.products` p 
on o.product_id = p.product_id
group by year, month
order by year, month
)
select year, month,
round(sum(sales_value) over (order by year,month)) as cumulative_sale,
round(avg(sales_value) over (order by year,month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)) as six_month_avg
from cte_sale
order by year, month

