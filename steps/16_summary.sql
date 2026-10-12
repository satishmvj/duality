-- TITLE: Step 16 - what was built: three document shapes, one set of tables
SELECT view_name, root_table_name, allow_insert, allow_update, allow_delete, status
  FROM user_json_duality_views
 ORDER BY view_name;

-- Documents per view, rows per table. The views add documents, not data.
SELECT 'PRODUCTS_DV' AS object_name, COUNT(*) AS items FROM products_dv  UNION ALL
SELECT 'ORDERS_DV',                  COUNT(*)          FROM orders_dv    UNION ALL
SELECT 'CUSTOMERS_DV',               COUNT(*)          FROM customers_dv UNION ALL
SELECT 'PRODUCTS',                   COUNT(*)          FROM products     UNION ALL
SELECT 'ORDERS',                     COUNT(*)          FROM orders       UNION ALL
SELECT 'ORDER_ITEMS',                COUNT(*)          FROM order_items  UNION ALL
SELECT 'CUSTOMERS',                  COUNT(*)          FROM customers;

-- ORDERS_DV was left INVALID by step 15's ALTER TABLE, yet it answered the count above.
-- The status after that query:
SELECT view_name, status FROM user_json_duality_views ORDER BY view_name;

-- Storage belongs to the tables and their indexes only. The three views have none.
SELECT segment_type, COUNT(*) AS segments
  FROM user_segments
 GROUP BY segment_type
 ORDER BY segment_type;

SELECT object_type, COUNT(*) AS objects
  FROM user_objects
 WHERE object_type IN ('TABLE', 'VIEW', 'INDEX')
 GROUP BY object_type
 ORDER BY object_type;
