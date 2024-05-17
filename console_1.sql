create database s1;
drop database s1;
use student_course;
CREATE UNIQUE INDEX Stusno ON Student(Sno);
CREATE UNIQUE INDEX Coucno ON course(Cno);
CREATE UNIQUE INDEX SCno ON SC(Sno ASC,Cno DESC );

DROP INDEX Stusno ON student;
/*比较*/
SELECT Sname,Sage
from student
where Sage<20;
/*范围*/
select Sname,Sdept,Sage
from student
where  Sage between 20 and 23;
/*集合*/
select Sname,Sex
from student
where Sdept not in ('CS','MA','IS');
/*聚集函数*/
select count(*)
from student;
/*匹配*/
select *
from student
where Sno like '201215121';
/*空值*/
select Sno,Cno
from sc
where Grade is null;
/*排序*/
select *
from student
order by Sage DESC;
/*分组*/
select Cno,count(Sno)
from sc
group by Cno;
/*自然*/
select student.sno,Sname,Sex,Sage,Sdept,Cno,Grade
from student,sc
where student.Sno=sc.Sno;
/*自身*/
select first.cno,second.cpno
from course first,course second
where first.Cpno=second.Cno;
/*外*/
select student.sno,Sname,Sex,Sage,Sdept,Cno,Grade
from student left outer join sc s on student.Sno = s.Sno;
/*嵌套*/
select sno,Sname,Sdept
from student
where Sdept in
(
    select Sdept
    from student
    where Sname='刘晨'
    );
/*相关*/
select Sno,Cno
from sc x
where Grade >= (
    select avg(Grade)
    from sc y
    where y.Sno=x.Sno
    );
/*exist*/
select Sname
from student
where exists(
    select *
    from sc
    where sc.Sno=student.Sno and Cno='1'
          );