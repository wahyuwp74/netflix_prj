drop table if exists netflix;
create table netflix (
						show_id VARCHAR(6),
						type VARCHAR(10),
						title VARCHAR(125),
						director VARCHAR(225),
						casts VARCHAR(800),
						country VARCHAR(150),
						date_added VARCHAR(50),
						release_year int,
						rating VARCHAR(25),
						duration VARCHAR(15),
						listed_in VARCHAR(100),
						description VARCHAR(250)
)

select * from netflix
where director is null
or casts is null
or country is null

-- 1. Count the Number of Movies vs TV Shows
select 
	type,
	count(show_id) as total_show
from netflix
group by 1

-- 2.Find the Most Common Rating for Movies and TV Shows
WITH ratingcount as (
	select 
		type,
		rating,
		count(*) as rating_count
	from netflix
	group by 1,2
),

rankedrating as (
	select
		type,
		rating,
		rating_count,
		rank() over(partition by type order by rating_count desc) as rankk
	from ratingcount
)

select 
	type,
	rating as most_frequently_type
from rankedrating
where rankk = 1

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select *
from netflix
where release_year = 2008
and type = 'Movie'

--4. Find the Top 5 Countries with the Most Content on Netflix
select 
	*
from 
	( 
	select 
		unnest(string_to_array (country, ',')) as new_country,
		count(*) as contents
	from netflix
	group by 1
	)as t1
where new_country is not null
order by contents desc
limit 5

-- 5. Identify the Longest Movie
select 
	* 
from netflix
where type = 'Movie' and duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
limit 1

--6. Find Content Added in the Last 5 Years
select *
from netflix
where to_date(date_added,'Month DD, YYYY') <= current_date - interval '5 year'

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select 
	*
from 
	( 	select
			*,
			unnest(string_to_array (director, ',')) as new_director
		from netflix
	) as t2
where new_director = 'Rajiv Chilaka'

select *
from netflix
where director ilike '%Rajiv Chilaka%'

-- 8. List All TV Shows with More Than 5 Seasons
select 
	*
from netflix
where type = 'TV Show' and split_part(duration,' ',1)::INT >= 5

--9. Count the Number of Content Items in Each Genre
select 
	unnest(string_to_array(listed_in,',')) as genre,
	count(*)
from netflix
group by 1
order by 2 desc

-- 10.Find each year and the average numbers of content release in India on netflix.
select 
	release_year,
	count(show_id) as total_release,
	round(
		count(show_id)::numeric / (select count(show_id) from netflix where country ilike '%india%')::numeric *100,2 
	) as avg_release
from netflix
where country ilike '%india%'
group by 1
order by avg_release desc

--11. List All Movies that are Documentaries

select *
from netflix
where listed_in ilike '%Documentaries%'
and type = 'Movie'

-- 12. Find All Content Without a Director

select *
from netflix
where director is null

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select *
from netflix
where casts ilike '%Salman Khan%'
and type='Movie'
and release_year >= extract(year from current_date) - 10

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
	unnest(string_to_array(casts,',')) as actors,
	count(show_id) as movie_product
from netflix
where country ilike '%india%'
group by 1
order by movie_product desc
limit 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

select 
	category,
	count(*) as total_product
from (
		select
			case when description ilike '%kill%' or description ilike '%violence%' then 'SNad'
			else 'Good' 
			end as category
		from netflix
) as categorized
group by 1