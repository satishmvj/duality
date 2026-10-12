-- TITLE: Step 15 - changing the shape: new columns, and a flex column for the unplanned
-- A new relational column does not appear in any document by itself. The view is a
-- declared shape, and existing applications keep receiving exactly what they expect.
ALTER TABLE products ADD (stock NUMBER DEFAULT 50 NOT NULL);

SELECT JSON_SERIALIZE(JSON_TRANSFORM(p.data, REMOVE '$._metadata')) AS still_four_fields
  FROM products_dv p WHERE p.data."_id" = 101;

-- But the DDL did touch the views. ORDERS_DV, which reads PRODUCTS for its line items,
-- is now INVALID. PRODUCTS_DV is VALID again only because the query above just used it.
SELECT view_name, status FROM user_json_duality_views ORDER BY view_name;

-- Applications often want to attach fields nobody planned for. As step 10 showed, an
-- undeclared field is rejected. A flex column - a JSON object column - catches them.
ALTER TABLE products ADD (extras JSON (OBJECT));

-- Redefine the view: expose the new column, and declare EXTRAS as the flex column.
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW products_dv AS
SELECT JSON {'_id'      : p.product_id,
             'name'     : p.name,
             'category' : p.category,
             'price'    : p.price,
             'stock'    : p.stock,
             p.extras AS FLEX}
  FROM products p WITH INSERT UPDATE DELETE;

-- Now two fields nobody declared go in without complaint...
UPDATE products_dv p
   SET p.data = JSON_TRANSFORM(p.data, SET '$.colour' = 'Black', SET '$.warrantyYears' = 2)
 WHERE p.data."_id" = 105;

-- ...land in the flex column, and come back as ordinary top-level fields.
SELECT product_id, stock, extras FROM products WHERE product_id = 105;

SELECT JSON_SERIALIZE(p.data PRETTY) AS monitor
  FROM products_dv p WHERE p.data."_id" = 105;

-- A declared field still goes to its own column, which SQL can index and constrain.
SELECT table_name, column_name, json_key_name, is_flex_col
  FROM user_json_duality_view_tab_cols
 WHERE view_name = 'PRODUCTS_DV'
 ORDER BY column_name;

COMMIT;
