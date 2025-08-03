with stage1 as (select customer_id, 
sum(case when product_name = 'A' then 1 else 0 end) as A_count,
sum(case when product_name = 'B' then 1 else 0 end) as B_count,
sum(case when product_name = 'C' then 1 else 0 end) as C_count,
sum(case when product_name = 'D' then 1 else 0 end) as D_count
from dataset22072025.orders
group by customer_id
) 
select s1.customer_id, customer_name 
from stage1 s1 left join dataset22072025.customers c
on s1.customer_id = c.customer_id
where A_count <> 0 and B_count <> 0 and C_count = 0

Row	    customer_id	    customer_name
1	    3	            Elizabeth


-- using count

with stage1 as (select customer_id, 
count(case when product_name = 'A' then 1 end) as A_count,
count(case when product_name = 'B' then 1 end) as B_count,
count(case when product_name = 'C' then 1 end) as C_count,
count(case when product_name = 'D' then 1 end) as D_count
from dataset22072025.orders
group by customer_id
) 
select s1.customer_id, customer_name 
from stage1 s1 left join dataset22072025.customers c
on s1.customer_id = c.customer_id
where A_count <> 0 and B_count <> 0 and C_count = 0

----

select name, department from (
select name, department, 
case when department = 'IT' then 1
     when department = 'HR' then 2
     when department = 'Devloper' then 3
     else 4
end as order_flag
 from `dataset22072025.employees` )
 order by order_flag, name


Row	name	department
1	Hasan	IT
2	Joe	    IT
3	Hillary	HR
4	Merry	HR
5	Yusuf	HR
6	Jhon	Devloper
7	Mark	Sales

---

SELECT accno,
sum(case 
      when trantype = 'C' then amount
      when trantype = 'D' then -amount
    end
) as balance

FROM `compact-scene-463014-f8.dataset19072025.transactions`
group by accno

Row	accno	balance
1	1003	350
2	1004	1200
3	1005	800
4	1002	-500
5	1001	-850

---
-- using sum 
select consumer_id,
sum(case when account_type = 'dmat' then 1  else 0 end) as has_dmat
from `dataset22072025.consumer`
group by consumer_id
order by consumer_id

--using count
select consumer_id,
count(case when account_type = 'dmat' then 1 end) as has_dmat
from `dataset22072025.consumer`
group by consumer_id
order by consumer_id

Row	consumer_id	has_dmat
1	1	        1
2	2	        0
3	3	        0
4	4	        1
5	5	        0

-- cumulative sum

select customer_id, txn_month,
sum(balance) over (partition by customer_id order by txn_month) as cumulative_balance
from `dataset22072025.customer_balances`

Row	customer_id	txn_month	cumulative_balance
1	1	        2024-01-01	1000
2	1	        2024-02-01	2500
3	1	        2024-03-01	3700
4	1	        2024-04-01	5000
5	1	        2024-05-01	6700
6	1	        2024-06-01	8500
7	1	        2024-07-01	10100
8	2	        2024-02-01	2000
9	2	        2024-03-01	4100
10	2	        2024-04-01	6000
11	2	        2024-05-01	8500
12	2	        2024-06-01	10900
13	2	        2024-07-01	13200

-- -- moving avg

select customer_id, txn_month,
avg(balance) over (partition by customer_id order by txn_month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS moving_avg_bal
from `dataset22072025.customer_balances`

Row	customer_id	txn_month	moving_avg_bal
1	2	        2024-02-01	2000.0
2	2	        2024-03-01	2050.0
3	2	        2024-04-01	2000.0
4	2	        2024-05-01	2125.0
5	2	        2024-06-01	2180.0
6	2	        2024-07-01	2200.0
7	1	        2024-01-01	1000.0
8	1	        2024-02-01	1250.0
9	1	        2024-03-01	1233.3333333333333
10	1	        2024-04-01	1250.0
11	1	        2024-05-01	1340.0
12	1	        2024-06-01	1416.6666666666667
13	1	        2024-07-01	1516.6666666666667