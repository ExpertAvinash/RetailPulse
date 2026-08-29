-- SECTION-A: REVENUE AND TRENDS


-- Query 1: Monthly Revenue & Order Count
-- Business Question: How is our revenue and order volume trending month over month?
select DATE_TRUNC('Month',o.order_purchase_timestamp) as month,
COUNT(DISTINCT o.order_id) as total_orders,
SUM(oi.price) as Revenue
from orders o
join order_items oi
on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by DATE_TRUNC('Month',o.order_purchase_timestamp)
order by month;


-- Query 2: Month-over-Month Revenue Growth %
-- Business Question: Is revenue growth accelerating, decelerating, or volatile month to month?
with monthly_update as (
	select month,
	total_revenue,
	lag(total_revenue) over(order by month) as previous_month_revenue
	from (select DATE_TRUNC('Month',o.order_purchase_timestamp) as month,
		sum(oi.price) as total_revenue
		from orders o
		join order_items oi
		on o.order_id = oi.order_id
		where o.order_status = 'delivered'
		group by DATE_TRUNC('Month', o.order_purchase_timestamp))
)
select month,
	total_revenue,
	previous_month_revenue,
	Round((total_revenue - previous_month_revenue) / previous_month_revenue * 100,2) as growth_percent
from monthly_update;


-- Query 3: Revenue by Product Category (Top 10)
-- Business Question: Which product categories are driving the majority of our revenue?
select p.product_category_name, pc.product_category_name_english, sum(oi.price) as revenue
from orders o
join order_items oi 
on o.order_id = oi.order_id
join products p 
on oi.product_id = p.product_id
join product_category pc
on p.product_category_name = pc.product_category_name
where o.order_status = 'delivered'
group by p.product_category_name , pc.product_category_name_english
order by sum(oi.price) desc
limit 10;


-- Query 4: Revenue by Customer State/Region
-- Business Question: Which regions generate the most revenue, and which have the highest-value customers per capita?
select c.customer_state,
		count(Distinct c.customer_unique_id) as total_customers,
		sum(oi.price) as Total_revenue,
		Round(sum(oi.price)/count(Distinct c.customer_unique_id),2) as revenue_per_customer
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by c.customer_state
order by total_revenue DESC;


-- Query 5: Average Order Value (AOV) Trend by Month
-- Business Question: Are customers spending more per order over time, or is revenue growth purely from more orders?
select Date_trunc('month' , o.order_purchase_timestamp) as month,
	sum(oi.price) as Total_revenue,
	count(distinct o.order_id) as total_orders,
	round(sum(oi.price)/count(distinct o.order_id),2) as Avg_order_value
from orders o
join order_items oi
on o.order_id = oi.order_id
where order_status = 'delivered'
group by Date_trunc('month' , o.order_purchase_timestamp)
order by Date_trunc('month' , o.order_purchase_timestamp); -- used date for order by as we want to know about the pattern
