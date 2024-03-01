--Q1.Which artist has the most no of Portraits paintings outside USA?. Display artist
--name, no of paintings and the artist nationality
select * from
(select a.full_name,a.nationality ,count(w.name) as number_of_paintings,
rank()over(order by count(w.name) desc) rank
from artist a  --artist full name --nationality
join work w
on a.artist_id = w.artist_id
join museum m
on m.museum_id = w.museum_id
join subject s
on s.work_id = w.work_id 
 where m.country <> 'USA' and s.subject ='Portraits'
group by 1,2--,m.country
) x
where x.rank =1


--Q2. Which are the 3 most popular and 3 least popular painting styles?	
select   most_popular_style,  least_popular_style  from
  (select style as most_popular_style from
				 (select  style,count(style),
				 rank()over(order by count(style) desc) rnk from work
				 group by 1) x where x.rnk <=3) as sub1
				 
cross join

  (select style as least_popular_style from
				 (select  style,count(style),
				 rank()over(order by count(style) asc) rnk from work
				 group by 1
				 having style is not null)x
				 where x.rnk <=3 )as sub2

---Q3.Which country has the 5th highest no of paintings?
select * from 
	(select m.country,count(m.country)as no_of_paintings,
	rank()over(order by count(m.country) desc)as rnk
	from work w
	join museum  m
	on m.museum_id =w.museum_id
	group by 1) x
where x.rnk = 5	


--Q4.Identify the artist and the museum where the most expensive and least expensive painting is placed. 
with cte as 
(select a.full_name ,m.name  ,p.sale_price from museum m
join work w on m.museum_id =w.museum_id
join product_size p on p.work_id =w.work_id
join artist a on a.artist_id = w.artist_id)

select query1.full_name as artist_expensive , query1.name as museum_expensive,query2.full_name as artist_least_exp,query2.name as museum_least_exp from
(select * from 
(select full_name,name,sale_price,
dense_rank()over(order by sale_price desc) rnk
from cte) x where x.rnk <=1) query1

cross join

(select * from 
(select full_name,name,sale_price,
dense_rank()over(order by sale_price asc) rnk
from cte) y where y.rnk <=1) query2

limit 1

--Q5. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
with cte as
(select sub1.country ,sub2.city from
            (select * from
			(select country, count(country),
			rank()over(order by count(country) desc ) rnk from museum
			group by 1)x where x.rnk =1) sub1

cross join

			(select * from
			(select city, count(city),
			rank()over(order by count(city) desc ) rnk from museum
			group by 1) y where y.rnk =1) sub2)

select string_agg(distinct country,',') as country, string_agg(city,',') as city from cte


--Q6. Identify the artists whose paintings are displayed in multiple countries.
with cte as 	
	(select distinct a.full_name ,m.country from artist  a
	join work  w on a.artist_id = w.artist_id 
	join museum m on m.museum_id = w.museum_id)
select  full_name ,count(2) from cte
group by 1
having count(2) > 1


--Q7.Which museum has the most no of most popular painting style
with cte as 		
		(select * from 
		(select style ,count(style),
		rank()over(order by count(style) desc) rnk
		from work
		group by style)x where x.rnk =1),
final_query as		
		(select m.name as musuem_name,cte.style,count(1),
		 rank()over(order by count(1)desc)rnk from cte
		join work w on w.style =cte.style
		join museum m on m.museum_id = w.museum_id
		group by 1,2)
select * from final_query	
where rnk =1

--Q8.Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

with cte as
		(select m.name as museum_name ,m.state,mh.day,mh.open,mh.close from museum m
		join museum_hours mh 
		on mh.museum_id = m.museum_id)
select museum_name ,state,day ,
to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as open_time from cte
order by open_time desc
limit 1

--Q9.Display the 3 least popular canva sizes
select * from
	(select cs.label,count(1),
	dense_rank()over(order by count(1) ) rnk 
	from canvas_size cs
	join product_size ps on ps.size_id = cs.size_id::text
	join work w on w.work_id = ps.work_id
	group by 1) x
	where x.rnk <=3

--Q10. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select * from 
	(select m.name as museum_name ,count(1),
	rank()over(order by count(1) desc) rnk from museum m
	join work w on m.museum_id =w.museum_id
	group by 1) x
	where x.rnk <=5

--Q11.Identify the museums with invalid city information in the given dataset
 
select city from museum
where city ~'^[0-9]'











