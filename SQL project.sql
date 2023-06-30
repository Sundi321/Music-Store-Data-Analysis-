Q1) who is the seniormost employee based on job title?
SELECT * FROM employee
ORDER BY levels desc 
limit 1

Q2) which countries have the most invoices?
SELECT COUNT(*) as c, billing_country
FROM invoice
GROUP BY billing_country
order by c desc

Q3) what are the top 3 values of total invoice?
SELECT total
FROM invoice
order by total desc
limit 3

--Q4) which city has best customers?we would like to 
throqw a promotional music festival in city we made most money.
write a query that returns one city that has highest sum of invoice totals,
return both the city name & sum of all invoice totals.
SELECT * FROM invoice
SELECT sum(total) as billing_invoice,billing_city
FROM invoice
group by billing_city
order by billing_invoice

Q5)who is the best customer ?the customer who has spent the most money 
will be declared best customer.write a query that returns person who has spent the most money.
SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--Q1. write query to return email, first, last name, genre of all rock music listeners. 
return your list ordered alphabetical by email starting with A
SELECT DISTINCT first_name, last_name, email
FROM customer
JOIN invoice  ON customer.customer_id=invoice.customer_id
JOIN invoice_line  ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id from track
	JOIN genre on track.genre_id= genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
order by email;

Q2. lets invite the artist who have written the most rock music in our datset. 
write a query that returns the artist name and total track count of top 10 rock bands.
SELECT artist.artist_id, artist.name ,COUNT(artist.artist_id) AS no_of_songs
from track
JOIN album ON album.album_id= track.album_id
JOIN artist on artist.artist_id=album.artist_id
JOIN genre ON genre.genre_id=track.genre_id
WHERE genre.name LIKE 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;

Q3. retrn all tracks names that have song length longer than 
avg song length.return name and msec for each track.order by 
song length with longest songs listed first.
select * from track
select name, milliseconds 
from track
WHERE milliseconds >= (
	select avg(milliseconds) as avg_track_length
	from track)
	order by milliseconds desc;

--advance
Q1. find how much amount spent by each cutomer on artists?
write a query to return customr name,artist name,total spent
with best_selling_artist as( 
	select artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity)as total_sale
    from invoice_line
    JOIN track on track.track_id=invoice_line.track_id
    JOIN album ON album.album_id= track.album_id
    JOIN artist on artist.artist_id=album.artist_id
    group by 1
    order by 3 desc
    limit 5
)
select c.customer_id, c.first_name, c.last_name, best_selling_artist .artist_name,
sum(invoice_line.unit_price*invoice_line.quantity)as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id= t.album_id
join best_selling_artist bsa on bsa.artist_id= alb.artist_id
group by 1,2,3,4
order by 5 desc;

Q2.we want to find out most popular music genre for each country .
we determine most popular genre as genre with highest amount of purchases .
write a query that returns each country along with top genre.for countries 
where max no of purchases is shared return al  genres.
with popular_genre as 
(
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
    row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNO
    from invoice_line
    JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
	JOIN customer ON customer.customer_id=invoice.customer_id
    JOIN track ON invoice_line.track_id=track.track_id
    JOIN genre ON genre.genre_id=track.genre_id
    group by 2,3,4
	order by 1 desc
)
select *from popular_genre where RowNo <=1

q3.write a query to determine customer that has spent the most on music for each country. 
write a query that returns country along with top customer &how much they spent.for countries
where top amount spent is shared,provide all customers who spent this amount
WITH customer_with_country as( 
	select customer.customer_id, customer.first_name, customer.last_name,invoice.billing_country , 
	sum(total)as total_spent
	from invoice
	JOIN customer ON customer.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 5 desc),
	
	country_max_spending as (
		select billing_country, max(total_spent) as max_purchase
		from customer_with_country 
		group by billing_country)
		
select cc.billing_country, cc.total_spent, cc.first_name,cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spent=ms.max_purchase
order by 1;
--method2
WITH customer_with_country as( 
	select customer.customer_id, customer.first_name, customer.last_name,invoice.billing_country , 
	sum(total)as total_spent,
	ROW_NUMBER() OVER(PARTITION BY billing_country order by sum(total) desc) as RowNo
	FROM invoice
	JOIN customer ON customer.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc)
select*from customer_with_country where Rowno <=1
	
