-- create database 
create database coffeeshop;

-- use database
use coffeeshop;

-- import the excel data goto "table data import wizard" --> choose path of the excel data --> continue to load the data by clicking "next"
-- wait for the data to load  

-- view tables in database
show tables;

-- view everything from table named as coffee_shop_sales
select * from coffee_shop_sales;

-- Data cleaning

-- to view datatypes (structure) of table
describe coffee_shop_sales;


-- change datatype of "transaction_date" column 
-- to change the format of "transaction_date" column 

update coffee_shop_sales set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

-- change datatype of "transaction_date" column from "int" to "date"

alter table coffee_shop_sales modify column transaction_date date;

-- change datatype of "transaction_time" column 
-- to change the format of "transaction_time" column

update coffee_shop_sales set transaction_time = str_to_date(transaction_time, '%H : %i : %s');

-- change datatype of "transaction_time" column from "int" to "time"

alter table coffee_shop_sales modify column transaction_time time;

-- alter field name form "ï»¿transaction_id" to "transaction_id"

alter table coffee_shop_sales change ï»¿transaction_id transaction_id int;

-- Data is ready for analysis
-- Total sales analysis

select 
round(sum(unit_price * transaction_qty),1) as Total_sales
from coffee_shop_sales;

-- Total sales on March month
select 
round(sum(unit_price * transaction_qty),1) as Total_sales_on_MARCH -- gives total sales value
from coffee_shop_sales
where month(transaction_date) =3 ; -- takes March month 


-- Month-on-Month increase or decrease in sales percentage

select 
month(transaction_date) as month,
round(sum(unit_price * transaction_qty),1) as Total_sales, -- total sales
round((sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1)  -- month sales difference
over (order by month(transaction_date))) / lag(sum(unit_price * transaction_qty),1) -- divide by PM sales
over (order by month(transaction_date)) * 100,1) as Month_On_Month_increase_decrease_percentage -- * 100 for percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)  -- 5 refers current month(CM) 'MAY' and 4 is 'APRIL' previous month(PM)
group by month(transaction_date)
order by month(transaction_date);

-- difference in sales between selected and previous month 
select 
month(transaction_date) as month,
round(sum(unit_price * transaction_qty),1) as Total_sales, -- total sales
round((sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1)  -- month sales difference
over (order by month(transaction_date))) ,1) as difference_in_sales_CM_PM
from coffee_shop_sales
where month(transaction_date) in (4,5)  -- 5 refers current month(CM) 'MAY' and 4 is 'APRIL' previous month(PM)
group by month(transaction_date)
order by month(transaction_date);

-- Total oredr analysis
-- Total no.of orders in each month

select count(transaction_id) as Total_orders
from coffee_shop_sales
where month(transaction_date) =3; -- total orders in march month

-- Month-on-Month increase or decrease in orders percentage
select 
month(transaction_date) as Month,
count(transaction_id) as total_orders,
(count(transaction_id) - lag(count(transaction_id),1)
over(order by month(transaction_date))) / lag(count(transaction_id),1)
over(order by month(transaction_date)) * 100 as MOM_orders_percentage
from coffee_shop_sales
where month(transaction_date) in (3,4)-- April -CM , March-PM
group by  month(transaction_date)
order by  month(transaction_date);

-- difference in orders between selected and previous month 
select 
month(transaction_date) as Month,
count(transaction_id) as total_orders,
(count(transaction_id) - lag(count(transaction_id),1)
over(order by month(transaction_date)))  as diff_in_orders
from coffee_shop_sales
where month(transaction_date) in (3,4)-- April -CM , March-PM
group by  month(transaction_date)
order by  month(transaction_date);

-- Total quantity sold analysis
-- Total quantity sold on selected month

select
month(transaction_date) as Month,
sum(transaction_qty) as Total_qty_sold
from coffee_shop_sales
where month(transaction_date) = 4
group by month(transaction_date);

-- Month-on-Month increase or decrease in Quantity sold percentage

select 
month(transaction_date) as Month,
sum(transaction_qty) as Total_qty_sold,
(sum(transaction_qty) - lag(sum(transaction_qty),1)
over (order by month(transaction_date))) / lag(sum(transaction_qty),1)
over (order by month(transaction_date)) * 100 as MOM_qty_sold_percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date) ;

-- difference in quantity sold between selected and previous month 

select month(transaction_date) as month,
round(sum(transaction_qty)) as total_qty_sold,
sum(transaction_qty) - lag(sum(transaction_qty)) 
over (order by month(transaction_date)) as diff_qty_sold
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date) 
order by month(transaction_date);

-- OVER ALL total sales, qty sold, orders 

select 
concat(round(sum(unit_price * transaction_qty)/1000,2),' K') as Total_sales,
concat(sum(transaction_qty),' K') as Total_qty_sold,
CONCAT(count(*),' K') as Total_orders
from coffee_shop_sales;

-- total sales, qty sold, orders for particular date and month

select 
transaction_date as Date,
concat(round(sum(unit_price * transaction_qty)/1000,1),' K') as Total_sales,
concat(round(sum(transaction_qty)/1000,1),'K') as Total_QTY_sold,
concat(round(count(transaction_id)/1000,1),'K') as Total_orders
from coffee_shop_sales
where transaction_date = '2023-03-27';

-- sales analysis by weekdays and weekends in a selected month

select 
case 
when dayofweek(transaction_date) in (1,7) then 'WeekEnd'
else 'Weekdays'
end as day_type,
CONCAT(round(sum(unit_price * transaction_qty)/1000,1),' k') as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day_type;

