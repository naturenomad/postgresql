
-- ##########################################
-- #### String Operations ###################

-- https://pgexercises.com/questions/string/


-- Format the names of members
-- Output the names of all members, formatted as 'Surname, Firstname' 
select concat(surname, ', ', firstname) as name
from cd.members;


-- Find facilities by a name prefix
select * from cd.facilities
where name like 'Tennis%';


-- Perform a case-insensitive search
select * from cd.facilities
where lower(name) like 'tennis%';


-- Find telephone numbers with parentheses
select memid, telephone
from cd.members 
where telephone like '%(%)%';

-- Discussion - alternative : use regular expressions.
-- Postgres implements POSIX regular expression matching via the ~ operator :
select memid, telephone from cd.members where telephone ~ '[()]'; 

-- Alternative 2 :
-- SQL Standard SIMILAR TO uses the '_' character to mean 'any character', 
-- and the '%' character to mean 'any string'. 


-- Pad zip codes with leading zeroes

select lpad(zipcode, 5, '0') as zip from cd.members order by zip;
-- Doesn't work

select table_name, column_name, data_type 
from information_schema.columns
where able_name = 'cd.members';
-- Shows that zipcode is integer and needs casting to string.
-- NVARCHAR does not exist in PostgreSql.

select lpad(cast(zipcode as varchar), 5, '0') as zip
from cd.members
order by zip;


-- Count the number of members whose surname starts with each letter of the alphabet 
select cast(surname as char) as letter, count(*)
from cd.members
group by letter
order by letter;

-- Alternative : substr(surname, 1, 1) or left(surname, 1)
-- NOTE : string functions in SQL are based on 1-indexing not 0-indexing


-- Clean up telephone numbers
-- The telephone numbers in the database are very inconsistently formatted. 
-- Print a list of member ids and numbers that have had '-','(',')', and ' ' characters removed. 
-- Order by member id. 
select memid, 
regexp_replace(telephone, '[-|(|)|/ ]+', '', 'g') as telephone
from cd.members
order by memid;

-- Discussion alternatives :
-- translate(telephone, '-() ', '')
-- regexp_replace(telephone, '[^0-9]', '', 'g')

-- Using a CHECK constraint on the column can prevent entry of poorly formatted data
-- Alternatives : Trigger on the table, or view over the table for formatting display,
-- Eg for legacy data.

