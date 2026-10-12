-- TITLE: Step 7 - querying documents with SQL, and what actually runs
-- Dot notation walks into the document. This is an ordinary SQL query.
SELECT o.data."_id".number()          AS order_id,
       o.data.customer.name.string()  AS customer,
       o.data.status.string()         AS status,
       JSON_VALUE(o.data, '$.items.size()') AS lines
  FROM orders_dv o
 WHERE o.data.customer.city.string() = 'Pune'
 ORDER BY 1
 FETCH FIRST 6 ROWS ONLY;

-- A filter on a nested array element: every order containing a monitor.
SELECT COUNT(*) AS orders_with_a_monitor
  FROM orders_dv o
 WHERE JSON_EXISTS(o.data, '$.items[*].product?(@.name == "27in Monitor")');

-- No document is stored anywhere. The plan reads the four tables: the order by its
-- key, and the customer and each product by theirs. Order lines are fetched with
-- ORDER_ID = :B1 - on this 81-row table, a full scan is the optimizer's cheapest way to do that.
EXPLAIN PLAN FOR
SELECT o.data FROM orders_dv o WHERE o.data."_id" = 1001;

SELECT plan_table_output
  FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +PREDICATE'));
