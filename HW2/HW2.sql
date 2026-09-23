-- 1
select category, round(avg(price), 2) as avg_per_category
from pastries
group by category;

-- 2
select experience_level, count(experience_level) as total_number
from baristas
group by experience_level;

-- 3
select city, count(city) as number_of_shops
from shops
group by city;

-- 4
select category, round(max(price), 2) as max_price
from pastries
group by category;

-- 5
select shopID, count(pastryID) as added_pastries
from offers
group by shopID;

-- 6
select name, category, round(price, 2) as p
from pastries
where round(price, 2) = (
	select round(max(price), 2)
    from pastries as p2
    where p2.category = pastries.category
);

-- 7
select distinct o.shopID
from offers o
join pastries p on o.pastryID = p.patryID
where p.price > (
	select avg(price)
    from pastries
);

-- 8
select *
from offers
order by date_added
limit 1;

-- 9
select shopID, count(pastryID) as pastry_count
from offers
group by shopID
having count(pastryID) = (
	select max(sub)
    from (
		select count(pastryID) as sub
        from offers
        group by shopID
    ) as max_counts
);

-- 10
select name
from baristas
where baristaID in (
	select baristaID
    from shops
    where shopID in (
		select shopID
        from shops
        where city = 'Seattle'
    )
);