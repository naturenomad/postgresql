

-- ##############################
-- #### Aggregation #############

-- https://pgexercises.com/questions/aggregates/


---------------------------------
-- Count the number of facilities
select count(*) from cd.facilities;


-------------------------------------------
-- Count the number of expensive facilities
-- We need to weed out the inexpensive facilities. This is easy to do using a WHERE clause. Our aggregation can now only see the expensive facilities. 
select count(*) from cd.facilities
where guestcost > 10;


--------------------------------------------------------
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


--------------------------------------------
--  List the total slots booked per facility
select facid, sum(slots)
from cd.bookings
group by facid
order by facid;


------------------------------------------------------------
-- List the total slots booked per facility in a given month
-- NOTE this doesn't work if set max date to starttime <= '09/30/2012'.
-- NOTE the aggregation happens after the WHERE clause is evaluated.
select facid, sum(slots) as "Total Slots"
from cd.bookings
where starttime >= '09/01/2012'
and starttime < '10/01/2012'
group by facid
order by "Total Slots";


-----------------------------------------------------
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


---------------------------------------------------------------
-- Find the count of members who have made at least one booking
-- (Including guests)
select count(distinct memid)
from cd.bookings;


---------------------------------------------------
-- List facilities with more than 1000 slots booked
select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid
having sum(slots)>1000
order by facid;


------------------------------------------
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


------------------------------------------------------
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


---------------------------------------------------------------------
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

-- (2) Common table expressions (CTEs) (WITH CTEName as (SQL-Expression)):
WITH sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);


-------------------------------------------------------------
-- List the total slots booked per facility per month, part 2
-- Produce a list of the total number of slots booked per facility per month 
-- in the year of 2012. 
-- In this version, include output rows containing totals for all months per facility, 
-- and a total for all months for all facilities. 
-- The output table should consist of facility id, month and slots, 
-- sorted by the id and month.
-- When calculating the aggregated values for all months and all facids, 
-- return null values in the month and facid columns. 
-- HINT : Look up Postgres' ROLLUP operator. 

-- Start by getting the totals per month per facid
select facid, date_part('month', starttime) as month, 
sum(slots) as slots
from cd.bookings
where date_part('year', starttime)='2012'
group by facid, month;

-- Adding the ROLLUP clause
-- The PostgreSQL ROLLUP is a subclause of the GROUP BY clause 
-- that offers a shorthand for defining multiple grouping sets. 

-- Different from the CUBE subclause, ROLLUP does not generate all possible grouping sets 
-- based on the specified columns. It just makes a subset of those.

-- Try it :
select facid, date_part('month', starttime) as month, 
sum(slots) as slots
from cd.bookings
where date_part('year', starttime)='2012'
group by rollup(facid, month, slots)
order by facid, month;
-- This gives all rollup outputs, grouping on all vectors.

-- One messy strategy - select the totals from this and union with the first query above :
(select facid, date_part('month', starttime) as month, 
sum(slots) as slots
from cd.bookings
where date_part('year', starttime)='2012'
group by facid, month)
UNION ALL
(select * from 
(select facid, date_part('month', starttime) as month, 
sum(slots) as slots
from cd.bookings
where date_part('year', starttime)='2012'
group by rollup(facid, month, slots)
order by facid, month) r
where month is null)
order by facid, month;

-- The Discussion has a much more elegant way of doing this :
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;  

-- Adapting to my style :
select facid, date_part('month', starttime) as month, sum(slots) as slots
from cd.bookings
where date_part('year', starttime)='2012'
group by rollup(facid, month)
order by facid, month; 

-- In other words, I need to group only by rollup(facid, month) to get the resultset I need,
-- ie the facid/monthly aggregates and facid aggregate.

-- ROLLUP produces a hierarchy of aggregations in the order passed into it: for example, 
-- ROLLUP(facid, month) outputs aggregations on (facid, month), (facid), and (). If we 
-- wanted an aggregation of all facilities for a month (instead of all months for a 
-- facility) we'd have to reverse the order, using ROLLUP(month, facid). Alternatively, if 
-- we instead want all possible permutations of the columns we pass in, we can use CUBE 
-- rather than ROLLUP. This will produce (facid, month), (month), (facid), and ().

-- ROLLUP and CUBE are special cases of GROUPING SETS. GROUPING SETS allow you to specify 
-- the exact aggregation permutations you want: you could, for example, ask for just (facid, 
-- month) and (facid), skipping the top-level aggregation.


