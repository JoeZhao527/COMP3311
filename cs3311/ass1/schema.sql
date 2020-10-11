-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by Haokai (Joe) Zhao

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type VisibilityType as enum ('public', 'private');
create type EventType as enum ('one-day', 'spanning', 'recurring');
create type WeekDayType as enum ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');

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


create table Calendars (
	id		serial,
	name	text not null,
	owner	int not null,
	colour	text not null,
	default_access	AccessibilityType not null,
	primary key (id),
	foreign key (owner) references Users(id)
);

create table Events (
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
	foreign key (part_of) references Calendars(id)
);

create table alarms (
	event_id	integer,
	alarm		interval,
	primary key (event_id, alarm),
	foreign key (event_id) references Events(id)
);

create table One_day_events (
	id		integer,
	date	date not null,
	primary key (id),
	foreign key	(id) references Events(id)
);

create table Spanning_events (
	id			integer,
	start_date	date not null,
	end_date		date not null,
	primary key (id),
	foreign key (id) references Events(id)
);

create table Recurring_events (
	id			integer,
	ntimes		integer,
	start_date	date not null,
	end_date	date,
	primary key (id),
	foreign key (id) references Events(id)

);

create table Weekly_events(
	id			integer,
	day_of_week	WeekDayType not null,
	frequency	integer not null check (frequency > 0),
	primary key	(id),
	foreign key (id) references Recurring_events(id)
);

create table Monthly_by_day_events (
	id		integer,
	dayOfWeek	WeekDayType not null,
	week_in_month	integer not null check (week_in_month between 1 and 5),
	primary key	(id),
	foreign key (id) references Recurring_events(id)
);

create table Monthly_by_date_events (
	id		integer,
	date_in_month	integer not null check (date_in_month between 1 and 31),
	primary key	(id),
	foreign key (id) references Recurring_events(id)
);

create table Annual_events (
	id		integer,
	date	date not null,
	primary key	(id),
	foreign key (id) references Recurring_events(id)
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
	calendars_id	integer,
	access		AccessibilityType not null,
	primary key	(users_id, calendars_id),
	foreign key (users_id) references Users(id),
	foreign key (calendars_id) references Calendars(id)
);

create table subscribed (
	users_id 	integer,
	calendars_id	integer,
	colour		text,
	primary key	(users_id, calendars_id),
	foreign key (users_id) references Users(id),
	foreign key (calendars_id) references Calendars(id)
);

create table invited(
	users_id	integer,
	event_id	integer,
	status 		InviteStatus not null,
	primary key	(users_id, event_id),
	foreign key (users_id) references Users(id),
	foreign key (event_id) references Calendars(id)
);