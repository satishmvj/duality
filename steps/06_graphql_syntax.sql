-- TITLE: Step 6 - the same idea in GraphQL syntax: a customer with their orders
-- The GraphQL form is shorter: joins are inferred from the foreign keys, and a field
-- with the same name as its column needs no mapping. @insert, @update and @delete
-- do the job of the WITH clause.
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW customers_dv AS
customers @insert @update @delete
{
  _id    : customer_id,
  name,
  email,
  city,
  orders : orders @noinsert @noupdate @nodelete
  {
    orderId   : order_id,
    orderDate : order_date,
    status
  }
};

SELECT JSON_SERIALIZE(c.data PRETTY) AS customer_1
  FROM customers_dv c
 WHERE c.data."_id" = 1;

-- Three views, three shapes, one copy of the data underneath.
SELECT view_name, root_table_name, allow_insert, allow_update, allow_delete, status
  FROM user_json_duality_views
 ORDER BY view_name;
