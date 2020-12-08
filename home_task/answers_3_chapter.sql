
set serveroutput on format wraped;

DECLARE 
BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello');
END;

--    1. Напишите процедуру, добавляющую в таблицу AGroup запись 
--    о новой группе, определяемую параметрами процедуры.
--    Процедура должна проверять вводимые значения на 
--    соответствие формату данных в таблице БД, а также должна допускать
--    использование значения по умолчанию для поля mag. Кроме того,
--    в процедуре должен быть предусмотрен блок обработки исключений.

CREATE OR REPLACE 
PROCEDURE add_group (
    name VARCHAR2, 
    faculty VARCHAR2, 
    course NUMBER, 
    head NUMBER,
    specialty VARCHAR2,
    mag VARCHAR2 DEFAULT 'Нет'
) IS
    row_group agroup%ROWTYPE;
    error_param EXCEPTION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Start procedure');
    IF LENGTH(name) > 10 THEN 
        RAISE error_param;
    END IF;
    IF LENGTH(faculty) > 30 THEN 
        RAISE error_param;
    END IF;
    IF course > 6 THEN 
        RAISE error_param;
    END IF;
    IF head > 99999999 THEN 
        RAISE error_param;
    END IF;
    IF LENGTH(specialty) > 100 THEN 
        RAISE error_param;
    END IF;
    INSERT INTO agroup    
        (name, faculty, course, head, specialty, mag)
        VALUES
        (name, faculty, course, head, specialty, mag);
--    COMMIT
    SELECT * INTO row_group FROM agroup WHERE name = 'GROUP';
    DBMS_OUTPUT.PUT_LINE(row_group.specialty);
EXCEPTION
WHEN error_param THEN
    DBMS_OUTPUT.PUT_LINE('Error in param');
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE);
    DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
END add_group;

DECLARE 
BEGIN
  add_group('GROUP', 'IVT', 6, NULL, 'SP IVT');
END;

SELECT * FROM agroup;

ROLLBACK;

DROP PROCEDURE add_group;

--    2. Напишите процедуру, выводящую упорядоченный по 
--    группам список студентов, которым нужно сдавать указанную 
--    в параметре дисциплину. В процедуре должен быть предусмотрен блок
--    обработки исключений.


SELECT s.name, s.group_name, d.name FROM student s, discipline d, group_disc gd
WHERE s.group_name = gd.group_name AND gd.disc_cipher = d.cipher AND 'Нейронные сети' = d.name
ORDER BY group_name

CREATE OR REPLACE
PROCEDURE list_stud_disc(disc VARCHAR2) IS
    CURSOR stud(disc VARCHAR2) IS
        SELECT s.name, s.group_name FROM student s, discipline d, group_disc gd
        WHERE 
            s.group_name = gd.group_name 
            AND gd.disc_cipher = d.cipher
            AND disc = d.name
        ORDER BY group_name;    
BEGIN
    FOR stud_rec IN stud(disc)
    LOOP
        DBMS_OUTPUT.PUT_LINE(stud_rec.name||' '||stud_rec.group_name);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE);
    DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
END list_stud_disc;

DECLARE 
BEGIN
  list_stud_disc('Нейронные сети');
END;

DROP PROCEDURE list_stud_disc;

--    3. Напишите функцию, выводящую среднее количество часов
--    по каждой форме отчётности для каждой группы, факультета и 
--    университета в целом. В качестве результата возвращается
--    среднее количество часов по университету. В функции должен
--    быть предусмотрен блок обработки исключений.


SELECT 
    DECODE(
        GROUPING(gd.group_name),
        1, 'Все группы', 
        NVL(gd.group_name, 'без группы')
    ) AS "GROUP",
    DECODE(
        GROUPING(g.faculty),
        1, 'Все факультеты', 
        NVL(g.faculty, 'без факультета')
    ) AS "FACULTY",
    DECODE(
        GROUPING(d.control),
        1, 'Все формы отчетности', 
        NVL(d.control, 'без формы отчетности')
    ) AS "SPECIALTY",
    AVG(d.hours)
FROM group_disc gd, discipline d, agroup g
WHERE gd.disc_cipher = d.cipher AND g.name = gd.group_name
GROUP BY GROUPING SETS (
    (gd.group_name, g.faculty, d.control), 
    (g.faculty, d.control), 
    (d.control), 
    ()
);

SELECT AVG(d.hours)
FROM discipline d

SELECT *
FROM discipline d

