
-- ##############################
-- #### Joins and Subqueries ####

-- https://pgexercises.com/questions/joins/

-- Joining allows you to combine related information from multiple tables to answer a 
-- question. This isn't just beneficial for ease of querying: a lack of join capability 
-- encourages denormalisation of data, which increases the complexity of keeping your data 
-- internally consistent. 

-- This topic covers inner, outer, and self joins, as well as spending a little time 
-- on subqueries (queries within queries). 


-- Retrieve the start times of members' bookings
-- Produce a list of the start times for bookings by members named 'David Farrell'.
-- NB. In PostgreSql - double-quotes " are reserved for names of tables or fields.
-- Ie. MUST USE SINGLE QUOTES HERE.
select b.starttime
from cd.bookings b
inner join cd.members m
on b.memid=m.memid
where m.surname='Farrell'
and m.firstname='David';


-- Work out the start times of bookings for tennis courts
-- Produce a list of the start times for bookings for tennis courts, for the date 
-- '2012-09-21'. Return start time and facility name pairings, ordered by the time. 
select b.starttime, f.name
from cd.bookings b
inner join cd.facilities f
on b.facid=f.facid
where date(b.starttime) = '2012-09-21'
and f.name like '%Tennis Court%'
order by starttime;


-- Produce a list of all members who have recommended another member
-- Ensure that there are no duplicates in the list, and that results are ordered by 
-- (surname, firstname). 
select distinct recommender.firstname, recommender.surname
from cd.members recommended
inner join cd.members recommender
on recommended.recommendedby=recommender.memid
order by recommender.surname, recommender.firstname;


-- Produce a list of all members, along with their recommender
-- How can you output a list of all members, including the individual who recommended 
-- them (if any)? Ensure that results are ordered by (surname, firstname).
select mem.firstname as memfname, mem.surname as memsname,
rec.firstname as recfname, rec.surname as recsname
from cd.members mem
left join cd.members rec
on mem.recommendedby=rec.memid
order by memsname, memfname;


-- Produce a list of all members who have used a tennis court
-- Include in the output the name of the court, and the name of the member formatted as a 
-- single column. Ensure no duplicate data, and order by the member name followed by the 
-- facility name. 
select distinct concat(m.firstname, ' ', m.surname) as member, f.name as facility
from cd.members m
inner join cd.bookings b
on m.memid=b.memid
inner join cd.facilities f
on b.facid=f.facid
where f.name like '%Tennis Court%'
order by member, facility;


-- Produce a list of costly bookings
-- Produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) 
-- more than $30. Remember that guests have different costs to members (the listed costs are 
-- per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name 
-- of the facility, the name of the member formatted as a single column, and the cost. Order 
-- by descending cost, and do not use any subqueries. 

-- Notes : PostgreSql assesses the where clause before the select clause, so cannot use
-- a created column name in the where clause. Do mitigate this, could wrap the select 
-- statement to a derived table and select from that.
select * from 
(select concat(m.firstname, ' ', m.surname) as member, f.name as facility,
       case when m.surname like '%GUEST%' then (b.slots*f.guestcost)
            else (b.slots*f.membercost)
       end as cost
from cd.facilities f
inner join cd.bookings b
on f.facid=b.facid
left join cd.members m
on b.memid=m.memid
where date(b.starttime) = '2012-09-14') as t
where cost>30
order by cost desc;

-- Alternative (better obviates the subquery issue):
select concat(m.firstname, ' ', m.surname) as member, f.name as facility,
       case when m.surname like '%GUEST%' then (b.slots*f.guestcost)
            else (b.slots*f.membercost)
       end as cost
from cd.facilities f
inner join cd.bookings b
on f.facid=b.facid
left join cd.members m
on b.memid=m.memid
where date(b.starttime) = '2012-09-14'
and (
    (m.memid = 0 and b.slots*f.guestcost > 30) or
    (m.memid != 0 and b.slots*f.membercost > 30)
)
order by cost desc;


-- Produce a list of all members, along with their recommender, using no joins. 
-- Output a list of all members, including the individual who recommended them (if any), 
-- without using any joins? Ensure that there are no duplicates in the list, and that each 
-- firstname + surname pairing is formatted as a column and ordered. 
select distinct concat(m.firstname, ' ', m.surname) as member, 
	(select concat(r.firstname, ' ', r.surname) as recommender
	 from cd.members r
	where r.memid=m.recommendedby)
from cd.members m
order by member;


-- Produce a list of costly bookings, using a subquery
-- The Produce a list of costly bookings exercise contained some messy logic: we had to 
-- calculate the booking cost in both the WHERE clause and the CASE statement. Try to 
-- simplify this calculation using subqueries. 
-- (See subquery form above. Below is an alternative version using union all, which
-- does not save complexity particularly):
select * from ((select concat(m.firstname, ' ', m.surname) as member,
f.name as facility, slots*guestcost as cost
from cd.members m
inner join cd.bookings b
on m.memid=b.memid
inner join cd.facilities f
on b.facid=f.facid
where m.firstname like '%GUEST%'
and date(b.starttime)='2012-09-14')
UNION ALL
(select concat(m.firstname, ' ', m.surname) as member,
f.name as facility, slots*membercost as cost
from cd.members m
inner join cd.bookings b
on m.memid=b.memid
inner join cd.facilities f
on b.facid=f.facid
where m.firstname not like '%GUEST%'
and date(b.starttime)='2012-09-14')) as everyone
where cost > 30
order by cost desc;

