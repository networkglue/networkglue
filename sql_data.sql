\c ng

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',2,'Users','dynamic: name','0', '0', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',3,'Users','dynamic: name', '0', '0', '1');

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: enabled',3,'Users','dynamic: enabled','1', '0', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: enablepassword',3,'Users','dynamic: enablepassword','1', '0', '1');

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: dateexceedsenabled',3,'Users','dynamic: expirydateenabled','1', '0', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: dateexceeds',3,'Users','dynamic: expirydate','1', '0', '1');

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','static: identitygroupname "All Groups:Technicians"',2,'Users', 'static: groups "Technicians"','1', '1', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','static: identitygroupname "All Groups:Engineers"',2,'Users', 'static: groups "Engineers"','1', '1', '1');

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','static: identitygroupname "All Groups:Technicians"',3,'InternalUsers', 'static: identitygroups "Technicians"','1', '1', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','static: identitygroupname "All Groups:Engineers"',3,'InternalUsers', 'static: identitygroups "Engineers"','1', '1', '1');


insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',3,'InternalUsers','dynamic: firstname "Empty"','1', '0', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',3,'InternalUsers','dynamic: lastname "Empty"','1', '0', '1');
insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',3,'InternalUsers','dynamic: email "noemail"','1', '0', '1');

insert into mappings(source_ds, source_table, source_field, destination_ds, destination_table, destination_field, overwriteflag, appendflag, createflag) values (1,'Users','dynamic: name',2,'Users','dynamic: external "1"','1', '0', '1');


insert into ds_types (id, shortname, name) values (1, 'ACS', 'Cisco ACS 5.x');
insert into ds_types (id, shortname, name) values (2, 'Intermapper', 'HelpSystems Intermapper 5.x/6.x');
insert into ds_types (id, shortname, name) values (3, 'ISE', 'Cisco ISE 2.x');
insert into ds_types(id,shortname,name) values (4,'HPNA','HP Network Automation 10.x');

insert into ds_tables (id, type, coretable, name, tablepk) values (1, 1, 'accounts', 'users', 'name');
insert into ds_tables (id, type, coretable, name, tablepk) values (2, 2, 'accounts', 'users', 'name');
insert into ds_tables (id, type, coretable, name, tablepk) values (3, 3, 'accounts', 'internalusers', 'name');

insert into ds_tables (id, type, coretable, name, tablepk) values (4, 1, 'accountgroups', 'identitygroupname', 'name');
insert into ds_tables (id, type, coretable, name, tablepk) values (5, 2, 'accountgroups', '*', 'name');
insert into ds_tables (id, type, coretable, name, tablepk) values (6, 3, 'accountgroups', 'identitygroups', 'name');
