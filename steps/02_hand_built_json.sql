-- TITLE: Step 2 - building the document by hand, and why it only works one way
-- The usual answer: assemble the JSON in SQL. It reads well...
CREATE OR REPLACE VIEW orders_json_v AS
SELECT o.order_id,
       JSON_OBJECT(
         'orderId'  VALUE o.order_id,
         'status'   VALUE o.status,
         'customer' VALUE (SELECT JSON_OBJECT('name' VALUE c.name, 'city' VALUE c.city)
                             FROM customers c WHERE c.customer_id = o.customer_id),
         'items'    VALUE (SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT('product'  VALUE p.name,
                                                'quantity' VALUE i.quantity)
                                    ORDER BY i.line_no)
                             FROM order_items i JOIN products p ON p.product_id = i.product_id
                            WHERE i.order_id = o.order_id)) AS data
  FROM orders o;

SELECT data FROM orders_json_v WHERE order_id = 1001;

-- ...but it only works one way. The application edits the document and sends it back,
-- and an ordinary view has no idea which table the change belongs to.
UPDATE orders_json_v v
   SET v.data = JSON_TRANSFORM(v.data, SET '$.status' = 'SHIPPED')
 WHERE v.order_id = 1001;

-- So every write needs hand-written code that takes the document apart again.
DROP VIEW orders_json_v;
