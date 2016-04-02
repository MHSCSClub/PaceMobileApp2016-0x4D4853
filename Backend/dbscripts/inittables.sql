#Create tables

USE pace2016;

CREATE TABLE users
(
	userid int unsigned not null auto_increment primary key,
	usertype int unsigned not null
);

CREATE TABLE caretakers
(
	cid int unsigned not null primary key,
	username char(50),
	password char(64),
	salt char(64)
);

CREATE TABLE patients
(
	pid int unsigned not null primary key,
	name char(50) not null,
	usability int not null
);

CREATE TABLE devices
(
	did int unsigned not null auto_increment primary key,
	userid int unsigned not null unique,
	uiud char(64) not null
);

CREATE TABLE auth
(
	sid int unsigned not null auto_increment primary key,
	userid int unsigned not null,
	authcode char(64),
	expire DATETIME
);

CREATE TABLE relation
(
	rid int unsigned not null auto_increment primary key,
	cid int unsigned not null,
	pid int unsigned not null,
	active BOOL not null
);

CREATE TABLE link
(
	lid int unsigned not null auto_increment primary key,
	cid int unsigned not null,
	pid int unsigned not null,
	lcode char(8) not null,
	open BOOL not null
);

CREATE TABLE medication
(
	medid int unsigned not null auto_increment primary key,
	pid int unsigned not null,
	name char(50) not null,
	dosage int unsigned not null,
	remain int unsigned not null,
	pic MEDIUMBLOB,
	info varchar(800)
);

CREATE TABLE schedule
(
	schid int unsigned not null auto_increment primary key,
	pid int unsigned not null,
	take DATETIME not null,
	UNIQUE index ptuq (pid, take)
);

CREATE TABLE medsche
(
	msid int unsigned not null auto_increment primary key,
	schid int unsigned not null,
	medid int unsigned not null,
	taken DATETIME,
	UNIQUE index smuq (schid, medid)
);