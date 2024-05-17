GRANT ALL PRIVILEGES
ON TABLE Student
TO U1
WITH GRANT OPTION;

GRANT SELECT,UPDATE(Sex)
ON TABLE Student
TO U2;
-- 定义职工关系模式
CREATE TABLE 职工 (
    职工号 INT PRIMARY KEY,
    姓名 VARCHAR(50),
    年龄 INT,
    职务 VARCHAR(50),
    工资 DECIMAL(10, 2),
    部门号 INT,
    CONSTRAINT FK_部门号 FOREIGN KEY (部门号) REFERENCES demp (部门号),
    CONSTRAINT CK_年龄 CHECK (年龄 <= 65)
);

-- 定义部门关系模式
CREATE TABLE 部门 (
    部门号 INT PRIMARY KEY,
    名称 VARCHAR(50),
    经理姓名 VARCHAR(50),
    电话 VARCHAR(20)
);
-- 插入部门数据
INSERT INTO demp (部门号, 名称, 经理姓名, 电话) VALUES
(1, '人力资源部', '张三', '1234567890'),
(2, '财务部', '李四', '2345678901'),
(3, '技术部', '王五', '3456789012');

-- 插入职工数据
INSERT INTO EMP (职工号, 姓名, 年龄, 职务, 工资, 部门号) VALUES
(1, '赵六', 30, '工程师', 8000.00, 3), -- 技术部
(2, '孙七', 28, '助理', 5000.00, 1), -- 人力资源部
(3, '周八', 35, '财务经理', 10000.00, 2), -- 财务部
(4, '吴九', 25, '实习生', 3000.00, 3); -- 技术部

GRANT INSERT
ON TABLE EMP
TO '王明';

GRANT SELECT
ON TABLE EMP
WHEN USER()=NAME
TO ALL;
USE student_course;
CREATE TABLE SC_U (
    Sno CHAR(9),
    Cno INT,
    Oldgrade INT,
    Newgrade INT
);
CREATE TRIGGER update_grade_trigger
AFTER UPDATE ON SC
FOR EACH ROW
BEGIN
    IF OLD.Grade != NEW.Grade THEN
        INSERT INTO SC_U (Sno, Cno, Oldgrade, Newgrade)
        VALUES (OLD.Sno, OLD.Cno, OLD.Grade, NEW.Grade);
    END IF;
END;

-- 修改学号为201215121的学生在课程编号为1的课程的成绩为95
UPDATE sc
SET Grade = 95
WHERE Sno = '201215121' AND Cno = 1;
SELECT * FROM SC_U;


CREATE TABLE `Student-InsertLog` (
    InsertTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    InsertedStudentsCount INT
);

drop trigger student_insert_trigger;
DELIMITER //

CREATE TRIGGER student_insert_trigger
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    -- 假设每次插入只增加一个学生
    SET @inserted_count = 1;

    -- 插入新的记录到Student-InsertLog表中，假设Student-InsertLog有一个名为InsertTime的字段来记录时间
    INSERT INTO `Student-InsertLog` (InsertedStudentsCount, InsertTime) VALUES (@inserted_count, NOW());
END;
//
DELIMITER ;


-- 向student表中插入一条新的记录
INSERT INTO student (Sno, Sname, Sex, Sage, Sdept)
VALUES ('201215127', '赵一', '男', 20, 'CS');
SELECT * FROM `Student-InsertLog`;



CREATE TRIGGER check_credit_trigger
BEFORE INSERT ON course
FOR EACH ROW
BEGIN
    IF NEW.Ccredit > 5 THEN
        SET NEW.Ccredit = 5;
    END IF;
END;
-- 尝试插入一条学分为6的课程记录
INSERT INTO course (Cno, Cname, Cpno, Ccredit)
VALUES (7, '高级数据库', NULL, 6);
SELECT * FROM course WHERE Cno = 7;
