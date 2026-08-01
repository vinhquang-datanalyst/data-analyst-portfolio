/*====================================================
Business Question 1
Yearly Sales Trend

Objective:
Analyze yearly sales performance to identify overall revenue trends.
====================================================*/
select
	extract(year from order_date) as year,
	sum(sales) as total_sales
from superstore
group by year
order by year desc;


/*====================================================
Business Question 2
Revenue Contribution by Region

Objective:
Measure each region's contribution to total company revenue.
====================================================*/
with si as
(
select
	region,
	sum(sales) as total_sales
from superstore
group by region
),
si2 as
(
select 
	region,
	total_sales,
	dense_rank() over(order by total_sales desc) as r,
	round(total_sales*100 / coalesce(sum(total_sales) over(),0),2) as percent_of_company
from si
group by region, total_sales
)
select 
	region,
	total_sales,
	percent_of_company
from si2;


/*====================================================
Business Question 3
Top 5 Customers by Revenue

Objective:
Identify the top five customers generating the highest sales.
====================================================*/
with si as
(
select
	customer_name,
	sum(sales) as total_sales,
	dense_rank() over(order by sum(sales) desc) as r
from superstore
group by customer_name
)
select 
	customer_name,
	total_sales
from si
where r <=5;


/*====================================================
Business Question 4
Top 3 Products by Region

Objective:
Find the three best-selling products in each region.
====================================================*/
with product_info as
(
select
	product_name,
	region,
	sum(sales) as total_sales
from superstore
group by product_name, region
),
product_ranked as
(
select *,
	dense_rank() over(
		partition by region
		order by total_sales desc
	) as r
from product_info
)
select 
	product_name,
	region,
	total_sales
from product_ranked
where r <= 3
order by region, total_sales desc;


/*====================================================
Business Question 5
Top Customer in Each Region

Objective:
Identify the highest revenue customer within every region.
====================================================*/
with sales_by_region as
(
select 
	region,
	customer_name,
	sum(sales) as total_sales,
	dense_rank() over(
		partition by region
		order by sum(sales) desc
		) as r
from superstore
group by region, customer_name
)
select 
	region,
	customer_name,
	total_sales
from sales_by_region
where r = 1
order by total_sales desc;


/*====================================================
Business Question 6
Pareto Analysis (80/20 Rule)

Objective:
Determine the percentage of customers required to generate 80% of total company revenue.
====================================================*/
with sales_by_cus as 
(
select 
	customer_name,
	sum(sales) as sales_of_customer
from superstore
group by customer_name
),
percent_of_com as
(
select *,
	round(sales_of_customer*100
	/
	sum(sales_of_customer) over(),2) as "% company"
from sales_by_cus
),
running_total as
(
select *,
	sum("% company") over(
		order by sales_of_customer desc) 
	as "% running total"
from percent_of_com
)
select
	round((select count(*) from running_total
	where "% running total" <=80)::numeric*100
	/
	(select count(*) from running_total)::numeric,2) as ratio;


/*====================================================
Business Question 7
Top Category by Region

Objective:
Determine the highest-performing product category in each region.
====================================================*/
with sales_by_region as
(
select
	region,
	category,
	sum(sales) as total_sales,
	dense_rank() over(
		partition by region
		order by sum(sales) desc) as r
from superstore
group by region, category
)
select 
	region,
	category,
	total_sales
from sales_by_region
where r = 1
order by total_sales desc;


/*====================================================
Business Question 8
Peak Sales Month by Region

Objective:
Identify the overall peak sales month in each region.
====================================================*/
with sales_by_mons as
(
select
	region,
	extract(month from order_date) as month,
	sum(sales) as total_sales
from superstore
group by region, month
),
ranked_by_mons as
(
select *,
	dense_rank() over(
		partition by region
		order by total_sales desc
	) as r
from sales_by_mons
)
select 
	region,
	month,
	total_sales
from ranked_by_mons
where r = 1
order by total_sales desc;


/*====================================================
Business Question 9
Most Frequent Customers

Objective:
Identify customers with the highest purchase frequency and total revenue.
====================================================*/
select  	
	customer_name,
	count(distinct order_id) as number_of_orders,
	sum(sales) as total_sales
from superstore
group by customer_name
order by number_of_orders desc, total_sales desc
limit 10;
