/*************************
A script that creates a
database named library with
four tables
*************************/

DROP TABLE book;

CREATE TABLE Book
(
	bookID	NUMBER	NOT NULL,
	ISBN	CHAR(13)	NOT NULL,
	title	VARCHAR(40)	NOT NULL,
	author	VARCHAR(40)	NOT NULL,
	publish_year	CHAR(4),
	category	CHAR(15)	NOT NULL,
	CONSTRAINT book_pk PRIMARY KEY (bookID)
);
DROP TABLE member;
CREATE TABLE Member
(
	memberID	NUMBER	NOT NULL,
	lastname	VARCHAR(20)	NOT NULL,
	firstname	VARCHAR(20)	NOT NULL,
	address	VARCHAR(40)	NOT NULL,
	phone_number	CHAR(10)	NOT NULL,
	limit	NUMBER	DEFAULT 10,
	CONSTRAINT member_pk PRIMARY KEY (memberID)
);

drop table currentloan;
CREATE TABLE CurrentLoan
(
	memberID NUMBER	NOT NULL,
	bookID	NUMBER	NOT NULL,
	loan_date	DATE	NOT NULL,
	due_date	DATE	NOT NULL,
	CONSTRAINT memberID_bookID PRIMARY KEY (memberID, bookID),
	CONSTRAINT cl_member_fk FOREIGN KEY (memberID) REFERENCES Member (memberID),
	CONSTRAINT cl_book_fk FOREIGN KEY (bookID) REFERENCES Book (bookID)
);

CREATE TABLE History
(
	memberID	INT	NOT NULL,
	bookID	INT	NOT NULL,
	loan_date	DATE	NOT NULL,
	return_date DATE	NOT NULL,
	CONSTRAINT member_book_loan	PRIMARY KEY (memberID, bookID, loan_date),
	CONSTRAINT history_member_fk FOREIGN KEY (memberID) REFERENCES Member (memberID),
	CONSTRAINT history_book_fk FOREIGN KEY (bookID) REFERENCES Book (bookID)
);

INSERT INTO book VALUES (1, '9780399251825', 'The Very Hungry Caterpillar', 'Carle Eric', '2008', 'Children''s');
INSERT INTO book VALUES (2, '9780694013203', 'The Grouchy Ladybug', 'Carle Eric', '1999', 'Children''s');
INSERT INTO book VALUES (3, '9781416979173', 'The Tiny Seed', 'Carle Eric', '2009', 'Children\'s');
INSERT INTO book VALUES (4, '9780764588457', 'XML For Dummies', 'Dykes Lucinda', '2005', 'Non-fiction');
INSERT INTO book VALUES (5, '9781284194531', 'Ugly''s Electrical References', 'Miller Charles', '2020', 'Reference');
INSERT INTO book VALUES (6, '9781734499315', 'Supplements Desk Reference', 'O''Sullivan Jen', '2020', 'Reference');
INSERT INTO book VALUES (7, '9780596006341', 'XQuery', 'Walmsley Priscilla', '2007', 'Non-fiction');
INSERT INTO book VALUES (8, '9780060935467', 'To Kill a Mockingbird', 'Lee Harper', '2002', 'Fiction');
INSERT INTO book VALUES (9, '9780596006341', 'XQuery', 'Walmsley Priscilla', '2007', 'Non-fiction');
INSERT INTO book VALUES (10, '9780743273565', 'The Great Gatsby', 'Fitzgerald Scott', '2004', 'Fiction');
INSERT INTO book VALUES (11, '9780596006341', 'XQuery', 'Walmsley Priscilla', '2007', 'Non-fiction');
INSERT INTO book VALUES (12, '9780132886727', 'Definitive XML Schema', 'Walmsley Priscilla', '2013', 'Non-fiction');
INSERT INTO book VALUES (13, '9781558580091', 'The Rainbow Fish', 'Pfister Marcus', '1999', 'Children''s');
INSERT INTO book VALUES (14, '9780399229190', 'The Very Busy Spider', 'Carle Eric', '1995', 'Children''s');
INSERT INTO book VALUES (15, '9781558580091', 'The Rainbow Fish', 'Pfister Marcus', '1999', 'Children''s');

INSERT INTO member VALUES (1, 'Jones', 'Sarah', '3288 Meadwo Drive', '7421863294', 5);
INSERT INTO member VALUES (2, 'Ewing', 'Tracy', '1412 Stiles Street', '9995922013', 5);
INSERT INTO member VALUES (3, 'Martin', 'George', '3074 Southern Street', '3697214622', 5);
INSERT INTO member VALUES (4, 'Smith', 'John', '2126 Long Drive', '3801428820', 5);
INSERT INTO member VALUES (5, 'Trundle', 'Amanda', '2968 Jewel Road', '2714348789', 10);

INSERT INTO currentloan VALUES (1, 1, TO_DATE('2020/02/03', 'yyyy/mm/dd'), TO_DATE('2020/03/03', 'yyyy/mm/dd'));
INSERT INTO currentloan VALUES (1, 3, TO_DATE('2020/01/11','yyyy/mm/dd'), TO_DATE( '2020/02/11', 'yyyy/mm/dd'));
INSERT INTO currentloan VALUES (4, 4, TO_DATE('2020/01/15', 'yyyy/mm/dd'), TO_DATE('2020/02/15', 'yyyy/mm/dd'));
INSERT INTO currentloan VALUES (4, 5, TO_DATE('2020/01/22', 'yyyy/mm/dd'), TO_DATE('2020/02/22', 'yyyy/mm/dd'));

