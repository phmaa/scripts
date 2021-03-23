/******************************************************************
* This script creates the database named SFRC
*******************************************************************/

DROP DATABASE IF EXISTS SFRC;
CREATE DATABASE SFRC;
USE SFRC;

-- create the tables for the database
CREATE TABLE rates (
	condo_type ENUM('SandsOF2BR', 'SandsOF3BR', 'SandsOV2BR', 'SandsOV3BR', 'Tides2BR', 'Tides3BR') PRIMARY KEY,
	rate_january DECIMAL(10,2)	NOT NULL,
	rate_april DECIMAL(10,2)	NOT NULL,
	rate_june	DECIMAL(10,2)	NOT NULL,
	rate_september	DECIMAL(10,2)	NOT NULL,
	rate_november	DECIMAL(10,2)	NOT NULL
);
	
	
CREATE TABLE properties (
	property_id	VARCHAR(10)		PRIMARY KEY,
	building	ENUM('SANDS', 'TIDES') NOT NULL,
	condo_type	ENUM('SandsOF2BR', 'SandsOF3BR', 'SandsOV2BR', 'SandsOV3BR', 'Tides2BR', 'Tides3BR') NOT NULL,
	cleaning_fee 	DECIMAL(10, 2) NOT NULL,
	pet_allowed	ENUM('Yes', 'No')	NOT NULL,
	with_net	ENUM('Yes', 'No') NOT NULL,
	CONSTRAINT properties_fk_rates
		FOREIGN KEY (condo_type)
		REFERENCES rates (condo_type)
);

CREATE TABLE clients (
	client_id	INT	PRIMARY KEY	AUTO_INCREMENT,
	client_fname	VARCHAR(60)	NOT NULL,
	client_lname	VARCHAR(60)	NOT NULL,
	client_address	VARCHAR(60)	NOT NULL,
	client_city	VARCHAR(40)	NOT NULL,
	client_state	VARCHAR(2)	NOT NULL,
	client_zip	VARCHAR(10)	NOT NULL,
	client_phone	VARCHAR(12)	NOT NULL,
	client_email	VARCHAR(255)
);

CREATE TABLE owners (
	owner_id	INT		PRIMARY KEY	AUTO_INCREMENT,
	property_id	VARCHAR(10)	NOT NULL,
	first_name	VARCHAR(60)	NOT NULL,
	last_name	VARCHAR(60)	NOT NULL,
	address		VARCHAR(60)	NOT NULL,
	city		VARCHAR(40)	NOT NULL,
	state		VARCHAR(2)	NOT NULL,
	zip_code	VARCHAR(10) 	NOT NULL,
	phone		VARCHAR(12)	NOT NULL,
	email		VARCHAR(255)	NOT NULL,
	CONSTRAINT owners_fk_properties
		FOREIGN KEY (property_id)
		REFERENCES properties (property_id)
);

CREATE TABLE transactions (
	transaction_id	INT		PRIMARY KEY AUTO_INCREMENT,
	property_id 	VARCHAR(10)	NOT NULL,
	client_id	INT		NOT NULL,
	arrival_date	DATE 		NOT NULL,
	depart_date	DATE 		NOT NULL,
	rental_deposit	DECIMAL(10,2)	NOT NULL,
	pet_deposit	DECIMAL(10,2)	DEFAULT 0,
	pet_type	VARCHAR(40) 	DEFAULT NULL,
	rental_fee	DECIMAL(10,2)	NOT NULL,
	payment_method	ENUM('AMEX', 'Cash', 'Check', 'MasterCard', 'PayPal', 'Visa')	NOT NULL,
	CONSTRAINT transactions_fk_properties
		FOREIGN KEY (property_id)
		REFERENCES properties (property_id),
	CONSTRAINT transactions_fk_clients
		FOREIGN KEY (client_id)
		REFERENCES clients (client_id)
);



-- insert data into tables
INSERT INTO rates (condo_type, rate_january, rate_april, rate_june, rate_september, rate_november) VALUES
('SandsOF2BR', 400, 475, 600, 475, 400),
('SandsOF3BR', 450, 525, 650, 525, 450),
('SandsOV2BR', 375, 425, 575, 425, 375),
('SandsOV3BR', 425, 475, 625, 475, 425),
('Tides2BR', 350, 375, 450, 375, 350),
('Tides3BR', 375, 400, 500, 400, 375);


INSERT INTO properties (property_id, building, condo_type, cleaning_fee, pet_allowed, with_net) VALUES
('301S', 'SANDS',	'SandsOF3BR', 60.00, 'Yes', 'Yes'),
('207S', 'SANDS',	'SandsOV3BR', 60.00, 'Yes', 'Yes'),
('1100T', 'TIDES',	'Tides3BR',	60.00, 'No', 'No'),
('1201T',	'TIDES', 'Tides3BR', 60.00,	'No', 'Yes'),
('317S',	'SANDS', 'SandsOF2BR',	50.00, 'No', 'Yes'),
('110T', 'TIDES',	'Tides2BR', 50.00,	'No', 'Yes'),
('1010S',	'SANDS', 'SandsOV2BR', 50.00,	'No', 'No'),
('409S', 'SANDS',	'SandsOF2BR', 50.00,	'Yes', 'Yes'),
('505T',	'TIDES', 'Tides2BR',	50.00, 'Yes', 'No'),
('1005T',	'TIDES', 'Tides3BR',	60.00, 'Yes', 'Yes'),
('656S', 'SANDS',	'SandsOV2BR',	50.00, 'Yes', 'No'),
('942S', 'SANDS',	'SandsOF3BR',	60.00, 'No', 'No'),
('517T', 'TIDES',	'Tides3BR',	60.00, 'Yes', 'Yes');

