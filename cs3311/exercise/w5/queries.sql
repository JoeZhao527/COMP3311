-- COMP3311 18s1 Prac 05 Exercises

-- Q1. What beers are made by Toohey's?

create or replace view Q1 as
    select  b.name
    from    Beers b join Brewers r on (b.brewer = r.id)
    where   r.name = 'Toohey''s'
;

-- Q2. Show beers with headings "Beer", "Brewer".

create or replace view Q2 as
    select  b.name, r.name
    from    Beers b
    join    Brewers r on (b.brewer = r.id)
;

-- Q3. Find the brewers whose beers John likes.

create or replace view Q3 as
    select  r.name
    from    Beers b join Brewers r on (b.brewer = r.id)
    join    Likes l on (l.beer = b.id)
    join    Drinkers d on (l.drinker = d.id)
    where   d.name = 'John'
;

-- Q4. How many different beers are there?

create or replace view Q4 as
    select  distinct count(*)
    from    Beers
;

-- Q5. How many different brewers are there?

create or replace view Q5 as
    select distinct count(*)
    from   Brewers
;

-- Q6. Find pairs of beers by the same manufacturer
--     (but no pairs like (a,b) and (b,a), and no (a,a))

create or replace view Q6 as
    select  b1.name as beer1, b2.name as beer2
    from    beers b1 join beers b2 on (b1.brewer = b2.brewer)
    where   b1 < b2
;

-- Q7. How many beers does each brewer make?

create or replace view Q7 as
    select  r.name as brewer, count(b.name) as nbeer
    from    beers b join brewers r on (b.brewer = r.id)
    group by    r.name
;

-- Q8. Which brewer makes the most beers?

create or replace view Q8 as
    with    BrewersProductivity as (
        select  r.name as brewer, count(b.name) as nbeer
        from    beers b join brewers r on (b.brewer = r.id)
        group by    r.name
    )
    select  b.brewer
    from    BrewersProductivity b
    where   b.nbeer = (select max(nbeer) from BrewersProductivity)
;

-- Q9. Beers that are the only one by their brewer.

create or replace view Q9 as
    with    BrewersProductivity as (
        select  r.id as brewer, count(b.name) as nbeer
        from    beers b join brewers r on (b.brewer = r.id)
        group by    r.id
    )
    select  b.name
    from    BrewersProductivity r join Beers b on (r.brewer = b.brewer)
    where   r.nbeer = 1
;

-- Q10. Beers sold at bars where John drinks.

create or replace view Q10 as
    select  distinct be.name as beer
    from    Likes l join Drinkers d on (l.drinker = d.id)
    join    Frequents f on (d.id = f.drinker)
    join    Bars b on (f.bar = b.id)
    join    Sells s on (b.id = s.bar)
    join    Beers be on (be.id = s.beer)
    where   d.name = 'John'
    order by beer
;

-- Q11. Bars where either Gernot or John drink.

create or replace view Q11 as
    select  distinct(b.name) as bar
    from    Bars b join Frequents f on (b.id = f.bar)
    where   f.drinker = (select id from drinkers d where d.name = 'John')
    or      f.drinker = (select id from drinkers d where d.name = 'Gernot')
;

-- Q12. Bars where both Gernot and John drink.

create or replace view Q12 as
    (select  distinct(b.name) as bar
        from    Bars b join Frequents f on (b.id = f.bar)
        where   f.drinker = (select id from drinkers d where d.name = 'John')
    )
    intersect
    (select  distinct(b.name) as bar
        from    Bars b join Frequents f on (b.id = f.bar)
        where   f.drinker = (select id from drinkers d where d.name = 'Gernot')
    )
;

-- Q13. Bars where John drinks but Gernot doesn't

create or replace view Q13 as
    (select  distinct(b.name) as bar
        from    Bars b join Frequents f on (b.id = f.bar)
        where   f.drinker = (select id from drinkers d where d.name = 'John')
    )
    except
    (select  distinct(b.name) as bar
        from    Bars b join Frequents f on (b.id = f.bar)
        where   f.drinker = (select id from drinkers d where d.name = 'Gernot')
    )
;

-- Q14. What is the most expensive beer?

create or replace view Q14 as
    select  b.name
    from    Beers b join Sells s on (b.id = s.beer)
    where   s.price = (select max(price) from Sells)
;

-- Q15. Find bars that serve New at the same price
--      as the Coogee Bay Hotel charges for VB.

create or replace view Q15 as
    select  b.name
    from    Bars b
        join Sells s on (b.id = s.bar)
        join Beers be on (be.id = s.beer)
    where   be.name = 'New'
    and     s.price = (
        select  s.price
        from    Sells s 
            join Beers be on (s.beer = be.id)
            join Bars b on (b.id = s.bar) 
        where   be.name = 'Victoria Bitter' and b.name = 'Coogee Bay Hotel'
    )
;

-- Q16. Find the average price of common beers
--      ("common" = served in more than two hotels).

create or replace view Q16 as
select ...
from   ...
where  ...
;

-- Q17. Which bar sells 'New' cheapest?

create or replace view Q17 as
select ...
from   ...
where  ...
;

-- Q18. Which bar is most popular? (Most drinkers)

create or replace view Q18 as
select ...
from   ...
where  ...
;

-- Q19. Which bar is least popular? (May have no drinkers)

create or replace view Q19 as
select ...
from   ...
where  ...
;

-- Q20. Which bar is most expensive? (Highest average price)

create or replace view Q20 as
select ...
from   ...
where  ...
;

-- Q21. Which beers are sold at all bars?

create or replace view Q21 as
select ...
from   ...
where  ...
;

-- Q22. Price of cheapest beer at each bar?

create or replace view Q22 as
select ...
from   ...
where  ...
;

-- Q23. Name of cheapest beer at each bar?

create or replace view Q23 as
select ...
from   ...
where  ...
;

-- Q24. How many drinkers are in each suburb?

create or replace view Q24 as
select ...
from   ...
where  ...
;

-- Q25. How many bars in suburbs where drinkers live?
--      (Must include suburbs with no bars)

create or replace view Q25 as
select ...
from   ...
where  ...
;
