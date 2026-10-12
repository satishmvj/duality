-- Run as ADMIN, once. One schema owns the tables and the duality views over them.
DROP USER dvdemo CASCADE;

CREATE USER dvdemo IDENTIFIED BY "Dv7#Duality2026Zz" QUOTA UNLIMITED ON DATA;
GRANT CONNECT, RESOURCE TO dvdemo;
-- RESOURCE does not include CREATE VIEW, and a duality view is a view.
GRANT CREATE VIEW TO dvdemo;
GRANT SELECT ANY DICTIONARY TO dvdemo;
