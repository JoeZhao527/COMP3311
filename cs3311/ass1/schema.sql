-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by INSERT YOUR NAME HERE

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type ColourType as enum ('red', 'blue', 'green', 'yellow', 'black', 'white');
create type EventType as enum ('one-day', 'spanning', 'recurring');
-- add more types/domains if you want

-- Tables

create table Users (
	id          serial,
	email       text not null unique,
	passwd		text not null,
	is_admin	boolean,
	primary key (id)
);

create table Groups (
	id          serial,
	name        text not null,
	owner		int,
	foreign key (owner) references Users(id),
	primary key (id)
);


create table Calendar (
	id		serial,
	name	text not null,
	owner	int,
	colour	ColourType,
	default_access	AccessibilityType,
	foreign key (owner) references Users(id)
);

create table Event (
	id			serial,
	title		text not null,
	visibility 	text check (visibility in ('public', 'private')),
	start_time	time not null,
	end_time	time not null,
	loacation	text not null,
	event_type	EventType,
	primary key (id)
)

create table alarms (
	event_id	integer references Event(id),
	alarm_time	time,
	primary key (event_id, alarm_time)
);

-- relationships

create table Member (
	users_id 	integer references Users(id),
	groups_id	integer references Groups(id),
	primary key	(users_id, groups_id)
);

create table Accessibility (
	users_id 	integer references Users(id),
	calendar_id	integer references Calendar(id),
	access		AccessibilityType,
	primary key	(users_id, calendar_id)
);

create table subscribed (
	users_id 	integer references Users(id),
	calendar_id	integer references Calendar(id),
	colour		ColourType,
	primary key	(users_id, calendar_id)
);
