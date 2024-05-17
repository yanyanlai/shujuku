DELIMITER //

CREATE PROCEDURE compGPA(
    IN inSno CHAR(10),    -- 输入参数：学生学号
    OUT outGPA FLOAT      -- 输出参数：平均学分绩点
)
BEGIN
    DECLARE courseGPA FLOAT;    -- 课程绩点
    DECLARE totalGPA FLOAT;     -- 总绩点
    DECLARE totalCredit INT;    -- 总学分
    DECLARE grade INT;          -- 学生成绩
    DECLARE credit INT;         -- 课程学分

    DECLARE done INT DEFAULT 0; -- 用于循环的标志变量
    DECLARE mycursor CURSOR FOR
        SELECT Course.Ccredit, SC.grade
        FROM SC
        INNER JOIN Course ON SC.Cno = Course.Cno
        WHERE SC.Sno = inSno;   -- 查询指定学生的课程学分和成绩

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1; -- 当游标到达末尾时设置done标志

    SET totalGPA = 0;    -- 初始化总绩点
    SET totalCredit = 0; -- 初始化总学分

    OPEN mycursor;       -- 打开游标

    GPA_loop: LOOP
        FETCH mycursor INTO credit, grade; -- 从游标中获取数据
        IF done THEN
            LEAVE GPA_loop;    -- 如果游标到达末尾，跳出循环
        END IF;

        IF grade BETWEEN 90 AND 100 THEN
            SET courseGPA := 4.0;
        ELSEIF grade BETWEEN 80 AND 89 THEN
            SET courseGPA := 3.0;
        ELSEIF grade BETWEEN 70 AND 72 THEN
            SET courseGPA := 2.0;
        ELSEIF grade BETWEEN 60 AND 69 THEN
            SET courseGPA := 1.0;
        ELSE
            SET courseGPA := 0;
        END IF;

        SET totalGPA := totalGPA + courseGPA * credit; -- 计算总绩点
        SET totalCredit := totalCredit + credit;        -- 计算总学分
    END LOOP;

    CLOSE mycursor; -- 关闭游标

    IF totalCredit > 0 THEN
        SET outGPA := totalGPA / totalCredit; -- 计算平均学分绩点
    ELSE
        SET outGPA := 0; -- 如果总学分为0，则平均绩点为0
    END IF;
END //

DELIMITER ;


SET @student_id = '201215121'; -- 设置学生学号
CALL compGPA(@student_id, @outGPA); -- 调用存储过程并传入学生学号，结果存储在@outGPA变量中
SELECT @outGPA; -- 查看结果


create table Lisan(
    Score_lisan char(20),
	Count_lisan int	);


insert into Course values('8','离散数学',NULL,4)
insert into SC values('201215123','8',78);
insert into SC values('201215125','8',82);

select * from Course ;
select * from SC where Cno='8';

-- 创建存储过程来计算成绩分布
DELIMITER //


insert into SC values('201215121','8',45);
insert into SC values('201215122','8',65);CREATE PROCEDURE Grade_add()
BEGIN
    DECLARE less60 INT DEFAULT 0;
    DECLARE sixty_to_seventy INT DEFAULT 0;
    DECLARE seventy_to_eighty INT DEFAULT 0;
    DECLARE eighty_to_ninety INT DEFAULT 0;
    DECLARE ninety_to_hundred INT DEFAULT 0;

    SELECT COUNT(*) INTO less60
    FROM SC
    WHERE sc.Grade <= 60 AND Cno = 8;

    SELECT COUNT(*) INTO sixty_to_seventy
    FROM SC
    WHERE sc.Grade > 60 AND sc.Grade <= 70 AND Cno = 8;

    SELECT COUNT(*) INTO seventy_to_eighty
    FROM SC
    WHERE sc.Grade > 70 AND sc.Grade <= 80 AND Cno = 8;

    SELECT COUNT(*) INTO eighty_to_ninety
    FROM SC
    WHERE sc.Grade > 80 AND sc.Grade <= 90 AND Cno = 8;

    SELECT COUNT(*) INTO ninety_to_hundred
    FROM SC
    WHERE sc.Grade > 90 AND sc.Grade <= 100 AND Cno = 8;

    -- 插入到Lisan表中
    INSERT INTO Lisan VALUES('<=60', less60);
    INSERT INTO Lisan VALUES('60~70', sixty_to_seventy);
    INSERT INTO Lisan VALUES('70~80', seventy_to_eighty);
    INSERT INTO Lisan VALUES('80~90', eighty_to_ninety);
    INSERT INTO Lisan VALUES('90~100', ninety_to_hundred);
