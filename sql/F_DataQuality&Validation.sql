-- SECTION F: Data Quality / Validation


-- Query 21: Order Items Price Total ≠ Payments Total (Mismatch Check)
-- Business Question: Do order_items totals (price + freight) match payments totals, or are there discrepancies?
with payment_table as (
	select p.order_id, 
		SUM(payment_value) as Total_payments
	from payments p
	join orders o
	on p.order_id = o.order_id
	where o.order_status = 'delivered'
	group by p.order_id
),
order_table as (
	select o.order_id, 
		SUM(price+freight_value) as total_amount
	from order_items oi 
	join orders o
	on oi.order_id = o.order_id
	where o.order_status = 'delivered'
	group by o.order_id
),
mismatch as (
	select p.order_id,
		p.total_payments, 
		o.total_amount,
		p.total_payments - o.total_amount as difference
	from payment_table p
	join order_table o 
	on p.order_id = o.order_id
	WHERE ABS(p.total_payments - o.total_amount) > 1
)
SELECT COUNT(*) as Total_mismatch FROM mismatch;


-- Query 22: Check for Duplicate review_ids
-- Business Question: Are there any duplicate review_ids indicating a data integrity issue?
select review_id, count(review_id) as Duplicates
from reviews
group by review_id
having count(review_id)>1;


-- Query 23: Orders with Missing Delivery Dates (Still in Transit / Lost)
-- Business Question: How many orders have no delivery date recorded, and is that expected or a data issue?
select order_status, count(*) as count_data
from orders
where order_delivered_customer_date is null 
group by order_status
order by count_data;