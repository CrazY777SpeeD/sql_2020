--set serveroutput on format wraped;

--1. �������� ������� ��� �������� ����� ���������:
--? ������ � ������� � ����������� ��������� �����, ������������� ��������� ������;
--? ������ ����, ��� ������ � ����� ������������� ���������
--������� ������� Book;
--? ������ ������ ������������ �������;
--? ������ ������ ��������� ����������� ��������.

--
--DECLARE
--    TYPE countries IS TABLE OF number(7, 0)
--        NOT NULL INDEX BY varchar2(100);
--    TYPE books_collection IS TABLE OF Student%ROWTYPE;
--    TYPE records_array IS VARRAY(100) OF blob NOT NULL;
--    TYPE records_pack IS VARRAY(1000) OF records_array NOT NULL;
--    test countries;
--    test2 books_collection;
--    i varchar2(100);
--BEGIN
--    DBMS_OUTPUT.PUT_LINE(case test.FIRST IS NULL when TRUE then 'TRUE' else 'FALSE' end);
--    DBMS_OUTPUT.PUT_LINE('123');
--    i:= test.FIRST;
--    WHILE i <= test.LAST LOOP
--        DBMS_OUTPUT.PUT_LINE(i || ' - ' || test(i));
--        i := test.NEXT(i);
--    END LOOP;
--END;


--2. ���������� ����������� ������� AGroup ���, ����� ������ ��������� � ������ ������ ������������� ������ ������
--��������� ��������� � ���� ���������-���������.

CREATE OR REPLACE TYPE students_column2 IS
TABLE OF NUMBER(8,0);

CREATE OR REPLACE TYPE chipher_column2 IS
TABLE OF NUMBER(6,0);

CREATE TABLE "AGROUP6" 
   (	
    "NAME" VARCHAR2(10 BYTE), 
	"FACULTY" VARCHAR2(30 BYTE), 
	"COURSE" NUMBER(1,0), 
	"HEAD" NUMBER(8,0), 
	"SPECIALTY" VARCHAR2(100 BYTE), 
	"MAG" VARCHAR2(3 BYTE) DEFAULT '���',
    "STUDENTS" students_column2,
    "CHIPHER" chipher_column2
   ) 
   NESTED TABLE STUDENTS
     STORE AS students_in_tab6,
   NESTED TABLE CHIPHER
     STORE AS chipher_in_tab6;
--   
--   
--  CREATE TABLE "STUDENT" 
--   (	"ID" NUMBER(8,0), 
--	"NAME" VARCHAR2(100 BYTE), 
--	"BIRTHDAY" DATE, 
--	"S_PASS" NUMBER(4,0), 
--	"N_PASS" NUMBER(6,0), 
--	"AGRANT" NUMBER(9,2), 
--	"GROUP_NAME" VARCHAR2(10 BYTE), 
--	"GENDER" VARCHAR2(1 BYTE)
--   ) ;
   
   
   

--3. ��� ����� ���������� ������� AGroup �������� ���������, ��������� ��������� �� ������� ��������� � ���������,
--� ����� ����������� �� ���� ������� ������, ��� �������
--�� ������� ������������ � �������� ��������� � ���������.
CREATE OR REPLACE PROCEDURE delete_duplicates IS
    TYPE students_array IS VARRAY(100) OF NUMBER(8,0) NOT NULL;
    students students_array;
    has_student boolean;
BEGIN
    FOR group2 IN (SELECT * FROM AGroup6)
    LOOP    
        students  :=  students_array();
        FOR student IN group2.STUDENTS
        LOOP
            IF students.EXISTS(student) THEN
                CONTINUE;
            END IF;
            
            SELECT
                CASE WHEN EXISTS(
                    SELECT TRUE
                    FROM STUDENT s
                    WHERE s.ID = student
                ) THEN TRUE
                ELSE FALSE END
            INTO has_student
            FROM dual;
            
            IF NOT has_student THEN
                CONTINUE;
            END IF;

            students.EXTEND();
            students(students.COUNT) := student;
        END LOOP;
        
        UPDATE AGroup6 g SET
            g.STUDENTS = students
        WHERE g.name = group2.name;
        
    END LOOP;
END;



--4. ���������� ��������� �� ����������� ��������� �����
--�������, ����� ������ �������� �������������� � ������� �������� ��� �����������������.


--5. �������� ���������, ��������������� �������� NULL
--� ���� head ��� ���� �����, ��� ������� ��������� � ���� ���� ������� �� �������� ��������� ������ ������. � ���������
--������ ��������� ������� � ������� Student.

