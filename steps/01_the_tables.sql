-- TITLE: Step 1 - the relational side: one order is rows in four tables
-- Four normalised tables. Each customer, product and order is stored exactly once.
SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM customers   UNION ALL
SELECT 'PRODUCTS',                COUNT(*)              FROM products    UNION ALL
SELECT 'ORDERS',                  COUNT(*)              FROM orders      UNION ALL
SELECT 'ORDER_ITEMS',             COUNT(*)              FROM order_items;

-- What the application thinks of as "order 1001" comes back as a join of four tables:
-- three rows, with the order header and the customer repeated on every one of them.
SELECT o.order_id, o.status, c.name AS customer, c.city,
       i.line_no, p.name AS product, p.price, i.quantity
  FROM orders o
  JOIN customers   c ON c.customer_id = o.customer_id
  JOIN order_items i ON i.order_id    = o.order_id
  JOIN products    p ON p.product_id  = i.product_id
 WHERE o.order_id = 1001
 ORDER BY i.line_no;
