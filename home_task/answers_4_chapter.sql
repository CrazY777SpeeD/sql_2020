--1. Напишите команды для создания типов коллекций:
--∙ список с данными о численности населения стран, индексируемый названием страны;
--∙ список книг, где запись о книге соответствует структуре
--кортежа таблицы Book;
--∙ список треков музыкального альбома;
--∙ список треков множества музыкальных альбомов.

DECLARE
    TYPE countries IS TABLE OF number(7, 0)
        NOT NULL INDEX BY varchar2(100);
    test countries;
    i varchar2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE(case test.FIRST IS NULL when TRUE then 'TRUE' else 'FALSE' end);
    DBMS_OUTPUT.PUT_LINE('123');
    i:= test.FIRST;
    WHILE i <= test.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(i || ' - ' || test(i));
        i := test.NEXT(i);
    END LOOP;
END;

-- 1.1
TYPE countries IS TABLE OF number(7, 0)
	NOT NULL INDEX BY varchar2(100);

-- 1.2
TYPE books_collection IS TABLE OF Student%ROWTYPE;

-- 1.3
TYPE records_array IS VARRAY(100) OF blob NOT NULL;

-- 1.4
TYPE records_pack IS VARRAY(1000) OF records_array NOT NULL;

--2. Перепишите определение таблицы AGroup так, чтобы список студентов и список шифров преподаваемых каждой группе
--дисциплин хранились в виде атрибутов-коллекций.

CREATE OR REPLACE TYPE students_column IS
TABLE OF Varchar2(100);

CREATE TABLE "AGROUP" 
   (	
    "NAME" VARCHAR2(10 BYTE), 
	"FACULTY" VARCHAR2(30 BYTE), 
	"COURSE" NUMBER(1,0), 
	"HEAD" NUMBER(8,0), 
	"SPECIALTY" VARCHAR2(100 BYTE), 
	"MAG" VARCHAR2(3 BYTE) DEFAULT 'Нет',
    "STUDENTS" students_column
   ) NESTED TABLE STUDENTS
     STORE AS stud_in_tab;

--3. Для новой реализации таблицы AGroup напишите процедуру, удаляющую дубликаты из списков студентов и дисциплин,
--а также исключающую из этих списков записи, для которых
--не найдено соответствие в таблицах студентов и дисциплин.


--4. Перепишите процедуру из предыдущего упражения таким
--образом, чтобы каждая проверка осуществлялась с помощью операций над мультимножествами.


--5. Напишите процедуру, устанавливающую значение NULL
--в поле head для всех групп, для которых указанный в этом поле студент не является студентом данной группы. В процедуре
--нельзя выполнять запросы к таблице Student.