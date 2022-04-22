
-- ##############################
-- #### Modifying data ##########

-- https://pgexercises.com/questions/updates/

-- This section deals with inserting, updating, and deleting information. 
-- Ie Data Manipulation Language, or DML.


-- Insert some data into a table
-- The club is adding a new facility - a spa. We need to add it into the facilities table. -- Use the following values:
--     facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, 
-- monthlymaintenance: 800.
insert into cd.facilities
values (9, 'Spa', 20, 30, 100000, 800);


--  Insert multiple rows of data into a table
-- Use the following values:
--     facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, 
-- monthlymaintenance: 800.
--     facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 
-- 5000, monthlymaintenance: 80.
insert into cd.facilities
values
    (9, 'Spa', 20, 30, 100000, 800),
    (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);


-- Insert calculated data into a table
Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
insert into cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
values ((select max(facid)+1 from cd.facilities), 
		'Spa', 20, 30, 100000, 800);


-- Update some existing data
-- We made a mistake when entering the data for the second tennis court. 
-- The initial outlay was 10000 rather than 8000: alter the data to fix the error. 
update cd.facilities set initialoutlay = 10000 where name = 'Tennis Court 2';


-- Update multiple rows and columns at the same time
-- We want to increase the price of the tennis courts for both members and guests. 
-- Update the costs to be 6 for members, and 30 for guests. 
update cd.facilities set membercost=6, guestcost=30 
where name like '%Tennis Court%';

-- Alternative from the Discussion :
update cd.facilities set membercost = 6, guestcost = 30
where facid in (0,1);  


-- Update a row based on the contents of another row
-- Alter the price of the second tennis court so that it costs 10% more than the first one.
-- Not clear in the question but its talking about member cost and guest cost.
update cd.facilities
set 
membercost = 1.1 * (select membercost from cd.facilities where name like '%Tennis Court 1%'),
guestcost = 1.1 * (select guestcost from cd.facilities where name like '%Tennis Court 1%')
where name like '%Tennis Court 2%';

-- Alternative derived from the Discussion (good where a lot of columns need updating) :

update cd.facilities f1 
set
membercost = f2.membercost * 1.1,
guestcost = f2.guestcost * 1.1
from (select * from cd.facilities where name like '%Tennis Court 1%') f2
where f1.name like '%Tennis Court 2%';

-- NOTE you cannot use f1.membercost = f2.membercost * 1.1 :
-- 'ERROR: column "f1" of relation "facilities" does not exist'
-- You can only SET the column in its own context.


-- Delete all bookings
delete from cd.bookings;


--  Delete a member from the cd.members table
delete from cd.members where memid=37;


-- Delete based on a subquery
-- Delete all members who have never made a booking :
delete from cd.members where memid not in (select memid from cd.bookings);