INSERT INTO clients (client_fname, client_lname, client_address, client_city, client_state, client_zip, client_phone, client_email) VALUES
('Harriet', 'O''Casey', '4088 Ottumwa Way', 'Mentira', 'IL',  '61788', '303-417-4438', 'harrieto@com.net'),
('John', 'Grainger', '2256 N Santa Fe Dr.',  'Iliase', 'MD',  '23456',	'303-444-4475', 	'johnny@com.net'),
('Steve', 'Snider',	'39430 Big Rock Rd.',  'Flame Throw', 'TN',  '59012',	'717-420-1212',	'snidley@com.net'),
('David', 'Stocking',	'291-A Gorgonzola',  'Cleo', 'KS',  '81029',	'616-410-2990',	'stockingfeet@com.net'),
('Frank', 'Wheeler',	'2225 Iola Ave',  'Catuchi', 'PA',  '56231',	'303-414-0404',	'fwheeler@com.net'),
('Brittany', 'Foxe',	'297-B Gorgonzola',  'Cleo', 'KS',  '81029',	'616-410-2942',	'bfoxy@com.net'),
('Fran', 'McCoy',	'1440 Manchester Way',  'Mountain View', 'CO',  '87757',	'303-477-8787',	'franm@com.net'),
('Joan', 'Thomas', 	'667438 E. 91st St.',  'Baseboard', 'PA',  '56987',	'616-684-9385',	'joanie@com.net'),
('Ted', 'Stiggle',	'12920 Industrial Workers',  'Scraggy View', 'CO',  '82191',	'303-421-1410',	'thestig@com.net'),
('Dean', 'Farrell',	'121 Highway 80',  'Excelsior', 'MD',  '23498',	'717-483-3111',	'farrelld@com.net'),
('Marsha', 'Waltz',	'1900 Industrial Way',  'Fargone', 'NC',  '41923',	'215-419-2349',	'waltzer@com.net'),
('Jane', 'Logan',	'860 Charleston St.',  'Oxalys', 'NY',  '54133',	'303-441-1321',	'janetlogan@com.net'),
('Linda', 'Paloma',	'1928 Highway 12',  'Portugal', 'NC',  '82394',	'317-423-9417',	'palomafam@com.net'),
('Gregory', 'Hansen',	'6065 Rainbow Falls Rd.',  'Roselle', 'PA',  '57203',	'505-472-0398',	'gregghansen@com.net'),
('Pat', 'Carroll',	'4018 Landers Lane',  'Lafayette', 'OH',  '34548',	'303-476-2718',	'pcarroll@com.net'),
('Bee', 'Wolf',	'1775 Bear Trail',  'Outcroppin', 'WY',  '74345',	'404-443-4863',	'beew@com.net'),
('Scott', 'Crumple',	'580 E Main St.',  'La Garita', 'CO',  '88413',	'303-444-1324', ''),	
('Elliot', 'Harvey',	'34 Kerry Dr.',  'El Mano', 'MD',  '23646',	'505-406-4647', ''),	
('Carrie', 'Zygote',	'8607 Ferndale St.',  'Montgomery', 'AL', '60631',	'303-406-3104',	'carriez@com.net'),
('Abbie', 'Loftus',	'8077 Montana Place',  'Big Fish', 'MT',  '86505',	'606-468-0858',	'aloftus@com.net'),
('Micah', 'Dowenger',	'1515 Elliot Way', 'Asheville', 'NC', '28801', 	'828-121-6445',	'mdowenger@com.net');

