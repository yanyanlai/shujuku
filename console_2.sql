use spj;
CREATE TABLE S(
	SNO char(9) primary key,
	SNAME char(9),
	STATUS char(9),
	CITY char(9)
);
CREATE TABLE P(
	PNO char(9) primary key,
	PNAME char(9),
	COLOR char(2),
	WEIGHT SMALLINT
);
CREATE TABLE J(
	JNO char(9) primary key,
	JNAME char(9),
	CITY char(9)
);
CREATE TABLE SPJ(
	SNO char(9),
	PNO char(9),
	JNO char(9),
	QTY SMALLINT,
	foreign key (SNO) references S(SNO),
	foreign key (PNO) references P(PNO),
	foreign key (JNO) references J(JNO)
);

INSERT INTO S VALUES ('S1', '精益', '20', '天津');
INSERT INTO S VALUES ('S2', '盛锡', '10', '北京');
INSERT INTO S VALUES ('S3', '东方红', '30', '北京');
INSERT INTO S VALUES ('S4', '丰泰盛', '30', '天津');
INSERT INTO S VALUES ('S5', '为民', '30', '上海');

INSERT INTO P VALUES ('P1', '螺母', '红', 12);
INSERT INTO P VALUES ('P2', '螺栓', '绿', 17);
INSERT INTO P VALUES ('P3', '螺丝刀', '蓝', 14);
INSERT INTO P VALUES ('P4', '螺丝刀', '红', 14);
INSERT INTO P VALUES ('P5', '凸轮', '蓝', 40);
INSERT INTO P VALUES ('P6', '齿轮', '红', 30);

INSERT INTO J VALUES ('J1', '三建', '北京');
INSERT INTO J VALUES ('J2', '一汽', '长春');
INSERT INTO J VALUES ('J3', '弹簧厂', '天津');
INSERT INTO J VALUES ('J4', '造船厂', '天津');
INSERT INTO J VALUES ('J5', '机车厂', '唐山');
INSERT INTO J VALUES ('J6', '无线电厂', '常州');
INSERT INTO J VALUES ('J7', '半导体厂', '南京');

INSERT INTO SPJ VALUES ('S1', 'P1', 'J1', 200);
INSERT INTO SPJ VALUES ('S1', 'P1', 'J3', 100);
INSERT INTO SPJ VALUES ('S1', 'P1', 'J4', 700);
INSERT INTO SPJ VALUES ('S1', 'P2', 'J2', 100);
INSERT INTO SPJ VALUES ('S2', 'P3', 'J1', 400);
INSERT INTO SPJ VALUES ('S2', 'P3', 'J2', 200);
INSERT INTO SPJ VALUES ('S2', 'P3', 'J4', 500);
INSERT INTO SPJ VALUES ('S2', 'P3', 'J5', 400);
INSERT INTO SPJ VALUES ('S2', 'P5', 'J1', 400);
INSERT INTO SPJ VALUES ('S2', 'P5', 'J2', 100);
INSERT INTO SPJ VALUES ('S3', 'P1', 'J1', 200);
INSERT INTO SPJ VALUES ('S3', 'P3', 'J1', 200);
INSERT INTO SPJ VALUES ('S4', 'P5', 'J1', 100);
INSERT INTO SPJ VALUES ('S4', 'P6', 'J3', 300);
INSERT INTO SPJ VALUES ('S4', 'P6', 'J4', 200);
INSERT INTO SPJ VALUES ('S5', 'P2', 'J4', 100);
INSERT INTO SPJ VALUES ('S5', 'P3', 'J1', 200);
INSERT INTO SPJ VALUES ('S5', 'P6', 'J2', 200);
INSERT INTO SPJ VALUES ('S5', 'P6', 'J4', 500);

