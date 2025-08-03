sales
+---------+----------+--------+
| emp_id  | month    | sales  |
+---------+----------+--------+
| E1      | Jan      | 1000   |
| E1      | Feb      | 1200   |
| E2      | Jan      | 1100   |
| E2      | Feb      | 1300   |
+---------+----------+--------+

+---------+-------+-------+
| emp_id  | Jan   | Feb   |
+---------+-------+-------+
| E1      | 1000  | 1200  |
| E2      | 1100  | 1300  |
+---------+-------+-------+

select emp_id,
max(case when month = 'Jan' then sales end) as Jan,
max(case when month = 'Feb' then sales end) as Feb
from sales
group by emp_id

orders
+---------+------------+----------+
| user_id | order_date | amount   |
+---------+------------+----------+
| U1      | 2023-01-01 | 100      |
| U1      | 2023-01-10 | 250      |
| U1      | 2023-02-01 | 300      |
| U2      | 2023-01-05 | 200      |
| U2      | 2023-01-20 | 150      |
+---------+------------+----------+

+---------+------------+----------+
| user_id | order_date | amount   |
+---------+------------+----------+
| U1      | 2023-02-01 | 300      |
| U1      | 2023-01-10 | 250      |
| U2      | 2023-01-20 | 150      |
| U2      | 2023-01-05 | 200      |
+---------+------------+----------+

with stage1 as
(select user_id,order_date,amount,
dense_rank() over (partition by user_id order by order_date desc) as rank
from orders)
select user_id,order_date,amount from stage1 where rank <= 2


transactions
+----------+------------+--------+
| user_id  | txn_date   | amount |
+----------+------------+--------+
| U1       | 2023-01-10 | 100    |
| U1       | 2023-01-20 | 200    |
| U1       | 2023-02-01 | 300    |
| U2       | 2023-02-05 | 400    |
+----------+------------+--------+

+----------+------------+--------+
| user_id  | month      | total  |
+----------+------------+--------+
| U1       | 2023-01    | 300    |
| U1       | 2023-02    | 300    |
| U2       | 2023-02    | 400    |
+----------+------------+--------+

with cte_ext_month as (
    select user_id, FORMAT_DATE('%Y-%m',txn_date) as month, amount from transactions
)
select user_id, month, sum(amount) as total from cte_ext_month group by user_id, month;

payments
+---------+------------+--------+
| cust_id | pay_date   | amount |
+---------+------------+--------+
| C1      | 2023-01-01 | 100    |
| C1      | 2023-01-05 | 200    |
| C1      | 2023-01-10 | 300    |
+---------+------------+--------+

+---------+------------+--------+--------------+
| cust_id | pay_date   | amount | running_total|
+---------+------------+--------+--------------+
| C1      | 2023-01-01 | 100    | 100          |
| C1      | 2023-01-05 | 200    | 300          |
| C1      | 2023-01-10 | 300    | 600          |
+---------+------------+--------+--------------+

select cust_id, pay_date, amount,
sum(amount) over (order by pay_date) as running_total
from payments


logs
+---------+---------------------+
| user_id | timestamp           |
+---------+---------------------+
| U1      | 2023-01-01 10:00:00 |
| U1      | 2023-01-01 10:05:00 |
| U1      | 2023-01-01 10:20:00 |
| U2      | 2023-01-01 11:00:00 |
| U2      | 2023-01-01 11:30:00 |
+---------+---------------------+
Rule: Start a new session if gap between events > 10 minutes
+---------+---------------------+-------------+
| user_id | timestamp           | session_id  |
+---------+---------------------+-------------+
| U1      | 2023-01-01 10:00:00 | 1           |
| U1      | 2023-01-01 10:05:00 | 1           |
| U1      | 2023-01-01 10:20:00 | 2           |
| U2      | 2023-01-01 11:00:00 | 1           |
| U2      | 2023-01-01 11:30:00 | 2           |
+---------+---------------------+-------------+

