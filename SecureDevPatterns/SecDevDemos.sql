use master

if exists (select * from sys.databases where name='secure')
BEGIN
alter database secure set single_user with rollback immediate
drop database secure
END
GO


create database secure
go

use secure
go

--sql injection example

select * from sys.all_objects where name='$input'

$input="TABLE_PRIVILEGES"
select * from sys.all_objects where name='TABLE_PRIVILEGES'

$input="TABLE_PRIVILEGES' or 1='1"
select * from sys.all_objects where name='TABLE_PRIVILEGES' or 1='1'

create table TopSecret(
	id int  identity,
	FirstName varchar(50),
	SurName varchar(50),
	CreditCard char(16),
	Salary int
)

insert into TopSecret Values ('Alice','Smith','1234567890123456','10000')
insert into TopSecret Values ('Bob','Jones','6543210987654321','10000')
insert into TopSecret Values ('Carol','Grant','1029384756102938','10000')
insert into TopSecret Values ('Dave','Pays','5647382910473829','20000')

select * from TopSecret;

-- create user for demos
create login [normal] with password= 'P@ssw0rd';
create user normal for login normal
go
sp_addrolemember 'db_datareader','normal'


create login [Cardadmin] with password='P@ssw0rd';
create user Cardadmin for login CardAdmin
go
sp_addrolemember 'db_datareader','cardadmin'

--Not best practice below, this inherits dbo rights.
create role CardUsers authorization dbo
go
sp_addrolemember 'CardUsers','cardadmin'

--Create a new user/schema to own the new SQL Server role - This is the way
create user SecureOwner without login
create role SecureCardUsers authorization SecureOwner
go

-- add cardadmin to the new role
sp_addrolemember 'SecureCardUsers','cardadmin'
GO

-- remove cardadmin from the old role
sp_droprolemember 'CardUsers','cardadmin'

select * from topsecret
go

-- use view to return different data to different roles
create view GetSecrets
as
select 
	FirstName,
	SurName,
	case 
		when IS_ROLEMEMBER('SecureCardUsers') = 1 then CreditCard
		else stuff(CreditCard,1,12,'xxxxxxxxxxxx')
	end as 'CreditCard'
from	
	TopSecret
GO

--try as normal user
execute as user='normal'
select * from GetSecrets
revert

--try as card admin
execute as user='CardAdmin'
select * from GetSecrets
revert

--all good except
execute as user='normal'
select * from TopSecret
revert
--Oops, should not be able to query the underlying table

sp_droprolemember 'db_datareader','normal'
--Now user permission chaining in affect. Normal has no 'rights' on TopSecret, but the rights on GetSecrets give an ownership chain

grant select on GetSecrets to normal
execute as user='normal'
select * from GetSecrets
select * from TopSecret
revert

--What we wanted!

--Data Masking

create table Masking(
	id int  identity,
	FirstName varchar(50),
	SurName varchar(50),
	Email varchar(50) MASKED WITH (FUNCTION = 'email()'),
	CreditCard char(16) MASKED WITH (FUNCTION = 'partial(0,"XXXXXXXXXXXX",4)'),
	Salary int MASKED WITH (FUNCTION = 'default()')
)

insert into Masking Values ('Alice','Smith','alice.smith@email.com','1234567890123456','10000')
insert into Masking Values ('Bob','Jones','rob@outlook2000.com','6543210987654321','10000')
insert into Masking Values ('Carol','Grant','carolgrant@email.com','1029384756102938','10000')
insert into Masking Values ('Dave','Pays','dave.pays@gmailclone.com','5647382910473829','20000')

select * from Masking;

grant select on Masking to normal

execute as user='normal'
select * from Masking
revert

-- Add salary masking to our to
Alter table TopSecret alter column salary int MASKED WITH (FUNCTION = 'default()');

execute as user='CardAdmin'
select * from TopSecret
select * from TopSecret order by Salary desc
revert

--Allows inference of data, we now know Dave is paid more than everyone else
execute as user='CardAdmin'
select * from TopSecret where Salary> 5000
select * from TopSecret Where Salary > 10000
select * from TopSecret where Salary > 15000
select * from TopSecret where Salary > 20000
revert
go

-- use a view to simulate masking and stop inference leakage

create view GetSalary
as
select 
	FirstName,
	SurName,
	case 
		when IS_ROLEMEMBER('SecureCardUsers') = 1 then Salary
		else 0
	end as 'Salary'
from	
	TopSecret
GO

grant select on GetSalary to normal
go

execute as user='normal'
select * from GetSalary 
select * from GetSalary where Salary> 5000
select * from GetSalary Where Salary > 10000
select * from GetSalary where Salary > 15000
select * from GetSalary where Salary > 20000
revert
go

-- use stored procs to audit usage

create procedure sp_carddata
as
select * from GetSecrets
GO

grant execute on sp_carddata to normal;
grant execute on sp_carddata to cardadmin;


execute as user='normal'
exec sp_carddata
revert

execute as user='Cardadmin'
exec sp_carddata
revert

create table secureaudit (
id int identity,
who varchar(50) DEFAULT USER,
what varchar(50),
datestamp datetime default (getdate())
)
go

alter procedure sp_carddata
as
select * from GetSecrets
insert into secureaudit (what) values ('GetSecrets')
GO

execute as user='normal'
exec sp_carddata
revert

execute as user='Cardadmin'
exec sp_carddata
revert

select * from secureaudit



--Clean up post demos
use master
go

drop database secure
go

drop login CardAdmin
drop login normal

