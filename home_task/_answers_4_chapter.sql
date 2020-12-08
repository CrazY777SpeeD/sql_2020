--set serveroutput on format wraped;

--1. Напишите команды для создания типов коллекций:
--? список с данными о численности населения стран, индексируемый названием страны;
--? список книг, где запись о книге соответствует структуре
--кортежа таблицы Book;
--? список треков музыкального альбома;
--? список треков множества музыкальных альбомов.

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


--2. Перепишите определение таблицы AGroup так, чтобы список студентов и список шифров преподаваемых каждой группе
--дисциплин хранились в виде атрибутов-коллекций.

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
	"MAG" VARCHAR2(3 BYTE) DEFAULT 'Нет',
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
   
   
   

--3. Для новой реализации таблицы AGroup напишите процедуру, удаляющую дубликаты из списков студентов и дисциплин,
--а также исключающую из этих списков записи, для которых
--не найдено соответствие в таблицах студентов и дисциплин.
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



--4. Перепишите процедуру из предыдущего упражения таким
--образом, чтобы каждая проверка осуществлялась с помощью операций над мультимножествами.


--5. Напишите процедуру, устанавливающую значение NULL
--в поле head для всех групп, для которых указанный в этом поле студент не является студентом данной группы. В процедуре
--нельзя выполнять запросы к таблице Student.

