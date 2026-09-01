-- SECTION D: Product & Seller Performance


-- Query 15: Top 10 Best-Selling Product Categories by Revenue
-- Business Question: Which product categories generate the most revenue, and should be prioritized for inventory/marketing focus?
select pc.product_category_name_english,
	sum(oi.price) as total_revenue
from order_items oi
join products p
on oi.product_id = p.product_id
join orders o 
on o.order_id = oi.order_id
join product_category pc 
on p.product_category_name = pc.product_category_name
where o.order_status = 'delivered'
group by pc.product_category_name_english
order by total_revenue DESC
Limit 10;


-- Query 16: Top 10 Worst-Reviewed Product Categories
-- Business Question: Which product categories have the lowest customer satisfaction, and might need quality or listing improvements?
select pc.product_category_name_english,AVG(r.review_score) as ratings
from products p
join order_items oi
on p.product_id = oi.product_id
join reviews r 
on r.order_id = oi.order_id
join product_category pc
on p.product_category_name = pc.product_category_name
join orders o
on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by pc.product_category_name_english
having count(r.review_score) >= 30
order by ratings
limit 10;


-- Query 17: Seller Performance — Revenue and Avg Review Score per Seller
-- Business Question: Which sellers are our top performers by revenue, and do high-revenue sellers also maintain good review scores — or are some sellers driving revenue at the cost of customer satisfaction?
select s.seller_id ,
	s.seller_state,
	SUM(oi.price) as Total_revenue,
	COUNT(DISTINCT o.order_id) as Total_orders,
	Round(AVG(r.review_score),2) as Rating
from orders o
join order_items oi
on o.order_id = oi.order_id
join sellers s
on oi.seller_id = s.seller_id
join reviews r
on oi.order_id = r.order_id
where o.order_status = 'delivered'
group by s.seller_id,s.seller_state
having count(DISTINCT o.order_id) >= 30
order by Total_revenue DESC
limit 10;


-- Query 18: Products with High Return/Cancellation Rate
-- Business Question: Which product categories have unusually high cancellation or unavailability rates — a signal of inventory, listing accuracy, or fulfillment problems?
with orderdata as	
	(select pc.product_category_name_english,
		count(case when o.order_status in ('canceled','unavailable') then 1 end) as canceled_count,
		count(Distinct o.order_id) as Total_count
	from orders o
	join order_items oi
	on o.order_id = oi.order_id
	join products p
	on oi.product_id = p.product_id
	join product_category pc
	on p.product_category_name = pc.product_category_name
	group by pc.product_category_name_english
	having count(Distinct o.order_id) >= 100)     
select *, 
	Round((canceled_count::numeric/total_count::numeric)*100,2) as canceletion_pct
from orderdata
order by canceletion_pct DESC
limit 15;