-------------------------------------------------
-- List the total hours booked per named facility
-- Produce a list of the total number of hours booked per facility, remembering that a slot 
-- lasts half an hour. The output table should consist of the facility id, name, and hours 
-- booked, sorted by facility id. Try formatting the hours to two decimal places.
select f.facid, f.name,
round(sum(b.slots*.5),2) as "Total Hours"
from cd.facilities f
inner join cd.bookings b
on f.facid=b.facid
group by f.facid, f.name
order by f.facid;


------------------------------------------------------------
-- List each member's first booking after September 1st 2012
-- Produce a list of each member name, id, and their first booking after 
-- September 1st 2012. Order by member ID. 
select m.surname, m.firstname, m.memid,
min(b.starttime) as starttime
from cd.members m
inner join cd.bookings b
on m.memid=b.memid
where b.starttime >= '2012-09-01'
group by m.memid
order by m.memid;


----------------------------------------------------------------------------------
-- Produce a list of member names, with each row containing the total member count
select (select count(*) from cd.members) as count, firstname, surname
from cd.members
order by joindate;

-- The Discussion introduces Window Functions as an alternative solution to this problem.

select count(*) over(), firstname, surname
	from cd.members
order by joindate;

-- Window functions operate on the result set of your (sub-)query, after the WHERE clause 
-- and all standard aggregation. They operate on a window of data. By default this is 
--unrestricted: the entire result set, but it can be restricted to provide more useful 
--results. Example :
select count(*) over(partition by date_trunc('month',joindate) order by joindate asc), 
	count(*) over(partition by date_trunc('month',joindate) order by joindate desc), 
	firstname, surname
	from cd.members
order by joindate;
-- Gives what number joinee in the given month each member was, 
-- in ascending and descending order.


--------------------------------------
-- Produce a numbered list of members
-- Produce a monotonically increasing numbered list of members (including guests), 
-- ordered by their date of joining. 
-- Remember that member IDs are not guaranteed to be sequential. 

-- Propose :
-- The ROW_NUMBER() function is a window function that assigns a sequential integer 
-- to each row in a result set. 
select row_number() over() as row_number, firstname, surname
from cd.members
order by joindate;

-- This shows as the right answer, but the discussion says to run over(order by joindate)
-- on the window function so perhaps it would have failed in some cases.
-- Alternative :
select count(*) over(order by joindate) as row_number, firstname, surname
from cd.members
order by joindate;
-- ie can run over() against aggregates.

-- In this query, we don't define a partition, meaning that the partition is the entire 
-- dataset. Since we define an order for the window function, for any given row the window 
-- is: start of the dataset -> current row.


----------------------------------------------------------------------------
-- Output the facility id that has the highest number of slots booked, again
-- Ensure that in the event of a tie, all tieing results get output. 
select facid, total from
(select facid, sum(slots) as total
from cd.bookings
group by facid) b
where total = (select max(total) from 
			  (select facid, sum(slots) as total
from cd.bookings
group by facid) b);
-- Can't use b in the where clause because this does not recognise the b assignment,
-- having been calculated before the assignment.

-- The discussion gives an alternative answer :
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1;
-- Uses the RANK function. This ranks values based on the ORDER BY that is passed to it.


----------------------------------------
-- Rank members by (rounded) hours used
-- Produce a list of members (including guests), along with the number of hours they've 
-- booked in facilities, rounded to the nearest ten hours. Rank them by this rounded figure, 
-- producing output of first name, surname, rounded hours, rank. Sort by rank, surname, and 
-- first name. 
select m.firstname, m.surname, round(sum(b.slots)*0.5,-1) as hours,
rank() over (order by round(sum(b.slots)*0.5,-1) desc) rank
from cd.members m
inner join cd.bookings b
on m.memid=b.memid
group by m.firstname, m.surname
order by rank, m.surname, m.firstname;


----------------------------------------------------
-- Find the top three revenue generating facilities
-- Produce a list of the top three revenue generating facilities (including ties). 
-- Output facility name and rank, sorted by rank and facility name. 
select name, rank() over (order by revenue desc) rank
from
(select f.name as name, sum (
case when b.memid=0 then b.slots*f.guestcost
else b.slots*f.membercost end) as revenue
from cd.facilities f
inner join cd.bookings b
on f.facid=b.facid
group by name) r
order by rank, name
limit 3;

-- A different interpretation of the question - the Discussion selects for rank <=3 which 
-- requires a slightly different approach (and may have a resultset > 3):
-- Watch out for ERROR: window functions are not allowed in WHERE clause.
select name, rank 
from (select f.name as name, 
rank() over (order by 
   sum (case when b.memid=0 then b.slots*f.guestcost
   else b.slots*f.membercost end) desc)
from cd.facilities f
inner join cd.bookings b
on f.facid=b.facid
group by name) r
where rank <=3
order by rank, name;

