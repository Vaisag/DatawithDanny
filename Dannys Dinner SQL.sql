/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, sum(price) FROM (
SELECT *
FROM dannys_diner.sales s
join dannys_diner.menu m on s.product_id = m.product_id ) firstq
group by customer_id 
order by customer_id;
;

-- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct(order_date))
FROM dannys_diner.sales s
group by customer_id ;

-- 3. What was the first item from the menu purchased by each customer?

Select * from (SELECT s.customer_id
, s.order_date
, m.product_id
, m.product_name
, row_number() over(partition by customer_id order by customer_id, order_date) as rnum
FROM dannys_diner.sales s
join dannys_diner.menu m on s.product_id = m.product_id 
order by customer_id,order_date) firstq
where firstq.rnum = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name,count(m.product_name)
FROM dannys_diner.sales s
join dannys_diner.menu m on s.product_id = m.product_id 
group by m.product_name 
order by 2 desc
limit 1; 

-- 5. Which item was the most popular for each customer?
select customer_id,product_id, tot_orders from (SELECT *,
row_number() over(partition by customer_id order by tot_orders desc) as best_prod                                           
from (SELECT s.customer_id, s.product_id
, row_number() over(partition by s.customer_id,s.product_id
                    order by s.customer_id) as tot_orders
FROM dannys_diner.sales s
join dannys_diner.menu m on s.product_id = m.product_id) firstq
order by customer_id,tot_orders desc) secondq
where best_prod = 1;


-- 6. Which item was purchased first by the customer after they became a member?

select * from (select *
, row_number() over(partition by customer_id order by join_date) rankpur
from (
  SELECT s.customer_id,
  u.join_date,
  s.order_date,
  m.product_name
FROM dannys_diner.sales s
join dannys_diner.menu m on s.product_id = m.product_id
join dannys_diner.members u on u.customer_id = s.customer_id
) firstq where order_date >= join_date
order by 1,2) secq
where rankpur = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH cte_firstq as (
select u.customer_id, u.join_date, s.order_date
  , m.product_name
  , m.price
  from dannys_diner.sales s
  join dannys_diner.menu m on s.product_id = m.product_id
  join dannys_diner.members u on s.customer_id = u.customer_id)
  ,
  cte_secondq as (
  select customer_id, join_date, order_date 
  , product_name
  , price
  from cte_firstq 
  where order_date < join_date
  )
  
select * from (select 
  customer_id
  , join_date
  , order_date
  , product_name
  , row_number() over(partition by customer_id order by order_date desc) as purdate
  from cte_secondq) thirdq
  where purdate = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte_firstq as (
select u.customer_id, u.join_date, s.order_date
  , m.product_name
  , m.price
  from dannys_diner.sales s
  join dannys_diner.menu m on s.product_id = m.product_id
  join dannys_diner.members u on s.customer_id = u.customer_id)
  ,
  cte_secondq as (
  select customer_id, join_date, order_date 
  , product_name
  , price
  from cte_firstq 
  where order_date < join_date
  )
  
select customer_id
,sum(price) 
from cte_secondq
group by customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH cte_firstq as (
select s.customer_id, u.join_date, s.order_date
  , m.product_name
  , m.price
  from dannys_diner.sales s
  join dannys_diner.menu m on s.product_id = m.product_id
  left join dannys_diner.members u on s.customer_id = u.customer_id)
 , cte_secondq as (
 select customer_id, 
   case 
   when product_name = 'sushi' THEN price * 2 
   ELSE price  
   END points
   from cte_firstq          
 )
 
 select customer_id,
 sum(points) 
 from cte_secondq
 group by customer_id;
 
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 
WITH cte_firstq as (
select s.customer_id, u.join_date, s.order_date
  , m.product_name
  , m.price
  from dannys_diner.sales s
  join dannys_diner.menu m on s.product_id = m.product_id
  join dannys_diner.members u on s.customer_id = u.customer_id
where order_date < '2021-02-01')
 , cte_secondq as (
 select customer_id, 
   case 
   when product_name = 'sushi' THEN price * 2 
   when order_date <= join_date + INTERVAL '7 days' and order_date >= join_date THEN price * 2
   ELSE price  
   END points
   from cte_firstq          
 )
 select customer_id,sum(points) from cte_secondq
 group by customer_id