-- TITLE: Step 14 - the document contract: JSON Schema generated from the view
-- Every duality view publishes a JSON Schema describing its documents: the types come
-- from the columns, 'required' from NOT NULL, and dbFieldProperties from the annotations.
-- An application team can validate against it without reading any SQL.
SELECT JSON_SERIALIZE(DBMS_JSON_SCHEMA.DESCRIBE('PRODUCTS_DV') PRETTY) AS products_dv_schema
  FROM dual;

-- The joins the view was built on, as the database recorded them.
SELECT view_name, parent_table_name, child_table_name, from_column, to_column, join_type
  FROM user_json_duality_view_links
 ORDER BY view_name, parent_table_name, child_table_name;
