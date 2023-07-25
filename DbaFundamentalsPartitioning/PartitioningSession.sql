--create database
USE [master]
GO

drop database [partition]
go


CREATE DATABASE [partition]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'partition', FILENAME = N'F:\data\partition.mdf' , SIZE = 663552KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ) 
 LOG ON 
( NAME = N'partition_log', FILENAME = N'G:\log\partition_log.ldf' , SIZE = 3284992KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

use partition

--create a numbers table

CREATE TABLE [dbo].[numbers](
	[number] [int] NULL
) ON [PRIMARY]
GO

INSERT INTO numbers(number) SELECT TOP 100000000 row_number() over(order by t1.number) as N
FROM master..spt_values t1 
    CROSS JOIN master..spt_values t2

--create a normal flat table
CREATE TABLE [dbo].[flat_table](
	[date] [datetime] NULL,
	[number] [int] NULL
) ON [PRIMARY]
GO

--create a clustered indexed table
CREATE TABLE [dbo].[clustered_table](
	[date] [datetime] NULL,
	[number] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ClusteredIndex-date] ON [dbo].[clustered_table]
(
	[date] ASC
)
GO



--create a partition function
--Right aligned partitions better for date/time
CREATE PARTITION FUNCTION [tablePartitionFunc](datetime) AS 
RANGE RIGHT FOR VALUES (N'2014-01-01T00:00:00.000', N'2017-01-01T00:00:00.000', N'2020-01-01T00:00:00.000', N'2023-01-01T00:00:00.000')
GO 

--create partition schema
CREATE PARTITION SCHEME [tablePartitionSchema] as PARTITION [tablePartitionFunc] ALL TO ('primary')

--create a partitioned table
CREATE TABLE [dbo].[partitioned_table](
	[date] [datetime] PRIMARY KEY,
	[number] [int] NULL
) ON tablePartitionSchema(date)
GO

--create a partitioned table acros multiple files

--add new files and filegroups:
ALTER DATABASE Partition ADD FILEGROUP [fg_yearspre2011] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_pre2011',FILENAME = N'f:\data\Partitionpre2011.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_yearspre2011]  
ALTER DATABASE Partition ADD FILEGROUP [fg_years2011] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_2011',FILENAME = N'f:\data\Partition2011.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_years2011]  
ALTER DATABASE Partition ADD FILEGROUP [fg_years2014] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_2014',FILENAME = N'f:\data\Partition2014.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_years2014]  
ALTER DATABASE Partition ADD FILEGROUP [fg_years2017] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_2017',FILENAME = N'f:\data\Partition2017.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_years2017]  
ALTER DATABASE Partition ADD FILEGROUP [fg_years2020] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_2020',FILENAME = N'f:\data\Partition2020.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_years2020]  
ALTER DATABASE Partition ADD FILEGROUP [fg_years2023] 
ALTER DATABASE Partition ADD FILE (NAME = N'Partition_2023',FILENAME = N'f:\data\Partition2023.ndf', SIZE = 30MB, MAXSIZE = 10000MB, FILEGROWTH = 30MB) TO FILEGROUP [fg_years2023]  


CREATE PARTITION FUNCTION [filePartitionFunc](datetime) AS 
RANGE RIGHT FOR VALUES (N'2011-01-01T00:00:00',N'2014-01-01T00:00:00.000', N'2017-01-01T00:00:00.000', N'2020-01-01T00:00:00.000', N'2023-01-01T00:00:00.000')
GO

--Example of creating one for every day for the next 3 years:
DECLARE @DatePartitionFunction nvarchar(max) = 
    N'CREATE PARTITION FUNCTION DatePartitionFunction (datetime) 
    AS RANGE RIGHT FOR VALUES (';  
DECLARE @i datetime2 = '2023-07-23T00:00:00.000';  
WHILE @i < '2026-07-23T00:00:00.000'  
BEGIN  
SET @DatePartitionFunction += '''' + CAST(@i as nvarchar(10)) + '''' + N', ';  
SET @i = DATEADD(DY, 1, @i);  
END  
SET @DatePartitionFunction += '''' + CAST(@i as nvarchar(10))+ '''' + N');';  
print @DatePartitionFunction
--enable the next line to actually create it.
--EXEC sp_executesql @DatePartitionFunction;  
GO  

CREATE PARTITION SCHEME [filePartitionSchema] as PARTITION [filePartitionFunc] TO (fg_yearspre2011,fg_years2011,fg_years2014, fg_years2017, fg_years2020, fg_years2023)

CREATE TABLE [dbo].[filepartition_table](
	[date] [datetime]  PRIMARY KEY,
	[number] [int] NULL
) ON filePartitionSchema(date)
GO
--insert data into tables

truncate table flat_table
truncate table clustered_table
truncate table partitioned_table
truncate table filepartition_table

