-- TITLE: Step 11 - one change, every document: the problem from step 3, solved
-- Step 3 had to find every copy of the USB-C Hub price. Here there is one: a single
-- document in PRODUCTS_DV, which is a single row in PRODUCTS.
SELECT COUNT(*) AS orders_containing_the_hub
  FROM orders_dv o
 WHERE JSON_EXISTS(o.data, '$.items[*].product?(@.productId == 102)');

UPDATE products_dv p
   SET p.data = JSON_TRANSFORM(p.data, SET '$.price' = 2299)
 WHERE p.data."_id" = 102;

-- Every order document that contains the hub now shows the new price. No copy was
-- updated because no copy exists.
SELECT JSON_VALUE(o.data, '$.items[*]?(@.product.productId == 102).product.price') AS hub_price,
       COUNT(*) AS order_documents
  FROM orders_dv o
 WHERE JSON_EXISTS(o.data, '$.items[*].product?(@.productId == 102)')
 GROUP BY JSON_VALUE(o.data, '$.items[*]?(@.product.productId == 102).product.price');

-- The same goes across views with different shapes. A customer renamed through
-- CUSTOMERS_DV is renamed inside every order document that mentions them.
UPDATE customers_dv c
   SET c.data = JSON_TRANSFORM(c.data, SET '$.name' = 'Arjun N. Nair')
 WHERE c.data."_id" = 3;

SELECT o.data."_id" AS order_id, o.data.customer.name.string() AS customer_in_order
  FROM orders_dv o
 WHERE o.data.customer.customerId.number() = 3
 ORDER BY 1;

COMMIT;
