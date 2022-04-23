
-- ##############################
-- #### Aggregation #############

-- https://pgexercises.com/questions/aggregates/


-- Count the number of facilities
select count(*) from cd.facilities;


-- Count the number of expensive facilities
-- We need to weed out the inexpensive facilities. This is easy to do using a WHERE clause. Our aggregation can now only see the expensive facilities. 
select count(*) from cd.facilities
where guestcost > 10;


-- Count the number of recommendations each member makes
select recommendedby, count(recommendedby) as count
from cd.members
group by recommendedby
having recommendedby>0
order by recommendedby;

-- Alternative from discussion :
select recommendedby, count(*)
from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby;


--  List the total slots booked per facility
select facid, sum(slots)
from cd.bookings
group by facid
order by facid;


-- List the total slots booked per facility in a given month
-- NOTE this doesn't work if set max date to starttime <= '09/30/2012'.
-- NOTE the aggregation happens after the WHERE clause is evaluated.
select facid, sum(slots) as "Total Slots"
from cd.bookings
where starttime >= '09/01/2012'
and starttime < '10/01/2012'
group by facid
order by "Total Slots";


-- List the total slots booked per facility per month
-- Produce a list of the total number of slots booked per facility per month 
-- in the year of 2012. 
-- Produce an output table consisting of facility id and slots, 
-- sorted by the id and month. 
select facid, date_part('month', starttime) as month, 
sum(slots) as "Total Slots"
from cd.bookings
where date_part('year', starttime) = 2012
group by facid, month;

-- Alternative from discussion, using EXTRACT instead of DATE_PART:
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where extract(year from starttime) = 2012
	group by facid, month
order by facid, month; 


-- Find the count of members who have made at least one booking
-- (Including guests)
select count(distinct memid)
from cd.bookings;


-- List facilities with more than 1000 slots booked
select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid
having sum(slots)>1000
order by facid;


-- Find the total revenue of each facility
-- Produce a list of facilities along with their total revenue. 
-- The output table should consist of facility name and revenue, sorted by revenue. 
-- Remember that there's a different cost for guests and members.
select f.name,
sum(case when memid=0 then b.slots*f.guestcost
	else b.slots*f.membercost
	end) as revenue
from cd.bookings b
inner join cd.facilities f
on b.facid=f.facid
group by f.name
order by revenue;


-- Find facilities with a total revenue less than 1000
-- Produce an output table consisting of facility name and revenue, sorted by revenue. 
-- Remember that there's a different cost for guests and members.
-- NOTE : Referring to revenue in a HAVING clause doesn't work. 
-- ERROR: column "revenue" does not exist. 
-- Postgres, unlike some other RDBMSs like SQL Server and MySQL, 
-- doesn't support putting column names in the HAVING clause.
select * from 
(select f.name,
sum(case when memid=0 then b.slots*f.guestcost
	else b.slots*f.membercost
	end) as revenue
from cd.bookings b
inner join cd.facilities f
on b.facid=f.facid
group by f.name) as r
where revenue < 1000
order by revenue;

-- HAVING is useful for simple queries, as it increases clarity. 
-- Otherwise, this subquery approach is often easier to use.


-- Output the facility id that has the highest number of slots booked
select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid
order by "Total Slots" desc
limit 1;
-- NOTE this doesn't catch the scenario where more than one facid has the same top score.

-- For bonus points, try a version without a LIMIT clause. 
-- This version will probably look messy.
select facid, "Total Slots" from
(select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid) as b
where "Total Slots"=
(select max("Total Slots") from
(select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid) as m);

-- Alternatives from the discussion :
-- (1) Use of HAVING instead of WHERE which I've used.

-- Common table expressions (CTEs) (WITH CTEName as (SQL-Expression)):
WITH sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);


-- tbc......
