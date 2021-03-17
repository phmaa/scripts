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
