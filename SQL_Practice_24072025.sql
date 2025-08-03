-- orders(order_id, customer_id, order_date, order_amount)
-- customers(customer_id, customer_name, country)

-- Write a query to find the top 3 customers who spent the most in total, along with their total spend.

with STAGE1 AS(
        select customer_id, sum(order_amount) as total_spent,
        DENSE_RANK() OVER (order by sum(order_amount) desc) as ranked
        from orders 
        group by customer_id
)
select customer_id, customer_name, country
from STAGE1 s
left join customers c
on s.customer_id = c.customer_id
where ranked <= 3

-- transactions(txn_id, account_id, txn_date, txn_type, amount)

-- Write a query to detect accounts that had more than 3 withdrawals of over ₹50,000 in a single day.

select account_id, txn_date
from transactions
where txn_type = 'D'
and amount >= 50000
group by  account_id,txn_date
having count(txn_id) > 3


-- employees(emp_id, emp_name, department_id)
-- leaves(emp_id, leave_date, leave_type)

--Write a query to find employees who took more than 5 leaves in the last 30 days.


select emp_id
from employees e
join leaves l -- no left join because you are not counting the employee who have not taken any leaves
on e.emp_id = l.emp_id
and leave_date between DATE_SUB(CURRENT_DATE(),INTERVAL 30 DAY) AND CURRENT_DATE() 
group by emp_id
having count(leave_date) > 5

-- views(user_id, video_id, view_date, duration_minutes)
-- videos(video_id, category, uploaded_by)

-- Write a query to find the most-watched video category in terms of total minutes watched in the last 7 days.

WITH STAGE1 AS (
select category, SUM(duration_minutes) as total_duration
from videos v
join views vw
on v.video_id = vw.video_id
where view_date between DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND CURRENT_DATE()
group by category
)
select category
from STAGE1
order by total_duration desc
limit 1