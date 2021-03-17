--1.	From the rate table, list the average rental rate for each type of property.
--(Notice this is not what is was rented for, but what could be charged throughout the year).
MariaDB [SFRC]> CREATE OR REPLACE VIEW view1_average_rate AS
    -> SELECT condo_type,
    -> ROUND(AVG(rate_january + rate_april + rate_june + rate_september + rate_november)/5, 2) AS average_rental_rate
    -> FROM rates GROUP BY condo_type;
Query OK, 0 rows affected (0.01 sec)

MariaDB [SFRC]> select * from view1_average_rate;

+------------+---------------------+
| condo_type | average_rental_rate |
+------------+---------------------+
| SandsOF2BR |              470.00 |
| SandsOF3BR |              520.00 |
| SandsOV2BR |              435.00 |
| SandsOV3BR |              485.00 |
| Tides2BR   |              380.00 |
| Tides3BR   |              410.00 |
+------------+---------------------+
6 rows in set (0.00 sec)


-- 2.	SFRC would like to contact owners of “non-rented” properties to discuss offering promotions to encourage rentals.
-- List the properties (along with owner name and contact info) which have never been rented.
MariaDB [SFRC]> CREATE OR REPLACE VIEW view2_never_rented AS
    -> SELECT o.property_id, CONCAT_WS(' ', first_name, last_name) AS 'Owner', phone
    -> FROM owners o LEFT JOIN transactions t
    -> ON o.property_id = t.property_id
    -> WHERE t.property_id is null;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view2_never_rented;

+-------------+---------------+--------------+
| property_id | Owner         | phone        |
+-------------+---------------+--------------+
| 301S        | Sandy Claus   | 404-678-0909 |
| 1010S       | Barney Rubble | 720-555-1456 |
| 517T        | Luke Taylors  | 828-445-9776 |
+-------------+---------------+--------------+
3 rows in set (0.00 sec)

-- 3.	If SFRC wanted to recognize the “most frequent renter(s),” who would be recognized?
MariaDB [SFRC]> CREATE OR REPLACE VIEW view3_frequent_renters AS
    -> SELECT COUNT(*), CONCAT_WS(' ', client_fname, client_lname) as client_name
    -> FROM clients NATURAL JOIN transactions
    -> GROUP BY client_id
    -> HAVING COUNT(*) > 2
    -> ORDER BY COUNT(*) desc;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view3_frequent_renters;

+----------+-----------------+
| COUNT(*) | client_name     |
+----------+-----------------+
|        6 | Fran McCoy      |
|        3 | Ted Stiggle     |
|        3 | Joan Thomas     |
|        3 | David Stocking  |
|        3 | Harriet O'Casey |
|        3 | Linda Paloma    |
+----------+-----------------+
6 rows in set (0.00 sec)

'
-- 4.	SFRC wants to send a Summer Coupon to all 2019 renters.
-- Please provide a list of names and address of people who rented in 2019.
MariaDB [SFRC]> CREATE OR REPLACE VIEW view4_summer_coupon AS
    -> SELECT CONCAT_WS(' ', client_fname, client_lname) AS client_name,
    -> CONCAT(client_address, ' ', client_city, ', ', client_state, ' ', client_zip) as client_address
    -> FROM clients NATURAL JOIN transactions
    -> WHERE arrival_date >= '2019-01-01' AND depart_date <= '2019-12-31';
Query OK, 0 rows affected (0.01 sec)

MariaDB [SFRC]> SELECT * FROM view4_summer_coupon;

