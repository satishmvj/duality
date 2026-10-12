-- TITLE: Step 3 - the other answer: store documents, and store every fact many times
-- A pure document store keeps each order as one self-contained JSON document. Built here
-- from the same 40 orders, so both sides hold identical information.
CREATE TABLE order_docs (id NUMBER PRIMARY KEY, data JSON);

INSERT INTO order_docs
SELECT o.order_id,
       JSON_OBJECT(
         'orderId'  VALUE o.order_id,
         'customer' VALUE JSON_OBJECT('name' VALUE c.name, 'city' VALUE c.city),
         'items'    VALUE (SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT('product'  VALUE p.name,
                                                'price'    VALUE p.price,
                                                'quantity' VALUE i.quantity))
                             FROM order_items i JOIN products p ON p.product_id = i.product_id
                            WHERE i.order_id = o.order_id)
         RETURNING JSON)
  FROM orders o JOIN customers c ON c.customer_id = o.customer_id;

-- Reading is easy. The cost is that a product's name and price are copied into every
-- order that contains it. In the tables, the USB-C Hub price exists once.
SELECT COUNT(*) AS rows_in_products_table
  FROM products WHERE name = 'USB-C Hub';

SELECT COUNT(*) AS copies_in_documents
  FROM order_docs d,
       JSON_TABLE(d.data, '$.items[*]' COLUMNS (product VARCHAR2(60) PATH '$.product')) jt
 WHERE jt.product = 'USB-C Hub';

-- A price change now means finding every copy. Miss one and the store disagrees with
-- itself - here the change reaches only the orders the code happened to look at.
UPDATE order_docs d
   SET d.data = JSON_TRANSFORM(d.data,
                  SET '$.items[*]?(@.product == "USB-C Hub").price' = 2299)
 WHERE d.id < 1020;

SELECT jt.price, COUNT(*) AS copies
  FROM order_docs d,
       JSON_TABLE(d.data, '$.items[*]' COLUMNS (product VARCHAR2(60) PATH '$.product',
                                                 price   NUMBER       PATH '$.price')) jt
 WHERE jt.product = 'USB-C Hub'
 GROUP BY jt.price
 ORDER BY jt.price;

DROP TABLE order_docs PURGE;
