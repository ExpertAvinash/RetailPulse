-- SECTION C: Delivery & Operations


-- Query 11: Average Delivery Time (Actual vs Estimated) — Overall
-- Business Question: On average, how long do deliveries actually take, and how does that compare to what we promise customers at checkout?
select EXTRACT(day from AVG(order_delivered_customer_date - order_purchase_timestamp)) as actual_delivery,
	EXTRACT(day from AVG(order_estimated_delivery_date - order_purchase_timestamp)) as estimated_delivery,
 	EXTRACT(day from AVG(order_estimated_delivery_date - order_purchase_timestamp)) - EXTRACT(day from AVG(order_delivered_customer_date - order_purchase_timestamp)) as difference
from orders
where order_status = 'delivered';


-- Query 12: % of Orders Delivered Late
-- Business Question: What percentage of all delivered orders actually arrived after the promised estimated delivery date?
select
	count(case when order_delivered_customer_date>order_estimated_delivery_date then 1 end) as late_orders,
	count(order_delivered_customer_date) as Total_delivery,
	Round(count(case when order_delivered_customer_date>order_estimated_delivery_date then 1 end)::numeric/count(order_delivered_customer_date) * 100,2) as late_percentage
from orders
where order_status = 'delivered';


-- Query 13: Late Delivery Rate by Seller State
-- Business Question: Are delivery delays concentrated in certain seller regions, or spread evenly? Which seller states have the worst on-time performance?
select s.seller_state,
	count(case when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 end) as late_per_seller,
	count(order_delivered_customer_date) as Total_delivery,
	Round(count(case when order_delivered_customer_date>order_estimated_delivery_date then 1 end)::numeric/count(o.order_delivered_customer_date) * 100,2) as late_percentage
from sellers s
join order_items oi 
on s.seller_id = oi.seller_id
join orders o
on oi.order_id = o.order_id
where order_status = 'delivered'
group by s.seller_state
order by late_percentage DESC;


-- Query 14: Delivery Delay vs Review Score
-- Business Question: Does a late delivery actually hurt review scores, and if so, by how much?
with reviewdata as 
(select o.order_id,r.review_id, o.order_delivered_customer_date, o.order_estimated_delivery_date,r.review_score,
	o.order_delivered_customer_date - o.order_estimated_delivery_date  as delivery_delay 
	from orders o
	join reviews r
	on o.order_id = r.order_id
	where (o.order_delivered_customer_date is not null 
		and o.order_estimated_delivery_date is not null))
, 
data as 
(select delivery_delay,review_score,
	case
		when Extract(day from delivery_delay) >= 4 then 'later_4+day'
		when Extract(day from delivery_delay) > 0 then 'later_1to3_days'
		when Extract(day from delivery_delay) <= 0 then 'Early_on_time'
		end as delivery_time
	from reviewdata)
select delivery_time,Round(AVG(review_score),3)
from data
group by delivery_time;