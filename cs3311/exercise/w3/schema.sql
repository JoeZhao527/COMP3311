-- COMP3311 Prac 03 Exercise
-- Schema for simple company database

create table Employees (
	tfn         char(11) check (tfn ~ '[0-9]{3}-[0-9]{3}-[0-9]{3}'),
	givenName   varchar(30) not null,
	familyName  varchar(30),
	hoursPweek  float check (hoursPweek between 0 and 168),
	primary key (tfn)
);

create table Departments (
	id          char(3) check (id ~'[0-9]{3}'),
	name        varchar(100) not null unique,
	manager     char(11) not null unique,
	primary key (id),
	foreign key (manager) references Employees(tfn)
);

create table DeptMissions (
	department  char(3),
	keyword     varchar(20),
	primary key (department, keyword),
	foreign key (department) references Departments(id)
);

create table WorksFor (
	employee    char(11) not null,
	department  char(3) not null,
	percentage  float check ((percentage between 0 and 100) and 
		100 >= percentage + sum(
			select percentage
			from WorksFor w
			where w.employee = employee
		)
	),
	foreign key (employee) references Employees(tfn),
	foreign key (department) references Departments(id)
);
