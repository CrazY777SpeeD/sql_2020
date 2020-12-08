--    1. �������� ������� �� �������� ������ 
--    AGroup 
--    � Discipline, 
--    ����������� ��� ������������ �����������


CREATE TABLE AGROUP1(
    "name" VARCHAR2(10 BYTE)
        PRIMARY KEY
        NOT NULL,
    "faculty" VARCHAR2(30 BYTE) 
        NOT NULL,
    "course" NUMBER(1, 0) 
        NOT NULL
        CHECK ("course" BETWEEN 1 AND 6),
    "head" NUMBER(8, 0) 
        REFERENCES "STUDENT"("ID")
        ON DELETE SET NULL,
    "specialty" VARCHAR2(100 BYTE) 
        NOT NULL,
    "mag" VARCHAR2(3 BYTE) 
        DEFAULT '���'
        NOT NULL
        CHECK("mag" IN ('��', '���'))
);

DROP TABLE AGROUP1;

CREATE TABLE DISCIPLINE1(
    "cipher" NUMBER(6, 0)
        NOT NULL
        PRIMARY KEY,
    "name" VARCHAR2(100 BYTE)
        NOT NULL,
    "hours" NUMBER(3, 0)
        NOT NULL,
    "control" VARCHAR2(7 BYTE) 
        DEFAULT '�������'
        NOT NULL,
    CONSTRAINT "DISCIPLINE1_CHK1"
        CHECK("hours" > 0 AND "hours" <= 250),
    CONSTRAINT "DISCIPLINE1_CHK2"
        CHECK("control" IN ('�������', '�����'))
);

DROP TABLE DISCIPLINE1;

--    2. �������� ������ �� �������� �������� �������������, 
--    ����������� ���������� � 
--    ���� ������� ������� ����� ������������; 
--    ������������� ������ ��������� �����������, 
--    ���������� ��������.

CREATE OR REPLACE VIEW BACCALAUREATE1 AS
SELECT * 
FROM AGROUP
WHERE name LIKE '%��' AND course = 1
WITH CHECK OPTION;

DROP VIEW BACCALAUREATE1;


--    3. �������� ������ �� �������� ���������� �������������,
--    ����������� ���������� � ���� ����������-��������������;
--    ������������� �� ������ ��������� DML-��������.

CREATE OR REPLACE VIEW BACCALAUREATE_COURSE1 AS
SELECT s.name, s.birthday, s.group_name, g.faculty, g.specialty
FROM AGROUP g, STUDENT s
WHERE 
    s.group_name =  g.name
    AND s.group_name LIKE '%��' 
    AND g.course = 1
WITH READ ONLY;

DROP VIEW BACCALAUREATE_COURSE1;

--    4. �������� ������ �� �������� 
--    ������������������ ���������� ������ ���������.
--    ������ ���� ������ ���� ����- ��� ������������, 
--    �������� ����� ������� ����� 3.


CREATE SEQUENCE seq_disc
START WITH 10000
INCREMENT BY 3
MAXVALUE 9999999
NOCACHE
NOCYCLE;


SELECT seq_disc.NEXTVAL FROM DUAL;
SELECT seq_disc.CURRVAL FROM DUAL;

DROP SEQUENCE seq_disc;


--    5. �������� ������, 
--    ����������� � ������� Discipline 
--    ������� tutor_id �� ������� �� �������� ����� 
--    �� ��������� ���� ������� Tutor.

CREATE TABLE DISCIPLINE1(
    "cipher" NUMBER(6, 0)
        NOT NULL
        PRIMARY KEY,
    "name" VARCHAR2(100 BYTE)
        NOT NULL,
    "hours" NUMBER(3, 0)
        NOT NULL,
    "control" VARCHAR2(7 BYTE) 
        DEFAULT '�������'
        NOT NULL,
    CONSTRAINT "DISCIPLINE1_CHK1"
        CHECK("hours" > 0 AND "hours" <= 250),
    CONSTRAINT "DISCIPLINE1_CHK2"
        CHECK("control" IN ('�������', '�����'))
);

CREATE TABLE TUTOR1(
    "id" NUMBER(8, 0) 
        PRIMARY KEY
        NOT NULL,
    "name" VARCHAR2(10 BYTE)
        NOT NULL
);

ALTER TABLE DISCIPLINE1 ADD(
    "TUTOR_ID" NUMBER(8, 0)
        REFERENCES TUTOR1("id")
        ON DELETE SET NULL
);

DROP TABLE DISCIPLINE1;

DROP TABLE TUTOR1;


--    6. �������� ������ � ������� ������, 
--    ��������� �������� ���� ������, 
--    � ������� �� ������ ������, 
--    �� ������� ��� �� �����������.

SELECT table_name 
FROM ALL_TABLES 
MINUS
SELECT table_name 
FROM USER_TABLES;
