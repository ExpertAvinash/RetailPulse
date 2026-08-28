-- Section-B: Customer Analysis


-- Query 6: Customer Lifetime Value — Top 10 by Spend
-- Business Question: Who are our highest-spending customers, and how many orders have they placed?
select  c.customer_unique_id, 
	count(DISTINCT o.order_id) as total_order_placed,
	sum(price) as total_spent
from orders o
join order_items oi 
on o.order_id = oi.order_id
join customers as c
on o.customer_id = c.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
order by total_spent DESC, total_order_placed DESC
limit 10;


-- Query 7: Recency — Days Since Last Order
-- Business Question: How long has it been since each customer's last purchase?
with date_reference as
(select max(order_purchase_timestamp) as reference from orders where order_status = 'delivered')
, 
customer_data as 
	(select c.customer_unique_id,max(o.order_purchase_timestamp) as last_order
	from customers c
	join orders o 
	on c.customer_id = o.customer_id
	where o.order_status = 'delivered'
	group by c.customer_unique_id)
select customer_unique_id,
		extract(day from (select reference from date_reference) - last_order) as recency_days
from customer_data;


-- Query 8: Combined RFM Table (Recency, Frequency, Monetary)
-- Business Question: What does each customer's full purchase behavior look like — recency, order count, and total spend?
select c.customer_unique_id,
	extract(day from (select max(order_purchase_timestamp) from orders where order_status = 'delivered') - max(order_purchase_timestamp)) as Recency,
	count(distinct o.order_id) as Frequency,
	sum(oi.price) as Monetory
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by c.customer_unique_id
order by Monetory DESC, Frequency DESC, Recency DESC;


-- Query 9: Repeat vs One-Time Customer Analysis (Count + Revenue Contribution)
-- Business Question: What % of customers are repeat buyers, and how much more do they spend on average vs. one-time buyers?
with customers_data as (
	select c.customer_unique_id,
		sum(oi.price) as total_spent,
		count(DISTINCT o.order_id) as total_order_placed
	from orders o
	join order_items oi
	on o.order_id = oi.order_id
	join customers c
	on o.customer_id = c.customer_id
	where o.order_status = 'delivered'
	group by c.customer_unique_id
	order by total_order_placed 
)
select 
	count(case when total_order_placed = 1 then 1 END) as onetime_customer,
	count(case when total_order_placed > 1 then 1 END) as repeated_customer,
	round(AVG(case when total_order_placed = 1 then total_spent end),2) as onetime_buys,
	round(AVG(case when total_order_placed > 1 then total_spent end),2) as reptead_buys,
	round(Sum(case when total_order_placed > 1 then total_spent end)/sum(total_spent) *100,2) as repeated_revenue_pct,
	round(((count(case when total_order_placed > 1 then 1 END))::numeric / (count(case when total_order_placed = 1 then 1 END) + count(case when total_order_placed > 1 then 1 END)))*100,2) as repeated_customers_pct
from customers_data;


-- Query 10: New vs Returning Customers per Month
-- Business Question: Each month, how much of our order volume comes from new customers vs. repeat buyers?
with customer_data as (
	select c.customer_id,
		c.customer_unique_id,
		o.order_purchase_timestamp,
		o.order_id,
		min(order_purchase_timestamp) over(partition by c.customer_unique_id) as First_purchase,
		case
			when o.order_purchase_timestamp = min(order_purchase_timestamp) over(partition by c.customer_unique_id) then 'New Customer' else 'Returning'
			end as Customer_status
	from customers c
	join orders o
	on c.customer_id = o.customer_id
	where o.order_status = 'delivered'
)
select DATE_TRUNC('month',order_purchase_timestamp), 
	customer_status,
	count(customer_status) as Buyers,
	count(DISTINCT order_id) as Total_orders
from customer_data 
group by DATE_TRUNC('month',order_purchase_timestamp), customer_status
order by DATE_TRUNC('month',order_purchase_timestamp), customer_status;

