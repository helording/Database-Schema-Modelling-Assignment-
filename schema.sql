-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by Harry Lording z5164744

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type VisibilityOptions as enum ('public', 'private');
create type Weekday as enum ('mon','tue', 'wed', 'thu', 'fri', 'sat', 'sun');

-- Tables

create table Users (
	id          serial,
	email       text not null unique, 
	name 		text not null,
	password	text not null,
	is_admin	char(1) check (is_admin in ('y', 'n')) not null,
	primary key (id)
);

create table Groups (
	id          serial,
	name        text not null, 
	owner		integer not null, 
	primary key (id),
	foreign key (owner) references Users(id)
);

create table Calendars (
	id			serial,
	name 		text not null, 
	default_access		AccessibilityType not null default 'none', -- If no privacy preferences is submitted than none they wouldn't want any restriction
	colour		text not null,
	owner		integer not null, 
	primary key (id),
	foreign key (owner) references Users(id)
);

create table Members (
	user_id 	integer,
	group_id	integer, 
	primary key (user_id, group_id),
	foreign key (group_id) references Groups(id),
	foreign key (user_id) references Users(id)
);

create table Accessibilities (
	user_id		integer, 
	calendar_id integer, 
	access		AccessibilityType not null, 
	primary key (user_id, calendar_id),
	foreign key (user_id) references Users(id),
	foreign key (calendar_id) references Calendars(id)
);

create table Subscribed (
	user_id		integer, 
	calendar_id	integer,
	colour 		text,
	primary key (user_id, calendar_id),
	foreign key (user_id) references Users(id),
	foreign key (calendar_id) references Calendars(id)
);

create table Events (
	id			serial,
	created_by 	integer not null,
	part_of		integer not null, 
	title		text not null, 
	location	text,
	visibility 	VisibilityOptions not null default 'private', -- set private automatically to ensure safety
	start_time 	time, 
	end_time 	time check (end_time > start_time),
	primary key (id),
	foreign key (created_by) references Users(id),
	foreign key (part_of) references Calendars(id)
);

create table Alarms (
	event_id 	integer, 
	alarm		integer,
	primary key (event_id, alarm),
	foreign key (event_id) references Events(id)
);

create table One_Day_Events (
	event_id	integer,
	date 		date not null, 
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Spanning_Events(
	event_id	integer,
	start_date	date not null, 
	end_date	date not null check (end_date > start_date),
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Recurring_Events (
	event_id 	integer,
	ntimes		integer,
	start_date	date not null, 
	end_date	date check (end_date > start_date),
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Weekly_Events (
	recurring_event_id 	integer,
	day_of_week			Weekday not null, 
	frequency			integer not null check (frequency between 1 and 4),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Day_Events (
	recurring_event_id 		integer,
	day_of_week				Weekday not null,
	week_in_month			integer not null check (week_in_month between 1 and 5),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Date_Events (
	recurring_event_id		integer,
	date_in_month			integer not null check (date_in_month between 1 and 31),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Annual_Events (
	recurring_event_id 	integer,
	date 				date not null,
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Invites (
	event_id 	integer,
	user_id 	integer,
	status 		InviteStatus not null,
	primary key (event_id, user_id),
	foreign key (event_id) references Events(id),
	foreign key (user_id) references Users(id)
);