/*求供应工程 Jl 零件的供应商号码 SNO*/
SELECT DISTINCT SPJ.SNO
FROM SPJ
WHERE SPJ.JNO = 'J1';
/*求供应工程 Jl 零件 Pl 的供应商号码 SNO*/
SELECT DISTINCT SPJ.SNO
FROM SPJ
WHERE SPJ.JNO = 'J1' AND SPJ.PNO = 'P1';
/*求供应工程 Jl 零件为红色的供应商号码 SNO*/
SELECT DISTINCT SPJ.SNO
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
WHERE SPJ.JNO = 'J1' AND P.COLOR = '红';
/*求没有使用天津供应商生产的红色零件的工程号 JNO*/
SELECT DISTINCT SPJ.JNO
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
JOIN S ON SPJ.SNO = S.SNO
WHERE P.COLOR = '红' AND S.CITY <> '天津';
/*求至少用了供应商 Sl 所供应的全部零件的工程号 JNO*/
SELECT DISTINCT SPJ.JNO
FROM SPJ
WHERE SPJ.PNO IN (SELECT PNO FROM SPJ WHERE SNO = 'S1')
GROUP BY SPJ.JNO
HAVING COUNT(DISTINCT SPJ.PNO) = (SELECT COUNT(DISTINCT PNO) FROM SPJ WHERE SNO = 'S1');

/*(1)找出所有供应商的姓名和所在城市。*/
SELECT SNAME, CITY
FROM S;

/*(2)找出所有零件的名称、颜色、重量。*/
SELECT PNAME, COLOR, WEIGHT
FROM P;

/*(3)找出使用供应商S1所供应零件的工程号码。*/
SELECT DISTINCT JNO
FROM SPJ
WHERE SNO = 'S1';

/*(4)找出工程项目J2使用的各种零件的名称及其数量。*/
SELECT P.PNAME, SPJ.QTY
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
WHERE SPJ.JNO = 'J2';

/*(5)找出上海厂商供应的所有零件号码。*/
SELECT DISTINCT PNO
FROM SPJ
WHERE SNO IN (SELECT SNO FROM S WHERE CITY = '上海');

/*(6)出使用上海产的零件的工程名称。*/
SELECT DISTINCT J.JNAME
FROM J
JOIN SPJ ON J.JNO = SPJ.JNO
JOIN P ON SPJ.PNO = P.PNO
JOIN S ON SPJ.SNO = S.SNO
WHERE S.CITY = '上海';


/*(7)找出没有使用天津产的零件的工程号码。*/
SELECT DISTINCT SPJ.JNO
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
JOIN S ON SPJ.SNO = S.SNO
WHERE S.CITY <> '天津';


/*(8)把全部红色零件的颜色改成蓝色。*/
UPDATE P
SET COLOR = '蓝'
WHERE COLOR = '红';

/*(9)由S5供给J4的零件P6改为由S3供应。*/
UPDATE SPJ
SET SNO = 'S3'
WHERE SNO = 'S5' AND JNO = 'J4' AND PNO = 'P6';

/*(10)从供应商关系中删除供应商号是S2的记录，并从供应情况关系中删除相应的记录。*/
DELETE FROM S WHERE SNO = 'S2';
DELETE FROM SPJ WHERE SNO = 'S2';

/*(11)请将(S2，J6，P4，200)插入供应情况关系。*/
INSERT INTO SPJ (SNO, JNO, PNO, QTY) VALUES ('S2', 'J6', 'P4', 200);

/*请为三建工程项目建立一个供应情况的视图，包括供应商代码(SNO)、零件代码(PNO)、供应数量(QTY)*/
CREATE VIEW VSP
AS
SELECT SNO,SPJ.PNO,QTY FROM SPJ,J
WHERE SPJ.JNO=J.JNO AND J.JNAME='三建';

/*(1)找出三建工程项目使用的各种零件代码及其数量。*/
SELECT DISTINCT PNO, QTY FROM VSP;

/*(2)找出供应商S1的供应情况。*/
SELECT DISTINCT * FROM VSP WHERE SNO='S1';

