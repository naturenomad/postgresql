

-- ##########################################
-- #### Recursive Queries ###################

-- https://pgexercises.com/questions/recursive/

-- Common Table Expressions allow creation of temporary tables for the 
-- duration of a query - they're largely a convenience to make more readable SQL. 
-- Using the WITH RECURSIVE modifier it's possible to create recursive queries as well.

-- Find the upward recommendation chain for member ID 27
-- That is, the member who recommended them, and the member who recommended that member, 
-- and so on. Return member ID, first name, and surname. Order by descending member id. 

-- Creating the first round :
select recommended.recommendedby, recommender.firstname, recommender.surname
from cd.members recommended
inner join cd.members recommender
on recommended.recommendedby=recommender.memid
where recommended.memid=27;

-- To keep this simple, build the recursion using recommendedby id only, 
-- then add the names at the end :
with recursive recommenders as (
select recommendedby
from cd.members
where memid=27
union
select r.recommendedby
from cd.members r
inner join recommenders on r.memid = recommenders.recommendedby
) select m.memid, m.firstname, m.surname from recommenders
inner join cd.members m
on recommenders.recommendedby=m.memid;


-- tbc...

