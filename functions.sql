/* -----------------------------------
Start file for Exercise 1, page 444
	Exercise description from book
	Write a script that creates and calls a stored procedure named test. This procedure should include a set of three SQL statements coded as a transaction to reflect the following change:

	United Parcel Service has been purchased by Federal Express Corporation and the new company is named FedUP.

	A good first step is to look at the data you will be working with.

	These two statements will show you the vendors and invoices that are in scope for this exercise (you can highlight and run even though they are in a comment):

		select * from vendors where vendor_id in(122,123);
			122	United Parcel Service -- change to FedUP
			123	Federal Express Corporation

		select * from invoices where vendor_id in(122,123);

	a) Rename one of the vendors and
	b) delete the other after updating the vendor_id column in the Invoices table.

	If these statements execute successfully, commit the changes. Otherwise, roll back the changes.

   ------------------------------steve chevalier 2/4/2020 */
USE ap;

DROP PROCEDURE IF EXISTS test;

DELIMITER //

-- this script creates and calls a stored procedure named test
CREATE PROCEDURE test()
BEGIN
  DECLARE sql_error INT DEFAULT FALSE;

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET sql_error = TRUE;

  START TRANSACTION;

  -- write an SQL that UPDATES all invoices for vendor_id 122 to vendor_id number 123
	UPDATE invoices
    SET vendor_id = 123
    WHERE vendor_id = 122;

  -- delete all vendors (there's just one of them)
	DELETE FROM vendors
    WHERE vendor_id = 122;

  -- UPDATE the name of vendor with vendor_id 123, the one that's left)
	UPDATE vendors
		SET vendor_name = 'FedUP' WHERE vendor_id = 123;

  IF sql_error = FALSE THEN
    COMMIT;
    SELECT 'The transaction was committed.' AS message;
  ELSE
    ROLLBACK;
    SELECT 'The transaction was rolled back.' AS message;
  END IF;
END//

DELIMITER ;

CALL test();

/*
mysql> call test();
+--------------------------------+
| message                        |
+--------------------------------+
| The transaction was committed. |
+--------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

*/

USE ap;
DROP FUNCTION IF EXISTS test_glaccounts_description;

DELIMITER //

CREATE FUNCTION test_glaccounts_description
(
	account_description_param VARCHAR(50)
)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN

	DECLARE duplicate_key_var TINYINT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR 1062
		SET duplicate_key_var = 1;

	IF account_description_param IN
		(SELECT account_description FROM general_ledger_accounts) THEN
		SET duplicate_key_var = 1;
	END IF;

    RETURN(duplicate_key_var);
END//

SELECT test_glaccounts_description('accounting') AS is_key_a_duplicate;

/*
mysql> SELECT test_glaccounts_description('accounting') AS is_key_a_duplicate;
+--------------------+
| is_key_a_duplicate |
+--------------------+
|                  1 |
+--------------------+
1 row in set, 1 warning (0.00 sec)

mysql> SELECT test_glaccounts_description('testing') AS is_key_a_duplicate;
+--------------------+
| is_key_a_duplicate |
+--------------------+
|                  0 |
+--------------------+
1 row in set (0.00 sec)

*/

USE ap;
DROP PROCEDURE IF EXISTS insert_glaccount_with_test;

DELIMITER //
CREATE PROCEDURE insert_glaccount_with_test
(
	account_number_param INT,
    account_description_param VARCHAR(50)
)
BEGIN
	DECLARE account_number_var INT;
    DECLARE account_description_var VARCHAR(50);

	IF test_glaccounts_description(account_description_param) = 1 THEN
		SIGNAL SQLSTATE '23000'
			SET MESSAGE_TEXT = 'Duplicate account description.',
            MySQL_ERRNO = 1062;
	ELSEIF account_number_param IS NULL THEN
		SIGNAL SQLSTATE '22003'
			SET MESSAGE_TEXT = 'The account_number can not be null.',
			MySQL_ERRNO = 1048;
    ELSE
		SET account_number_var = account_number_param;
		SET account_description_var = account_description_param;
        INSERT INTO general_ledger_accounts
        VALUES(account_number_var, account_description_var);
	END IF;

END//

call insert_glaccount_with_test(999, 'Cash');

/*
mysql> call insert_glaccount_with_test(null, 'Cash');
ERROR 1062 (23000): Duplicate account description.

mysql> call insert_glaccount_with_test(null, 'Testing');
ERROR 1048 (22003): The account_number can not be null.

mysql> call insert_glaccount_with_test(998, 'Testing');
Query OK, 1 row affected (0.04 sec)

+----------------+---------------------+
| account_number | account_description |
+----------------+---------------------+
|            998 | Testing             |
+----------------+---------------------+
1 row in set (0.00 sec)

*/
USE ap;
DROP PROCEDURE IF EXISTS insert_terms;

DELIMITER //
CREATE PROCEDURE insert_terms
(
	terms_description_param VARCHAR(50),
    terms_due_days_param INT
)
BEGIN
	DECLARE terms_description_var VARCHAR(50);
    DECLARE terms_due_days_var INT;

    -- Validate parameter value
    IF terms_due_days_param < 0 THEN
		SIGNAL SQLSTATE '22003'
			SET MESSAGE_TEXT =
            'The terms_due_days column must be a positive number.',
            MYSQL_ERRNO = 1264;
	ELSEIF terms_due_days_param IS NULL THEN
		SIGNAL SQLSTATE '22003'
			SET MESSAGE_TEXT =
            'The terms_due_days column can not be null.',
            MYSQL_ERRNO = 1048;
	ELSE
		SET terms_due_days_var = terms_due_days_param;
	END IF;

    -- Set default value for parameter
    IF terms_description_param IS NULL THEN
		SET terms_description_var = CONCAT('Net due ', terms_due_days_var, ' days');
	ELSE
		SET terms_description_var = terms_description_param;
    END IF;

	INSERT INTO terms(terms_description, terms_due_days)
    VALUES(terms_description_var, terms_due_days_var);
END//

call insert_terms('Net due 150 days', 150);

/*
mysql> call insert_terms(null, null);
ERROR 1048 (22003): The terms_due_days column can not be null.
mysql> call insert_terms(null, 120);
Query OK, 1 row affected, 1 warning (0.04 sec)

mysql> select * from terms;
+----------+-------------------+----------------+
| terms_id | terms_description | terms_due_days |
+----------+-------------------+----------------+
|        1 | Net due 10 days   |             10 |
|        2 | Net due 20 days   |             20 |
|        3 | Net due 30 days   |             30 |
|        4 | Net due 60 days   |             60 |
|        5 | Net due 90 days   |             90 |
|       10 | Net due 120 days  |            120 |
+----------+-------------------+----------------+
6 rows in set (0.00 sec)
*/
