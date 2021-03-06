// How to create rows to count properly line items
// Customer Cohorts
// Step 0: Show Orders details by Customers
select "Customer Name","Order_Date","Order ID","Product Name","Quantity"
from "INTERNAL"."PUBLIC"."SuperStore"
order by 1,2;

// Step 1: Show multiple Orders by Customers
select "Customer Name","Order_Date","Order ID", count(distinct "Order ID") as Orders,SUM(1) as "Line Items"
from "INTERNAL"."PUBLIC"."SuperStore"
group by 1,2,3
order by 1,3;

// Step 2: Show rank of Orders by Customers
select "Customer Name","Order ID","Order_Date",DENSE_RANK() OVER (PARTITION BY "Customer Name" ORDER by "Order_Date") as "Order Rank", count(distinct "Order ID") as Orders,SUM(1) as "Line Items"
from "INTERNAL"."PUBLIC"."SuperStore"
group by 1,2,3
order by 1,3;
--- enhance table to include Rank and first order date for Customer Cohort
CREATE OR REPLACE TABLE "INTERNAL"."PUBLIC"."SuperStore" AS
select *,DENSE_RANK() OVER (PARTITION BY "Customer Name" ORDER by "Order_Date") as "Order Rank",First_Value("Order_Date") OVER (PARTITION BY "Customer Name" ORDER by "Order_Date") as "Customer Cohort"
from "INTERNAL"."PUBLIC"."SuperStore";

// Product Sequence
// Step 3: Show all customers who ordered a product more than once
select "Customer Name","Product Name",SUM(1) as "Line Items"
from "INTERNAL"."PUBLIC"."SuperStore"
group by 1,2
having "Line Items">1
order by 1,2;

// Step 4: Show rank of Products by Customers
select "Customer Name","Order_Date","Order ID","Product Name",RANK() OVER (PARTITION BY "Customer Name","Product Name" ORDER by "Order_Date") as "Product Rank",SUM(1) as "Line Items"
from "INTERNAL"."PUBLIC"."SuperStore"
group by 1,2,3,4
order by 1,2;

// Step 5: Show rank of Products by Customers: check Suzanne
select "Customer Name","Product Name","Order_Date",RANK() OVER (PARTITION BY "Customer Name","Product Name" ORDER by "Order_Date") as "Product Rank",SUM(1) as "Line Items"
from "INTERNAL"."PUBLIC"."SuperStore"
WHERE "Customer Name"='Suzanne McNair'
group by 1,2,3
order by 1,2;

// Step 6: Show rank of Products by Customers with Quantities: WRONG!
select "Customer Name","Order_Date","Order ID","Product Name",RANK() OVER (PARTITION BY "Customer Name","Product Name" ORDER by "Order_Date") as "Product Rank",SUM(1) as "Line Items",SUM("Quantity")
from "INTERNAL"."PUBLIC"."SuperStore"
WHERE "Customer Name"='Suzanne McNair'
group by 1,2,3,4
order by 1,4;

select avg("Quantity") from "INTERNAL"."PUBLIC"."SuperStore";

// Step 7: Create Numbers Table
CREATE TABLE "INTERNAL"."PUBLIC"."NUMBERS"(Number  int  not null)  ;
// Step 8: Populate Numbers Table
insert into "INTERNAL"."PUBLIC"."NUMBERS"(Number)
  WITH Nums(Number) AS
(SELECT 1 AS Number
 UNION ALL
 SELECT Number+1 FROM Nums where Number<100
)
select Number from Nums;
//Check it
select * from "INTERNAL"."PUBLIC"."NUMBERS";
// Insert 100 additional
 insert into "INTERNAL"."PUBLIC"."NUMBERS"(Number)
  WITH Nums(Number) AS
(SELECT 101 AS Number
 UNION ALL
 SELECT Number+1 FROM Nums where Number<200
)
select Number from Nums;

// Step 8: Prepare Table with one additional row for each line item where quantity>1
CREATE OR REPLACE TABLE "INTERNAL"."PUBLIC"."SuperStore_Products" AS
SELECT SOURCE.*,N."NUMBER" as "Item Count"
FROM "INTERNAL"."PUBLIC"."SuperStore" AS SOURCE
    JOIN
   "INTERNAL"."PUBLIC"."NUMBERS" N 
   ON N.Number <= SOURCE."Quantity" ;

// Step 9: Update line items to keep totals
UPDATE "INTERNAL"."PUBLIC"."SuperStore_Products"
       SET "Sales" = "Sales"/"Quantity";
UPDATE "INTERNAL"."PUBLIC"."SuperStore_Products"
       SET "Profit" = "Profit"/"Quantity";
UPDATE "INTERNAL"."PUBLIC"."SuperStore_Products"
       SET "Quantity" = 1;
     
       
// Step 10: 
CREATE OR REPLACE TABLE "INTERNAL"."PUBLIC"."SuperStore_Products" AS
select *,RANK() OVER (PARTITION BY "Customer Name","Product Name" ORDER by "Order_Date","Item Count") as "Product Rank"
from "INTERNAL"."PUBLIC"."SuperStore_Products";

// Step 11: Test Table Before
select *,RANK() OVER (PARTITION BY "Customer Name","Product Name" ORDER by "Order_Date") as "Product Rank"
from "INTERNAL"."PUBLIC"."SuperStore"  
WHERE "Customer Name"='Suzanne McNair' AND "Product Name"='Southworth Parchment Paper & Envelopes'
ORDER BY "Product Rank" DESC;

// Step 12: Test Table After
select *
from "INTERNAL"."PUBLIC"."SuperStore_Products"
WHERE "Customer Name"='Suzanne McNair' AND "Product Name"='Southworth Parchment Paper & Envelopes'
ORDER BY "Customer Name","Product Name","Product Rank";
