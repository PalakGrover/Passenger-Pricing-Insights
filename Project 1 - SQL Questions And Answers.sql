-- Project 1 - Travego - Questions with Solutions-- 

-- Q1: Creating the schema and required tables using sql script or using MySQL workbench UI.
-- a.	Create a schema named Travego. 
-- b.	Create the tables mentioned above with the mentioned column names. 
-- c.	Insert the data in the newly created tables using sql script or using MySQL UI. 


create database travego;
use travego;
drop table Passenger;
create table Passenger
(
Passenger_id int,
Passenger_name varchar(20),
Category varchar(20),
Gender varchar(20),
Boarding_city varchar(20),
Destination_city varchar(20),
Distance int,
Bus_Type varchar(20),
primary key(passenger_id)
);

insert into Passenger(Passenger_id, Passenger_name, Category, Gender, Boarding_city, Destination_city, Distance,Bus_Type)
values
(1, 'Sejal', 'AC', 'F', 'Bengaluru', 'Chennai', 350, 'Sleeper'),
(2,'Anmol','Non-AC', 'M', 'Mumbai', 'Hyderabad', 700, 'Sitting'),
(3, 'Pallavi', 'AC', 'F', 'Panaji', 'Bwngaluru', 600, 'Sleeper'),
(4, 'Khushboo', 'AC', 'F', 'Chennai', 'Mumbai', 1500, 'Sleeper'),
(5, 'Udit', 'Non-AC', 'M', 'Trivandram', 'Panaji', 1000, 'Sleeper'),
(6, 'Ankit', 'AC', 'M', 'Nagpur', 'Hyderabad', 500, 'Sitting'),
(7, 'Hemant', 'AC', 'M', 'Panaji', 'Mumbai', 700, 'Sleeper'),
(8, 'Manish', 'Non-AC', 'M', 'Hyderabad', 'Bengaluru', 500, 'Sitting'),
(9, 'Piyush', 'AC', 'M', 'Pune', 'Nagpur', 700, 'Sitting');


create table Price
(
id int,
Bus_Type varchar(20),
Distance int,
Ticket_Price int
);

insert into Price(id, Bus_Type, Distance, Ticket_Price)
values
(1, 'Sleeper', 350, 770),
(2, 'Sleeper', 500,1100),
(3, 'Sleeper', 600, 1320),
(4, 'Sleeper', 700, 1540),
(5, 'Sleeper', 1000, 2200),
(6, 'Sleeper', 1200, 2640),
(7, 'Sleeper', 1500, 2700),
(8, 'Sitting', 500, 620),
(9, 'Sitting', 600, 744),
(10, 'Sitting', 700, 868),
(11, 'Sitting', 1000, 1240),
(12, 'Sitting', 1200, 1488),
(13, 'Sitting', 1500, 1860);

select * from Passenger;
select * from Price;

-- Q2: Perform read operation on the designed table created in the above task using SQL script. 
-- a.	How many females and how many male passengers traveled a minimum distance of 600 KMs?

-- Approach 1
select count(Gender) as cg
from Passenger 
where distance = any(select min(distance) as mdis
from Passenger
group by passenger_name
having mdis = 600);

-- b.	Find the minimum ticket price of a Sleeper Bus. 

-- Approach 1- Without E-R Diagram
select min(Ticket_Price)
from Price
where bus_type = 'Sleeper';

-- Approach 2 - With E-R Diagram
select min(Ticket_Price) as mtp
from Price
where 
id in
(select Passenger_id
from Passenger
where Passenger_id = id
and
Bus_type = 'Sleeper');

-- c.	Select passenger names whose names start with character 'S' 

-- Approach 1
select passenger_name
from passenger
where passenger_name like "s%";

-- Approach 2
select passenger_name
from Passenger
where passenger_id = 
(select id 
from price 
where passenger_id = id and
passenger_name like "s%");

-- Approach 3
select p.passenger_name, p.passenger_id
from passenger p
join
Price q
on
q.id = p.passenger_id
and p.passenger_name like "s%";

-- d. Calculate price charged for each passenger displaying Passenger name, Boarding City, Destination City, Bus_Type, Price in the output

select distinct Passenger_name, Boarding_City, Destination_City, p.Bus_Type, q.Ticket_Price
from passenger p, price q
where id =
any(select passenger_id 
from passenger p 
where passenger_id = id)
group by 1, 2, 3, 4, 5;

-- The above query gives 50 rows with repating values for te follwing reasons:
-- When  taking pessanger_id as the common column, we cannot actually determine the ticket price because id's are just identifiers
-- The bus_type, and the distance can only help us detemine the bus fare.
-- which is why, we must take Bus_Type as a common column in our subquery

-- Approach 1 - Using Subqeury and Joining using Where Clause

