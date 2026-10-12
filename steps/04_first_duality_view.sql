-- TITLE: Step 4 - the first duality view: one table, one document per row
-- A duality view declares a JSON shape over tables. It stores nothing of its own. The
-- WITH clause says what an application may do to the table through the document.
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW products_dv AS
SELECT JSON {'_id'      : p.product_id,
             'name'     : p.name,
             'category' : p.category,
             'price'    : p.price}
  FROM products p WITH INSERT UPDATE DELETE;

-- The view has exactly one column, DATA, of type JSON: one document per product row.
SELECT column_name, data_type FROM user_tab_columns WHERE table_name = 'PRODUCTS_DV';

-- JSON_SERIALIZE turns the binary JSON into text. The _metadata field is trimmed from
-- this listing to keep it readable; the next query shows a document in full.
SELECT JSON_SERIALIZE(JSON_TRANSFORM(p.data, REMOVE '$._metadata')) AS data
  FROM products_dv p;

-- '_id' is required and maps to the primary key. '_metadata' was not declared: the
-- database adds it. The etag is a hash of the document, and step 12 is what it is for.
SELECT JSON_SERIALIZE(p.data PRETTY) AS one_document
  FROM products_dv p
 WHERE p.data."_id" = 105;
