SELECT s.name, s.birthday, g.name 
FROM student s, agroup g 
WHERE (s.group_name = g.name)
ORDER BY s.name

SELECT * FROM student


-- 1. �������� ������� �� ������� ��������� ������:

-- ������ ���� ��������� 1 ����� ������������

SELECT s.name, s.birthday, g.name 
FROM student s, agroup g 
WHERE (s.group_name = g.name) AND (g.mag <> '��') AND (g.course = 1) 
ORDER BY s.name

-- ������ ���� ��������� � ��������� �������� 
-- � ����� (�������� ���� �������������)

SELECT
    name,
    birthday,
    trunc(MONTHS_BETWEEN(SYSDATE, birthday) / 12) "AGE"
FROM student


-- ������ ���������, ���������� ����� ������� ���������
-- �� ���� ����� ������ ����������

-- ����� ������� ���������
-- �� ������ ����� ����������
--SELECT MAX(s.agrant), g.faculty, g.course
--FROM student s, agroup g
--WHERE (s.group_name = g.name)
--GROUP BY g.faculty, g.course

SELECT s.name, s.birthday, s.agrant, g.faculty, g.course
FROM student s, agroup g
WHERE 
    s.group_name = g.name
    AND (s.agrant, g.faculty, g.course) IN (
        SELECT MAX(s.agrant), g.faculty, g.course
        FROM student s, agroup g
        WHERE (s.group_name = g.name)
        GROUP BY g.faculty, g.course
    )

--   ������ �������, ������� ������ ����� ������� ������ �.�.

SELECT d.name
FROM student s, group_disc gd, discipline d
WHERE 
    s.name = '������ �.�.' AND s.id = 111110
    AND s.group_name = gd.group_name
    AND gd.disc_cipher = d.cipher
    AND d.control = '�����'
    
--    ������� ���������� ��������� � ������, 
--    ������������ ��� 
--    ������ ������������� ��������������� ����������,
--    ������� ����� ������� ����������, 
--    ������� ���������� 
--    � ������������ � ����� 
--    (�� ������ ���� ����������� � ����� �������);

SELECT
    DECODE(
        GROUPING(g.specialty), 
        1, '��� �������������', 
        NVL(g.specialty, '��� �������������')
    ) AS "�������������",
    DECODE(
        GROUPING(g.course), 
        1, '��� �����', 
        NVL(g.course, 0)
    ) AS "����", 
    DECODE(
        GROUPING(g.faculty), 
        1, '��� ����������', 
        NVL(g.faculty, '��� ����������')
    ) AS "���������",
    ROUND(AVG(s.agrant), 2) AS "�������_���������"
FROM student s, agroup g
WHERE s.group_name = g.name
GROUP BY GROUPING SETS ((g.specialty), (g.course, g.faculty), (g.faculty), ())


--    ������ ����� � ��������� ������� ���������, 
--    � ������� �������� 
--    ������, 
--        � ������� ������� ��������� ������ 
--        ������� ��������� �� ����� ����� ���� ����� �������� ����� ����������, 
--    � ����� �������� ������ ������������, 
--        � ������� ������� ��������� ������ 
--        ������� ��������� � ������������ ���� �� ����������

SELECT
    g.name AS "������",
    ROUND(AVG(s.agrant), 2) AS "��. ���������",
    (CASE 
        WHEN AVG(s.agrant) > (
            SELECT
                AVG(s2.agrant)
            FROM student s2, agroup g2
            WHERE 
                s2.group_name = g2.name
                AND g.course = g2.course
                AND g.mag = g2.mag
            GROUP BY g2.course, g2.mag
        )
        THEN 'V' ELSE ' ' 
    END) AS "������ �� ����� � ����� ����.",
    (CASE 
        WHEN AVG(s.agrant) > (
            SELECT
                AVG(s3.agrant)
            FROM student s3, agroup g3
            WHERE 
                s3.group_name = g3.name
                AND g3.mag = '��'
                AND g3.faculty = g.faculty
            GROUP BY g3.faculty, g3.mag
        )
        THEN 'V' ELSE ' ' 
    END) AS "������ ��� � ���."
