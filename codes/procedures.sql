USE ap;
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
	DECLARE count INT DEFAULT 0;

	SELECT COUNT(*) INTO count
	FROM invoices
	WHERE invoice_total - payment_total - credit_total >= 5000;

	SELECT CONCAT(count, ' invoices exceed $5,000.') AS message;
	END //;

DELIMITER ;

CALL test();

/*
#+---------------------------+
#| message                   |
#+---------------------------+
#| 2 invoices exceed $5,000. |
#+---------------------------+
#1 row in set (0.00 sec)

#Query OK, 0 rows affected (0.01 sec)
*/

USE ap;
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
	DECLARE count INT DEFAULT 0;
	DECLARE sum DECIMAL(9,2);
    DECLARE invoice_total_var DECIMAL(9,2);

	SELECT COUNT(*), SUM(invoice_total - payment_total - credit_total) as invoice_total_var
	INTO count, sum
	FROM invoices
	WHERE invoice_total - payment_total - credit_total >= 0;

	IF sum >= 30000 THEN
		SELECT CONCAT(count, ' invoices with a balance due. Total balance due is $', sum) AS message;
	ELSE
		SELECT 'Total balance due is less than $30,000.' AS message;
	END IF;
END //;

DELIMITER ;

CALL test();

/*
mysql> call test();
+-----------------------------------------------------------------+
| message                                                         |
+-----------------------------------------------------------------+
| 114 invoices with a balance due. Total balance due is $32020.42 |
+-----------------------------------------------------------------+
1 row in set (0.03 sec)

Query OK, 0 rows affected (0.04 sec)
*/

USE ap;
DROP PROCEDURE IF EXISTS test;
DELIMITER //
CREATE PROCEDURE test()
BEGIN
	DECLARE i INT DEFAULT 1;
	DECLARE factorial INT DEFAULT 1;

	WHILE i <= 10 DO
		SET factorial = factorial * i;
		SET i = i+1;
	END WHILE;

	SELECT CONCAT('The factorial of 10 is: ', format(factorial, 0)) AS message;
END //


delimiter ;
CALL test();

/*
#mysql> call test();
#+-----------------------------------+
#| message                           |
#+-----------------------------------+
#| The factorial of 10 is: 3,628,800 |
#+-----------------------------------+
#1 row in set (0.00 sec)

#Query OK, 0 rows affected (0.00 sec)
*/

USE ap;
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
	DECLARE vendor_name_var varchar(50);
	declare finished int default 0;
	DECLARE invoice_id_var INT;
	DECLARE invoice_number_var varchar(50);
	DECLARE invoice_total_var DECIMAL(9,2);
	DECLARE row_not_found TINYINT DEFAULT FALSE;
	DECLARE messages varchar(100) default '';
	DECLARE invoices_cursor CURSOR FOR
	SELECT vendor_name, invoice_number, invoice_total FROM vendors v join invoices i
	WHERE v.vendor_id = i.vendor_id AND
	invoice_total - credit_total - payment_total >= 5000
	order by invoice_total - credit_total - payment_total desc;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET finished = 1;

	OPEN invoices_cursor;

	getInvoice: LOOP
	FETCH invoices_cursor INTO vendor_name_var, invoice_number_var, invoice_total_var;
		If finished = 1 THEN
			LEAVE getInvoice;
		END IF;
		SET messages = CONCAT(invoice_total_var, '|', invoice_number_var, '|',
		vendor_name_var,'//', messages);
	END LOOP getInvoice;
	CLOSE invoices_cursor;

	SELECT messages AS message;

END //;

DELIMITER ;

CALL test();

/*
#mysql> call test();
#+--------------------------------------------------------------------------------------+
#| message                                                                              |
#+--------------------------------------------------------------------------------------+
#| 10976.06|0-2436|Malloy Lithographing Inc//20551.18|P-0608|Malloy Lithographing Inc// |
#+--------------------------------------------------------------------------------------+
#1 row in set (0.00 sec)

#Query OK, 0 rows affected (0.01 sec)

*/

USE ap;
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN

	DECLARE invoice_id_var INT;
	DECLARE column_cannot_be_null TINYINT DEFAULT FALSE;

	BEGIN
		DECLARE EXIT HANDLER FOR 1048
		SET column_cannot_be_null = TRUE;

		SET invoice_id_var = 1;

		UPDATE invoices
		SET invoice_due_date = NULL
		WHERE invoice_id = invoice_id_var;

		SELECT '1 row was updated' AS message;
	END;

	IF column_cannot_be_null = TRUE THEN
	SELECT 'Row was not updated - column cannot be null.' AS message;
	END IF;
