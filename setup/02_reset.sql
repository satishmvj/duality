-- Duality views first, then the tables they sit on.
BEGIN
  FOR v IN (SELECT view_name FROM user_views) LOOP
    EXECUTE IMMEDIATE 'DROP VIEW "' || v.view_name || '"';
  END LOOP;
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

SELECT (SELECT COUNT(*) FROM user_tables) AS tables_left,
       (SELECT COUNT(*) FROM user_views)  AS views_left
  FROM dual;