CREATE OR REPLACE
FUNCTION disc_hours RETURN NUMBER
IS
    CURSOR all_disc_hours IS
        SELECT 
            DECODE(
                GROUPING(gd.group_name),
                1, 'Все группы', 
                NVL(gd.group_name, 'без группы')
            ) AS "GROUP",
            DECODE(
                GROUPING(g.faculty),
                1, 'Все факультеты', 
                NVL(g.faculty, 'без факультета')
            ) AS "FACULTY",
            DECODE(
                GROUPING(d.control),
                1, 'Все формы отчетности', 
                NVL(d.control, 'без формы отчетности')
            ) AS "SPECIALTY",
            AVG(d.hours) AS "AVG_HOURS"
        FROM group_disc gd, discipline d, agroup g
        WHERE gd.disc_cipher = d.cipher AND g.name = gd.group_name
        GROUP BY GROUPING SETS (
            (gd.group_name, g.faculty, d.control), 
            (g.faculty, d.control), 
            (d.control), 
            ()
        );
    all_hour NUMBER;
BEGIN
    all_hour := 0;
    FOR disc_rec IN all_disc_hours
    LOOP
        DBMS_OUTPUT.PUT_LINE(disc_rec."GROUP"||' '||disc_rec.faculty||' '||disc_rec.specialty||' '||disc_rec.avg_hours);
        IF 
            disc_rec."GROUP" = 'Все группы'
            AND disc_rec.faculty = 'Все факультеты'
            AND disc_rec.specialty = 'Все формы отчетности'
        THEN
            all_hour := disc_rec.avg_hours;
        END IF;
    END LOOP;
    RETURN all_hour;
EXCEPTION
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE);
    DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
END disc_hours;


DECLARE 
BEGIN
  DBMS_OUTPUT.PUT_LINE(disc_hours);
END;

DROP FUNCTION disc_hours;

--    4. Напишите процедуру, выводящую список дисциплин, преподаваемых на 
--    двух и более факультетах, с указанием количества факультетов и 
--    количества групп; список сортируется сначала по 
--    убыванию количества факультетов, а затем — количества
--    групп. В процедуре должен быть предусмотрен блок обработки
--    исключений.

SELECT *
FROM
    (SELECT d.name AS "NAME", COUNT(DISTINCT g.faculty) AS "FACULTY", COUNT(g.name) AS "GROUP"
    FROM agroup g, group_disc gd, discipline d
    WHERE 
        gd.disc_cipher = d.cipher 
        AND g.name = gd.group_name
    GROUP BY d.name)
WHERE faculty >= 2
ORDER BY faculty DESC, "GROUP" DESC;

CREATE OR REPLACE
PROCEDURE list_disc IS
    CURSOR cursor_disc IS
        SELECT *
        FROM
            (SELECT d.name AS "NAME", COUNT(DISTINCT g.faculty) AS "FACULTY", COUNT(g.name) AS "GROUP"
            FROM agroup g, group_disc gd, discipline d
            WHERE 
                gd.disc_cipher = d.cipher 
                AND g.name = gd.group_name
            GROUP BY d.name)
        WHERE faculty >= 2
        ORDER BY faculty DESC, "GROUP" DESC;
BEGIN    
    FOR disc_rec IN cursor_disc
    LOOP
        DBMS_OUTPUT.PUT_LINE(disc_rec.NAME||' '||disc_rec.FACULTY||' '||disc_rec."GROUP");
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE);
    DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
END list_disc;

DECLARE 
BEGIN
  list_disc;
END;

DROP PROCEDURE list_disc;


--    5. Напишите процедуру, удаляющую из таблицы AGroup все
--    пустые группы (нет ни одного студента). В процедуре должен
--    быть предусмотрен блок обработки исключений.

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

CREATE OR REPLACE
PROCEDURE del_group IS
BEGIN
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
        ) = g.name;
EXCEPTION
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE);
    DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
END del_group;

DECLARE 
BEGIN
  del_group;
END;

--    6. Организуйте все процедуры и функции, разработанные
--    в упражнениях 1–5, в виде пакета с разделением на 
--    спецификацию и тело пакета.

CREATE OR REPLACE 
PACKAGE my_package AS
    PROCEDURE add_group (
        name VARCHAR2, 
        faculty VARCHAR2, 
        course NUMBER, 
        head NUMBER,
        specialty VARCHAR2,
        mag VARCHAR2 DEFAULT 'Нет'
    );
    PROCEDURE list_stud_disc(disc VARCHAR2);
    FUNCTION disc_hours RETURN NUMBER;
    PROCEDURE list_disc;
    PROCEDURE del_group;
END my_package;

