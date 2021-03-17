/*
	SQL vs NoSQL (MongoDB)  STARTER SCRIPT
    This file contains queries in both SQL and NoSQL

	Part I - import tables for this project using an existing project and an SQL script
	Part II - Connect to the Mongo Atlas cluster. This has been preloaded with the required data
	Part III - steps to construct the NoSQL
	Part IV - practice translating from SQL to NoSQL
*/
/* -----------------------------------------
-- 		Part I - import tables for this project using an existing project and an SQL script
-- ----------------------------------------- */
-- DO THIS: create schema and set to current schema
create schema if not exists sql_vs_nosql;
use sql_vs_nosql;

/* import the final strava table from the MySQL project
	 We'll do this with an SQL that creates the required table, strava_activities,
	 in the new schema with the following SQL statement
*/

/* -- DO THIS:
	create the strava activity table in the current schema by executing this SQL statement
*/
use sql_vs_nosql;
create table strava_activities as
	select strava_case_study.activities.ActivityID,
			strava_case_study.activities.ActivityType,
	    strava_case_study.secs2min(strava_case_study.activities.ElapsedTime) ElapsedMin,
			strava_case_study.km2mi(strava_case_study.activities.Distance) Miles, isoDate
	from strava_case_study.activities;

/*
 DO THIS:  in MySQL: import the other three tables
		open "import_other_3_tables.sql" and execute the entire file
*/

 -- DO THIS in MySQL: to review the data we just imported
 SELECT * FROM strava_activities Limit 5;
 SELECT * FROM faa_usairports_all Limit 5;
 SELECT * FROM nobel_laureates_1901_2019 Limit 5;
 SELECT * FROM usa_names_nc_1910_2019 Limit 5;

/* --------------------------------------------------
	Part II - Connect to the Mongo Atlas cluster. This has been preloaded with the required data
	---------------------------------------------------- */
/*
    open a command (terminal) window and use this code to connect to the exercise cluster
	This commands connect you to the cluster, default you to the class Database, show you the collections
		it calls "mongodb" and connects to the required Atlas cluster

	mongo "mongodb+srv://abtech-dba210-nosql-jnljd.gcp.mongodb.net/no_SQL_Proj"  --username dba210_student --password dba210_sp2020pw

-- Once in MongoDB use these commands to validate you are in the right place. You should see the collections we'll use.
--		rememeber: use a right mouse click to past at the MongoDB prompt
	use no_SQL_Proj
	db
	show collections
 */

/* DO THIS in MongoDB, look at the first 5 rows in each of these documents (copy/paste into termal after connecting)
	db.strava_activities.find().limit(5)
	db.faa_usairports.find().limit(5)
	db.nobel_laureates.find().limit(5)
	db.usa_names_nc.find().limit(5)
*/

/* -------------------------------------------
		Part III - training steps to construct the NoSQL versions
		----------------------------------------- */
-- Example 1: list activites after june 2019 with mailes between but not including .5 and 1.5 miles
-- SQL  execute so you have the result to compare to the NoSQL result
	select ActivityID, ActivityType, ElapsedMin, Miles, isoDate
	from strava_activities
	where Miles > .5 and Miles < 1.5
		and isoDate >= '2019-06-30';
/*
 step 1 - simple find with the field list requiested, start with a copy of the above first look at this data
	db.strava_activities.find(
		{},
		{ActivityType: 1, ElapsedMin: 1, Miles: 1}).limit(5)

  step 2 - add the WHERE clause in the empty brackets
	db.strava_activities.find(
		{Miles: {$gt: 0.5,$lt: 1.5}, ActivityDate: {$gt: ISODate('2019-06-31T00:00:00.000Z')} },
		{ActivityType: 1, ElapsedMin: 1, Miles: 1, isoDate: 1})

    the mongoDB output should match the SQL output
*/

-- Example 2: a sample that includes aggregation and the Nobel Price collection
-- Question: How many awards records are there after 1980
	SELECT count(*) as count
    FROM sql_vs_nosql.nobel_laureates_1901_2019
		WHERE year > 1980;
