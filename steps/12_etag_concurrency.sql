-- TITLE: Step 12 - lost updates: what the etag is for
-- A web application reads a document, the user edits it for a minute, and it is written
-- back. Meanwhile somebody else changed the same order. Without a check, the second
-- write would quietly overwrite the first.

-- The application's copy, as read at the start (kept in a table to stand in for it).
CREATE TABLE app_copy AS
SELECT o.data FROM orders_dv o WHERE o.data."_id" = 1005;

SELECT a.data.status.string() AS status_read, a.data."_metadata".etag.string() AS etag_read
  FROM app_copy a;

-- Meanwhile, the warehouse ships the order through plain SQL.
UPDATE orders SET status = 'SHIPPED' WHERE order_id = 1005;
COMMIT;

-- The etag of the live document has changed, because the data behind it has.
SELECT o.data.status.string() AS status_now, o.data."_metadata".etag.string() AS etag_now
  FROM orders_dv o
 WHERE o.data."_id" = 1005;

-- The application now tries to cancel the order, sending back its stale document.
-- The etag it carries no longer matches, so the write is refused.
UPDATE orders_dv o
   SET o.data = (SELECT JSON_TRANSFORM(a.data, SET '$.status' = 'CANCELLED') FROM app_copy a)
 WHERE o.data."_id" = 1005;

-- The fix is the one any optimistic-locking application uses: read again, then write.
UPDATE orders_dv o
   SET o.data = JSON_TRANSFORM(o.data, SET '$.status' = 'CANCELLED')
 WHERE o.data."_id" = 1005;

SELECT order_id, status FROM orders WHERE order_id = 1005;

COMMIT;
DROP TABLE app_copy PURGE;
