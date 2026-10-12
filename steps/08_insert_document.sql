-- TITLE: Step 8 - inserting a document writes rows to the tables
-- The application sends one JSON document. It never mentions ORDER_ITEMS.
INSERT INTO orders_dv VALUES ('
{
  "_id"       : 2001,
  "orderDate" : "2026-09-17T00:00:00",
  "status"    : "PLACED",
  "customer"  : {"customerId" : 3, "name" : "Arjun Nair", "city" : "Chennai"},
  "items"     : [
    {"lineNo" : 1, "quantity" : 1,
     "product" : {"productId" : 105, "name" : "27in Monitor", "price" : 18999}},
    {"lineNo" : 2, "quantity" : 2,
     "product" : {"productId" : 104, "name" : "Wireless Mouse", "price" : 1299}}
  ]
}');

-- One document became one ORDERS row and two ORDER_ITEMS rows. CUSTOMERS and PRODUCTS
-- are only referenced, so the customer and the products must already exist.
SELECT order_id, customer_id, order_date, status FROM orders WHERE order_id = 2001;

SELECT order_id, line_no, product_id, quantity FROM order_items WHERE order_id = 2001;

-- A trap. The customer is annotated NOUPDATE, so a wrong name in an incoming document
-- is not an error - it is ignored. This insert succeeds...
INSERT INTO orders_dv VALUES ('
{
  "_id" : 2002, "orderDate" : "2026-09-17T00:00:00", "status" : "PLACED",
  "customer" : {"customerId" : 3, "name" : "Somebody Else", "city" : "Nowhere"},
  "items" : []
}');

-- ...and reading it back shows the name from the table, not the one that was sent.
SELECT o.data.customer.name.string() AS name_stored,
       o.data.customer.city.string() AS city_stored
  FROM orders_dv o
 WHERE o.data."_id" = 2002;

-- The customer is only referenced, so an order cannot create one. Customer 999 does not
-- exist, and this document is refused.
INSERT INTO orders_dv VALUES ('
{
  "_id" : 2003, "orderDate" : "2026-09-17T00:00:00", "status" : "PLACED",
  "customer" : {"customerId" : 999, "name" : "New Customer", "city" : "Goa"},
  "items" : []
}');

COMMIT;
