Table: sales_data(product_id, month, sales_amount)
Question:
Pivot the table to show total sales_amount per product_id, with each month (Jan, Feb, Mar) as a separate column.

select product_id,
sum(case when month = 'Jan' then sales_amount else 0 end) as Jan,
sum(case when month = 'Feb' then sales_amount else 0 end) as Feb,
sum(case when month = 'Mar' then sales_amount else 0 end) as Mar
FROM sales_data
group by product_id
order by product_id

2. Gender Count
Table: students(student_id, gender)
Question:
Show one row with two columns: male_count and female_count.

select 
SUM(case when gender='Male' then 1 else 0 end) as male_count,
SUM(case when gender='Female' then 1 else 0 end) as female_count
from students

3. Attendance Status by Day
Table: attendance(emp_id, date, status)
Status can be 'Present', 'Absent', or 'Leave'
Question:
Pivot the table to show each employee total count of each status.

select emp_id,
sum(case when status = 'Present' then 1 else 0 end) as Present_days,
sum(case when status = 'Absent' then 1 else 0 end) as Absent_days,
sum(case when status = 'Leave' then 1 else 0 end) as Leave_days
from attendance
group by emp_id

4. Product Sales by Region
Table: sales(product_id, region, units_sold)
Question:
Pivot the data to show total units_sold per product_id, with columns for each region: North, South, East, West.

select product_id,
sum(case when region = 'North' then units_sold else 0 end) as North,
sum(case when region = 'South' then units_sold else 0 end) as South,
sum(case when region = 'East' then units_sold else 0 end) as East,
sum(case when region = 'West' then units_sold else 0 end) as West
from sales
group by product_id

5. Website Visitors by Device Type
Table: web_logs(user_id, visit_date, device_type)
Device types: Mobile, Desktop, Tablet
Question:
For each day, show how many users visited from each device type as columns.

select visit_date,
count(case when device_type='Mobile' then 1 end) as Mobile,
count(case when device_type='Desktop' then 1 end) as Desktop,
count(case when device_type='Tablet' then 1 end) as Tablet
from web_logs
group by visit_date


6. Daily Orders by Status
Table: orders(order_id, order_date, status)
Statuses include Delivered, Cancelled, Pending
Question:
For each order_date, pivot to get total number of each status.

select order_date,
count(case when status='Delivered' then 1 end) as Delivered,
count(case when status='Cancelled' then 1 end) as Cancelled,
count(case when status='Pending' then 1 end) as Pending
from orders
group by order_date


🔄 Advanced-Level
7. Revenue Breakdown by Payment Method and Year
Table: transactions(txn_id, txn_date, payment_method, amount)
Payment methods: Credit Card, UPI, Cash
Question:
For each year, show total revenue split across payment methods.

with cte_year_wise as (
    select extract(year from txn_date) as txn_year, payment_method, amount from transactions
)
select txn_year,
sum(case when payment_method='Credit Card' then amount else 0 end) as CreditCard,
sum(case when payment_method='UPI' then amount else 0 end) as UPI,
sum(case when payment_method='Cash' then amount else 0 end) as Cash
from cte_year_wise
group by txn_year

8. User Activity by Weekday
Table: logins(user_id, login_timestamp)
Question:
Pivot to show number of logins per weekday (Monday to Sunday) for each user.

with stage1 as (select user_id, extract(DAYOFWEEK from login_timestamp) as day from logins)
select user_id,
SUM(case when day = 1 then 1 else 0 end) as Monday,
SUM(case when day = 2 then 1 else 0 end) as Tuesday,
SUM(case when day = 3 then 1 else 0 end) as Wednesday,
SUM(case when day = 4 then 1 else 0 end) as Thursday,
SUM(case when day = 5 then 1 else 0 end) as Friday,
SUM(case when day = 6 then 1 else 0 end) as Saturday,
SUM(case when day = 7 then 1 else 0 end) as Sunday
from stage1
group by user_id


with stage1 as (select user_id, extract(DAYOFWEEK from login_timestamp) as day from logins)
select user_id,
COUNT(case when day = 1 then 1  end) as Monday,
COUNT(case when day = 2 then 1  end) as Tuesday,
COUNT(case when day = 3 then 1  end) as Wednesday,
COUNT(case when day = 4 then 1  end) as Thursday,
COUNT(case when day = 5 then 1  end) as Friday,
COUNT(case when day = 6 then 1  end) as Saturday,
COUNT(case when day = 7 then 1  end) as Sunday
from stage1
group by user_id

9. Customer Orders Split by Quarter
Table: orders(cust_id, order_date, order_value)
Question:
For each customer, show their total order value per quarter (Q1, Q2, Q3, Q4).

with cte_qtr as
(
    select cust_id,extract(MONTH from order_date) AS MNTH, order_value
from orders
)
select cust_id,
sum(case when MNTH in (1,2,3) then order_value else 0 end) as Q1,
sum(case when MNTH in (4,5,6) then order_value else 0 end) as Q2,
sum(case when MNTH in (7,8,9) then order_value else 0 end) as Q3,
sum(case when MNTH in (10,11,12) then order_value else 0 end) as Q4

from cte_qtr
group by cust_id

10. Combining PIVOT with JOIN
Given:

employees(emp_id, name, dept_id)

attendance(emp_id, date, status)

Question:
For each department, 
show how many employees were Present, Absent, or on Leave on a particular date (say '2025-07-25').

with cte_combine as (
    select e.emp_id, dept_id, date, status
    from employees e
    join attendance a
    on e.emp_id = a.emp_id
    where date = '2025-07-25'
)
select dept_id,
count(case when status = 'Present' then 1 end) as Present,
count(case when status = 'Absent' then 1 end) as Absent,
count(case when status = 'Leave' then 1 end) as Leave
from cte_combine
group by dept_id