CREATE OR REPLACE
PACKAGE BODY my_package AS
    PROCEDURE add_group (
        name VARCHAR2, 
        faculty VARCHAR2, 
        course NUMBER, 
        head NUMBER,
        specialty VARCHAR2,
        mag VARCHAR2 DEFAULT 'Нет'
    ) IS
        row_group agroup%ROWTYPE;
        error_param EXCEPTION;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Start procedure');
        IF LENGTH(name) > 10 THEN 
            RAISE error_param;
        END IF;
        IF LENGTH(faculty) > 30 THEN 
            RAISE error_param;
        END IF;
        IF course > 6 THEN 
            RAISE error_param;
        END IF;
        IF head > 99999999 THEN 
            RAISE error_param;
        END IF;
        IF LENGTH(specialty) > 100 THEN 
            RAISE error_param;
        END IF;
        INSERT INTO agroup    
            (name, faculty, course, head, specialty, mag)
            VALUES
            (name, faculty, course, head, specialty, mag);
    --    COMMIT
        SELECT * INTO row_group FROM agroup WHERE name = 'GROUP';
        DBMS_OUTPUT.PUT_LINE(row_group.specialty);
    EXCEPTION
    WHEN error_param THEN
        DBMS_OUTPUT.PUT_LINE('Error in param');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
    END add_group;
    
    PROCEDURE list_stud_disc(disc VARCHAR2) IS
        CURSOR stud(disc VARCHAR2) IS
            SELECT s.name, s.group_name FROM student s, discipline d, group_disc gd
            WHERE 
                s.group_name = gd.group_name 
                AND gd.disc_cipher = d.cipher
                AND disc = d.name
            ORDER BY group_name;    
    BEGIN
        FOR stud_rec IN stud(disc)
        LOOP
            DBMS_OUTPUT.PUT_LINE(stud_rec.name||' '||stud_rec.group_name);
        END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
    END list_stud_disc;   
    
    FUNCTION disc_hours RETURN NUMBER
    IS
        CURSOR all_disc_hours IS
            SELECT 
                DECODE(
                    GROUPING(gd.group_name),
                    1, 'Все группы', 
                    NVL(gd.group_name, 'без группы')
                ) AS "GROUP",
                DECODE(
                    GROUPING(g.faculty),
                    1, 'Все факультеты', 
                    NVL(g.faculty, 'без факультета')
                ) AS "FACULTY",
                DECODE(
                    GROUPING(d.control),
                    1, 'Все формы отчетности', 
                    NVL(d.control, 'без формы отчетности')
                ) AS "SPECIALTY",
                AVG(d.hours) AS "AVG_HOURS"
            FROM group_disc gd, discipline d, agroup g
            WHERE gd.disc_cipher = d.cipher AND g.name = gd.group_name
            GROUP BY GROUPING SETS (
                (gd.group_name, g.faculty, d.control), 
                (g.faculty, d.control), 
                (d.control), 
                ()
            );
        all_hour NUMBER;
    BEGIN
        all_hour := 0;
        FOR disc_rec IN all_disc_hours
        LOOP
            DBMS_OUTPUT.PUT_LINE(disc_rec."GROUP"||' '||disc_rec.faculty||' '||disc_rec.specialty||' '||disc_rec.avg_hours);
            IF 
                disc_rec."GROUP" = 'Все группы'
                AND disc_rec.faculty = 'Все факультеты'
                AND disc_rec.specialty = 'Все формы отчетности'
            THEN
                all_hour := disc_rec.avg_hours;
            END IF;
        END LOOP;
        RETURN all_hour;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
    END disc_hours;
    
    PROCEDURE list_disc IS
        CURSOR cursor_disc IS
            SELECT *
            FROM
                (SELECT d.name AS "NAME", COUNT(DISTINCT g.faculty) AS "FACULTY", COUNT(g.name) AS "GROUP"
                FROM agroup g, group_disc gd, discipline d
                WHERE 
                    gd.disc_cipher = d.cipher 
                    AND g.name = gd.group_name
                GROUP BY d.name)
            WHERE faculty >= 2
            ORDER BY faculty DESC, "GROUP" DESC;
    BEGIN    
        FOR disc_rec IN cursor_disc
        LOOP
            DBMS_OUTPUT.PUT_LINE(disc_rec.NAME||' '||disc_rec.FACULTY||' '||disc_rec."GROUP");
        END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
    END list_disc;
    
    PROCEDURE del_group IS
    BEGIN
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
            ) = g.name;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
    END del_group;    
END my_package;

DECLARE 
BEGIN
  my_package.list_disc;
END;


