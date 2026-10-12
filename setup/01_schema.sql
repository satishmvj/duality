-- TITLE: Setup - four normalised tables for a small online shop
-- Plain relational design: every fact is stored once, and every relationship is a
-- foreign key. The duality views later add nothing to this - they are defined over it.
-- The MEDIUM service runs INSERT ... SELECT in parallel, which cannot follow a serial
-- insert in the same transaction (ORA-12839), so the load runs serially.
ALTER SESSION DISABLE PARALLEL DML;

CREATE TABLE customers (
  customer_id  NUMBER        PRIMARY KEY,
  name         VARCHAR2(60)  NOT NULL,
  email        VARCHAR2(80)  NOT NULL UNIQUE,
  city         VARCHAR2(30)  NOT NULL
);

CREATE TABLE products (
  product_id   NUMBER        PRIMARY KEY,
  name         VARCHAR2(60)  NOT NULL,
  category     VARCHAR2(30)  NOT NULL,
  price        NUMBER(8,2)   NOT NULL
);

CREATE TABLE orders (
  order_id     NUMBER        PRIMARY KEY,
  customer_id  NUMBER        NOT NULL REFERENCES customers,
  order_date   DATE          NOT NULL,
  status       VARCHAR2(12)  NOT NULL
);

CREATE TABLE order_items (
  order_id     NUMBER        NOT NULL REFERENCES orders,
  line_no      NUMBER        NOT NULL,
  product_id   NUMBER        NOT NULL REFERENCES products,
  quantity     NUMBER        NOT NULL,
  CONSTRAINT order_items_pk PRIMARY KEY (order_id, line_no)
);

INSERT INTO customers
SELECT level,
       INITCAP(CASE MOD(level, 5) WHEN 0 THEN 'asha' WHEN 1 THEN 'ravi' WHEN 2 THEN 'meera'
                                  WHEN 3 THEN 'arjun' ELSE 'kavya' END)
         || ' ' || INITCAP(CASE MOD(level, 4) WHEN 0 THEN 'rao' WHEN 1 THEN 'shah'
                                              WHEN 2 THEN 'iyer' ELSE 'nair' END),
       'customer' || level || '@example.com',
       CASE MOD(level, 4) WHEN 0 THEN 'Mumbai' WHEN 1 THEN 'Pune'
                          WHEN 2 THEN 'Bengaluru' ELSE 'Chennai' END
  FROM dual CONNECT BY level <= 20;

INSERT INTO products VALUES (101, 'Laptop Stand',       'Accessories',  1899);
INSERT INTO products VALUES (102, 'USB-C Hub',          'Accessories',  2499);
INSERT INTO products VALUES (103, 'Mechanical Keyboard','Peripherals',  6499);
INSERT INTO products VALUES (104, 'Wireless Mouse',     'Peripherals',  1299);
INSERT INTO products VALUES (105, '27in Monitor',       'Displays',    18999);
INSERT INTO products VALUES (106, 'Webcam HD',          'Peripherals',  3499);
INSERT INTO products VALUES (107, 'Noise-Cancel Headset','Audio',       7999);
INSERT INTO products VALUES (108, 'Desk Lamp',          'Accessories',  1499);

INSERT INTO orders
SELECT 1000 + level,
       MOD(level * 7, 20) + 1,
       DATE '2026-09-01' + MOD(level, 14),
       CASE MOD(level, 3) WHEN 0 THEN 'SHIPPED' WHEN 1 THEN 'PLACED' ELSE 'DELIVERED' END
  FROM dual CONNECT BY level <= 40;

INSERT INTO order_items
SELECT o.order_id, n.line_no,
       101 + MOD(o.order_id * n.line_no, 8),
       MOD(o.order_id + n.line_no, 3) + 1
  FROM orders o
  JOIN (SELECT level AS line_no FROM dual CONNECT BY level <= 3) n
    ON n.line_no <= MOD(o.order_id, 3) + 1;

COMMIT;

BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS(USER);
END;
/

SELECT (SELECT COUNT(*) FROM customers)   AS customers,
       (SELECT COUNT(*) FROM products)    AS products,
       (SELECT COUNT(*) FROM orders)      AS orders,
       (SELECT COUNT(*) FROM order_items) AS order_items
  FROM dual;
