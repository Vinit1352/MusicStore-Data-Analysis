select * from album;

--****Start of the project****--

--Q1) Who is the senior most employee based on job title?
select Top 1 * from employee
order by levels Desc;

--Q2) Which countries have most invoices?
select Count(*)as Count_invoice,billing_country 
from invoice
Group by billing_country
Order by Count_invoice Desc;

--Q3) What are the top 3 values of total invoices?
select Top 3 total from invoice
Order by total DESC;

--Q4) Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals.
select billing_city, sum(total) as Invoice_total
from invoice
group by billing_city
order by Invoice_total desc;
--The best customers are from Prague and music fest should be held there as it has the highest invoice total.

--Q5) Who is the best cutomer? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.
select TOP 1 customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as Max_total
from customer
inner join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by Max_total desc;

--Q6) Write a query to return the email , first name , last name and genre of all Rock MUsic listeners.
--return your list ordered alphabetically by email starting with A
select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(

select track_id from track 
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
)
order by email;

--Q7) Let's invite the artists who have written the most rock music in our dataset.
--Write a query that returns the artist name and total track count of the top 10 rock bands

select top 10 artist.name , count(track.track_id) as rock_count
from artist 
join album on artist.artist_id= album.artist_id
join track on album.album_id = track.album_id
where track_id in(

select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name = 'Rock'

)
Group by artist.name
order by rock_count desc;

--Q8) Return all the track names that have a song length longer than the average song length.
---   Return the name and millisec for each track. order by the song length with the longest songs listed first.
select name ,milliseconds 
from track
Where milliseconds > (
         select avg(milliseconds) from track
		 )
order by milliseconds  desc;

--Q9) Find how much amount spent by each customer on artists?
--    Write a query to return customer name, artist name and total spent
With bestsell as(
  select top 1 artist.artist_id, artist.name as ArtistName,
  sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
  from invoice_line
  join track on track.track_id = invoice_line.track_id
  join album on album.album_id = track.track_id
  join artist on artist.artist_id = album.artist_id
  group by artist.artist_id ,artist.name
  order by 3 desc
 ) 
 select c.customer_id , c.first_name , c.last_name, bsa.ArtistName,
 sum(il.unit_price*il.quantity) as amount_spent
 from invoice i
 join customer c on c.customer_id = i.customer_id
 join invoice_line il on il.invoice_id = i.invoice_id
 join track t on t.track_id=il.track_id
 join album alb on alb.album_id = t.album_id
 join bestsell bsa on bsa.artist_id = alb.artist_id
 group by c.customer_id,c.first_name,c.last_name,bsa.ArtistName
 order by amount_spent desc;


--Q10)We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--    with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--    the maximum number of purchases is shared return all Genres.
with popular_genre as (
 select count(invoice_line.quantity) as Purchases , customer.country , genre.name , genre.genre_id,
 ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
 from invoice_line
 join invoice on invoice.invoice_id = invoice_line.invoice_id
 join customer on customer.customer_id = invoice.customer_id
 join track on track.track_id = invoice_line.invoice_line_id
 join genre on genre.genre_id = track.genre_id
 group by customer.country,genre.name , genre.genre_id
)
select * from popular_genre 
where RowNo<=1
order by 2 ASC , 1 desc;


--Q11) Write a query that determines the customer that has spent the most on music for each country. 
--     Write a query that returns the country along with the top customer and how much they spent. 
--     For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		)
SELECT * FROM Customter_with_country 
WHERE RowNo <= 1
ORDER BY 4 ASC,total_spending DESC;