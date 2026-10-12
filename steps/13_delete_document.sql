-- TITLE: Step 13 - deleting a document, and what it takes with it
SELECT (SELECT COUNT(*) FROM orders)      AS orders,
       (SELECT COUNT(*) FROM order_items) AS order_items,
       (SELECT COUNT(*) FROM customers)   AS customers,
       (SELECT COUNT(*) FROM products)    AS products
  FROM dual;

-- Deleting order 2001 deletes its ORDERS row and its ORDER_ITEMS rows, because both are
-- annotated DELETE. The customer and the products are only referenced, so they stay.
DELETE FROM orders_dv o WHERE o.data."_id" = 2001;

SELECT (SELECT COUNT(*) FROM orders)      AS orders,
       (SELECT COUNT(*) FROM order_items) AS order_items,
       (SELECT COUNT(*) FROM customers)   AS customers,
       (SELECT COUNT(*) FROM products)    AS products
  FROM dual;

-- The other direction is not allowed. Customer 3 still has orders, and CUSTOMERS_DV
-- declared its orders @nodelete, so removing the customer document is refused.
DELETE FROM customers_dv c WHERE c.data."_id" = 3;

-- The same data seen through the other view: customer 3 still lists order 2002.
SELECT JSON_SERIALIZE(c.data.orders PRETTY) AS orders_of_customer_3
  FROM customers_dv c
 WHERE c.data."_id" = 3;

COMMIT;
