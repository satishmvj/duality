-- TITLE: Step 9 - updating in either direction: the document and the rows are one thing
-- Direction 1: the application edits the document. JSON_TRANSFORM changes two fields at
-- two levels, and APPEND adds an array element - which is a new ORDER_ITEMS row.
UPDATE orders_dv o
   SET o.data = JSON_TRANSFORM(o.data,
                  SET    '$.status'            = 'SHIPPED',
                  SET    '$.items[0].quantity' = 3,
                  APPEND '$.items' = JSON {'lineNo'   : 3,
                                           'quantity' : 1,
                                           'product'  : {'productId' : 108,
                                                         'name'      : 'Desk Lamp',
                                                         'price'     : 1499}})
 WHERE o.data."_id" = 2001;

SELECT order_id, status FROM orders WHERE order_id = 2001;

SELECT order_id, line_no, product_id, quantity
  FROM order_items WHERE order_id = 2001 ORDER BY line_no;

-- Direction 2: a batch job, a report or another application uses plain SQL on the
-- tables. There is nothing to synchronise - the next read of the document shows it.
UPDATE orders      SET status   = 'DELIVERED' WHERE order_id = 2001;
DELETE FROM order_items WHERE order_id = 2001 AND line_no = 2;

SELECT JSON_SERIALIZE(o.data PRETTY) AS order_2001
  FROM orders_dv o
 WHERE o.data."_id" = 2001;

COMMIT;