INSERT INTO history VALUES (3, 4, TO_DATE('2020/02/03', 'yyyy/mm/dd'), TO_DATE( '2020/02/23', 'yyyy/mm/dd'));
INSERT INTO history VALUES (2, 1, TO_DATE('2020/01/23','yyyy/mm/dd'), TO_DATE( SYSDATE, 'yyyy/mm/dd'));
INSERT INTO history VALUES (2, 7, TO_DATE('2020/01/15', 'yyyy/mm/dd'), TO_DATE( SYSDATE, 'yyyy/mm/dd'));
INSERT INTO history VALUES (1, 5, TO_DATE('2019/11/25', 'yyyy/mm/dd'), TO_DATE( SYSDATE, 'yyyy/mm/dd'));
INSERT INTO history VALUES (2, 6, TO_DATE('2019/04/28','yyyy/mm/dd'), TO_DATE( '2019/05/16', 'yyyy/mm/dd'));
INSERT INTO history VALUES (1, 7, TO_DATE('2019/05/16', 'yyyy/mm/dd'), TO_DATE( '2019/06/03', 'yyyy/mm/dd'));
INSERT INTO history VALUES (1, 3, TO_DATE('2019/07/21', 'yyyy/mm/dd'), TO_DATE( '2019/08/09', 'yyyy/mm/dd'));


/*2) Find the book ID, title, author, and publish-year of all the books with the
words “XML” and “XQuery” in the  title.  These  two keywords  can appear in the
title  in  any  order  and  do  not have to  be  next  to  each other.  Sort
the results by publishyear in descending order.*/

select bookID, title, author, publish_year
from book
where title like '%XML%' or title like '%XQuery%'
order by publish_year desc;

    BOOKID TITLE		AUTHOR               PUBL
-------------------------------------------- ----
         3 XQuery		Walmsley Priscilla   2007

         7 XQuery		Walmsley Priscilla   2007

        12 XQuery		Walmsley Priscilla   2007

         9 XQuery		Walmsley Priscilla   2007

        11 XQuery		Walmsley Priscilla   2007

         4 XML For Dummies	Dykes Lucinda	 2005


/* 3) Find the bookID, title, and due date of all the books currently being checked
out by John Smith.*/
select c.bookID, b.title, c.due_date
from currentloan c join member m
on c.memberID = m.memberID
join book b on b.bookID = c.bookID
where m.lastname = 'Smith' and m.firstname='John';


    BOOKID TITLE                                    DUE_DATE
---------- ---------------------------------------- ---------
         4 XML For Dummies                          15-FEB-20
         5 Ugly's Electrical References             22-FEB-20

'/*(4) Find the member ID, last name,and first name of the members who have never
borrowed any books in the past or currently.*/
select memberID, lastname, firstname from member
where memberID not in
(select memberID from currentloan
union
select memberID from history);

  MEMBERID LASTNAME             FIRSTNAME
---------- -------------------- --------------------
         5 Trundle              Amamda

/* 5) List the ISBN and title of the books with at least two copies.
select ISBN, title from book group by ISBN, title having count(ISBN)>=2;*/

ISBN          TITLE
------------- ----------------------------------------
9780060935467 To Kill a Mockingbird
9780596006341 XQuery
9780743273565 The Great Gatsby
9781558580091 The Rainbow Fish

/* 6) Increase the limit by 2 for all members, but the maximum limit is 10.
Display the member ID and limit for each member before and after you make
the changes. */
 select * from member;

  MEMBERID LASTNAME             FIRSTNAME	ADDRESS          PHONE_NUMB   LIMIT
---------------------------------------- ---------- ----------
         1 Jones                Sarah	3288 Meadwo Drive    7421863294   5

         2 Ewing                Tracy	1412 Stiles Street   9995922013   5

         3 Martin               George	3074 Southern Street 3697214622   5

         4 Smith                John	2126 Long Drive      3801428820   5

         5 Trundle              Amamda	2968 Jewel Road      2714348789   10

SQL> update member set limit = c
case
when limit <= 8 then limit + 2
else 10
end;

4 rows updated.


  MEMBERID LASTNAME             FIRSTNAME	ADDRESS          PHONE_NUMB   LIMIT
---------------------------------------- ---------- ----------
         1 Jones                Sarah	3288 Meadwo Drive    7421863294   7

         2 Ewing                Tracy	1412 Stiles Street   9995922013   7

         3 Martin               George	3074 Southern Street 3697214622   7

         4 Smith                John	2126 Long Drive      3801428820   7

         5 Trundle              Amamda	2968 Jewel Road      2714348789   10

/* (7)  Find  the name  of  the author(s)that  has  the  largest  number  of
different books owned  by  the  library (multiple copies of the same book only
count as one book). */

select author from book group by author having count(distinct ISBN) >= all
(select count(distinct ISBN) from book group by author) ;



/*(8) For each member (using both member ID,
last name,and first name), list the number of books he/she has currently checked out, and  the  number of books he/she
checked out in the  past. If a  person  checked out the same book multiple times, it will be counted multiple times.
Zero count should also be listedas 0. */
select m.memberId, lastname, firstname, count(c.memberID) as current , count(h.memberID) as past
from member m
left join currentloan c on m.memberId = c.memberId
left join history h on
m.memberID = h.memberID group by m.memberID;