END //
DELIMITER ;

CALL Grade_add();
SELECT * FROM Lisan;

DROP TABLE IF EXISTS AveSC;

CREATE TABLE AveSC(
    Cno tinyint(4),    -- 课程号
    CNAME CHAR(40),  -- 课程名
    AvgScore FLOAT, -- 平均分
    FOREIGN KEY(Cno) REFERENCES Course(Cno)
);

-- 插入初始数据，假设所有课程的平均分初始为0
INSERT INTO AveSC (Cno, CNAME, AvgScore)
SELECT Cno, Cname, 0
FROM Course;

SELECT * FROM AveSC;

-- 创建存储过程来计算并更新课程的平均分
DELIMITER //
CREATE PROCEDURE AvgCourse()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cno_var CHAR(4);
    DECLARE avg_score FLOAT;
    DECLARE cur CURSOR FOR
        SELECT Cno FROM Course;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cno_var;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 计算每门课程的平均分
        SELECT AVG(Grade) INTO avg_score
        FROM SC
        WHERE Cno = cno_var;

        -- 更新AveSC表中的平均分
        UPDATE AveSC
        SET AvgScore = avg_score
        WHERE Cno = cno_var;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;

-- 调用存储过程
CALL AvgCourse();

-- 再次查询AveSC表以查看更新后的平均分
SELECT * FROM AveSC;

-- 删除SC表中的Score_level列（如果存在）


-- 在SC表中添加Score_level列
ALTER TABLE SC ADD Score_level CHAR(4);

-- 删除存储过程（如果存在）
DROP PROCEDURE IF EXISTS Createlevel;

-- 创建存储过程
DELIMITER //
CREATE PROCEDURE Createlevel()
BEGIN
    -- 更新Score_level的值
    UPDATE SC SET Score_level = 'E' WHERE Grade < 60;
    UPDATE SC SET Score_level = 'D' WHERE Grade >= 60 AND Grade < 70;
    UPDATE SC SET Score_level = 'C' WHERE Grade >= 70 AND Grade < 80;
    UPDATE SC SET Score_level = 'B' WHERE Grade >= 80 AND Grade < 90;
    UPDATE SC SET Score_level = 'A' WHERE Grade >= 90;
END //
DELIMITER ;

-- 调用存储过程
CALL Createlevel();

-- 查询SC表以查看更新后的数据
SELECT * FROM SC;

DROP PROCEDURE IF EXISTS GetStudentCourses;
DELIMITER //

CREATE PROCEDURE GetStudentCourses(IN student_sno CHAR(10))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE CnoOfStudent CHAR(10);
    DECLARE GradeOfStudent INT;
    DECLARE cur CURSOR FOR
        SELECT Cno, Grade FROM SC WHERE Sno = student_sno;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO CnoOfStudent, GradeOfStudent;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 在MySQL中，你不能直接“打印”或“通知”结果，但你可以通过SELECT语句返回结果
        -- 或者在应用程序中捕获结果并显示
        SELECT CONCAT('Sno: ', student_sno, ', Cno: ', CnoOfStudent, ', Grade: ', GradeOfStudent);
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

-- 调用存储过程
CALL GetStudentCourses('201215121');