WITH ordered_logs AS (
  SELECT
    user_id,
    timestamp,
    LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_timestamp
  FROM logs
),
flagged_sessions AS (
  SELECT
    user_id,
    timestamp,
    IF(
      prev_timestamp IS NULL OR TIMESTAMP_DIFF(timestamp, prev_timestamp, MINUTE) > 10,
      1,
      0
    ) AS is_new_session
  FROM ordered_logs
),
session_ids AS (
  SELECT
    user_id,
    timestamp,
    SUM(is_new_session) OVER (PARTITION BY user_id ORDER BY timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_id
  FROM flagged_sessions
)
SELECT * FROM session_ids
ORDER BY user_id, timestamp;



stocks
+------------+--------+
| date       | price  |
+------------+--------+
| 2023-01-01 | 100    |
| 2023-01-02 | 110    |
| 2023-01-03 | 105    |
+------------+--------+

+------------+--------+-------------+
| date       | price  | price_delta |
+------------+--------+-------------+
| 2023-01-01 | 100    | null        |
| 2023-01-02 | 110    | 10          |
| 2023-01-03 | 105    | -5          |
+------------+--------+-------------+

select date, price, (price - LAG() OVER (ORDER BY DATE)) as price_delta
from stocks
order by date


survey_responses
+------------+------------+---------+
| user_id    | question   | answer  |
+------------+------------+---------+
| U1         | Gender     | Male    |
| U1         | Age        | 25      |
| U1         | Country    | India   |
| U2         | Gender     | Female  |
| U2         | Age        | 30      |
| U2         | Country    | USA     |
+------------+------------+---------+

+------------+--------+-----+---------+
| user_id    | Gender | Age | Country |
+------------+--------+-----+---------+
| U1         | Male   | 25  | India   |
| U2         | Female | 30  | USA     |
+------------+--------+-----+---------+

select user_id,
max(case when question = 'Gender' then answer end) as Gender,
max(case when question = 'Age' then answer end) as Age,
max(case when question = 'Country' then answer end) as Country
from survey_responses
group by user_id

student_scores
+-----------+---------+--------+
| student   | subject | score  |
+-----------+---------+--------+
| S1        | Math    | 80     |
| S2        | Math    | 95     |
| S3        | Math    | 70     |
| S4        | Math    | 60     |
| S5        | Math    | 85     |
+-----------+---------+--------+

Expected Output:
(Divide students into 3 equal performance tiers)

+-----------+---------+--------+-----------+
| student   | subject | score  | tier      |
+-----------+---------+--------+-----------+
| S2        | Math    | 95     | 1         |
| S5        | Math    | 85     | 1         |
| S1        | Math    | 80     | 2         |
| S3        | Math    | 70     | 3         |
| S4        | Math    | 60     | 3         |
+-----------+---------+--------+-----------+

select student, subject, score,
NTILE(3) OVER (ORDER BY score desc) as tier
from 
student_scores
order by tier


sales
+--------+--------+--------+
| region | year   | amount |
+--------+--------+--------+
| East   | 2022   | 1000   |
| East   | 2023   | 1200   |
| West   | 2022   | 800    |
| West   | 2023   | 1000   |
+--------+--------+--------+

+--------+--------+--------+--------------+
| region | 2022   | 2023   | growth_rate   |
+--------+--------+--------+--------------+
| East   | 1000   | 1200   | 20.00%        |
| West   | 800    | 1000   | 25.00%        |
+--------+--------+--------+--------------+

with stage1 as (
    select region, 
    sum(case when year = 2022 then amount else 0) as sales_2022,
    sum(case when year = 2023 then amount else 0) as sales_2023
    from sales
    group by region
)
select region, sales_2022, sales_2023, ((sales_2023 - sales_2022)/sales_2022) as growth_rate
from stage1

product_sales
+-----------+---------+
| product   | revenue |
+-----------+---------+
| A         | 100     |
| B         | 300     |
| C         | 200     |
| D         | 500     |
| E         | 400     |
+-----------+---------+

+-----------+---------+
| product   | revenue |
+-----------+---------+
| D         | 500     |
+-----------+---------+

select product, revenue from
(select product, revenue, 
NTILE(5) OVER (ORDER BY revenue desc) as tier
from product_sales)
where tier = 1

attendance
+---------+------------+----------+
| emp_id  | date       | status   |
+---------+------------+----------+
| E1      | 2023-01-01 | Present  |
| E1      | 2023-01-02 | Absent   |
| E2      | 2023-01-01 | Present  |
| E2      | 2023-01-02 | Present  |
+---------+------------+----------+

+---------+------------+------------+
| emp_id  | 2023-01-01 | 2023-01-02 |
+---------+------------+------------+
| E1      | Present     | Absent    |
| E2      | Present     | Present   |
+---------+------------+------------+


select emp_id,
max(case when date = '2023-01-01' then status end) as Status_1st_Jan,
max(case when date = '2023-01-02' then status end) as Status_2nd_Jan
from attendance
group by emp_id


customer_balance
+------------+------------+---------+
| cust_id    | as_of_date | balance |
+------------+------------+---------+
| C1         | 2023-01-01 | 1000    |
| C1         | 2023-02-01 | 1100    |
| C2         | 2023-01-15 | 900     |
+------------+------------+---------+

+------------+------------+---------+
| cust_id    | as_of_date | balance |
+------------+------------+---------+
| C1         | 2023-02-01 | 1100    |
| C2         | 2023-01-15 | 900     |
+------------+------------+---------+

with cte_cb as (
    select cust_id,as_of_date,balance,
    ROW_NUMBER() OVER (PARTITION BY cust_id order by as_of_date desc) as latest
    from customer_balance
)
select cust_id,as_of_date,balance from cte_cb where latest = 1
order by cust_id