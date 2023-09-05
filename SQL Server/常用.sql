use Test;

-- 1.��ת�� PIVOT
create table sales(
	id int,
	name varchar(20),
	quarter int,
	number int
);

insert into sales values(1,N'ƻ��',1,1000);
insert into sales values(1,N'ƻ��',2,2000);
insert into sales values(1,N'ƻ��',3,4000);
insert into sales values(1,N'ƻ��',4,5000);
insert into sales values(2,N'����',1,3000);
insert into sales values(2,N'����',2,3500);
insert into sales values(2,N'����',3,4200);
insert into sales values(2,N'����',4,5500);

select * from sales;

select Id, Name,
[1] as 'һ����',
[2] as '������',
[3] as '������',
[4] as '�ļ���'
from sales
pivot
(
	sum(number) for quarter in ([1],[2],[3],[4])
) as pvt;

-- 2.��ת�� ͨ��
-- �������ݱ��һ���������ݣ�������
select id, name,
	sum(case when quarter=1 then number else 0 end) 'һ����',
	sum(case when quarter=2 then number else 0 end) '������',
	sum(case when quarter=3 then number else 0 end) '������',
	sum(case when quarter=4 then number else 0 end) '�ļ���'
from sales
group by id, name

create table salesTotal
(
	id int,
	name varchar(20),
	Q1 int,
	Q2 int,
	Q3 int,
	Q4 int
);

insert into salesTotal
select Id, name,
[1] as 'Q1',
[2] as 'Q2',
[3] as 'Q3',
[4] as 'Q4'
from sales
pivot
(
	sum(number) for quarter in ([1],[2],[3],[4])
) as pvt;

select * from salesTotal;

-- 3.��ת�� UNPIVOT
select id,name,quarter,number
from salesTotal
unpivot
(
	number for quarter in ([Q1],[Q2],[Q3],[Q4])
) as unpvt;

-- 4.�ַ����滻 substring/replace
select replace ('abcdef', SUBSTRING('abcdefg', 2,4), '**');

-- 5.�������� ROUND ����
-- ����С�������λ����Ҫ��������
select ROUND(150.45648 ,2);

-- ����С�������λ��0ΪĬ��ֵ����ʾ������������
select ROUND(150.45648, 2, 0);

-- ����С�������λ������Ҫ��������
select ROUND(150.45648, 2, 1);  -- ���һλ��������Ϊ0���������ֶ���һ����Ч��

-- ����С�������λ������Ҫ��������
select ROUND(150.45648, 2, 2);

-- 6.COALESCE�� ����������еĵ�һ���ǿձ��ʽ
select coalesce(null, null, 1, 2, 3);
select coalesce(null, 3, 2, 1, null);

-- 7.COUNT
select count(*) from salesTotal;
select count(id) from salesTotal;
select count(1) from salesTotal;

-- 8.�鿴���ݿ⻺���SQL
use master;
declare @dbid int
select @dbid=dbid from sysdatabases where name='bookdb_pre';

select dbid,usecounts,refcounts,cacheobjtype,objtype,
db_name(dbid) as databaseName, SQL
from syscacheobjects
where dbid=@dbid
order by dbid,usecounts desc, objtype;

-- 9.ɾ���ƻ�����
-- ɾ���������ݿ�ļƻ�����
DBCC FREEPROCCACHE

-- ɾ��ĳ�����ݿ�ļƻ�����
use master;
declare @dbid1 int
select @dbid1=dbid from sysdatabases where name='bookdb_pre'
DBCC FLUSHPROCINDB(@dbid1)

-- 10.SQL����
--�Ʊ�� CHAR(9)
--���з� CHAR(10)
--�س� CHAR(13)

-- ���ı���ʽ��ʾ�������select
print 'SQL'+char(13)+'ENTER'

-- 11.TRUNCATE��DELETE
-- truncate �ٶȿ졢Ч�ʸ�
-- truncate �� delete �ٶȿ죬��ʹ�õ�ϵͳ��������־��Դ��
-- delete ÿɾһ�У�����������־��Ϊ��ɾ����ÿ�м�¼һ�
-- truncateͨ���ͷŴ洢���������õ�����ҳ��ɾ�����ݣ�����ֻ��������־�м�¼ҳ���ͷš�
-- truncate ɾ�������У�����ṹ���С�Լ���������ȱ��ֲ��䣬��ʶ����ֵ���á�
-- delete ������ʶ����ֵ
-- truncate ����ʹ����foreign key Լ�����õı�truncate ����¼����־�У����Բ��ܼ��������Ҳ�������ڲ�����������ͼ�ı�
use Test;
TRUNCATE table sales; 
delete from salesTotal;

-- 12.����ϵͳ���ű�
-- �鿴�ڴ�״̬
dbcc memorystatus;

-- �鿴�ĸ������������ blk
exec sp_who active;

-- �鿴��ס���ĸ���Դid, objid
exec sp_lock;

-- 13.��ȡ�ű���ִ��ʱ��
declare @timediff datetime;
select @timediff=getdate();
use BookDB_Pre;
select * from book;
print 'total cost time: ' + convert(varchar(10), datediff(ms, @timediff, getdate()))