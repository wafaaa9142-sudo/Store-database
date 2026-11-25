/* =====================================================================
   PART 2 - NOT FOR programiz / SQLite!
   Needs SQL Server (functions + procedures) and MySQL (the trigger at the end).
   Run store_part1_sqlite.sql's tables first on that system (remove the "if exists" lines if SQL Server is old).
   ===================================================================== */

/* PART 2: SQL SERVER ONLY (T-SQL)  -  Chapters 6, 7, 8
   ===================================================================== */

/* ---------------- USER-DEFINED FUNCTIONS (Chapter 6) ---------------- */

-- 6.3 Scalar function: returns ONE value
create function TotalStock ()
returns int
as
begin
    declare @total int
    select @total = sum (stock) from product
    return @total
end
go

select dbo.TotalStock () as all_items_in_stock
go

-- 6.3.2 Scalar function with parameters
create function PriceWithTax (@price numeric(8,2), @rate numeric(4,2))
returns numeric(8,2)
as
begin
    return (@price + @price * @rate)
end
go

select prod_name, dbo.PriceWithTax (price, 0.14) as price_with_tax
from product
go

-- 6.4.1 Inline table-valued function: returns a table
create function ProductsByCategory (@cat int)
returns table
as
return
    select * from product
    where cat_id = @cat
go

select * from ProductsByCategory (1)
go

/* ---------------- STORED PROCEDURES (Chapter 7) ---------------- */

-- 7.3 Without parameters
create proc usp_list_products
as
select * from product
go

exec usp_list_products
go

-- 7.4 With parameters: insert / update / delete
create proc usp_add_customer (@id int, @name varchar(30), @city varchar(20))
as
insert into customer (cust_id, cust_name, city) values (@id, @name, @city)
go

exec usp_add_customer 6, 'Laila Nabil', 'Cairo'
go

create proc usp_change_price (@id int, @new_price numeric(8,2))
as
update product set price = @new_price where prod_id = @id
go

exec usp_change_price 6, 5.00
go

create proc usp_delete_customer (@id int)
as
delete from customer where cust_id = @id
go

exec usp_delete_customer 6
go

-- 7.5 With an OUTPUT parameter (returns a value)
create procedure usp_count_customers_in_city
    @city varchar(20),
    @cnt int output
as
select @cnt = count (*) from customer where city = @city
go

declare @cnt int
exec usp_count_customers_in_city @city = 'Cairo', @cnt = @cnt output
select @cnt as customers_in_cairo
go

-- 7.6 Try / Catch, 7.9 set nocount on, 7.7 comments (-- line, /* block */)
create procedure usp_safe_divide_test
as
set nocount on      /* stops the "n rows affected" message */
begin try
    select 1/0
end try
begin catch
    select error_number () as ErrorNumber      -- shows the error code
end catch
go

exec usp_safe_divide_test
go

-- 7.11 Modify a procedure
alter procedure usp_list_products
as
select prod_name, price from product order by price
go

-- 7.10 Delete a procedure
drop proc usp_safe_divide_test
go

/* ---------------- TRIGGER (Chapter 8) ----------------
   The book (8.2) writes triggers with BEFORE/AFTER ... FOR EACH ROW and
   NEW / OLD (MySQL style). The lines below follow the book exactly, so run
   this part on MySQL. SQL Server writes triggers differently (inserted /
   deleted tables), which the book does not show.                       */

create table price_changes
(prod_id    int,
 changed_at datetime default current_timestamp,
 old_price  numeric (8,2),
 new_price  numeric (8,2),
 primary key (prod_id, changed_at));

create trigger before_update_price
before update on product
for each row
begin
    if NEW.price <> OLD.price then
        insert into price_changes (prod_id, old_price, new_price)
        values (NEW.prod_id, OLD.price, NEW.price);
    end if;
end;

-- test: change a price, then look at the log table
update product set price = price * 1.05 where prod_id = 1;
select * from price_changes;
