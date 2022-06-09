--Schema SQL Query SQL ResultsEdit on DB Fiddle
-- Example Query:
SELECT
	runners.runner_id,
    runners.registration_date,
	COUNT(DISTINCT runner_orders.order_id) AS orders
FROM pizza_runner.runners
INNER JOIN pizza_runner.runner_orders
	ON runners.runner_id = runner_orders.runner_id
WHERE runner_orders.cancellation IS NOT NULL
GROUP BY
	runners.runner_id,
    runners.registration_date;
    
-- Clear out nulls

select * from pizza_runner.customer_orders
where extras is not null and extras != 'null';

update pizza_runner.customer_orders
set extras = 
case 
when extras is null then null
when extras = 'null' then null
when extras = '' then null
else extras
end ;

update pizza_runner.customer_orders
set exclusions = 
case 
when exclusions is null then null
when exclusions = 'null' then null
when exclusions = '' then null
else exclusions
end ;

select * from pizza_runner.runner_orders
where cancellation is not null;

update pizza_runner.runner_orders
set cancellation = 
case 
when cancellation is null then null
when cancellation = 'null' then null
when cancellation = '' then null
else cancellation
end ;

select * from pizza_runner.runner_orders;


-- A. Pizza Metrics
-- 1. How many pizzas were ordered?
select count(*) from pizza_runner.customer_orders ; 

-- 2. How many unique customer orders were made?
select count(distinct(order_id)) from pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?
select count(*) from pizza_runner.runner_orders
where cancellation not like '%Cancel%';

-- 4. How many of each type of pizza was delivered?
select pizza_name, count(*) from (select * from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on co.order_id = ro.order_id
join pizza_runner.pizza_names pn on pn.pizza_id = co.pizza_id
where ro.cancellation not like '%Cancel%') firstq
group by pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name, count(*) from (select * from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on co.order_id = ro.order_id
join pizza_runner.pizza_names pn on pn.pizza_id = co.pizza_id
where ro.cancellation not like '%Cancel%') firstq
group by customer_id,pizza_name
order by customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
select * from(
  select order_id, count(*) as maxnum
from pizza_runner.customer_orders
group by order_id) firstq
order by maxnum desc
limit 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change --    and how many had no changes?

select * from pizza_runner.customer_orders;
select * from pizza_runner.runner_orders;

select customer_id, count(*) from (select * from (select * from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null) firstq
where exclusions is not null or extras is not null) secondq
group by customer_id;



-- 8. How many pizzas were delivered that had both exclusions and extras?
select count(*) from (select * from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null) firstq
where exclusions is not null and extras is not null;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

select date_part('hour',order_time), count(*) from pizza_runner.customer_orders
group by 
--date_part('year',order_time),
--date_part('month',order_time),
--date_part('day',order_time),
date_part('hour',order_time);

-- 10. What was the volume of orders for each day of the week?

select to_char(order_time,'day'), count(*) from pizza_runner.customer_orders
group by 
to_char(order_time,'day');
