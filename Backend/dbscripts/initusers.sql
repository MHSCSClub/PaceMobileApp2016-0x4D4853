#Create Users

CREATE USER 'paceadmin'@'localhost' IDENTIFIED BY '123456';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE ON pace2016.* TO 'paceadmin'@'localhost';
