-- TITLE: Step 5 - a nested duality view: an order as the application sees it
-- Four tables, one document. The nesting follows the foreign keys, and each table gets
-- its own rules: the order and its lines can be changed through this document, while
-- the customer and the products are there to be read (NOUPDATE).
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW orders_dv AS
SELECT JSON {'_id'       : o.order_id,
             'orderDate' : o.order_date,
             'status'    : o.status,
             'customer'  :
               (SELECT JSON {'customerId' : c.customer_id,
                             'name'       : c.name,
                             'city'       : c.city}
                  FROM customers c WITH NOUPDATE
                 WHERE c.customer_id = o.customer_id),
             'items'     :
               [SELECT JSON {'lineNo'   : i.line_no,
                             'quantity' : i.quantity,
                             'product'  :
                               (SELECT JSON {'productId' : p.product_id,
                                             'name'      : p.name,
                                             'price'     : p.price}
                                  FROM products p WITH NOUPDATE
                                 WHERE p.product_id = i.product_id)}
                  FROM order_items i WITH INSERT UPDATE DELETE
                 WHERE i.order_id = o.order_id]}
  FROM orders o WITH INSERT UPDATE DELETE;

-- Order 1001 again - the same data as step 1's three joined rows, as one object.
SELECT JSON_SERIALIZE(o.data PRETTY) AS order_1001
  FROM orders_dv o
 WHERE o.data."_id" = 1001;

-- One document per row of the root table.
SELECT (SELECT COUNT(*) FROM orders_dv) AS documents,
       (SELECT COUNT(*) FROM orders)    AS order_rows
  FROM dual;
