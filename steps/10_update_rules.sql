-- TITLE: Step 10 - the rules the view enforces, and the errors that say so
-- 1. PRODUCTS is NOUPDATE in ORDERS_DV, so an order cannot reprice a product.
UPDATE orders_dv o
   SET o.data = JSON_TRANSFORM(o.data, SET '$.items[0].product.price' = 1)
 WHERE o.data."_id" = 2001;

-- 2. '_id' is the primary key of the root table and cannot be changed.
UPDATE orders_dv o
   SET o.data = JSON_TRANSFORM(o.data, SET '$._id' = 9999)
 WHERE o.data."_id" = 2001;

-- 3. The document shape is fixed by the view. A field it does not declare is rejected
--    rather than silently dropped (step 15 shows how to allow extra fields).
UPDATE orders_dv o
   SET o.data = JSON_TRANSFORM(o.data, SET '$.giftWrap' = 'yes')
 WHERE o.data."_id" = 2001;

-- 4. The same rules as data: what each table allows through ORDERS_DV...
SELECT table_name, relationship, allow_insert, allow_update, allow_delete, read_only
  FROM user_json_duality_view_tabs
 WHERE view_name = 'ORDERS_DV'
 ORDER BY table_number;

-- ...and down to each field. ALLOW_UPDATE is false for keys and for the NOUPDATE tables.
SELECT table_name, column_name, json_key_name, allow_update, primary_key_pos
  FROM user_json_duality_view_tab_cols
 WHERE view_name = 'ORDERS_DV'
 ORDER BY table_number, column_name;