FROM student s, agroup g
WHERE s.group_name = g.name
GROUP BY g.name, g.course, g.mag, g.faculty

--    ������� ��������� �� ����� ���� ����� �������� ����� ����������

SELECT
    ROUND(AVG(s2.agrant), 2) AS "��. ���������", g2.course, g2.mag
FROM student s2, agroup g2
WHERE 
    s2.group_name = g2.name
GROUP BY g2.course, g2.mag

--    ������� ��������� ������ 
--    ������� ��������� � ������������ ���� �� ����������

SELECT
    ROUND(AVG(s3.agrant), 2) AS "��. ���������", g3.faculty, g3.mag
FROM student s3, agroup g3
WHERE 
    s3.group_name = g3.name
    AND g3.mag = '��'
GROUP BY g3.faculty, g3.mag


--    2. ������������ �������, ����������� ��������, 
--        � �������� ������������� ������ � ���.

CREATE TABLE "DEPARTMENT" 
   (	
    "ID" NUMBER(6,0),
	"NAME" VARCHAR2(30 BYTE), 
	"CHIEF_DEPT" NUMBER(6,0)
   ) ;  
   
ALTER TABLE "DEPARTMENT" ADD CONSTRAINT "DEPARTMENT_PK" PRIMARY KEY ("ID") ENABLE;
ALTER TABLE "DEPARTMENT" MODIFY ("ID" NOT NULL ENABLE);
ALTER TABLE "DEPARTMENT" ADD CONSTRAINT "DEPT_CHIEF_DEPT_FK1" FOREIGN KEY ("CHIEF_DEPT")
	  REFERENCES "DEPARTMENT" ("ID") ON DELETE CASCADE ENABLE;
      
INSERT INTO DEPARTMENT (id, name, chief_dept) values (000000,'������� ������������� 0', NULL);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (111111,'������������� 1 � 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (222222,'������������� 2 � 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (333333,'������������� 3 � 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (444444,'������������� 4 � 2', 222222);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (555555,'������������� 5 � 2', 222222);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (666666,'������������� 6 � 4', 444444);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (777777,'������������� 7 � 4', 444444);

COMMIT

SELECT *
FROM department

SELECT id, name, LEVEL, id / 111111
FROM department
CONNECT BY PRIOR id = chief_dept;

SELECT id, name, LEVEL
FROM department
CONNECT BY id = PRIOR chief_dept;


SELECT id, name, LEVEL
FROM department START WITH name LIKE '%4%'
CONNECT BY PRIOR id = chief_dept
ORDER SIBLINGS BY name;



--    3. �������� ������ �� ���������� 
--        ����������� 
--        � ������ ���������� ������ 
--            �� ���� ����������� � ������ ���������� ��������, 
--            ����� ������� ������ 200 �����. 
--        ���������� ����� ����� ��������� 
--            ������ ���������� �������� �� ���������� ����� 
--            ��������������� ������ ���������.

INSERT INTO discipline
SELECT d.cipher + 1, CONCAT('��������� ', d.name), d.hours/2, '�����'
FROM discipline d
WHERE 
    d.control = '�������'
    AND d.hours > 200
    
ROLLBACK
    
SELECT *
FROM discipline

--    4. �������� ������ �� �������� ������ �����.

DELETE 
FROM agroup g
WHERE 
    (
        SELECT g2.name
        FROM agroup g2
        WHERE 
            (
                SELECT COUNT(s3.name) 
                FROM student s3 
                WHERE g2.name = s3.group_name
            ) = 0
    ) = g.name
    
ROLLBACK

SELECT * 
FROM agroup


--    5. �������� ������, 
--    ���������� ���������� �� 10 % ��������� 
--    ���� ��������� ������������.

UPDATE student s
SET s.agrant = s.agrant * 1.1
WHERE s.group_name LIKE '%��'

ROLLBACK

SELECT * FROM student
















