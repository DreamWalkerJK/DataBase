-- 一、查询数据库引擎
show engines;
show variables like '%storage_engine%';
-- 指定数据库对象的存储引擎
drop table if exists test;
create table test
(
	id int(5) auto_increment,
	name varchar(20),
	primary key(id)
)engine=MEMORY auto_increment=1 default charset=utf8;

-- 二、索引
-- 不适用情况：少量数据、频繁改动的字段、很少使用的字段
-- 会提高数据查询效率，降低IO和CPU使用率，但会降低增删改的效率
-- 分类：单值索引、唯一索引、复合索引
drop table if exists test;
create table test
(
	id int(4) not null auto_increment,
	workno varchar(6) not null,
	name varchar(20),
	dept varchar(4),
	primary key(id)
)engine=innodb auto_increment=1 charset=utf8;
-- 查询表结构
desc test;

-- create 创建索引
-- 创建单值索引
create index index_dept on test(dept);
-- 创建唯一索引
create unique index index_workno on test(workno);
-- 创建复合索引
create index index_dept_name on test(dept,name);
-- 查看表索引
show index from test;
-- delete 删除索引
drop index index_dept on test;
drop index index_workno on test;
drop index index_dept_name on test;

-- alter table 创建索引
-- 创建单值索引
alter table test add index index_dept(dept);
-- 创建唯一索引
alter table test add unique index index_workno(workno);
-- 创建复合索引
alter table test add index index_dept_name(dept,name);
show index from test;
-- alter table 删除索引
alter table test drop index index_dept;
alter table test drop index index_workno;
alter table test drop index index_dept_name;

-- 如果某个字段是primary key，则默认为主键索引，主键索引和唯一索引列中的数据都不能有相同值，但唯一索引可以为null值，主键索引不可以

-- 三、SQL性能
-- 人为优化：采用explain分析SQL的执行计划
-- 自动优化：SQL优化器

-- 查看执行计划
explain select * from test;
-- id:编号
-- select_type:查询类型
-- table:表
-- type:索引类型
-- possible_key:预测会用到的索引
-- key:实际使用的索引
-- key_len:实际使用的索引长度
-- ref:表之间的引用
-- rows:通过索引查询到的数据量
-- extra:额外的信息

-- id:编号
insert into teacher(Tid, Tname, TGender, Tage)
values
('T_1001', '张三','male', 25),
('T_1002', '李四','female', 30),
('T_1003', '王五','male', 28);

explain
	select s.*
	from student s, class c, teacher t
	where s.ClassId = c.CId and c.TeacherId = t.Tid
	and (c.CId = 'c_1004' or t.Tid = 'T_1001');

insert into teacher(Tid, Tname, TGender, Tage)
values
('T_1004', '赵六','male', 40),
('T_1005', '陈真','female', 45),
('T_1006', '贾假','male', 50),
('T_1007','路人甲','female',39);

explain
	select s.*
	from student s, class c, teacher t
	where s.ClassId = c.CId and c.TeacherId = t.Tid
	and (c.CId = 'c_1004' or t.Tid = 'T_1001');
--  id值相同，从上往下顺序执行，表的执行顺序会因表数据量而改变的原因是笛卡尔积
-- 	2*3*4=6*4=24 4*3*2=12*2=24 虽然结果一致，但是第一种方式临时数据是6，第二种方式是12，对于内存来说数据量越小越好，因此优化器会选择第一种方式

explain 
	select t.tname from teacher t
	where t.tid = 
	(
		select c.teacherid from class c
		where c.cid = 
		(
			select s.classid from student s where s.sname='xiyangyang'
		)
	);
-- id值不同，id值越大越优先查询，进行嵌套子查询时，先查内层再外层
-- 修改
explain 
	select c.CName,t.tname from class c, teacher t
	where c.TeacherId=t.Tid 
	and c.CId = 
	(
		select s.classid from student s where s.sname='xiyangyang'
	);
-- 	id值相同又不相同，id值越大越优先，id值相同从上至下顺序执行

-- select_type:查询类型
-- simple:简单查询，不包含子查询和union查询
explain select * from test;
-- primary:包含子查询的主查询（最外层）
-- subquery:包含子查询的著查询（非最外层）
-- derived:衍生查询（用到了临时表）
-- from子查询中只有一张表
-- from子查询中，如果tableA union tableB，则tableA就是derived表
explain 
	select s.sname
	from 
	(
		select * from student where sid='s_1003'
		union 
		select * from student where sid='s_1004'
	) s;
-- union:union之后的表为union表
-- union result:说明哪些表使用了union查询

-- type:索引类型