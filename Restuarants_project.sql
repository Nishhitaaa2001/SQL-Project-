create database project;
use project;
-- Consumers Table
CREATE TABLE consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    Latitude DECIMAL(10,7),
    Longitude DECIMAL(10,7),
    Smoker VARCHAR(10),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(50),
    Marital_Status VARCHAR(20),
    Children VARCHAR(20),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(10)
);

-- Restuarants Table
CREATE TABLE restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    Zip_Code VARCHAR(10),
    Latitude DECIMAL(11,8),
    Longitude DECIMAL(11,8),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(50),
    Price VARCHAR(10),
    Franchise VARCHAR(5),
    Area VARCHAR(10),
    Parking VARCHAR(50)
);

-- Restuarant_cuisines
CREATE TABLE restaurant_cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(255),
    PRIMARY KEY (Restaurant_ID, Cuisine),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);

-- Consumer_preferences
CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(255),
    PRIMARY KEY (Consumer_ID, Preferred_Cuisine),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID)
);

-- Ratings
CREATE TABLE ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,
    PRIMARY KEY (Consumer_ID, Restaurant_ID),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);

-- Using the WHERE clause to filter data based on specific criteria.

-- List all details of consumers who live in the city of 'Cuernavaca'.
select * from consumers where city='Cuernavaca';

-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select consumer_id,age,occupation from consumers where occupation='Student' and smoker='Yes';

-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
select name,city,alcohol_service,price from restaurants where alcohol_service='wine & beer' and price='medium';

-- Find the names and cities of all restaurants that are part of a 'Franchise'.
select name,city from restaurants where franchise='yes';

-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' 
-- (which corresponds to a value of 2, according to the data dictionary).
select consumer_id,restaurant_id,overall_rating from ratings where overall_rating=2;

-- Questions JOINs with Subqueries

-- List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
select r.name,r.city from restaurants r join ratings rt on r.restaurant_id=rt.restaurant_id where overall_rating=2;

-- Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
select distinct c.consumer_id,c.age 
from consumers c join ratings rt on c.consumer_id=rt.consumer_id
join restaurants r on rt.restaurant_id=rt.restaurant_id where r.city='San Luis Potosi';

-- List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select r.name from restaurants r 
join restaurant_cuisines rc on r.restaurant_id=rc.restaurant_id 
join ratings rt on r.restaurant_id=rc.restaurant_id where rc.cuisine='Mexican' and rt.consumer_id='U1001';

-- Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
select * from consumers c join consumer_preferences cp on c.consumer_id=cp.consumer_id where cp.preferred_cuisine='american' and c.budget='medium';

-- List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
select distinct r.name,r.city from restaurants r join ratings rt on r.restaurant_id=rt.restaurant_id where rt.food_rating<(select avg(food_rating) from ratings);

-- Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
select distinct c.consumer_id,c.age,c.occupation from consumers c join ratings rt on c.consumer_id=rt.consumer_id
where c.consumer_id not in(select rt1.consumer_id from ratings rt1 join restaurant_cuisines rc on rc.restaurant_id=rt1.restaurant_id where rc.cuisine='italian');

-- List restaurants (Name) that have received ratings from consumers older than 30.
select r.name from restaurants r join ratings rt on r.restaurant_id=rt.restaurant_id join consumers c  on rt.consumer_id=c.consumer_id  where c.age>30;

-- Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
select c.consumer_id,c.occupation from consumers c join consumer_preferences cp on c.consumer_id=cp.consumer_id where cp.preferred_cuisine='mexican' and c.consumer_id in (select distinct consumer_id from ratings where overall_rating=0);

-- List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
select distinct r.name,r.city from restaurants r join restaurant_cuisines rc on r.restaurant_id=rc.restaurant_id where rc.cuisine='pizzeria' and r.city in (select city from consumers where occupation ='student');

-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
select c.consumer_id,c.age from consumers c join ratings rt on rt.consumer_id=c.consumer_id where c.drink_level='social drinkers' and rt.restaurant_id in (select restaurant_id from restaurants where parking='none');

-- Questions Emphasizing WHERE Clause and Order of Execution
-- List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. 
-- Show only students who have rated more than 2 restaurants.
select rt.consumer_id,count(rt.restaurant_id) as no_of_restaurants from ratings rt join consumers c on c.consumer_id=rt.consumer_id 
where c.occupation='student' group by rt.consumer_id having count(rt.restaurant_id)>2;

-- We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation.
select consumer_id,age,(age/10) as engagement_score from consumers where (age/10)=2 and transportation_method='public';

-- For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.
select r.name,r.city,avg(rt.overall_rating) from restaurants r join ratings rt on r.restaurant_id=rt.restaurant_id where r.city='cuernavaca' group by r.name,r.city having avg(rt.overall_rating)>1;

-- Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.
select distinct c.consumer_id,c.age from consumers c join ratings rt on c.consumer_id=rt.consumer_id where c.marital_status='married' and rt.food_rating=rt.service_rating and rt.overall_rating=2;

-- List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
select distinct c.consumer_id,c.age,r.name from consumers c join ratings rt on c.consumer_id=rt.consumer_id join restaurants r on r.restaurant_id=rt.restaurant_id where c.occupation='employed' and rt.food_rating=0 and r.city='ciudad victoria';

-- Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures
-- Using a CTE, find all consumers who live in 'San Luis Potosi'.
-- Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.
with con_in_San as(
select * from consumers where city='San Luis Potosi')
select distinct con.consumer_id,con.age,r.name from con_in_San con join ratings rt on con.consumer_id=rt.consumer_id 
join restaurants r on r.restaurant_id=rt.restaurant_id join restaurant_cuisines rc on r.restaurant_id=rc.restaurant_id
where rc.cuisine='Mexican' and rt.Overall_rating=2;

-- For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. (Use a derived table to get consumers who have rated).
select c.occupation,avg(age) as avg_age from consumers c 
join ( select distinct consumer_id from ratings) as rated_consumers on c.consumer_id=rated_consumers.consumer_id group by c.occupation ;

-- Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.
with newtable as ( select rt.restaurant_id,rt.consumer_id,rt.overall_rating from ratings rt join restaurants r  on r.restaurant_id=rt.restaurant_id  where r.city='Cuernavaca' )
select restaurant_id,consumer_id,Overall_rating, rank() over (partition by restaurant_id order by overall_rating desc ) as ratingrank from newtable;

-- For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.
select consumer_id,restaurant_id,overall_rating, avg(overall_rating) over (partition by consumer_id) as avg_ratings from ratings;

-- Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).
with newtable_1 as( select consumer_id from consumers where occupation='Student' and budget='Low'), newtable_2 as (select cp.consumer_id,cp.preferred_cuisine, row_number() over( partition by (cp.consumer_id) order by cp.consumer_id,cp.preferred_cuisine ) as rn  from consumer_preferences cp join newtable_1 n1 on cp.consumer_id=n1.consumer_id )
select consumer_id,preferred_cuisine from newtable_2 where rn<=3 order by  consumer_id,rn;

-- Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first.
select restaurant_id,overall_rating,LEAD(r1.overall_rating) OVER (ORDER BY r1.restaurant_id) AS next_overall_rating
FROM (SELECT restaurant_id, overall_rating from ratings where consumer_id='U1008' ) as r1 order by r1.restaurant_id;

-- Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.
CREATE VIEW HighlyRatedMexicanRestaurantss AS
SELECT r.restaurant_id,r.name,r.city
FROM restaurants r
JOIN restaurant_cuisines rc 
    ON r.restaurant_id = rc.restaurant_id
JOIN ratings rt
    ON r.restaurant_id = rt.restaurant_id
WHERE rc.cuisine = 'Mexican' GROUP BY r.restaurant_id, r.name,r.city HAVING AVG(rt.overall_rating) > 1.5;

-- First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.
WITH mexican_lovers AS (
    SELECT consumer_id
    FROM consumer_preferences
    WHERE preferred_cuisine = 'Mexican')
SELECT ml.consumer_id
FROM mexican_lovers ml
WHERE ml.consumer_id NOT IN (
    SELECT DISTINCT r.consumer_id
    FROM ratings r
    JOIN HighlyRatedMexicanRestaurants h
        ON r.restaurant_id = h.restaurant_id );

-- Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input.
-- It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.
DELIMITER $$
CREATE PROCEDURE GetRestaurantRatingsAboveThresholds (
    IN p_restaurant_id VARCHAR(20),
    IN p_min_overall_rating INT )
BEGIN
    SELECT consumer_id,overall_rating,food_rating,service_rating FROM ratings WHERE restaurant_id = p_restaurant_id AND overall_rating >= p_min_overall_rating;
END $$
DELIMITER ;

-- Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.
WITH cuisine_ratings AS (
SELECT rc.cuisine,r.name AS restaurant_name,r.city,rt.overall_rating, DENSE_RANK() OVER (PARTITION BY rc.cuisine ORDER BY rt.overall_rating DESC) AS rating_rank
FROM restaurants r  JOIN ratings rt ON r.restaurant_id = rt.restaurant_id JOIN restaurant_cuisines rc ON r.restaurant_id = rc.restaurant_id )
SELECT cuisine,restaurant_name,city,overall_rating FROM cuisine_ratings WHERE rating_rank <= 2 ORDER BY cuisine, overall_rating DESC, restaurant_name;

