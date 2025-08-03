create table dataset19072025.customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);
select * from dataset19072025.customer_orders
insert into dataset19072025.customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;

with stage1 as (
  select customer_id, min(order_date) as first_order_date from dataset19072025.customer_orders group by customer_id
)
select order_date,
sum( case when order_date = first_order_date then  1 else 0 end) as first_order_count,
sum( case when order_date <> first_order_date then 1 else 0 end) as repeat_order_count,
sum (case when order_date = first_order_date then  order_amount else 0 end) as total_first_order_amt,
sum (case when order_date <> first_order_date then  order_amount else 0 end) as total_repeat_order_amt,
from dataset19072025.customer_orders co
join stage1 s1
on co.customer_id = s1.customer_id
group by order_date


____________________________________

CREATE TABLE dataset19072025.accounts (
    consumer_id INT,
    account_type STRING
);


INSERT INTO dataset19072025.accounts (consumer_id, account_type) VALUES
(1, 'savings'),
(1, 'dmat'),
(1, 'current'),
(2, 'savings'),
(3, 'savings'),
(3, 'current'),
(4, 'dmat'),
(4, 'savings'),
(5, 'current');

select * from dataset19072025.accounts;

with stage1 as(
 SELECT consumer_id, count(account_type) as dmat_account
    FROM dataset19072025.accounts
    WHERE account_type = 'dmat'
    GROUP BY consumer_id
)
select distinct a.consumer_id , coalesce(dmat_account,0) as has_dmat
from dataset19072025.accounts a
left join stage1 s
on a.consumer_id = s.consumer_id
order by consumer_id

with stage1 as(
 SELECT consumer_id, account_type
    FROM dataset19072025.accounts
    WHERE account_type = 'dmat'
)

select distinct a.consumer_id , 
case when s.account_type is null then 0 else 1 end as has_dmat
from dataset19072025.accounts a
left join stage1 s
on a.consumer_id = s.consumer_id
order by consumer_id

_______________________________________________

create table dataset19072025.entries ( 
name string,
address string,
email string,
floor int64,
resources string);

insert into dataset19072025.entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')

select * from dataset19072025.entries

with concat_resources as (
select name,count(1) as total_count,STRING_AGG(distinct resources,',') as resources_used from `dataset19072025.entries` group by name
), most_visit_floor as 
(
select name,floor,count(1) as no_of_floor_visit,rank() over(partition by name order by count(1) desc) as rn from `dataset19072025.entries` group by name,floor
)
select cr.name,cr.total_count,mv.floor,cr.resources_used 
from concat_resources cr 
left join most_visit_floor as mv 
on cr.name=mv.name and mv.rn =  1;


_______________________________

CREATE TABLE dataset19072025.transactions (
    txn_date DATE,
    accno INT,
    amount NUMERIC,
    trantype STRING  -- 'D' for Debit, 'C' for Credit
);


INSERT INTO dataset19072025.transactions (txn_date, accno, amount, trantype) VALUES
('2025-07-01', 1001, 500.00, 'D'),
('2025-07-01', 1001, 200.00, 'C'),
('2025-07-02', 1002, 1500.00, 'D'),
('2025-07-02', 1003, 750.00, 'C'),
('2025-07-03', 1001, 300.00, 'D'),
('2025-07-04', 1004, 1200.00, 'C'),
('2025-07-04', 1002, 1000.00, 'C'),
('2025-07-05', 1003, 400.00, 'D'),
('2025-07-05', 1005, 800.00, 'C'),
('2025-07-06', 1001, 250.00, 'D');


select * from dataset19072025.transactions

select accno, 
sum(case when trantype = 'C' then amount
         when trantype = 'D' then -amount   
         end) as balance
from dataset19072025.transactions
group by accno


____________________

-- running order amount on date

select 
customer_id,
order_date,
sum(order_amount) over (partition by customer_id order by order_date) as run_bal
from `dataset19072025.customer_orders`