END //;

DELIMITER ;


CALL test();
/*
#mysql> call test();
#+----------------------------------------------+
#| message                                      |
#+----------------------------------------------+
#| Row was not updated - column cannot be null. |
#+----------------------------------------------+
#1 row in set (0.00 sec)

#Query OK, 0 rows affected (0.01 sec)
*/

USE ap;
drop procedure if exists test;

DELIMITER //
create procedure test()
begin
	declare i int default 2;
	declare s varchar(400) default '';
	declare factor int;
	declare max int default 100;
	declare is_prime tinyint default true;

	while i < 100 do
		set is_prime = true;
		set factor = 2;
		while factor < i do
			if i % factor = 0 then
				set is_prime = false;
			end if;
			set factor = factor + 1;
		end while;
		if is_prime = true then
		set s = concat(s, ' ', i);
		end if;
		set i = i + 1;

	end while;
	select s as message;
end //;

DELIMITER ;
call test();

/*
#mysql> call test();
#+-------------------------------------------------------------------------+
#| message                                                                 |
#+-------------------------------------------------------------------------+
#|  2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 |
#+-------------------------------------------------------------------------+
#1 row in set (0.05 sec)

#Query OK, 0 rows affected (0.06 sec)
*/

USE ap;
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
	DECLARE vendor_name_var varchar(50);
	DECLARE invoice_id_var INT;
	DECLARE invoice_number_var varchar(50);
	DECLARE invoice_total_var DECIMAL(9,2);
	DECLARE row_not_found TINYINT DEFAULT FALSE;
	DECLARE messages varchar(200) default '';
	DECLARE invoices_cursor CURSOR FOR
	SELECT vendor_name, invoice_number, invoice_total FROM vendors v join invoices i
	WHERE v.vendor_id = i.vendor_id AND
	invoice_total - credit_total - payment_total >= 5000
	order by invoice_total - credit_total - payment_total desc;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET row_not_found = TRUE;

	OPEN invoices_cursor;
	getInvoice: LOOP
	FETCH invoices_cursor INTO vendor_name_var, invoice_number_var, invoice_total_var;
		IF row_not_found = TRUE THEN
			LEAVE getInvoice;
		END IF;
		IF invoice_total_var >= 20000 THEN
			SET messages = CONCAT(messages, '$20,000 or More: ', invoice_total_var, '|', invoice_number_var, '|',
				vendor_name_var,'//');
		END IF;
	END LOOP getInvoice;
	CLOSE invoices_cursor;

	SET row_not_found = FALSE;
	OPEN invoices_cursor;
	getInvoice: LOOP
		FETCH invoices_cursor INTO vendor_name_var, invoice_number_var, invoice_total_var;
			IF row_not_found = TRUE THEN
				LEAVE getInvoice;
			END IF;
			IF invoice_total_var >= 10000 AND invoice_total_var < 20000 THEN
				SET messages = CONCAT(messages, '$10,000 to $20,000: ', invoice_total_var, '|', invoice_number_var, '|',
					vendor_name_var,'//');
			END IF;
	END LOOP getInvoice;
	CLOSE invoices_cursor;

	SET row_not_found = FALSE;
	OPEN invoices_cursor;
	getInvoice: LOOP
	FETCH invoices_cursor INTO vendor_name_var, invoice_number_var, invoice_total_var;
		IF row_not_found = TRUE THEN
			LEAVE getInvoice;
		END IF;
		IF invoice_total_var >= 5000 AND invoice_total_var < 10000 THEN
			SET messages = CONCAT(messages, '$5,000 to $10,000: ', invoice_total_var, '|', invoice_number_var, '|',
				vendor_name_var,'//');
		END IF;
	END LOOP getInvoice;
	CLOSE invoices_cursor;

	SELECT messages AS message;

END //;

DELIMITER ;

CALL test();

/*
#mysql> call test();
#| message                                                                                                                   |
#+---------------------------------------------------------------------------------------------------------------------------+
#| $20,000 or More: 20551.18|P-0608|Malloy Lithographing Inc//$10,000 to $20,000: 10976.06|0-2436|Malloy Lithographing Inc// |
#+---------------------------------------------------------------------------------------------------------------------------+
#1 row in set (0.00 sec)

#Query OK, 0 rows affected (0.03 sec)
*/