select Passenger_name, Boarding_City, Destination_City, Bus_Type,
(select ticket_price
from price q
where q.bus_type = p.bus_type and q.distance  = p.distance) as Bus_Fare
from passenger p
order by 1;

-- Approach - Using Joins and Subqeuries 
select Passenger_name, Boarding_City, Destination_City, p.Bus_Type
from passenger p
join
(select bus_type, distance, ticket_price
from price)q
on p.bus_type = q.bus_type 
and
p.distance = q.distance
order by 1;

-- Approach 2 - Using Purely Joins
select Passenger_name, Boarding_City, Destination_City, p.Bus_Type
from passenger p
join
price q 
on p.bus_type = q.bus_type 
and
p.distance = q.distance
order by 1;

-- e.	What are the passenger name(s) and the ticket price for those who traveled 1000 KMs Sitting in a bus?  

-- Approach 1
select
Passenger_name, ticket_price
from passenger p
join 
price q 
on p.bus_type = q.bus_type
and 
p.distance = q.distance
where 
p.distance = 1000
and 
p.bus_type = 'Sitting';


-- Approach 2
select Passenger_name, ticket_price
from passenger p
join
price q
on 
q.bus_type = p.bus_type
where
p.distance = 1000
and p.bus_type = 'Sitting';


-- We can infer from here that person with 'Sitting' Bus Type in table 'price' having 11 columns shows that bus_id '11' has ticket_price of 1240
-- However, the same category of 'sitting; type and Distance 1000 kms doesn't exists and shows null
-- Therefore, we cannot fetch a data from the above query

SELECT Passenger.Passenger_name, Price.Ticket_Price
FROM Passenger
JOIN Price ON Passenger.Bus_Type = Price.Bus_Type AND Passenger.Distance = Price.Distance
WHERE Passenger.Category = 'Non-AC' AND Passenger.Distance = 1000 AND Passenger.Bus_Type = 'Sitting';

-- Assuming that Non_ac buses charge < 1000, we say that still no data match the criteria

-- f.	What will be the Sitting and Sleeper bus charge for Pallavi to travel from Bangalore to Panaji?

-- Approach 1
select q.bus_type, q.ticket_price
from price q
join
passenger p
on q.id = p.passenger_id
and
q.distance = p.distance
where
p.passenger_name = 'Pallavi'
and 
p.boarding_city = 'Bangalore'
and
p.destination_city = 'Panaji'
and
p.bus_type = 'sitting' and 'sleeper';

-- Approach 2
select  q.bus_type, ticket_price
from price q
where bus_type in(
select bus_type
from passenger p
where
p.passenger_name = 'Pallavi'
and 
p.boarding_city = 'Bangalore'
and
p.destination_city = 'Panaji'
and
p.bus_type like 'sitting' and 'sleeper');

-- Approach 3
select q.Bus_Type, q.Ticket_Price
from Price q
join Passenger p on q.Bus_Type = p.Bus_Type and q.Distance = p.Distance
where p.Passenger_name = 'Pallavi'
and p.Boarding_city = 'Bangalore'
and p.Destination_city = 'Panaji'
and q.Bus_Type in ('Sitting', 'Sleeper');

-- g.	List the distances from the "Passenger" table which are unique (non-repeated distances) in descending order. 
-- Approach 1

select distinct distance
from passenger p
order by 1 desc;

-- Approach 2
select distinct distance 
from passenger
where distance in
(select distinct distance
from passenger)
order by 1 desc;

-- Approach 3
select distance 
from passenger
group by 1
order by 1 desc;


-- Approach 4
with unique_dist_desc as
(select distinct distance
from passenger)
select distance
from unique_dist_desc
order by 1 desc;

-- h.	Display the passenger name and percentage of distance traveled by that passenger from the total distance traveled by all passengers without using user variables
-- Easiest Approach
select passenger_name,
round(distance/(select sum(distance) from passenger) * 100,2) as dist_per
from passenger;


-- Approach 2-  With double open and close parenthesis
select passenger_name,
round((distance/(select sum(distance) from passenger))*100,2) as per_distance
from passenger;

-- Approach 3 - Somewhat Easy Approach

select passenger_name,
round(sum(p.distance/(select sum(distance) from passenger))*100,2) as pct_dis
from passenger p
group by p.passenger_name;

select 
p.passenger_name,
round(sum((p.distance)/(select sum(distance) from passenger)) * 100,2) as per_distance
from passenger p
group by p.passenger_name;

-- Approach 3
select passenger_name,
(distance/total_distance_travelled *100) as percentage_travelled
from passenger,
(select sum(distance) as total_distance_travelled from passenger) as ty
order by 1;

-- Approach 4 -Using a cross join
select p.passenger_name, 
round(sum((p.distance)/t.total_distance) *100, 2)  as per_travelled
from passenger p
cross join
(select sum(distance) as total_distance from passenger) as t
group by p.passenger_name;

