-- SECTION E: Payments


-- Query 19: Revenue Breakdown by Payment Type
-- Business question: "How do customers prefer to pay, and which payment methods bring in the most revenue?"
select p.payment_type,
	SUM(p.payment_value) as Revenue_by_payment,
	(SUM(p.payment_value)/SUM(SUM(p.payment_value)) over())*100 as revenue_pct_share
from payments p
join orders o
on p.order_id = o.order_id
where o.order_status = 'delivered'
group by payment_type
order by Revenue_by_payment DESC;


-- Query 20: Average Order Value by Installment Bucket
-- Business question: "Do customers making larger purchases tend to split payment across more installments?"
with payment_buckets as	
	(select *,
		case
			when payment_installments = 0 then '0_installments'
		    when payment_installments = 1 then '1_one'
    		when payment_installments between 2 and 3 then '2_two_to_three'
    		when payment_installments between 4 and 6 then '3_four_to_six'
    		when payment_installments >= 7 then '4_seven_plus'
		end as payment_bucket
	from payments p 
	join orders o
	on p.order_id = o.order_id
	where o.order_status = 'delivered')
select payment_bucket,
	Round(AVG(payment_value),2) as Revenue
from payment_buckets
group by payment_bucket
order by payment_bucket;