INSERT INTO owners (property_id, first_name, last_name, address, city, state, zip_code, phone, email) VALUES
('301S',	'Sandy', 'Claus',	'123 North Pole Dr.',  'Snowshoe', 'PA',  '23987',	'404-678-0909',	'sandyclaus@com.net'),
('207S', 'Richard', 'Compote', '645 Snowpass Rd.', 'Plymouht', 'MD', '48170', '413-555-9876', 'richc@com.net'),
('1100T',	'Lucille', 'Livingood',	'63 Park Ave',  'New York', 'NY',  '12340',	'007-555-3636',	'livingood@com.net'),
('1201T',	'Charles', 'Brown',	'8706 Main St.',  'Snowshoe', 'CO',  '48000',	'303-555-1236',	'charlie@com.net'),
('317S',	'Jack', 'Bauer',	'469 Carriage Hill Dr.',  'Washington', 'DC', '20001',	'713-555-3872',	'jackbauer@com.net'),
('110T',	'Barbie', 'Beckwith',	'9010 Upper Crust Way',  'Littleton', 'NY',  '20127',	'007-555-9999',	'babs@com.net'),
('1010S',	'Barney', 'Rubble',	'1616 Stonehenge',  'Granite', 'CO',  '80234',	'720-555-1456',	'rockhead@com.net'),
('409S',	'Fred', 'Flintstone',	'26 Quarry Dr.',  'Granite', 'CO',  '80234',	'720-555-7676',	'freddie@com.net'),
('505T',	'Larry', 'Lizard',	'908 Green Mtn Rd.',  'Green Mountain', 'UT', '23987',	'765-555-4392',	'lizard@com.net'),
('1005T',	'Gwen', 'Grizzlie',	'56231 Bear Lane',  'Bear Lake', 'MD',  '23123',	'413-678-9808',	'griz@com.net'),
('656S',	'Olivia', 'Pope',	'878 Fort Rd.',  'Washington', 'DC', '20001',	'404-555-8877',	'opa@com.net'),
('942S',	'Robert', 'Smith',	'5223 Mountain Lane',  'Ft. Morgan', 'WV',  '34665',	'505-555-1456',	'bobbys@com.net'),
('517T',	'Luke', 'Taylors',	'375 Windward Way', 'Asheville', 'NC',  '28801',	'828-445-9776',	'luket@com.net');

INSERT INTO transactions (property_id, client_id, arrival_date, depart_date, rental_deposit, pet_deposit, pet_type, rental_fee, payment_method) VALUES
('1100T', 19, '2019-01-06', '2019-01-13', 100.00, 0, '', 375.00, 'Cash'),
('317S',	8, '2019-01-13', '2019-01-27',	100.00, 0, '', 800.00,	'AMEX'),
('1005T', 9, '2019-01-20', '2019-02-03', 100.00, 0, '', 750.00, 'Check'),
('505T', 6, '2019-02-03', '2019-02-24', 100.00, 150.00, 'cat', 1050.00, 'Check'),
('207S',	19, '2019-02-17', '2019-02-24', 100.00,	150.00,	'dog', 375.00, 'Visa'),
('942S',	7,	'2019-02-10', '2019-02-24', 100.00, 0, '', 900.00,	'AMEX'),
('110T',	4,	'2019-02-24', '2019-03-03',	100.00, 0, '', 350.00, 'PayPal'),
('1005T', 14, '2019-03-03', '2019-03-10', 100.00, 0, '', 375.00, 'Visa'),
('942S',	7, '2019-03-17', '2019-03-24', 100.00, 0, '', 450.00, 'MasterCard'),
('942S', 7,	'2019-04-07', '2019-04-14', 100.00, 0, '', 525.00, 'MasterCard'),
('1005T', 1, '2019-04-07', '2019-04-17', 100.00, 150.00, 'dog', 400.00,	'Check'),
('1201T', 13, '2019-04-14', '2019-04-21', 100.00, 0, '', 400.00, 'MasterCard'),
('409S', 8,	'2019-05-05', '2019-05-19', 100.00,	150.00,	'cat', 950.00,	'AMEX'),
('1100T', 7,	'2019-05-05', '2019-05-12',	100.00, 0, '', 400.00, 'MasterCard'),
('317S', 4,	'2019-05-05', '2019-05-19', 100.00, 0, '', 950.00, 'PayPal'),
('942S', 6,	'2019-05-05', '2019-05-12',	100.00,	0, '', 525.00, 'Cash'),
('1201T', 13, '2019-05-12', '2019-05-19', 100.00, 0, '', 400.00, 'MasterCard'),
('1005T', 9, '2019-05-12', '2019-05-19', 100.00,  0, '', 400.00, 'Visa'),
('656S', 2,	'2019-05-19', '2019-05-26',	100.00,	150.00,	'dog', 425.00, 'Visa'),
('317S', 3,	'2019-06-02', '2019-06-16', 100.00, 0, '', 1200.00, 'PayPal'),
('942S', 7,	'2019-06-02', '2019-06-23',	100.00, 0, '', 1950.00,	'PayPal'),
('1005T', 1, '2019-06-09', '2019-06-16', 100.00, 150.00, 'dog',	500.00,	'Check'),
('1201T', 13, '2019-06-16', '2019-06-23', 100.00, 0, '', 500.00, 'MasterCard'),
('1005T', 9, '2020-01-05', '2020-01-12', 100.00, 0, '', 375.00,	'Check'),
('942S', 7,	'2020-01-19', '2020-02-02', 100.00, 0, '', 900.00, 	'MasterCard'),
('110T', 4,	'2020-02-02', '2020-02-09',	100.00, 0, '', 350.00, 'PayPal'),
('1005T', 1, '2020-02-09', '2020-02-16', 100.00, 150.00, 'dog', 375.00, 'Check'),
('409S', 8,	'2020-03-02', '2020-03-23', 100.00,	150.00,	'cat', 1200.00,	'AMEX');


