USE ap;
DROP TRIGGER IF EXISTS invoices_before_update;

DELIMITER //

CREATE TRIGGER invoices_before_update
	BEFORE UPDATE ON invoices
    FOR EACH ROW
BEGIN
	DECLARE balance_total decimal(9,2);
    SELECT NEW.credit_total + NEW.payment_total
    INTO balance_total
    FROM invoices
    WHERE invoice_id = NEW.invoice_id;

    IF NEW.invoice_total < balance_total  THEN
		SIGNAL SQLSTATE 'HY000'
			SET MESSAGE_TEXT =
            'The invoice_total must be greater than payment_total plus credit_total.';
	END IF;

END//

UPDATE invoices
SET payment_total = 80, credit_total = 20
WHERE invoice_id = 110;

/*
mysql> UPDATE invoices
    -> SET payment_total = 80,
    -> credit_total = 20
    -> WHERE invoice_id = 110;
ERROR 1644 (HY000): The invoice_total must be greater than payment_total plus credit_total.
*/

USE ap;
DROP TRIGGER IF EXISTS invoices_after_update;

DELIMITER //
CREATE TRIGGER invoices_after_update
	AFTER UPDATE ON invoices
    FOR EACH ROW
BEGIN
	INSERT INTO invoices_audit
    VALUES(OLD.vendor_id, OLD.invoice_number, OLD.invoice_total, 'UPDATED', NOW());
END//

UPDATE invoices
SET credit_total = 10
WHERE invoice_id = 110;

SELECT * FROM invoices_audit;

/*

mysql> SELECT * FROM invoices_audit;
+-----------+----------------+---------------+-------------+---------------------+
| vendor_id | invoice_number | invoice_total | action_type | action_date         |
+-----------+----------------+---------------+-------------+---------------------+
|        34 | ZXA-080        |      14092.59 | INSERTED    | 2020-09-12 10:58:15 |
|        34 | ZXA-080        |      14092.59 | DELETED     | 2020-09-12 10:58:15 |
|        80 | 134116         |         90.36 | UPDATED     | 2020-09-12 11:06:50 |
+-----------+----------------+---------------+-------------+---------------------+
3 rows in set (0.00 sec)

*/

USE ap;
DROP EVENT IF EXISTS minute_insert_audit_rows;

DELIMITER //

CREATE EVENT minute_insert_audit_rows
ON SCHEDULE EVERY 1 minute
STARTS '2020-09-12'
DO BEGIN
	INSERT INTO invoices
    VALUES(116, 110, 'ABC-001', '2020-01-01', 999.99, 0, 0, 3, '2020-09-12', NULL);
END//

SHOW EVENTS;

SELECT * FROM invoices_audit;

DROP EVENT minute_insert_audit_rows;
/*
mysql> SHOW EVENTS;
+------+----------------------------+----------------+-----------+-----------+---------------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+--------------------+
| Db   | Name                       | Definer        | Time zone | Type      | Execute at          | Interval value | Interval field | Starts              | Ends | Status  | Originator | character_set_client | collation_connection | Database Collation |
+------+----------------------------+----------------+-----------+-----------+---------------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+--------------------+
| ap   | minute_insert_audit_rows   | root@localhost | SYSTEM    | RECURRING | NULL                | 1              | MINUTE         | 2020-09-12 00:00:00 | NULL | ENABLED |          1 | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_0900_ai_ci |
| ap   | monthly_delete_audit_rows  | root@localhost | SYSTEM    | RECURRING | NULL                | 1              | MONTH          | 2020-09-11 00:00:00 | NULL | ENABLED |          1 | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_0900_ai_ci |
| ap   | one_time_delete_audit_rows | root@localhost | SYSTEM    | ONE TIME  | 2020-10-12 10:56:05 | NULL           | NULL           | NULL                | NULL | ENABLED |          1 | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_0900_ai_ci |
+------+----------------------------+----------------+-----------+-----------+---------------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+--------------------+
3 rows in set (0.04 sec)

mysql> SELECT * FROM invoices_audit;
+-----------+----------------+---------------+-------------+---------------------+
| vendor_id | invoice_number | invoice_total | action_type | action_date         |
+-----------+----------------+---------------+-------------+---------------------+
|        34 | ZXA-080        |      14092.59 | INSERTED    | 2020-09-12 10:58:15 |
|        34 | ZXA-080        |      14092.59 | DELETED     | 2020-09-12 10:58:15 |
|        80 | 134116         |         90.36 | UPDATED     | 2020-09-12 11:06:50 |
|       110 | ABC-001        |        999.99 | INSERTED    | 2020-09-12 11:18:00 |
+-----------+----------------+---------------+-------------+---------------------+
4 rows in set (0.00 sec)