/*
 1. start with counting all rows
db.nobel_laureates.aggregate( [
	{ $group: { _id: null, count: { $sum: 1 } } }
])
// 2. test the filter
db.nobel_laureates.find({Year: {$gt: 1980}},{Year: 1, Category: 1, _id: 0}).sort( { Year: 1 })
	NOTE: the "Type "it" for more in the shell.  you have to type it to see the next page of the result

// combine group and filter (note the "" around year in match)
db.nobel_laureates.aggregate( [
	{ $match: { "Year": {$gt: 1980} } },
	{ $group: { _id: null, count: { $sum: 1 } } }
]);

// Note: adding the "$Year" to $group would give you counts for each of these years
	try this too
//   I also added sort descending to put the larger counts at the top
db.nobel_laureates.aggregate( [
	{ $match: { "Year": {$gt: 1980} } },
	{ $group: { _id: "$Year", count: { $sum: 1 } } },
	{ $sort: {count: -1 } }
]);


[ { _id: 2009, count: 18 },
  { _id: 2013, count: 16 },
  { _id: 2011, count: 16 },
  { _id: 2005, count: 16 },
  { _id: 2001, count: 15 },
  { _id: 2012, count: 15 },
  { _id: 2014, count: 15 },
  { _id: 2008, count: 15 },
  { _id: 2007, count: 14 },
  { _id: 2002, count: 14 },
  { _id: 2004, count: 14 },
  { _id: 1996, count: 13 },
  { _id: 2015, count: 13 },
  { _id: 1997, count: 13 },
  { _id: 1988, count: 13 },
  { _id: 2000, count: 13 },
  { _id: 1994, count: 12 },
  { _id: 2003, count: 12 },
  { _id: 1998, count: 12 },
  { _id: 2010, count: 12 } ]

Your result should match the result from the SQL statement
*/

/* NOTE:
	these examples are a good place to start when you work through the problems below
	copy and use below as starter code
*/

/* ----------------------------------------------------
		Part IV - translating from SQL to NoSQL, YOUR TURN
---------------------------------------------------- */
/* -----------------------------------
		question: In all the years covered in this table, how many nobel prizes where presented
    for individuals summarized by the individals country of birth. Show country and count only
    -- --------------------------------------- */
	Select `Birth Country`, count(*) as prizesAwarded
	FROM nobel_laureates_1901_2019
	where `Birth Country` != ""
	group by `Birth Country`
	having count(*) > 20
	order by count(*) desc;

/* nosql

db.nobel_laureates.aggregate([
{$match:{"Birth Country": {$ne:""}}}, 
{$group: {_id:"$Birth Country", prizeAward: {$sum: "$Birth Country"}}},
{$match: {prizeAward: {$gt: 20}}} , 
{$sort: {prizeAward: -1}} 
]);

[ { _id: 'United States of America', prizeAward: 276 },
  { _id: 'United Kingdom', prizeAward: 88 },
  { _id: 'Germany', prizeAward: 70 },
  { _id: 'France', prizeAward: 53 },
  { _id: 'Sweden', prizeAward: 30 },
  { _id: 'Japan', prizeAward: 29 } ]

*/

/* 	----------------------------------------------------
	faa_usairports_all
		This is a table from FAA open data of all airports in the USA
	---------------------------------------------------- */
/* question: what are the names, city, state, elevation and faa identifier of
			the Heliports in the US that have an elevation over 2000 feet */
	SELECT name, service_city, state_abbreviation, country, elevation, faa_identifier
	FROM faa_usairports_all
	WHERE elevation > 2000 and airport_type = "Heliport";
	-- this returns 621 rows

/* NoSQL - Your turn
	
	db.faa_usairports.find(
	{ elevation: {$gt: 2000}, airport_type: "Heliport" }, 
	{name: 1, service_city: 1, state_abbreviation: 1, country: 1, elevation: 1, faa_identifier: 1, _id: 0})
	
{ faa_identifier: 'AA14',
  name: 'Toolik',
  elevation: 2405,
  service_city: 'Toolik Field Station',
  state_abbreviation: 'AK',
  country: 'United States' }
{ faa_identifier: '09AA',
  name: 'Sheldon Chalet',
  elevation: 5742,
  service_city: 'Talkeetna',
  state_abbreviation: 'AK',
  country: 'United States' }
{ faa_identifier: 'AZ16',
  name: 'Northern Cochise Community Hospital',
  elevation: 4174,
  service_city: 'Willcox',
  state_abbreviation: 'AZ',
  country: 'United States' }
{ faa_identifier: '70AZ',
  name: 'Rgnl Public Safety Training Academy',
  elevation: 2580,
  service_city: 'Tucson',
  state_abbreviation: 'AZ',
  country: 'United States' }
{ faa_identifier: 'AZ89',
  name: 'Sierra Vista Rgnl Health Center',
  elevation: 4548,
  service_city: 'Sierra Vista',
  state_abbreviation: 'AZ',
  country: 'United States' }

// to get row count
db.faa_usairports.find( { elevation: {$gt: 2000}, airport_type: "Heliport" } ).count()

NOTE: copy the first 5 rows returned here
*/

/* question: what states have seaports and how many in each state */
SELECT state_abbreviation, count(*)
FROM faa_usairports_all
WHERE airport_type = "Seaport"
GROUP BY state_abbreviation
ORDER BY count(*) DESC;

