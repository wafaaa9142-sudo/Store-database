/* STORE DATABASE - Part 1 (standard SQL, book Chapter 3 only)
   Works on programiz.com online SQL editor (SQLite). Safe to run again and again. */

-- Clean start: drop tables (children first). IF EXISTS = no error if missing (needed in SQLite).
drop table if exists order_item;
drop table if exists orders;
drop table if exists product;
drop table if exists category;
drop table if exists customer;
drop table if exists expensive_product;

/* ---------------- PART 1: DATA DEFINITION (book section 3.2) ---------------- */

-- create table = makes a new table. primary key = unique ID of each row.
create table category
(cat_id    int,
 cat_name  varchar (30) not null,      -- not null = value is required
 primary key (cat_id));

create table product
(prod_id   int,
 prod_name varchar (40) not null,
 cat_id    int,
 price     numeric (8,2),              -- numeric(8,2) = 8 digits, 2 after the point
 stock     int,
 primary key (prod_id),
 foreign key (cat_id) references category);   -- must match an existing category

create table customer
(cust_id   int,
 cust_name varchar (30) not null,
 city      varchar (20),
 phone     varchar (15),
 primary key (cust_id));

create table orders
(order_id   int,
 cust_id    int,
 order_date varchar (10),
 primary key (order_id),
 foreign key (cust_id) references customer);

create table order_item
(order_id int,
 prod_id  int,
 quantity int,
 primary key (order_id, prod_id),            -- primary key from two columns
 foreign key (order_id) references orders,
 foreign key (prod_id) references product);

-- alter table ... add = adds a new column (old rows get null)
alter table customer add email varchar (40);

/* ---------------- INSERT (book section 3.9.2) ---------------- */

insert into category values (1, 'Drinks');
insert into category values (2, 'Snacks');
insert into category values (3, 'Stationery');
insert into category values (4, 'Cleaning');

insert into product values (1, 'Orange Juice', 1, 15.50, 40);
insert into product values (2, 'Mineral Water', 1, 5.00, 200);
insert into product values (3, 'Chips', 2, 10.00, 120);
insert into product values (4, 'Chocolate Bar', 2, 12.75, 80);
insert into product values (5, 'Notebook', 3, 20.00, 60);
insert into product values (6, 'Blue Pen', 3, 4.50, 300);
insert into product values (7, 'Dish Soap', 4, 30.00, 25);
insert into product values (8, 'Tea Box', 1, 45.00, null);   -- null = stock not known yet

insert into customer values (1, 'Ahmed Ali', 'Cairo', '01011111111', null);
insert into customer values (2, 'Mona Samir', 'Giza', '01022222222', null);
insert into customer values (3, 'Omar Hassan', 'Cairo', '01033333333', null);
insert into customer values (4, 'Sara Adel', 'Alexandria', null, null);
insert into customer values (5, 'Youssef Khaled', 'Giza', '01055555555', null);

insert into orders values (101, 1, '2026-11-01');
insert into orders values (102, 2, '2026-11-02');
insert into orders values (103, 1, '2026-11-03');
insert into orders values (104, 3, '2026-11-05');
insert into orders values (105, 4, '2026-11-06');

-- insert with a column list (book 3.9.2): column order can be chosen
insert into order_item (order_id, prod_id, quantity) values (101, 1, 2);
insert into order_item (order_id, prod_id, quantity) values (101, 3, 5);
insert into order_item (order_id, prod_id, quantity) values (102, 2, 10);
insert into order_item (order_id, prod_id, quantity) values (102, 5, 3);
insert into order_item (order_id, prod_id, quantity) values (103, 4, 4);
insert into order_item (order_id, prod_id, quantity) values (103, 6, 10);
insert into order_item (order_id, prod_id, quantity) values (104, 1, 1);
insert into order_item (order_id, prod_id, quantity) values (104, 7, 2);
insert into order_item (order_id, prod_id, quantity) values (105, 3, 3);

