-- COMP3311 Prac 03 Exercise
-- Schema for simple company database

create table Employees (
	tfn         char(11) check (tfn ~ '[0-9]{3}-[0-9]{3}-[0-9]{3}'),
	givenName   varchar(30) not null,
	familyName  varchar(30),
	hoursPweek  float check (hoursPweek between 0 and 168)
);

create table Departments (
	id          char(3) check (id ~'[0-9]{3}'),
	name        varchar(100) unique,
	manager     char(11) unique
);

create table DeptMissions (
	department  char(3),
	keyword     varchar(20)
);

create table WorksFor (
	employee    char(11),
	department  char(3),
	percentage  float check (percentage between 0 and 100)
);