/*
// NoSQL
db.faa_usairports.aggregate([ 
{$match: {airport_type: "Seaport"} },
{$group: {_id: "$state_abbreviation", count: {$sum: 1 }} },
{$sort: {count: -1}}
])

[ { _id: 'AK', count: 137 },
  { _id: 'MN', count: 62 },
  { _id: 'FL', count: 56 },
  { _id: 'ME', count: 46 },
  { _id: 'IN', count: 18 },
  { _id: 'WA', count: 17 },
  { _id: 'WI', count: 17 },
  { _id: 'MA', count: 17 },
*/

/* Question: Create a SIMPLE question of your own of the FAA airport dataset 
List the names, city, state, and elevation of the top five airports that have 
an elevation over 10000 feet, order by elevation */
-- SQL answer
// -- your sql goes here
	SELECT name, service_city, state_abbreviation, country, elevation
	FROM faa_usairports_all
    where elevation >=10000
	order by elevation desc limit 5;

/* NoSQL answer
// -- your nosql goes here
db.faa_usairports.find(
{elevation: {$gte: 10000}}, 
{_id: null, name: 1, service_city:1, state_abbreviation: 1, country: 1, elevation:1}).limit(5).sort({elevation: -1});

{ name: 'Berthoud Pass',
  elevation: 12442,
  service_city: 'Empire',
  state_abbreviation: 'CO',
  country: 'United States' }
{ name: 'Badger Mountain',
  elevation: 11294,
  service_city: 'Tarryall',
  state_abbreviation: 'CO',
  country: 'United States' }
{ name: 'Sacramento',
  elevation: 11104,
  service_city: 'Fairplay',
  state_abbreviation: 'CO',
  country: 'United States' }
{ name: 'Mount Princeton',
  elevation: 10858,
  service_city: 'Mount Princeton',
  state_abbreviation: 'CO',
  country: 'United States' }
{ name: 'Arapahoe',
  elevation: 10672,
  service_city: 'Idaho Springs',
  state_abbreviation: 'CO',
  country: 'United States' }
*/

/* 	----------------------------------------------------
	usa_names_nc_1910_2019
		This is a table of all first names provided on all Social Security Cards Applications since 1910 (11 decades)
	---------------------------------------------------- */
-- question: Using your first name or any name of your choice, How many SSNumbers were requested in total?
--  you may want look at the names First
SELECT DISTINCT name FROM usa_names_nc_1910_2019 where name like 'St%' order by name;

-- Note, all names start with a capital letter in the database

-- my sql
SELECT sum(number) as nameCount
FROM usa_names_nc_1910_2019
WHERE name IN ("Steve", "Steven","Stevie");

-- Your SQL  -------------------

/* Your NoSQL

	db.usa_names_nc.aggregate([{$match: {name: {$in: ["Steve", "Steven", "Stevie"]}}}, 
    {$group: {_id: null, nameCount: {$sum: "$number"}}} ])

[ { _id: null, nameCount: 31319 } ]

*/

-- question: change the above so year is included in the grouping
-- my sql
SELECT year, name, sum(number) as nameCount
FROM usa_names_nc_1910_2019
WHERE name IN ("Steve", "Steven","Stevie")
group by year, name
order by year;
-- your sql


/* YOUR NoSQL

	db.usa_names_nc.aggregate([
	{$match: {name: {$in: ["Steve", "Steven", "Stevie"]}}}, 
	{$group: {_id: {year: "$year", name: "$name", nameCount: {$sum: "$number"}} }}, 
	{$sort: {_id: 1}} 
	])

*/

-- question: Create a SIMPLE question of your own of the Social Security application first name dataset on any criteria
-- Display the top ten most popular names.
-- yours  SQL
	--	 your sql goes here
select name, count(name) as top_ten_names
from usa_names_nc_1910_2019
group by name
order by top_ten_names desc limit 10;
/* your NoSQL
	-- your nosql goes here
	db.usa_names_nc.aggregate([
    {$match: {name: {$ne:null}}},
	{$group: {_id: "$name", top_ten_names: {$sum: 1} }}, 
	{$sort: {top_ten_names: -1}},
	{$limit: 10}
	]);
    
    [ { _id: 'Jessie', top_ten_names: 218 },
  { _id: 'Lee', top_ten_names: 191 },
  { _id: 'Marion', top_ten_names: 188 },
  { _id: 'James', top_ten_names: 187 },
  { _id: 'William', top_ten_names: 178 },
  { _id: 'Leslie', top_ten_names: 175 },
  { _id: 'Willie', top_ten_names: 173 },
  { _id: 'Robert', top_ten_names: 173 },
  { _id: 'John', top_ten_names: 171 },
  { _id: 'Kelly', top_ten_names: 168 } ]
*/
