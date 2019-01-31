USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select  CONCAT_WS( " " , first_name , last_name ) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name like "%Joe%";

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select * from actor where last_name like "%LI%" ORDER BY last_name,first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country in  ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table `sakila`.`actor`
add column `Description` blob after `last_name`;

-- Mostrar cambios en la tabla
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table `sakila`.`actor` drop column Description;

-- Mostrar cambios en la tabla
select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name) from actor 
group by last_name
having count(last_name)>1 ;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select * from actor where first_name = "GROUCHO" and last_name="WILLIAMS";
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" and last_name="WILLIAMS";
SELECT * FROM actor where first_name = "HARPO" and last_name="WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor set first_name="GROUCHO" where first_name="HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select * from staff;
select * from address;

select staff.first_name,staff.last_name, address.address 
from staff 
left join address 
on staff.address_id = address.address_id; 

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select * from staff;
select * from payment;

select t1.staff_id, t1.first_name, t1.last_name , sum(t2.amount)
from staff as t1
left join payment as t2
on t1.staff_id = t2.staff_id
group by t1.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film_actor;
select * from film;

select t1.title, count(t2.actor_id)
from film as t1
inner join film_actor as t2
on t1.film_id = t2.film_id
group by t1.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;
select * from film;

select t1.title , count(t2.film_id)
from film as t1
left join inventory as t2
on t1.film_id = t2.film_id
where t1.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select * from payment;
select * from customer;

select t1.first_name , t1.last_name , sum(t2.amount)
from customer as t1
left join payment as t2
on t1.customer_id = t2.customer_id
group by t1.first_name
order by t1.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from film;
select * from language;

select title from film
where (title like "K%" or title like "Q%") and language_id in (Select language_id where language_id =1 ) ;


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from film_actor;
select * from film;
select * from actor;

select first_name,last_name from actor 
where actor_id in ( Select actor_id from film_actor where film_id in ( Select film_id from film where title="Alone Trip" )  );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.

select * from customer;
select * from address;
select * from city;
select * from country;

select first_name,last_name,email from customer 
where address_id in ( Select address_id from address where city_id in 
( Select city_id from city where country_id in 
(Select country_id from country where country="Canada" )  ) );

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select * from film;
select * from film_category;
select * from category;

select title from film 
where film_id in (Select film_id from film_category where category_id in (Select category_id from category where category_id=8 ) );

-- 7e. Display the most frequently rented movies in descending order.
select * from rental;
select * from inventory;
select * from film;


select title, (select count( (Select count(*) from rental where rental.inventory_id = inventory.inventory_id ) ) 
from inventory where film.film_id=inventory.film_id ) as "Most Frequently Rented" 
from film
order by (select count( (Select count(*) from rental where rental.inventory_id = inventory.inventory_id ) ) 
from inventory where film.film_id=inventory.film_id ) desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
select * from staff;
select * from payment;

select store_id, 
( select sum( 
(Select sum(amount) from payment where payment.staff_id = staff.staff_id  ) ) from staff where staff.store_id =store.store_id ) as "Revenue per Store"
from store;


-- 7g. Write a query to display for each store its store ID, city, and country.

















