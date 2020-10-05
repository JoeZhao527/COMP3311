-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by INSERT YOUR NAME HERE

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type VisibilityType as enum ('public', 'private');
create type EventType as enum ('one-day', 'spanning', 'recurring');
create type WeekDayType as enum ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');
-- add more types/domains if you want

-- Tables

create table Users (
	id          serial,
	name		text not null,
	email       text not null unique,
	passwd		text not null,
	is_admin	boolean not null,
	primary key (id)
);

create table Groups (
	id          serial,
	name        text not null,
	owner		int not null,
	primary key (id),
	foreign key (owner) references Users(id)
);


create table Calendar (
	id		serial,
	name	text not null,
	owner	int not null,
	colour	text not null,
	default_access	AccessibilityType not null,
	primary key (id),
	foreign key (owner) references Users(id)
);

create table Event (
	id			serial,
	title		text not null,
	visibility 	VisibilityType not null,
	start_time	time,
	end_time	time,
	location	text,
	part_of		integer not null,
	created_by	integer not null,
	event_type	EventType not null,
	primary key (id),
	foreign key (created_by) references Users(id),
	foreign key (part_of) references Calendar(id)
);

create table alarms (
	event_id	integer,
	alarm		interval,
	foreign key event_id references Event(id),
	primary key (event_id, alarm)
);

create table one_day_event (
	id		integer,
	date	date not null,
	primary key (id),
	foreign key	(id) references Event(id)
);

create table spanning_event (
	id			integer,
	start_date	date not null,
	end_date		date not null,
	primary key (id),
	foreign key (id) references Event(id)
);

create table recurring_event (
	id			integer,
	ntimes		integer,
	start_date	date not null,
	end_date	date,
	primary key (id),
	foreign key (id) references Event(id)

);

create table weekly_event(
	id			integer,
	day_of_week	WeekDayType not null,
	frequency	integer not null check (frequency > 0),
	primary key	(id),
	foreign key (id) references recurring_event(id)
);

create table monthly_by_day_event(
	id		integer,
	dayOfWeek	WeekDayType not null,
	week_in_month	integer not null check (week_in_month between 1 and 5),
	primary key	(id),
	foreign key (id) references recurring_event(id)
);

create table monthly_by_date_event (
	id		integer,
	date_in_month	integer not null check (date_in_month between 1 and 31),
	primary key	(id),
	foreign key (id) references recurring_event(id)
);

create table annual_event (
	id		integer,
	date	date not null,
	primary key	(id),
	foreign key (id) references recurring_event(id)
);

-- relationships

create table Member (
	users_id 	integer,
	groups_id	integer,
	primary key	(users_id, groups_id),
	foreign key (users_id) references Users(id),
	foreign key (groups_id) references Groups(id)
);

create table Accessibility (
	users_id 	integer,
	calendar_id	integer,
	access		AccessibilityType not null,
	primary key	(users_id, calendar_id),
	foreign key (users_id) references Users(id),
	foreign key (calendar_id) references Calendar(id)
);

create table subscribed (
	users_id 	integer,
	calendar_id	integer,
	colour		text,
	primary key	(users_id, calendar_id),
	foreign key (users_id) references Users(id),
	foreign key (calendar_id) references Calendar(id)
);

create table invited(
	users_id	integer,
	event_id	integer,
	status 		InviteStatus not null,
	primary key	(users_id, event_id),
	foreign key (users_id) references Users(id),
	foreign key (event_id) references Calendar(id)
);