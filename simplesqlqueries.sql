##########################################################################

# Solutions to the PostgreSql exercises listed at https://pgexercises.com/
# Listed below in sequential order

############################
#### Simple SQL Queries ####

https://pgexercises.com/questions/basic/

# This category deals with the basics of SQL. It covers select and where clauses, case expressions, unions, and a few other odds and ends. 

# Retrieve everything from a table
select * from cd.facilities;

# Retrieve specific columns from a table
select name, membercost from cd.facilities;

#  Control which rows are retrieved
select * from cd.facilities where membercost > 0;

# Control which rows are retrieved - part 2
select facid, name, membercost, monthlymaintenance 
from cd.facilities where membercost > 0 and membercost < (monthlymaintenance/50);

# Basic string searches
select * from cd.facilities where name like '%Tennis%';

# Matching against multiple possible values
select * from cd.facilities where facid in (1,5);

# Classify results into buckets
select name, 
    case 
        when (monthlymaintenance > 100) then 'expensive'
        else 'cheap'
    end as cost
from cd.facilities;

# Working with dates
select memid, surname, firstname, joindate from cd.members
where joindate >= '2012-09-01';

# Removing duplicates, and ordering results
select distinct(surname) from cd.members order by surname limit 10;

# Combining results from multiple queries
select surname from cd.members
union
select name from cd.facilities;

# Simple aggregation
select max(joindate) from cd.members;

# More aggregation
select firstname, surname, joindate from cd.members
where joindate=(select max(joindate) from cd.members);

