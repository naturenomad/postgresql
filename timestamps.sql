
-- ##########################################
-- #### Working with Timestamps #############

-- https://pgexercises.com/questions/date/

-- Dates/Times in SQL are a complex topic, deserving of a category of their own. 
-- They're also fantastically powerful, making it easier to work with variable-length 
-- concepts like 'months' than many programming languages.


------------------------------------------------------------
-- Produce a timestamp for 1 a.m. on the 31st of August 2012 
select '2012-08-31 01:00:00' as timestamp;

-- Discussion offers the following :
select timestamp '2012-08-31 01:00:00'; 
select '2012-08-31 01:00:00'::timestamp; -- PostgreSql extension
select cast('2012-08-31 01:00:00' as timestamp); -- SQL-standard

-- Timestamps can be stored with or without time zone information. 
-- You could format the timestamp like "2012-08-31 01:00:00 +00:00", assuming UTC.  
-- timestamp with time zone is a different type to timestamp - when you're declaring it, you 
-- should use TIMESTAMP WITH TIME ZONE 2012-08-31 01:00:00 +00:00.


---------------------------------------
--  Subtract timestamps from each other
-- Find the result of subtracting the timestamp '2012-07-30 01:00:00' 
-- from the timestamp '2012-08-31 01:00:00' 
select timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00' as interval;

-- INTERVALs are a special data type for representing the difference 
-- between two TIMESTAMP types.
-- When subtracting timestamps, Postgres will typically give an interval in terms of 
-- days, hours, minutes, seconds, without venturing into months. 
-- To schedule something to occur in exactly one month's time, 
-- regardless of the length of month, could use [timestamp] + interval '1 month'.
-- Intervals stand in contrast to SQL's treatment of DATE types. 
-- Dates don't use intervals - instead, subtracting two dates will return an integer 
-- representing the number of days between the two dates.


---------------------------------------------------
-- Generate a list of all the dates in October 2012
-- They can be output as a timestamp (with time set to midnight) or a date. 
-- Hint : Look at Postgres' GENERATE_SERIES function
select * from generate_series('2012-10-01', '2012-10-31', INTERVAL '1 day') as ts;

-- Can also simplify this to -
select generate_series('2012-10-01', '2012-10-31', interval '1 day') as ts; 


--------------------------------------------
-- Get the day of the month from a timestamp
-- Get the day of the month from the timestamp '2012-08-31' as an integer. 
select date_part('day', timestamp '2012-08-31');

-- Alternative :
select extract(day from timestamp '2012-08-31');  


----------------------------------------------------
-- Work out the number of seconds between timestamps
-- Hint You can do this by extracting the epoch from the interval between two timestamps.
select date_part('epoch', (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00'));

-- Postgresql : Extracting the epoch converts an interval or timestamp into a number of 
-- seconds, or the number of seconds since epoch (January 1st, 1970) respectively.


----------------------------------------------------
-- Work out the number of days in each month of 2012

-- Get list of numbered months :
select date_part('months', 
	generate_series('2012-01-01', '2012-12-31', 
	interval '1 month')) as month;
	
-- Get list of 1st of each month :
select generate_series('2012-01-01', '2012-12-01', interval '1 month');

-- Get length of a month :
select date_part('days', (timestamp '2012-01-01' + interval '1 month')
    - timestamp '2012-01-01');

-- Combine :
select date_part('months', ts.month) as month,
concat(date_part('days', (ts.month + interval '1 month') - ts.month), ' days') as length
from 
(select generate_series('2012-01-01', '2012-12-01', interval '1 month') as month) ts;


-----------------------------------------------------
-- Work out the number of days remaining in the month
-- For any given timestamp, work out the number of days remaining in the month. 
-- The current day should count as a whole day, regardless of the time. 
-- Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer. 
-- Format the output as a single interval value.
-- Hint Take a look at the DATE_TRUNC function 

-- Solve by going to beginning of month plus one month, 
-- and subtracting the date to get days remaining -
select (date_trunc('month', timestamp '2012-02-11 01:00:00') 
		+ interval '1 month')
		- date_trunc('day', timestamp '2012-02-11 01:00:00') 
		as remaining;


------------------------------------
-- Work out the end time of bookings
-- Return a list of the start and end time of the last 10 bookings 
-- (ordered by the time at which they end, followed by the time at which they start) 
-- in the system. 
select starttime, 
starttime + (interval '1 hour' * (slots*0.5)) as endtime
from cd.bookings
order by endtime desc, starttime desc
limit 10;

-- Alternative : slots * (interval '30 minutes')


--------------------------------------------
-- Return a count of bookings for each month
select date_trunc('month', starttime) as month, count(*)
from cd.bookings
group by month
order by month;


-----------------------------------------------------------------
-- Work out the utilisation percentage for each facility by month 
-- Sorted by name and month, rounded to 1 decimal place. 
-- Opening time is 8am, closing time is 8.30pm. 
-- Treat every month as a full month, 
-- regardless of if there were some dates the club was not open. 
select f.name, date_trunc('month', b.starttime) as month,
round((sum(0.5 * b.slots) /
(date_part('days', 
  (date_trunc('month', b.starttime) + interval '1 month')
  - date_trunc('month', b.starttime)) * 12.5) * 100)::numeric, 1) as utilisation
from cd.bookings b
inner join cd.facilities f
on b.facid=f.facid
group by name, month
order by name, month;

