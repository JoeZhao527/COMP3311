-- COMP3311 Prac Exercise
--
-- Written by: YOU


-- Q1: how many page accesses on March 2

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q1(nacc) as
-- ... replace this line by your SQL query ...
    select  count(*) as nacc 
    from    accesses a
    where   a.accTime between '2005-03-02 00:00:00' and '2005-03-02 23:59:59'
;


-- Q2: how many times was the MessageBoard search facility used?

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q2(nsearches) as
-- ... replace this line by your SQL query ...
    select  count(*)
    from    accesses a
    where   a.page ~ 'messageboard' and a.params ~ 'state=search'
;


-- Q3: on which Tuba lab machines were there incomplete sessions?

-- .. replace this line by auxiliary views (or delete it) ...

create or replace view Q3(hostname) as
-- ... replace this line by your SQL query ...
    select  distinct h.hostname
    from    hosts as h join sessions as s on (h.id = s.id)
    where   s.complete = 'f' and h.hostname ~ 'tuba'
;


-- Q4: min,avg,max bytes transferred in page accesses

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q4(min,avg,max) as
-- ... replace this line by your SQL query ...
    select  min(a.nbytes), avg(a.nbytes) :: integer, max(a.nbytes)
    from    accesses a
;


-- Q5: number of sessions from CSE hosts

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q5(nhosts) as
-- ... replace this line by your SQL query ...
    select  count(*) 
    from    hosts h
    where   h.hostname ~ 'cse.unsw.edu.au$'
;


-- Q6: number of sessions from non-CSE hosts

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q6(nhosts) as
-- ... replace this line by your SQL query ...
    select  count(*) 
    from    hosts h
    where   h.hostname !~ 'cse.unsw.edu.au$'
;


-- Q7: session id and number of accesses for the longest session?

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q7(session,length) as 
-- ... replace this line by your SQL query ...
    select  a.session, count(*) as length
    from    accesses a
    group by    a.session
    order by length DESC
    limit   1
;


-- Q8: frequency of page accesses

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q8(page,freq) as
-- ... replace this line by your SQL query ...
    select  a.page, count(*) as freq
    from    accesses a
    group by    a.page
;


-- Q9: frequency of module accesses

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q9(module,freq) as
-- ... replace this line by your SQL query ...

    with    pos(page_name, end_pos) as (
        select  a.page,
        case
            when    position('/' in a.page) = 0 then length(a.page)
            else    position('/' in a.page) - 1
        end as  end_pos
        from    accesses a
    )
    select  substring(p.page_name, 1, p.end_pos) as module, count(*) as freq
    from    pos p
    group by    module
;


-- Q10: "sessions" which have no page accesses

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q10(session) as
-- ... replace this line by your SQL query ...
    select  s.id
    from    sessions s
    left outer join Accesses a on (s.id = a.session)
    where   a.session is null
;


-- Q11: hosts which are not the source of any sessions

-- ... replace this line by auxiliary views (or delete it) ...

create or replace view Q11(unused) as
-- ... replace this line by your SQL query ...
    select  h.hostname
    from    sessions s
    left outer join Accesses a on (s.id = a.session)
    join hosts h on (s.host = h.id)
    where a.session is null
;