-- to show which sales is higher (weekday or weekend)

select
day_type,
Total_sales,
(case
when (select sum(unit_price * transaction_qty)
from coffee_shop_sales
where month(transaction_date) =5 and dayofweek(transaction_date) not in(1,7)) >
(select sum(unit_price * transaction_qty)
from coffee_shop_sales
where month(transaction_date) =5 and dayofweek(transaction_date) in (1,7))
then "sales are higher on week days" 
else "sales are higher on weekends" 
end) as sales_value 
from 
( select case 
when dayofweek(transaction_date) in (1,7) then "weekend"
else "weekday"
end as day_type,
CONCAT(round(sum(unit_price * transaction_qty)/1000,1),' k') as Total_sales
from coffee_shop_sales
where month(transaction_date) =5 
group by day_type
) as sales_data;

-- sales value by store location on selected month

select
store_location,
concat(round(sum(unit_price * transaction_qty)/1000,1),' K') as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5  -- remove this to check overall(for all months) sales value by store location irrespective of their month
group by store_location
order by total_sales;

-- average sales of a month
select
concat(round(avg(total_sales)/1000,2),' K') as Avg_sales
from(
select sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date
) as inner_query;
 
-- or 
select
distinct(avg(sum(unit_price * transaction_qty)) over ()) as Avg_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date;

-- daily sales of the month

select 
dayofmonth(transaction_date) as Date_of_month,
format(sum(unit_price * transaction_qty),2) as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by Date_of_month ;

-- to check sales for particular day in a month eg., 31st date in may month

select 
dayofmonth(transaction_date) as Date_of_month,
format(sum(unit_price * transaction_qty),2) as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5 and dayofmonth(transaction_date) = 31
group by Date_of_month ;

-- sales status for every day in a month based on sales avg on that month

select
day(transaction_date) as Date_of_month ,
round(sum(unit_price * transaction_qty),2) as Total_sales,
round((avg(sum(unit_price * transaction_qty)) over())) as avg_sales,
case
when sum(unit_price * transaction_qty) > (avg(sum(unit_price * transaction_qty)) over()) then "above average"
when sum(unit_price * transaction_qty) < (avg(sum(unit_price * transaction_qty)) over()) then "below average"
else "average"
end as sales_status
from coffee_shop_sales
where month(transaction_date) = 5
group by Date_of_month ;

-- (or) sales status for every day in a month based on sales avg on that month

select
day_of_month,
round(total_sales,2),
case when total_sales > avg_sales then "above average" 
when total_sales < avg_sales then "below average" 
else "average" 
end as sales_status
from (
select 
dayofmonth(transaction_date) as day_of_month,
sum(unit_price * transaction_qty) as total_sales,
(avg(sum(unit_price * transaction_qty))  over()) as avg_sales
from coffee_shop_sales
where month(transaction_date) = 5  -- change month accordingly
group by Day_of_month 
) as inner_query;

-- sales by product category
select
product_category, 
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5  
group by product_category
order by total_sales desc;


-- overall top 10 products by top sales 

select
product_type, 
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales 
group by product_type
order by total_sales desc limit 10;

-- sales for particular product category if its coffee there is different types in coffe eg., brewed coffed,Gourmet brewed coffee
select product_category,
product_type,
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales 
where month(transaction_date)=5 and product_category ='tea'  -- you can remove month filter to see over all sales 
group by product_type
order by total_sales desc;

-- sales analysis by days and hours
-- total sales,total orders,total qty sold for particular month in that selected month what is sales on particular day and particular hour
-- we are finding total sales,orders,qty sold for each monday at 8th hour in may month if we remove the "hour" condition we will get results for whole monday

select
day(transaction_date) as day_of_month,
round(sum(unit_price * transaction_qty),2) as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders
from coffee_shop_sales 
where dayofweek(transaction_date)=2  and month(transaction_date)=5 and hour(transaction_time) =8 
group by transaction_date;

--  total sales,orders,qty sold for all mondays and 8th hour in may month
select
round(sum(unit_price * transaction_qty),2) as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders
from coffee_shop_sales 
where dayofweek(transaction_date) =2 and month(transaction_date)=5 and hour(transaction_time) =8 ;

-- to find sales in peek hours

select
hour(transaction_time) as hrs,
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales 
where month(transaction_date) =5 
group by hour(transaction_time)
order by total_sales desc;

-- sales from monday to sunday

select
case
 when dayofweek(transaction_date) = 1 then "sunday"
 when dayofweek(transaction_date) = 2 then "Monday"
 when dayofweek(transaction_date) = 3 then "Tuesday"
 when dayofweek(transaction_date) = 4 then "Wednesday"
 when dayofweek(transaction_date) = 5 then "Thursday"
 when dayofweek(transaction_date) = 6 then "Friday"
 else "saturday"
 end as day_of_week,
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales 
where month(transaction_date) =5 
group by day_of_week ;


-- sales for all hours for month of may

select
hour(transaction_time) as hrs,
concat(round(sum(unit_price * transaction_qty),2),' K') as total_sales
from coffee_shop_sales 
where month(transaction_date) =5 
group by hour(transaction_time)
order by hour(transaction_time);


-- Calculate top 10 best selling product based on total sales.

SELECT 
  product_type, 
  round(SUM(transaction_qty * unit_price),2) AS total_sales 
  FROM Coffee_shop_sales 
  GROUP BY product_type
  order by total_sales desc limit 10;