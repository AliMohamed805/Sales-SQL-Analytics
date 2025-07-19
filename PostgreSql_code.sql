select  order_date,
        sales_amount
from gold_fact_sales
order by order_date;

--

select  order_date,
        sales_amount
from gold_fact_sales
where order_date is null
order by order_date;

--

select  *
from gold_fact_sales
where order_date is null
order by order_date;

--
select g1.order_number,
       g1.order_date,
       g2.order_date
    from gold_fact_sales as g1
    inner join gold_fact_sales as g2
    on g1.order_number = g2.order_number
where g2.order_date is null;

--

select (shipping_date :: date - order_date::date) as days_difference
    from gold_fact_sales;

--

update gold_fact_sales
set order_date =  shipping_date::date - interval '7 day'
where order_date is null;

--
/*                              Change Over Time Analysis                                         */

SELECT
    DATE_PART('year', order_date::date) AS order_year,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_year
ORDER BY order_year;

--
SELECT
    DATE_PART('month', order_date::date) AS order_month,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_month
ORDER BY order_month;

--

SELECT
    DATE_PART('year', order_date::date) AS order_year,
    DATE_PART('month', order_date::date) AS order_month,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_year ,
         order_month
ORDER BY order_year,
         order_month;

--

SELECT
    date_trunc('month', order_date::date) AS order_dates,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_dates
ORDER BY order_dates;

--

SELECT
    date_trunc('year', order_date::date) AS order_dates,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_dates
ORDER BY order_dates;

--
SELECT
    date_trunc('quarter', order_date::date) AS order_dates,
    SUM(sales_amount::integer) AS total_sales,
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
GROUP BY order_dates
ORDER BY order_dates;

--

/*                                 Cumulative Analysis                                  */

SELECT
    date_trunc('month', order_date::date) AS order_dates,
    SUM(sales_amount::integer) AS total_sales
FROM gold_fact_sales
GROUP BY order_dates
ORDER BY order_dates;

--
select order_dates ,
       total_sales,
       SUM(total_sales :: integer) OVER ( ORDER BY order_dates) AS cumulative_sales
from
(SELECT date_trunc('month', order_date::date) AS order_dates,
        SUM(sales_amount::integer)            AS total_sales
 FROM gold_fact_sales
 GROUP BY order_dates
 ORDER BY order_dates
) t ;

--

select order_dates ,
       total_sales,
       SUM(total_sales :: integer) OVER ( ORDER BY order_dates) AS cumulative_sales
from
    (SELECT date_trunc('year', order_date::date) AS order_dates,
            SUM(sales_amount::integer)            AS total_sales
     FROM gold_fact_sales
     GROUP BY order_dates
     ORDER BY order_dates
    ) t ;

--

select order_dates ,
       total_sales,
       SUM(total_sales :: integer) OVER ( ORDER BY order_dates) AS cumulative_sales,
       AVG(total_sales :: integer) OVER ( ORDER BY order_dates) AS moving_avg_sales
from
    (SELECT date_trunc('year', order_date::date) AS order_dates,
            SUM(sales_amount::integer)            AS total_sales,
            AVG(sales_amount::integer)            AS  avg_sales
     FROM gold_fact_sales
     GROUP BY order_dates
     ORDER BY order_dates
    ) t ;


--

/*                                 Performance Analysis                                  */

select  *
from gold_fact_sales s
left join gold_dim_products p
on s.product_key = p.product_key ;

--
select  date_part('year', order_date::date) as order_year,
        p.product_name,
        sum(s.sales_amount::integer) as total_sales
from gold_fact_sales s
         left join gold_dim_products p
                   on s.product_key = p.product_key
group by order_year,p.product_name
order by order_year ;

--
with yearly_products_sales as (
select date_part('year', order_date::date) as order_year,
p.product_name,
sum(s.sales_amount::integer)        as total_sales
from gold_fact_sales s
 left join gold_dim_products p
     on s.product_key = p.product_key
group by order_year, p.product_name
 )
