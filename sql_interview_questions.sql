E-Commerce Orders Analysis
Scenario: You are given two tables:

orders(order_id, customer_id, order_date, order_amount)
customers(customer_id, customer_name, country)

Question:
Write a query to find the top 3 customers who spent the most in total, along with their total spend.

with cte_customer_ranked as (
    select c.customer_id, sum(order_amount) as total_order_amount,
    dense_rank() over (order by total_order_amount desc) as rank
    from customers c
    join orders o
    on c.customer_id = o.customer_id
    group by customer_id
)
select * from cte_customer_ranked where rank <= 3

✅ 2. Banking Transactions - Fraud Check
Scenario: A bank maintains the following transaction records:


transactions(txn_id, account_id, txn_date, txn_type, amount)
Question:
Write a query to detect accounts that had more than 3 withdrawals of over ₹50,000 in a single day.

with stage1 as
    (
    select account_id
    from transactions
    where amount > 50000
    and  txn_type = 'D'
    group by account_id, txn_date
    having count(txn_id) > 3
)
select distinct account_id from stage1

3. HR Leave Management
Scenario: You have access to the following tables:

employees(emp_id, emp_name, department_id)
leaves(emp_id, leave_date, leave_type)
Question:
Write a query to find employees who took more than 5 leaves in the last 30 days.

select e.emp_id
from employees e
join leaves l
on e.emp_id = l.emp_id
where leave_date between date_sub(current_date(), interval 30 day) and current_date()
group by e.emp_id
having count(leave_date) > 5

4. Streaming Platform Usage
Scenario: A platform tracks user views as:

views(user_id, video_id, view_date, duration_minutes)
videos(video_id, category, uploaded_by)
Question:
Write a query to find the most-watched video category in terms of total minutes watched in the last 7 days.

with cte_ranked as (
    select category, sum(duration_minutes) as total_mins_watched,
dense_rank() over (order by sum(duration_minutes) desc) as rnk
from videos v
join views vw 
on v.video_id = vw.video_id
where view_date between date_sub(current_date(), interval 7 day) and current_date()
group by category
)
select category from cte_ranked where rnk = 1


5. Retail Inventory - Reorder Alert
Scenario:

products(product_id, product_name, category, stock_quantity, reorder_level)
Question:
Find all products where the current stock is less than or equal to the reorder level and grouped by category.

select category,product_id, product_name
from products
group by category,product_id, product_name
having sum(stock_quantity) <= sum(reorder_level)

Employee Salary Change Tracking
Scenario:

salaries(emp_id, effective_date, salary)
Question:
Write a query to find the latest salary for each employee.



select emp_id, effective_date, salary from
(select emp_id, effective_date, salary,
row_number() over (partition by emp_id order by effective_date desc) as rn
from salaries )
where rn = 1

Follow-up: Find employees whose salary increased by more than 20% compared to their previous salary.

WITH salary_changes AS (
  SELECT
    emp_id,
    effective_date,
    salary,
    LAG(salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary,
    ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY effective_date DESC) AS rn_latest
  FROM salaries
)
SELECT
  emp_id,
  effective_date,
  salary,
  prev_salary,
  ROUND((salary - prev_salary) / prev_salary * 100, 2) AS percent_increase
FROM salary_changes
WHERE rn_latest = 1
  AND prev_salary IS NOT NULL
  AND (salary - prev_salary) / prev_salary > 0.20;



7. Monthly Active Users
Scenario: Given a log of user activity:

activity_logs(user_id, activity_date)
Question:
Write a query to find the number of monthly active users (users who logged in at least once in each month) for the last 3 months.

with recent_logs as (
    select *, extract(month from activity_date) as month
    from activity_logs
    where activity_date between date_sub(current_date(), interval 3 month) and current_date()
)
select user_id
from recent_logs
group by user_id
having count(activity_date) >= 1 and count(distinct month) >= 3

8. Product Reviews & Ratings
Scenario:

reviews(review_id, product_id, user_id, rating, review_date)
Question:
Write a query to list the top 5 products with the highest average rating, but only include products that have at least 10 reviews.

with cte_ranked as (
    select  product_id, 
            avg(rating) as avg_rating,
            dense_rank() over (order by avg(rating) desc) as ranked
    from reviews
    group by product_id
    having count(review_id) >= 10
)
select product_id, avg_rating 
from cte_ranked 
where ranked <= 5
order by avg_rating desc

9. Sales Rep Performance
Scenario:
sales(sale_id, rep_id, sale_amount, sale_date)
reps(rep_id, rep_name, region)
Question:
Write a query to find the top-performing rep in each region based on total sales this quarter.

with cte_rep_data as (
    select s.rep_id, r.rep_name, sale_amount, region
    from sales s
    join reps r
    on s.rep_id = r.rep_id
    where sale_date between date_sub(current_date(), interval 90 day) and current_date()
),
cte_interim as (
    select rep_id, rep_name, region, sum(sale_amount) as total_sale_amt,
    dense_rank() over (partition by region order by sum(sales_amount) desc)  as rep_rank
    from cte_rep_data
    group by rep_id, rep_name, region
)
select * from cte_interim where rep_rank = 1


10. Time Difference Between Events
Scenario: You are tracking user sessions:

sessions(user_id, session_start, session_end)
Question:
Write a query to calculate the average session duration per user.

with cte_session as (
    select user_id, session_start, session_end, TIMESTAMP_DIFF(session_end, session_start, SECOND) as session_duration
    from sessions
    WHERE session_end >= session_start
    AND session_start IS NOT NULL
    AND session_end IS NOT NULL
)
select user_id, avg(session_duration) as avg_session_duration
from cte_session
group by user_id



