-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by INSERT YOUR NAME HERE

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type ColourType as enum ('red', 'blue', 'green', 'yellow', 'black', 'white');
create type EventType as enum ('one-day', 'spanning', 'recurring');
create type WeekDayType as enum ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');
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
	defalutAccess	AccessibilityType,
	foreign key (owner) references Users(id)
);

create table Event (
	id			serial,
	title		text not null,
	visibility 	text check (visibility in ('public', 'private')),
	startTime	time not null,
	endTime		time not null,
	loacation	text not null,
	property	EventType,
	partOf		integer unique not null,
	createdBy	integer unique not null,
	primary key (id),
	foreign key (createdBy) references Users(id),
	foreign key (partOf) references Calendar(id)
);

create table alarms (
	eventId	integer references Event(id),
	alarmTime	time,
	primary key (eventId, alarmTime)
);

create table OneDayEvent (
	eventId	integer,
	eventDate	date not null,
	primary key (eventId),
	foreign key	(eventId) references Event(id)
);

create table SpanningEvent (
	eventId	integer,
	startDate	date not null,
	endDate	date not null,
	primary key (eventId),
	foreign key (eventId) references Event(id)
);

create table RecurringEvent (
	eventId	integer,
	ntimes		integer not null,
	startDate	date not null,
	endDate	date,
	primary key (eventId),
	foreign key (eventId) references Event(id)

);

create table WeeklyEvent(
	eventId		integer,
	dayOfWeek	WeekDayType,
	frequency	integer not null check (frequency > 0),
	primary key	(eventId),
	foreign key (eventId) references RecurringEvent(eventId)
);

create table MonthByDateEvent(
	eventId		integer,
	dayOfWeek	WeekDayType,
	weekInMonth	integer not null check (weekInMonth between 1 and 5),
	primary key	(eventId),
	foreign key (eventId) references RecurringEvent(eventId)
);

create table MonthByDayEvent (
	eventId		integer,
	dateInMonth	integer not null check (weekInMonth between 1 and 31),
	primary key	(eventId),
	foreign key (eventId) references RecurringEvent(eventId)
);

create table AnnulEvent (
	eventId		integer,
	dateInMonth	date not null,
	primary key	(eventId),
	foreign key (eventId) references RecurringEvent(eventId)
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

create table invited(
	users_id	integer references Users(id),
	event_id	integer references Calendar(id),
	status 		InviteStatus,
	primary key	(users_id, event_id)
);