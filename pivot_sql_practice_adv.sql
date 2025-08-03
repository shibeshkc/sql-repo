1. Pivot with Aggregation and Filter
Scenario:
You have a sales table with product_id, region, sales_amount, and sale_date. 
You want to see total sales by product only for the last month, pivoted by region.

Task:
For each product, show total sales for regions North, South, and East in separate columns, 
but only for sales made in the last 30 days.

select product_id,
sum(case when region = 'North' then sales_amount else 0 end) as North,
sum(case when region = 'South' then sales_amount else 0 end) as South,
sum(case when region = 'East' then sales_amount else 0 end) as East
--sum(case when region = 'West' then sales_amount else 0 end) as West
from sales
where sale_date between date_sub(current_date(), interval 30 day) and current_date()
group by product_id

-- 2. Dynamic Pivot Using SQL (Simulated)
-- Scenario:
-- You don’t know in advance all the possible category values in your products table. 
-- You want a report showing sales per category as columns.

-- Task:
-- Write a query or explain an approach to generate a pivot table with dynamic columns (categories) using SQL or scripting.

-- select * from products
-- pivot (sum(sales) for categories in (select distinct categories from products))

3. Pivot with Multiple Aggregations
Scenario:
From a table orders(order_id, product_id, order_status, order_value), create a report that shows, per product:

Total number of orders with status Delivered and Cancelled

Total revenue from Delivered orders

Show these metrics as separate columns.


select product_id,
sum(case when order_status = 'Delivered' then 1 else 0 end) as Delivered,
sum(case when order_status = 'Cancelled' then 1 else 0 end) as Cancelled,
sum(case when order_status = 'Delivered' then order_value else 0 end) as Total_Revenue
from orders
group by product_id

4. Pivot with Date Bucketing
Scenario:
You have a logins(user_id, login_date) table. Create a pivot showing login counts per user for each day of the current week (Monday to Sunday).

with stage1 as (select user_id, extract(DAYOFWEEK from login_date) as day 
from logins where login_date between date_sub(current_date(), interval 6 day) and current_date())
select user_id,
COUNT(case when day = 1 then 1  end) as Sunday,
COUNT(case when day = 2 then 1  end) as Monday,
COUNT(case when day = 3 then 1  end) as Tuesday,
COUNT(case when day = 4 then 1  end) as Wednesday,
COUNT(case when day = 5 then 1  end) as Thursday,
COUNT(case when day = 6 then 1  end) as Friday,
COUNT(case when day = 7 then 1  end) as Saturday

from stage1
group by user_id

5. Conditional Pivot with Additional Filter
Scenario:
In an employees(emp_id, department, gender, salary) table, 
you want to see the average salary per department, pivoted by gender, but only including employees with salary > 50000.

with cte_emp as (
    select * from employees where salary > 50000
)
select 
department
avg(case when gender='Male' then salary end) as avg_salary_male,
avg(case when gender='Female' then salary end) as avg_salary_female
from cte_emp
group by department

6. Pivot with JOIN
Scenario:
You have sales and products tables. Pivot total sales amount by product category. Category info is only in the products table.

select 
sum(case when p.category = 'CAT1' THEN s.sales_amount ELSE 0 END) AS CAT1_SALES,
sum(case when p.category = 'CAT2' THEN s.sales_amount ELSE 0 END) AS CAT2_SALES,
sum(case when p.category = 'CAT3' THEN s.sales_amount ELSE 0 END) AS CAT3_SALES
from sales s
join product p
on s.product_id = p.product_id
--GROUP BY p.category

7. Pivot with Ranking
Scenario:
In a scores(student_id, subject, marks) table, show each student’s highest score per subject as columns. 
If a student has multiple scores per subject, pick the highest.


select student_id,
MAX(case when subject = 'Maths' then marks) end as Maths,
MAX(case when subject = 'English' then marks) end as English,
MAX(case when subject = 'Science' then marks) end as Science
from scores
group by student_id