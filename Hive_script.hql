-- shows all databases 
show databases;
-- uses the database i want to qury
use project1;
-- shows all the tables 
show tables;

--creating the tables
create table if not exists branch(Drink String , BranchID String)row format delimited fields terminated by ',' stored as textfile;
create table if not exists count(Drink String , Drink_count Int)row format delimited fields terminated by ',' stored as textfile;

--loading data into the tables
LOAD DATA INPATH '/user/dylan/Branch.txt' OVERWRITE INTO TABLE branch;
LOAD DATA INPATH '/user/dylan/count.txt' OVERWRITE INTO TABLE count;

--checking content
SELECT * from branch
select * from count



-- problem statement 1
-- Question 1
select sum(c.drink_count) from branch b JOIN count c on (b.Drink = c.Drink) WHERE b.branchid = "Branch1"; 
-- Question 2
select sum(c.drink_count) from branch b JOIN count c on (b.Drink = c.Drink) WHERE b.branchid = "Branch2"; 



-- problem statement 2
-- Question 1
SELECT c.drink, sum(c.drink_count) as drink_total from branch b JOIN count c on (b.Drink = c.Drink) where branchid = 'Branch1' GROUP by c.drink order by drink_total DESC limit 1
--What is the least consumed beverage on Branch2
-- Question 2
SELECT c.drink, sum(c.drink_count) as drink_total from branch b JOIN count c on (b.Drink = c.Drink) where branchid = 'Branch2' GROUP by c.drink order by drink_total limit 1


-- problem statement 3
-- Question 1
select DISTINCT drink from branch where branchid = 'Branch1' or branchid = 'Branch8' or branchid = 'Branch10'
-- Question 2
select distinct drink from branch where branchid = 'Branch4' INTERSECT select distinct drink from branch where branchid = 'Branch7' 



-- create a partition,index,View for the scenario3.
-- problem statement 4

--views
create view if not exists PS_3_Q1 as select DISTINCT drink from branch where branchid = 'Branch1' or branchid = 'Branch8' or branchid = 'Branch10'
create view if not exists PS_3_Q2 as select distinct drink from branch where branchid = 'Branch4' INTERSECT select distinct drink from branch where branchid = 'Branch7' 

select * from ps_3_q1 

-- index
create index test2 on table branch(drink) AS 'COMPACT' WITH DEFERRED REBUILD;
alter index test2 on branch rebuild

-- Partition

create table branch_partition (drink string) partitioned by (branchid string)row format delimited fields terminated by ',' stored as textfile;


SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;


INSERT OVERWRITE TABLE branch_partition PARTITION (branchid) select Drink, BranchID from branch; 

select DISTINCT drink from branch_partition where branchid = 'Branch1' or branchid = 'Branch8' or branchid = 'Branch10'
select distinct drink from branch_partition where branchid = 'Branch4' INTERSECT select distinct drink from branch where branchid = 'Branch7' 


-- Alter the table properties to add "note","comment"
-- problem statement 5
show tblproperties count;
ALTER TABLE count SET TBLPROPERTIES('comment'='this table has a list of drinks, and a list of how many drinks sold');
show tblproperties count;

ALTER TABLE count SET TBLPROPERTIES('note'='this is a note');

show tblproperties count;

-- Remove the row 5 from a TABLE
-- problem statement 6
create table if not exists pbs6 row format delimited fields terminated by ',' stored as textfile AS SELECT c.drink, sum(c.drink_count) as drink_total from branch b JOIN count c on (b.Drink = c.Drink) where branchid = 'Branch1' GROUP by c.drink order by drink_total DESC limit 5

--before
select * from pbs6

--after 
select drink, drink_total from (select pbs6.*, ROW_NUMBER() over (order by drink_total DESC) as rownum from pbs6) pbs6 where rownum != 5; 