/* ---------------- QUERIES (book sections 3.3 - 3.8) ---------------- */

-- 1. Basic select / from (3.3.1)
select prod_name
from product;

-- 2. distinct removes duplicates (3.3.1)
select distinct city
from customer;

-- 3. Arithmetic in select + rename with "as" (3.3.1, 3.4.1)
select prod_name, price * 1.1 as price_after_10_percent
from product;

-- 4. where with and (3.3.1)
select prod_name, price
from product
where cat_id = 1 and price < 20;

-- 5. Join two tables with where (3.3.2)
select prod_name, cat_name
from product, category
where product.cat_id = category.cat_id;

-- 6. Rename tables with "as" (3.4.1)
select C.cust_name, O.order_id
from customer as C, orders as O
where C.cust_id = O.cust_id;

-- 7. natural join (3.3.3): joins on columns with the same name
select cust_name, order_id, order_date
from customer natural join orders;

-- 8. String match with like (3.4.2): % = any text
select prod_name
from product
where prod_name like '%Pen%';

-- 9. order by (3.4.4)
select prod_name, price
from product
order by price desc, prod_name asc;

-- 10. between (3.4.5)
select prod_name, price
from product
where price between 10 and 30;

-- 11. Set operations (3.5): union / intersect / except (no brackets, for SQLite)
select cust_id from orders where order_date = '2026-11-01'
union
select cust_id from orders where order_date = '2026-11-05';

select cust_id from orders where order_date <= '2026-11-03'
intersect
select cust_id from orders where order_date >= '2026-11-03';

select cust_id from customer
except
select cust_id from orders;          -- customers who never ordered

-- 12. Null values (3.6): use "is null", never "= null"
select prod_name
from product
where stock is null;

-- 13. Aggregate functions (3.7.1)
select avg (price) as avg_price
from product;

select count (*) as number_of_products
from product;

select count (distinct cust_id) as customers_who_ordered
from orders;

select max (price) as highest_price, min (price) as lowest_price
from product;

-- 14. group by (3.7.2)
select cat_id, avg (price) as avg_price, count (*) as products
from product
group by cat_id;

-- 15. group by + natural join
select cust_name, count (order_id) as orders_count
from customer natural join orders
group by cust_name;

-- 16. having filters groups (3.7.3)
select cat_id, avg (price) as avg_price
from product
group by cat_id
having avg (price) > 12;

-- 17. Nested subqueries: in / not in (3.8.1)
select cust_name
from customer
where cust_id in (select cust_id from orders);

select prod_name
from product
where prod_id not in (select prod_id from order_item);   -- never sold

-- 18. Subquery with a comparison (3.8): same idea as "some" / "all", written with min / max
--     (SQLite does not support some / all)
select prod_name, price
from product
where price > (select min (price) from product where cat_id = 2);

select prod_name, price
from product
where price >= (select max (price) from product);        -- most expensive

-- 19. Scalar subquery (3.8.4)
select cat_name,
       (select count (*)
        from product
        where product.cat_id = category.cat_id) as num_products
from category;

/* ---------------- MODIFICATION (book section 3.9) ---------------- */

-- update (3.9.3): raise Snacks prices by 5%
update product
set price = price * 1.05
where cat_id = 2;

-- update with case (3.9.3)
update product
set price = case
              when price <= 20 then price * 1.05
              else price * 1.03
            end;

-- update with a subquery in where
update product
set stock = 0
where stock is null and price < (select avg (price) from product);

-- delete (3.9.1)
delete from order_item
where quantity = 1;

delete from customer
where cust_id not in (select cust_id from orders);

-- insert ... select (3.9.2): copy rows from another query
create table expensive_product
(prod_id int, prod_name varchar (40), price numeric (8,2), primary key (prod_id));

insert into expensive_product
select prod_id, prod_name, price
from product
where price > 25;

-- drop table (3.2.2): removes table AND its data (delete from only removes rows)
drop table expensive_product;


-- Final check: look at the data
select * from product;
