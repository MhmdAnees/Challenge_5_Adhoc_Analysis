#Task 1
SELECT 
distinct market 
FROM dim_customer
WHERE customer="Atliq Exclusive" AND   region = "APAC";

#Task 2
SELECT 
    COUNT(DISTINCT CASE WHEN f.fiscal_year = 2020 THEN p.product_code END) AS unique_products_2020,
    COUNT(distinct CASE WHEN f.fiscal_year = 2021 THEN p.product_code END) AS unique_products_2021,
    (COUNT(DISTINCT CASE WHEN f.fiscal_year = 2021 THEN p.product_code END)  -
    COUNT(distinct CASE WHEN f.fiscal_year = 2020 THEN p.product_code END) ) /nullif(COUNT(DISTINCT CASE WHEN f.fiscal_year = 2020 THEN p.product_code END),0)*100
    AS percentage_chg
FROM 
    dim_product p
JOIN 
    fact_sales_monthly f 
    
ON p.product_code = f.product_code
WHERE 
    f.fiscal_year IN (2020, 2021);

#Task 3
select 
segment, COUNT(distinct product_code) as product_count
from dim_product
GROUP BY 1
ORDER BY 2 DESC
;

#Task 4
select segment,
COUNT(distinct CASE
WHEN
 fm.fiscal_year = 2020 then p.product_code END) as product_count_2020,
 COUNT(distinct CASE
WHEN
 fm.fiscal_year = 2021 then p.product_code END) as product_count_2021,
 (COUNT(distinct CASE
WHEN
 fm.fiscal_year = 2021 then p.product_code END) - COUNT(distinct CASE
WHEN
 fm.fiscal_year = 2020 then p.product_code END)) as "2021 vs 2020"
from dim_product p 
JOIN fact_sales_monthly fm
ON fm.product_code = p.product_code
GROUP BY 1;

#Task 5
SELECT m.product_code, concat(product," (",variant,")") AS product, cost_year,manufacturing_cost
FROM fact_manufacturing_cost m
JOIN dim_product p ON m.product_code = p.product_code
WHERE manufacturing_cost= 
(SELECT min(manufacturing_cost) FROM fact_manufacturing_cost)
or 
manufacturing_cost = 
(SELECT max(manufacturing_cost) FROM fact_manufacturing_cost) 
ORDER BY manufacturing_cost DESC;


#Task 6
SELECT 
c.customer_code,c.customer, ROUND(p.pre_invoice_discount_pct*100,2) as average_discount_percentage
FROM 
dim_customer c
JOIN fact_pre_invoice_deductions p
ON c.customer_code = p.customer_code
WHERE p.pre_invoice_discount_pct > (SELECT 
AVG(pre_invoice_discount_pct) as average_discount_percentage
FROM gdb023.fact_pre_invoice_deductions)
order by average_discount_percentage DESC
LIMIT 5;

#Task 7
with t1 as (select 
monthname(date) as Month, year(date) as Year,(sold_quantity * gross_price)  AS gross_sales
from 
fact_sales_monthly m
JOIN fact_gross_price g
ON m.product_code = g.product_code
JOIN dim_customer c
ON m.customer_code = c.customer_code
WHERE c.customer="Atliq exclusive")

select 
Month, YEAR,CONCAT(ROUND(SUM(gross_sales)/1000000,2),"M") as Gross_Sales_Million
from t1
GROUP BY 1,2;

#Task 8
SELECT CASE  
WHEN MONTH(date) IN (9, 10, 11) THEN "Q1"
WHEN MONTH(date) IN (12, 1, 2) THEN ' Q2'
WHEN MONTH(date) IN (3, 4, 5) THEN 'Q3'
WHEN MONTH(date) IN (6, 7, 8) THEN 'Q4'
END AS 'Quarter',round(sum(sold_quantity)/1000000,2) as total_sold_Quantity
FROM gdb023.fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY 1
ORDER BY 2 DESC;

#Task 9
with t1 as (select 
c.channel, SUM(m.sold_quantity*g.gross_price) as gross_sales_amt
from dim_customer c
JOIN fact_sales_monthly m
ON c.customer_code = m.customer_code
JOIN fact_gross_price g
ON m.product_code = g.product_code
group by 1)
select 
channel, 
round(gross_sales_amt/1000000,2) as gross_sales_amt,
round(gross_sales_amt/(SUM(gross_sales_amt) OVER())*100,2) as percentage_contribution
from t1;

#Task 10
select 
p.division,m.product_code,p.product,SUM(sold_quantity) as total_sold_quantity,
dense_rank() OVER(order by SUM(sold_quantity) DESC) as ranks
from 
fact_sales_monthly m
JOIN dim_product p
ON m.product_code = p.product_code
WHERE m.fiscal_year = 2021
GROUP BY 1,2,3
ORDER BY ranks 
LIMIT 3;