+-----------------+-------------------------------------------------+
| client_name     | client_address                                  |
+-----------------+-------------------------------------------------+
| Carrie Zygote   | 8607 Ferndale St. Montgomery, AL 60631          |
| Joan Thomas     | 667438 E. 91st St. Baseboard, PA 56987          |
| Ted Stiggle     | 12920 Industrial Workers Scraggy View, CO 82191 |
| Brittany Foxe   | 297-B Gorgonzola Cleo, KS 81029                 |
| Carrie Zygote   | 8607 Ferndale St. Montgomery, AL 60631          |
| Fran McCoy      | 1440 Manchester Way Mountain View, CO 87757     |
| David Stocking  | 291-A Gorgonzola Cleo, KS 81029                 |
| Gregory Hansen  | 6065 Rainbow Falls Rd. Roselle, PA 57203        |
| Fran McCoy      | 1440 Manchester Way Mountain View, CO 87757     |
| Fran McCoy      | 1440 Manchester Way Mountain View, CO 87757     |'
| Harriet O'Casey | 4088 Ottumwa Way Mentira, IL 61788              |
| Linda Paloma    | 1928 Highway 12 Portugal, NC 82394              |
| Joan Thomas     | 667438 E. 91st St. Baseboard, PA 56987          |
| Fran McCoy      | 1440 Manchester Way Mountain View, CO 87757     |
| David Stocking  | 291-A Gorgonzola Cleo, KS 81029                 |
| Brittany Foxe   | 297-B Gorgonzola Cleo, KS 81029                 |
| Linda Paloma    | 1928 Highway 12 Portugal, NC 82394              |
| Ted Stiggle     | 12920 Industrial Workers Scraggy View, CO 82191 |
| John Grainger   | 2256 N Santa Fe Dr. Iliase, MD 23456            |
| Steve Snider    | 39430 Big Rock Rd. Flame Throw, TN 59012        |
| Fran McCoy      | 1440 Manchester Way Mountain View, CO 87757     |'
| Harriet O'Casey | 4088 Ottumwa Way Mentira, IL 61788              |
| Linda Paloma    | 1928 Highway 12 Portugal, NC 82394              |
+-----------------+-------------------------------------------------+
23 rows in set (0.00 sec)



-- 5.	SFRC is thinking of increasing rates for oceanview condos only, please provide a list
-- of the current rate along with a 6% increase in rates … do not update the rates. SFRC just
-- wants to show “new” rates to “old” ones.
MariaDB [SFRC]> CREATE OR REPLACE VIEW view5_new_rates AS
    -> SELECT condo_type, rate_january as '1/01-3/31', ROUND(rate_january * 1.06, 2) as 'new 1/01-3/31',
    -> rate_april as '4/01-5/31', ROUND(rate_april * 1.06, 2) as 'new 4/01-5/31',
    -> rate_june as '6/01-8/31', ROUND(rate_june * 1.06, 2) as ' new 6/01-8/31',
    -> rate_september as '9/01-10/31', ROUND(rate_september * 1.06, 2) as 'new 9/01-10/31',
    -> rate_november as '11/01-12/31', ROUND(rate_november * 1.06, 2) as 'new 11/01-12/31'
    -> FROM rates WHERE condo_type = 'SandsOV2BR' OR condo_type = 'SandsOV3BR';