insert into flat_table (date, number) select dateadd(minute,number, '2011-03-01 00:00:01'), number from numbers;
insert into clustered_table (date, number) select dateadd(minute,number, '2011-03-01 00:00:01'), number from numbers;
insert into partitioned_table (date, number) select dateadd(minute,number, '2011-03-01 00:00:01'), number from numbers;
insert into filepartition_table (date, number) select dateadd(minute,number, '2011-03-01 00:00:01'), number from numbers;

--single row query
select * from flat_table where date ='2018-12-12 03:14:01.000' 
select * from clustered_table where date ='2018-07-18 17:04:01.000'
select * from partitioned_table where date ='2018-12-12 03:14:01.000'
select * from filepartition_table where date ='2018-12-12 03:14:01.000'

--range query in single partition
select * from flat_table where date between '2017-12-12 03:14:01.000' and '2018-09-12 03:14:01.000'
select * from clustered_table where date between '2017-07-18 17:04:01.000' and '2018-09-12 03:14:01.000'
select * from partitioned_table where date between '2017-12-12 03:14:01.000' and '2018-09-12 03:14:01.000'
select * from filepartition_table where date between '2017-12-12 03:14:01.000' and '2018-09-12 03:14:01.000'

--range query across multiple partition
select * from flat_table where date between '2019-12-12 03:14:01.000' and '2020-09-12 03:14:01.000'
select * from clustered_table where date between '2019-07-18 17:04:01.000' and '2020-09-12 03:14:01.000'
select * from partitioned_table where date between '2019-12-12 03:14:01.000' and '2020-09-12 03:14:01.000'
select * from filepartition_table where date between '2019-12-12 03:14:01.000' and '2020-09-12 03:14:01.000'

--Partition Switching examples

--Create table switch existing partition to
CREATE TABLE [dbo].[holding_table](
	[date] [datetime] PRIMARY KEY,
	[number] [int] NULL
) on [fg_years2017] 
GO


insert into incoming_table (date, number) select dateadd(minute,number, '2017-03-01 00:00:01'), '5' from numbers where number<1000;

select * from incoming_table;

--switch out current partition
select * from holding_table;
alter table filepartition_table switch partition 4 to holding_table;
select * from holding_table;
--check the partitioned table
select * from filepartition_table where Date between '2017-01-01T00:00:00.000' and '2020-01-01T00:00:00.000'

--this will fail:
alter table holding_table switch to filepartition_table partition 4
--must explicitly provide the constraint/check
alter table holding_table add constraint check_holding check (Date>'2017-01-01T00:00:00.000' and date<'2020-01-01T00:00:00.000')
--will now work:
alter table holding_table switch to filepartition_table partition 4
select count(1) from filepartition_table where Date between '2017-01-01T00:00:00.000' and '2020-01-01T00:00:00.000'

--Create table to switch in to filepartition_table
drop table incoming_table
CREATE TABLE [dbo].[incoming_table](
	[date] [datetime] PRIMARY KEY,
	[number] [int] NULL,
	CONSTRAINT incomingdate CHECK (date>='2017-01-01T00:00:00.000' and date<'2020-01-01T00:00:00.000')
) on [fg_years2017] 
GO

--create a back up  of the original partition
drop table holding_table;
CREATE TABLE [dbo].[holding_table](
	[date] [datetime] PRIMARY KEY,
	[number] [int] NULL,
	CONSTRAINT holdingdate CHECK (date>='2017-01-01T00:00:00.000' and date<'2020-01-01T00:00:00.000')
) on [fg_years2017] 
GO
--create a 6512704 row table from our overnight processing
--select datediff(second, '2017-01-01 00:00:01', '2018-01-01 00:00:01') gives 31536000
insert into incoming_table (date, number) select dateadd(second,number, '2017-01-01 00:00:01'), number from numbers where number<31536000;

--take a backup of the incoming data
alter table filepartition_table switch partition 4 to holding_table;
select * from holding_table;
--switch in new data
alter table incoming_table switch to filepartition_table partition 4 ;
select * from filepartition_table where date between '2017-01-01 00:00:01' and '2017-01-01 00:05:01'
--oops, wrong data, swap back over
alter table  filepartition_table switch partition 4 to incoming_table;
alter table holding_table switch to filepartition_table partition 4 ;


--you can see what is in each partition directly if needed. This is handy if you're not 100% which partition holds what datae
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=0  
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=1  
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=2
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=3
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=4
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=5
select min(date), max(date) from filepartition_table where $PARTITION.filePartitionFunc(date)=6

-- you can use a specific value to see what partition it's in
select $PARTITION.filePartitionFunc ('2020-09-12T00:00:00')


--Get a count of rows in each partition
SELECT 
	$PARTITION.filePartitionFunc([date]) AS Partition,   
	COUNT(1) AS [COUNT] 
FROM dbo.filePartition_Table
GROUP BY $PARTITION.filePartitionFunc([date])  
ORDER BY Partition ;  
GO  