select order_year,
       product_name,
       total_sales,
       avg(total_sales) over (partition by product_name) as avg_sales,
       total_sales - avg(total_sales) over (partition by product_name) as sales_difference,
       case when total_sales - avg(total_sales) over (partition by product_name) > 0 then 'Above Average'
            when total_sales - avg(total_sales) over (partition by product_name) < 0 then 'Below Average'
            else 'Average' end as performance_status ,
       lag(total_sales) over (partition by product_name order by order_year) as previous_year_sales,
         total_sales - lag(total_sales) over (partition by product_name order by order_year) as sales_change,
         case when total_sales - lag(total_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
                when total_sales - lag(total_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
                else 'No Change' end as sales_trend
from yearly_products_sales;

/*                                       Part-To-Whole Analysis                                          */

select category,
       sum(sales_amount::integer) as total_sales
from gold_fact_sales s
left join gold_dim_products p
on s.product_key = p.product_key
group by category ;

--
with category_sales as (
    select  category,
            sum(sales_amount::integer) as total_sales
    from gold_fact_sales s
    left join gold_dim_products p
    on s.product_key = p.product_key
    group by category
)
select category,
       total_sales,
       round(total_sales * 100.0 / sum(total_sales) over () , 2) || '%' as percentage_of_total_sales
from category_sales ;

/*                             Data Segmentation                                    */

select product_key,
       product_name,
       cost
from gold_dim_products ;

--
with product_segments as (
                       select product_key,
                       product_name,
                       cost,
                       case when  cost < 100 then 'Below 100'
            when cost between 100 and 500 then '100 - 500'
            when cost between 500 and 1000 then '500 - 1000'
            else 'Above 1000' end as cost_segment
from gold_dim_products
)
select cost_segment,
       count(*) as product_count
from product_segments
group by cost_segment
order by product_count desc;

--
with customer_spending as (select c.customer_key,
                                  sum(sales_amount::integer)                      as total_sales,
                                  min(order_date::date)                           as first_order_date,
                                  max(order_date::date)                           as last_order_date,
                                  (max(order_date::date) - min(order_date::date))/30 as Lifetime_value
                           from gold_fact_sales s
                                    left join gold_dim_customers c
                                              on s.customer_key = c.customer_key
                           group by c.customer_key )
select customer_key,
         case when Lifetime_value>=12 and  total_sales >5000 then 'VIP'
                when Lifetime_value>=12 and  total_sales <=5000 then 'Regular'
                else 'New' end as customer_segment
from customer_spending ;

--

with customer_spending as (select c.customer_key,
                                  sum(sales_amount::integer)                      as total_sales,
                                  min(order_date::date)                           as first_order_date,
                                  max(order_date::date)                           as last_order_date,
                                  (max(order_date::date) - min(order_date::date))/30 as Lifetime_value
                           from gold_fact_sales s
                                    left join gold_dim_customers c
                                              on s.customer_key = c.customer_key
                           group by c.customer_key )
select customer_segment,
       count(customer_key) as customer_count
from (
select customer_key,
       case when Lifetime_value>=12 and  total_sales >5000 then 'VIP'
            when Lifetime_value>=12 and  total_sales <=5000 then 'Regular'
            else 'New' end as customer_segment
from customer_spending ) t
group by customer_segment
order by customer_count desc;

/*                                  Building Customer Report                                     */

create view gold_customer_report as
with customer as  (with base_query AS (SELECT s.order_number,
                            s.product_key,
                            s.order_date,
                            s.sales_amount,
                            s.quantity,
                            c.customer_key,
                            c.customer_number,
                            c.first_name || ' ' || c.last_name        AS customer_name,
                            EXTRACT(YEAR FROM AGE(c.birthdate::date)) AS customer_age
                     FROM gold_fact_sales s
                              LEFT JOIN gold_dim_customers c
                                        ON s.customer_key = c.customer_key)
 SELECT customer_key,
        customer_number,
        customer_name,
        customer_age,
        COUNT(DISTINCT order_number)                                     AS total_orders,
        SUM(sales_amount::integer)                                       AS total_sales,
        SUM(quantity::integer)                                           AS total_quantity,
        COUNT(DISTINCT product_key)                                      AS total_products,
        MAX(order_date::date)                                            AS last_order_date,
        ROUND((MAX(order_date::date) - MIN(order_date::date)) / 30.0, 0) AS customer_lifespan_months
 FROM base_query
 GROUP BY customer_key,
          customer_number,
          customer_name,
          customer_age )
select customer_key,
       customer_number,
       customer_name,
       customer_age,
       case when customer_age < 20 then 'Below 20'
           when customer_age between 20 and 29 then '20 - 29'
           when customer_age between 30 and 39 then '30 - 39'
           when customer_age between 40 and 49 then '40 - 49'
           else '50 and above' end as age_segment,
       case when customer_lifespan_months >=12 and total_sales > 5000 then 'VIP'
            when customer_lifespan_months >=12 and total_sales <= 5000 then 'Regular'
            else 'New' end as customer_segment,
       total_orders,
       total_sales,
       total_quantity,
       total_products,
       last_order_date,
       customer_lifespan_months,
       case when total_sales=0 then 0
            else round((total_sales::integer * 1.0 / total_orders::integer), 2) end as average_order_value,
       case when customer_lifespan_months = 0 then 0
            else round((total_sales::integer * 1.0 / customer_lifespan_months::integer), 2) end as average_monthly_spending
    from customer;

-- Query the customer report view

select *
from gold_customer_report ;

/*                                Building Product Report                                                      */

CREATE VIEW gold_product_report AS
WITH base_query AS (
    SELECT
        s.order_number,
        s.order_date,
        s.customer_key,
        s.sales_amount::numeric,
        s.quantity::integer,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost::numeric
    FROM gold_fact_sales s
             LEFT JOIN gold_dim_products p
                       ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

     product_aggregations AS (
         SELECT
             product_key,
             product_name,
             category,
             subcategory,
             cost,
             DATE_PART('month', AGE(MAX(order_date::date), MIN(order_date::date))) AS lifespan,
             MAX(order_date::date) AS last_sale_date,
             COUNT(DISTINCT order_number) AS total_orders,
             COUNT(DISTINCT customer_key) AS total_customers,
             SUM(sales_amount) AS total_sales,
             SUM(quantity) AS total_quantity,
             ROUND(AVG(sales_amount / NULLIF(quantity, 0))::numeric, 1) AS avg_selling_price
         FROM base_query
         GROUP BY
             product_key,
             product_name,
             category,
             subcategory,
             cost
     )

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATE_PART('month', AGE(CURRENT_DATE, last_sale_date)) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
        END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE ROUND((total_sales / total_orders)::numeric, 2)
        END AS avg_order_revenue,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE ROUND((total_sales / NULLIF(lifespan, 0))::numeric, 2)
        END AS avg_monthly_revenue
FROM product_aggregations;

-- Query the product report view

SELECT *
FROM gold_product_report;