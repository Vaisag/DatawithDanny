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

update pizza_runner.runner_orders
set pickup_time = 
case when pickup_time = 'null' then null
else pickup_time
end;
alter table pizza_runner.runner_orders
alter column pickup_time type timestamp
using pickup_time::timestamp;

select * from pizza_runner.runner_orders;

-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select to_char(registration_date,'week'),count(runner_id) from pizza_runner.runners
group by to_char(registration_date,'week'); 

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id, avg(time_taken)/60,2 diff  from (select ro.order_id, ro.runner_id
, extract(epoch from ro.pickup_time - co.order_time)  as time_taken
from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on ro.order_id = co.order_id
where cancellation is null) firstq
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

select firstq.order_id
, ro.pickup_time
, firstq.cnt
, extract(epoch from ro.pickup_time - firstq.order_time)/60 time_delay
from (select order_id
               , max(order_time)as order_time 
               ,count(order_id) as cnt 
from pizza_runner.customer_orders co
group by order_id
order by order_id) firstq 
join pizza_runner.runner_orders ro on firstq.order_id = ro.order_id
where cancellation is null;

-- 4. What was the average distance travelled for each customer?

update pizza_runner.runner_orders
set duration =
case 
when duration = 'null' then null
when duration like '%mi%' then substr(duration,1,2)
else duration
end;

select * from pizza_runner.runner_orders;

select customer_id, round(avg(cast (duration as numeric)),2) as duration from (select *
from pizza_runner.customer_orders co
join pizza_runner.runner_orders ro on ro.order_id = co.order_id
where cancellation is null) firstq
group by customer_id;
                                       

-- 5. What was the difference between the longest and shortest delivery times for all orders?

select cast(max(duration) as numeric) - cast(min(duration) as numeric) as difference from pizza_runner.runner_orders; 

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

update pizza_runner.runner_orders 
set distance = 
case when distance = 'null' then 0
when distance similar to '%km' then cast(trim(trim('km' from distance)) as numeric) 
else cast(trim(distance) as numeric)
end;

select * from pizza_runner.runner_orders ;

select runner_id, round(avg(cast(distance as numeric)/(cast(duration as numeric))),2) as speed
from pizza_runner.runner_orders ro
group by runner_id;

-- 7. What is the successful delivery percentage for each runner?

select runner_id, 
cast(count(*) * 100/(select count(*) from pizza_runner.runner_orders where cancellation is null) as decimal(5,2)) as percentage
from (select * from pizza_runner.runner_orders where cancellation is null) firstq
group by runner_id;
