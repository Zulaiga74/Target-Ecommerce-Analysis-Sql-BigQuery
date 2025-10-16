select*from `Target_SQL.customers`;
select*from `Target_SQL.orders`;

# Geting the time range between which the orders were placed. 
select 
min(order_purchase_timestamp) as start_time,
max(order_purchase_timestamp) as end_time
from `Target_SQL.orders`;

# Counting the Cities & States of customers who ordered during the given period.
 select
c.customer_city,c.customer_state
from `Target_SQL.customers` c
join `Target_SQL.orders` o
on c.customer_id = o.customer_id
where extract(year from o.order_purchase_timestamp) = 2018
and extract(month from o.order_purchase_timestamp) between 1 and 3;

# Is there a growing trend in the no. of orders placed over the past years? 
select
extract(month from order_purchase_timestamp) as month,
count(order_id) as order_num
from `Target_SQL.orders`
group by extract(month from order_purchase_timestamp) 
order by order_num desc;

# During what time of the day, do the Brazilian customers mostly place 
# their orders? (Dawn, Morning, Afternoon or Night) 
select
extract(hour from order_purchase_timestamp) as time,
count(order_id) as order_num
from `Target_SQL.orders`
group by extract(hour from order_purchase_timestamp)
order by order_num desc;

# Get the month on month no. of orders placed in each state. 
select
extract(month from order_purchase_timestamp) as month,
extract(year from order_purchase_timestamp) as year,
count(*) as num_orders
from `Target_SQL.orders`
group by year,month
order by year,month;

# How are the customers distributed across all the states? 
select
customer_city,customer_state,
count(distinct customer_id) as customer_count
from `Target_SQL.customers`
group by customer_city,customer_state
order by customer_count desc;

# Get the % increase in the cost of orders from year 2017 to 2018 
-- (include months between Jan to Aug only). 
-- You can use the "payment_value" column in the payments table to get 
-- the cost of orders.
with yearly_totals as
(
select
extract(year from o.order_purchase_timestamp) as year,
sum(p.payment_value) as total_payment
from `Target_SQL.payments` p
join `Target_SQL.orders` o
on p.order_id = o.order_id
where extract(year from order_purchase_timestamp) in (2017,2018) and
extract(month from order_purchase_timestamp) between 1 and 8
group by year
order by total_payment desc),
yearly_comparisons as(
select
year,total_payment,
lead(total_payment)over(order by year desc) as prev_payment
from yearly_totals
)
select ((total_payment-prev_payment)/prev_payment)*100
from yearly_comparisons;

# Calculate the Total & Average value of order price,order freight for each state. 
select 
c.customer_state,
avg(price) as avg_price,
sum(price) as total_price,
avg(freight_value) as avg_freight,
sum(freight_value) as total_freight
from `Target_SQL.orders` o
join `Target_SQL.order_items` oi
on o.order_id = oi.order_id
join `Target_SQL.customers` c
on o.customer_id = c.customer_id
group by c.customer_state;

# Find the no. of days taken to deliver each order from the order’s 
-- purchase date as delivery time. 
-- Also, calculate the difference (in days) between the estimated & actual 
-- delivery date of an order. 
-- Do this in a single query. 
select order_id,
date_diff(date(order_delivered_customer_date),date(order_purchase_timestamp),day) as days_to_deliver,
date_diff(date(order_delivered_customer_date),date(order_estimated_delivery_date),day) as diff_estimated_delivery
from `Target_SQL.orders`;

# Find out the top 5 states with the highest & lowest average freight value. 
select c.customer_state,
avg(freight_value) as avg_freight,
from `Target_SQL.orders` o
join `Target_SQL.order_items` oi
on o.order_id = oi.order_id
join `Target_SQL.customers` c
on o.customer_id = c.customer_id
group by c.customer_state
order by avg_freight desc
limit 5;

# Find out the top 5 states with the highest & lowest average delivery time.
 select c.customer_state,
avg(extract(date from o.order_delivered_customer_date)-extract(date from order_purchase_timestamp)) as
avg_time_to_delivery
from `Target_SQL.orders` o
join `Target_SQL.order_items` oi
on o.order_id = oi.order_id
join `Target_SQL.customers` c
on o.customer_id = c.customer_id
group by c.customer_state
order by avg_time_to_delivery desc
limit 5;

# Find the month on month no. of orders placed using different payment types.  
select
payment_type,
extract(year from order_purchase_timestamp) as year,
extract(month from order_purchase_timestamp) as month,
count(distinct o.order_id) as num_orders
from `Target_SQL.orders` o
join `Target_SQL.payments` p
on o.order_id = p.order_id
group by payment_type,year,month
order by payment_type,year,month;

# Find the no. of orders placed on the basis of the payment installments that have been paid 
select payment_installments,
count(order_id) as num_orders
from `Target_SQL.payments`
group by payment_installments;
