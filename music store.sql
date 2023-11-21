-- 1) Finding senior most employee based on job title :

select * from employee
order by levels desc
limit 1;

-- 2) Finding country with the most invoices :
select billing_country, count(*) from invoice
group by billing_country 
order by count(*) desc
limit 1;

-- 3)  Finding value of top 3 invoices :
select * from invoice
order by total desc
limit 3;

-- 4) Finding city which generated most revenues :
select billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1;



-- 5) Finding customer who had spent the most :
select t1.customer_id,t1.first_name,t1.last_name, sum(t2.total) from customer as t1
join invoice as t2 on t1.customer_id = t2.customer_id
group by t1.customer_id
order by sum(t2.total) desc
limit 1;


-- 6) Writing query to return the email, first name and the last name of all rock music listeners alphabetically by email :
select email, first_name, last_name
from customer as t1
join invoice as t2 on t1.customer_id = t2.customer_id
join invoice_line as t3 on t2.invoice_id = t3.invoice_id
where track_id in(select track_id from track
				 join genre on track.genre_id= genre.genre_id
				 where genre.name like 'Rock')
order by email;

                  -- alternate way to solve the above query
select email, first_name, last_name
from customer as t1
full join invoice as t2 on t1.customer_id = t2.customer_id
full join invoice_line as t3 on t2.invoice_id = t3.invoice_id
full join track as t4 on t3.track_id= t4.track_id
full join genre as t5 on t4.genre_id=t5.genre_id
where  t5.name like 'Rock'
order by email;


-- 7) Writing query to get the list of Artist name and track count of top 10 rock bands :
select  t1.name,count(t3.name) as total_track_count from artist as t1
full join album as t2 on t1.artist_id= t2.artist_id
full join track as t3 on t2.album_id = t3.album_id
full join genre as t4 on t3.genre_id = t4.genre_id
where t4.name like 'Rock'
group by t1.name
order by total_track_count desc
limit 10;


-- 8) List of all tracks having song length longer than the average song length:
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order 
by milliseconds desc;



-- 9) Find out how much amount spent by each customer on top 2 most selling artists :
with bsa as (select a.artist_id as artist_id,a.name as artist_name , sum(d.unit_price * d.quantity) as revenue
from artist as a
join album as b on a.artist_id = b.artist_id
join track as c on b.album_id = c.album_id
join invoice_line as d on c.track_id = d.track_id
group by a.artist_id
order by revenue desc
limit 2)

select concat(t1.first_name,t1.last_name)as customer_name, bsa.artist_name, sum(t3.unit_price * t3.quantity) as expenses
from customer as t1
join invoice as t2 on t1.customer_id= t2.customer_id
join invoice_line as t3 on t2.invoice_id= t3.invoice_id
join track as t4 on t3.track_id= t4.track_id
join album as t5 on t4.album_id= t5.album_id
join bsa on bsa.artist_id =t5.artist_id
group by customer_name, bsa.artist_name
order by customer_name;



-- 10) Find the most popular music genre for each country 
with popular_genre as
 ( select count(il.quantity) as sale, c.country as region, g.name,g.genre_id,
  row_number() over(partition by c.country order by count(il.quantity) desc) as Row_no
  from invoice_line as il
  join invoice as i on il.invoice_id = i.invoice_id
  join customer as c on i.customer_id = c.customer_id
  join track as t on t.track_id = il.track_id
  join genre as g on t.genre_id = g.genre_id
  group by region,3,4
  order by 2 asc, 1 desc
)
select * from popular_genre where Row_no <=1