Query OK, 0 rows affected, 1 warning (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view5_new_rates;

+------------+-----------+---------------+-----------+---------------+-----------+---------------+------------+----------------+-------------+-----------------+
| condo_type | 1/01-3/31 | new 1/01-3/31 | 4/01-5/31 | new 4/01-5/31 | 6/01-8/31 | new 6/01-8/31 | 9/01-10/31 | new 9/01-10/31 | 11/01-12/31 | new 11/01-12/31 |
+------------+-----------+---------------+-----------+---------------+-----------+---------------+------------+----------------+-------------+-----------------+
| SandsOV2BR |    375.00 |        397.50 |    425.00 |        450.50 |    575.00 |        609.50 |     425.00 |         450.50 |      375.00 |          397.50 |
| SandsOV3BR |    425.00 |        450.50 |    475.00 |        503.50 |    625.00 |        662.50 |     475.00 |         503.50 |      425.00 |          450.50 |
+------------+-----------+---------------+-----------+---------------+-----------+---------------+------------+----------------+-------------+-----------------+
2 rows in set, 1 warning (0.00 sec)

-- 6.	Provide a list with the following information for each property and include a total line for each year as well as a total for all properties.
-- a.	Property ID
-- b.	Total Rent (total rent collected for a particular property)
-- c.	Cleaning (total cleaning fees collected for a particular property)
-- d.	Pets (total pet deposits collected for a particular property)1/
-- e.	Property Total Collected (total rent + cleaning fees + pet deposits)
-- f.	SFRC Fees (amount of the Property Total Collected which goes to SFRC)
-- g.	Owner Amount  (amount of the Property Total Collected which goes to the owner)
MariaDB [SFRC]>  CREATE OR REPLACE VIEW view6_total_rent AS
    -> SELECT property_id AS 'Property ID', sum(rental_fee) AS 'Total Rent',
    -> sum(pet_deposit) AS 'Pets', sum(cleaning_fee) AS 'Cleaning Fee',
    -> sum(rental_fee) + sum(pet_deposit) + sum(cleaning_fee) AS 'Property Total Collected',
    -> ROUND(sum(rental_fee) * .25, 2) AS 'SFRC Fees',
    -> sum(rental_fee) - ROUND(sum(rental_fee) * .25, 2) AS 'Owner Amount'
    -> FROM transactions NATURAL JOIN properties
    -> GROUP BY property_id WITH ROLLUP;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view6_total_rent;

+-------------+------------+---------+--------------+--------------------------+-----------+--------------+
| Property ID | Total Rent | Pets    | Cleaning Fee | Property Total Collected | SFRC Fees | Owner Amount |
+-------------+------------+---------+--------------+--------------------------+-----------+--------------+
| 1005T       |    3175.00 |  450.00 |       420.00 |                  4045.00 |    793.75 |      2381.25 |
| 1100T       |     775.00 |    0.00 |       120.00 |                   895.00 |    193.75 |       581.25 |
| 110T        |     700.00 |    0.00 |       100.00 |                   800.00 |    175.00 |       525.00 |
| 1201T       |    1300.00 |    0.00 |       180.00 |                  1480.00 |    325.00 |       975.00 |
| 207S        |     375.00 |  150.00 |        60.00 |                   585.00 |     93.75 |       281.25 |
| 317S        |    2950.00 |    0.00 |       150.00 |                  3100.00 |    737.50 |      2212.50 |
| 409S        |    2150.00 |  300.00 |       100.00 |                  2550.00 |    537.50 |      1612.50 |
| 505T        |    1050.00 |  150.00 |        50.00 |                  1250.00 |    262.50 |       787.50 |
| 656S        |     425.00 |  150.00 |        50.00 |                   625.00 |    106.25 |       318.75 |
| 942S        |    5250.00 |    0.00 |       360.00 |                  5610.00 |   1312.50 |      3937.50 |
| NULL        |   18150.00 | 1200.00 |      1590.00 |                 20940.00 |   4537.50 |     13612.50 |
+-------------+------------+---------+--------------+--------------------------+-----------+--------------+
11 rows in set (0.00 sec)

-- 7.	How much money has SFRC received per each method of payment?  Include a total line.
-- Hint:  Total collected here should be the same as what you get for 7e.
MariaDB [SFRC]> CREATE OR REPLACE VIEW view7_payment_methods AS
    -> SELECT payment_method as 'Payment Method',
    -> SUM(rental_fee) + SUM(pet_deposit) + SUM(cleaning_fee) AS 'Property Total Collected'
    -> FROM transactions Natural JOIN properties
    -> GROUP BY payment_method WITH ROLLUP;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view7_payment_methods;

+----------------+--------------------------+
| Payment Method | Property Total Collected |
+----------------+--------------------------+
| AMEX           |                  4360.00 |
| Cash           |                  1020.00 |
| Check          |                  4400.00 |
| MasterCard     |                  3995.00 |
| PayPal         |                  5060.00 |
| Visa           |                  2105.00 |
| NULL           |                 20940.00 |
+----------------+--------------------------+
7 rows in set (0.00 sec)


-- 8.	Make up another question which involves at least two tables (criteria required).
-- Be sure to include the questions as a comment in your sql file.
-- Question: Find out the how frequent a property was rented out in 2019 and its owner’s name.

MariaDB [SFRC]> CREATE OR REPLACE VIEW view8_frequent_rental AS
    -> SELECT COUNT(property_id) as 'Frequency', t.property_id,
    -> CONCAT_WS(' ', first_name, last_name) AS 'Owner'
    -> FROM transactions t NATURAL JOIN owners o
    -> WHERE arrival_date >= '2019-01-01' AND depart_date <= '2019-12-31'
    -> GROUP BY property_id ORDER BY COUNT(*) desc;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view8_frequent_rental;

+-----------+-------------+-------------------+
| Frequency | property_id | Owner             |
+-----------+-------------+-------------------+
|         5 | 1005T       | Gwen Grizzlie     |
|         5 | 942S        | Robert Smith      |
|         3 | 317S        | Jack Bauer        |
|         3 | 1201T       | Charles Brown     |
|         2 | 1100T       | Lucille Livingood |
|         1 | 656S        | Olivia Pope       |
|         1 | 409S        | Fred Flintstone   |
|         1 | 207S        | Richard Compote   |
|         1 | 110T        | Barbie Beckwith   |
|         1 | 505T        | Larry Lizard      |
+-----------+-------------+-------------------+
10 rows in set (0.00 sec)



-- 9.	Make up another question which involves at least three tables (criteria and aggregates required).
-- Provide the question, code and result.
-- Question: Find out the highest rental fee and the lowest rental fee for each rental that
-- the condo’s owner who rented out in 2019 received.

MariaDB [SFRC]> CREATE OR REPLACE VIEW view9_high_low AS
    -> SELECT condo_type, CONCAT_WS(' ', first_name, last_name) AS Owner,
    -> MAX(rental_fee) AS Highest, MIN(rental_fee) AS Lowest
    -> FROM properties NATURAL JOIN owners NATURAL JOIN transactions
    -> WHERE arrival_date >= '2019-01-01' AND depart_date <= '2019-12-31'
    -> GROUP BY property_id;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> SELECT * FROM view9_high_low;

+------------+-------------------+---------+---------+
| condo_type | Owner             | Highest | Lowest  |
+------------+-------------------+---------+---------+
| Tides3BR   | Gwen Grizzlie     |  750.00 |  375.00 |
| Tides3BR   | Lucille Livingood |  400.00 |  375.00 |
| Tides2BR   | Barbie Beckwith   |  350.00 |  350.00 |
| Tides3BR   | Charles Brown     |  500.00 |  400.00 |
| SandsOV3BR | Richard Compote   |  375.00 |  375.00 |
| SandsOF2BR | Jack Bauer        | 1200.00 |  800.00 |
| SandsOF2BR | Fred Flintstone   |  950.00 |  950.00 |
| Tides2BR   | Larry Lizard      | 1050.00 | 1050.00 |
| SandsOV2BR | Olivia Pope       |  425.00 |  425.00 |
| SandsOF3BR | Robert Smith      | 1950.00 |  450.00 |
+------------+-------------------+---------+---------+
10 rows in set (0.00 sec)

-- 10.	All of our properties now have Internet access. Create a query for this update.
-- This should not be a VIEW.
MariaDB [SFRC]> CREATE OR REPLACE VIEW view10_with_net AS
    -> SELECT * FROM properties;
Query OK, 0 rows affected (0.00 sec)

MariaDB [SFRC]> UPDATE view10_with_net
    -> SET with_net = 'Yes' WHERE with_net = 'No';
Query OK, 5 rows affected (0.00 sec)
Rows matched: 5  Changed: 5  Warnings: 0

MariaDB [SFRC]> SELECT * FROM view10_with_net;
+-------------+----------+------------+--------------+-------------+----------+
| property_id | building | condo_type | cleaning_fee | pet_allowed | with_net |
+-------------+----------+------------+--------------+-------------+----------+
| 1005T       | TIDES    | Tides3BR   |        60.00 | Yes         | Yes      |
| 1010S       | SANDS    | SandsOV2BR |        50.00 | No          | Yes      |
| 1100T       | TIDES    | Tides3BR   |        60.00 | No          | Yes      |
| 110T        | TIDES    | Tides2BR   |        50.00 | No          | Yes      |
| 1201T       | TIDES    | Tides3BR   |        60.00 | No          | Yes      |
| 207S        | SANDS    | SandsOV3BR |        60.00 | Yes         | Yes      |
| 301S        | SANDS    | SandsOF3BR |        60.00 | Yes         | Yes      |
| 317S        | SANDS    | SandsOF2BR |        50.00 | No          | Yes      |
| 409S        | SANDS    | SandsOF2BR |        50.00 | Yes         | Yes      |
| 505T        | TIDES    | Tides2BR   |        50.00 | Yes         | Yes      |
| 517T        | TIDES    | Tides3BR   |        60.00 | Yes         | Yes      |
| 656S        | SANDS    | SandsOV2BR |        50.00 | Yes         | Yes      |
| 942S        | SANDS    | SandsOF3BR |        60.00 | No          | Yes      |
+-------------+----------+------------+--------------+-------------+----------+
13 rows in set (0.01 sec)
