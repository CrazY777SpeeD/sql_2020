--    1. Напишите запросы на создание таблиц 
--    AGroup 
--    и Discipline, 
--    учитывающие все естественные ограничения


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
        DEFAULT 'Нет'
        NOT NULL
        CHECK("mag" IN ('Да', 'Нет'))
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
        DEFAULT 'Экзамен'
        NOT NULL,
    CONSTRAINT "DISCIPLINE1_CHK1"
        CHECK("hours" > 0 AND "hours" <= 250),
    CONSTRAINT "DISCIPLINE1_CHK2"
        CHECK("control" IN ('Экзамен', 'Зачёт'))
);

DROP TABLE DISCIPLINE1;

--    2. Напишите запрос на создание простого представления, 
--    содержащего информацию о 
--    всех группах первого курса бакалавриата; 
--    представление должно проверять ограничения, 
--    задаваемые запросом.

CREATE OR REPLACE VIEW BACCALAUREATE1 AS
SELECT * 
FROM AGROUP
WHERE name LIKE '%БО' AND course = 1
WITH CHECK OPTION;

DROP VIEW BACCALAUREATE1;


--    3. Напишите запрос на создание составного представления,
--    содержащего информацию о всех бакалаврах-первокурсниках;
--    представление не должно дозволять DML-операции.

CREATE OR REPLACE VIEW BACCALAUREATE_COURSE1 AS
SELECT s.name, s.birthday, s.group_name, g.faculty, g.specialty
FROM AGROUP g, STUDENT s
WHERE 
    s.group_name =  g.name
    AND s.group_name LIKE '%БО' 
    AND g.course = 1
WITH READ ONLY;

DROP VIEW BACCALAUREATE_COURSE1;

--    4. Напишите запрос на создание 
--    последовательности уникальных шифров дисциплин.
--    Каждый шифр должен быть пяти- или шестизначным, 
--    интервал между шифрами равен 3.


CREATE SEQUENCE seq_disc
START WITH 10000
INCREMENT BY 3
MAXVALUE 9999999
NOCACHE
NOCYCLE;


SELECT seq_disc.NEXTVAL FROM DUAL;
SELECT seq_disc.CURRVAL FROM DUAL;

DROP SEQUENCE seq_disc;


--    5. Напишите запрос, 
--    добавляющий в таблицу Discipline 
--    атрибут tutor_id со ссылкой по внешнему ключу 
--    на первичный ключ таблицы Tutor.

CREATE TABLE DISCIPLINE1(
    "cipher" NUMBER(6, 0)
        NOT NULL
        PRIMARY KEY,
    "name" VARCHAR2(100 BYTE)
        NOT NULL,
    "hours" NUMBER(3, 0)
        NOT NULL,
    "control" VARCHAR2(7 BYTE) 
        DEFAULT 'Экзамен'
        NOT NULL,
    CONSTRAINT "DISCIPLINE1_CHK1"
        CHECK("hours" > 0 AND "hours" <= 250),
    CONSTRAINT "DISCIPLINE1_CHK2"
        CHECK("control" IN ('Экзамен', 'Зачёт'))
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


--    6. Напишите запрос к словарю данных, 
--    выводящий названия всех таблиц, 
--    к которым вы имеете доступ, 
--    но которые вам не принадлежат.

SELECT table_name 
FROM ALL_TABLES 
MINUS
SELECT table_name 
FROM USER_TABLES;
