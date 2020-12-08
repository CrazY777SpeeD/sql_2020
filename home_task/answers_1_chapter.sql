SELECT s.name, s.birthday, g.name 
FROM student s, agroup g 
WHERE (s.group_name = g.name)
ORDER BY s.name

SELECT * FROM student


-- 1. Напишите запросы на выборку следующих данных:

-- список всех студентов 1 курса бакалавриата

SELECT s.name, s.birthday, g.name 
FROM student s, agroup g 
WHERE (s.group_name = g.name) AND (g.mag <> 'Да') AND (g.course = 1) 
ORDER BY s.name

-- список всех студентов с указанием возраста 
-- в годах (неполные годы отбрасываются)

SELECT
    name,
    birthday,
    trunc(MONTHS_BETWEEN(SYSDATE, birthday) / 12) "AGE"
FROM student


-- список студентов, получающих самую большую стипендию
-- на своём курсе своего факультета

-- самые большие стипендии
-- на каждом курсе факультета
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

--   список зачётов, которые должен сдать студент Иванов И.И.

SELECT d.name
FROM student s, group_disc gd, discipline d
WHERE 
    s.name = 'Иванов И.И.' AND s.id = 111110
    AND s.group_name = gd.group_name
    AND gd.disc_cipher = d.cipher
    AND d.control = 'Зачёт'
    
--    среднее количество студентов в группе, 
--    рассчитанное для 
--    каждой специальности безотносительно факультета,
--    каждого курса каждого факультета, 
--    каждого факультета 
--    и университета в целом 
--    (всё должно быть реализовано в одном запросе);

SELECT
    DECODE(
        GROUPING(g.specialty), 
        1, 'Все специальности', 
        NVL(g.specialty, 'без специальности')
    ) AS "специальность",
    DECODE(
        GROUPING(g.course), 
        1, 'Все курсы', 
        NVL(g.course, 0)
    ) AS "курс", 
    DECODE(
        GROUPING(g.faculty), 
        1, 'Все факультеты', 
        NVL(g.faculty, 'без факультета')
    ) AS "факультет",
    ROUND(AVG(s.agrant), 2) AS "средняя_стипендия"
FROM student s, agroup g
WHERE s.group_name = g.name
GROUP BY GROUPING SETS ((g.specialty), (g.course, g.faculty), (g.faculty), ())


--    список групп с указанием средней стипендии, 
--    в котором отмечены 
--    группы, 
--        в которых средняя стипендия больше 
--        средней стипендии по этому курсу этой формы обучения этого факультета, 
--    а также отмечены группы бакалавриата, 
--        в которых средняя стипендия больше 
--        средней стипендии в магистратуре того же факультета

SELECT
    g.name AS "группа",
    ROUND(AVG(s.agrant), 2) AS "ср. стипендия",
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
    END) AS "больше по курсу и форме обуч.",
    (CASE 
        WHEN AVG(s.agrant) > (
            SELECT
                AVG(s3.agrant)
            FROM student s3, agroup g3
            WHERE 
                s3.group_name = g3.name
                AND g3.mag = 'Да'
                AND g3.faculty = g.faculty
            GROUP BY g3.faculty, g3.mag
        )
        THEN 'V' ELSE ' ' 
    END) AS "больше чем в маг."
FROM student s, agroup g
WHERE s.group_name = g.name
GROUP BY g.name, g.course, g.mag, g.faculty

--    средняя стипендия по курсу этой формы обучения этого факультета

SELECT
    ROUND(AVG(s2.agrant), 2) AS "ср. стипендия", g2.course, g2.mag
FROM student s2, agroup g2
WHERE 
    s2.group_name = g2.name
GROUP BY g2.course, g2.mag

--    средняя стипендия больше 
--    средней стипендии в магистратуре того же факультета

SELECT
    ROUND(AVG(s3.agrant), 2) AS "ср. стипендия", g3.faculty, g3.mag
FROM student s3, agroup g3
WHERE 
    s3.group_name = g3.name
    AND g3.mag = 'Да'
GROUP BY g3.faculty, g3.mag


--    2. Разработайте таблицу, реализующую иерархию, 
--        и напишите иерархический запрос к ней.

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
      
INSERT INTO DEPARTMENT (id, name, chief_dept) values (000000,'Главное подразделение 0', NULL);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (111111,'Подразделение 1 в 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (222222,'Подразделение 2 в 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (333333,'Подразделение 3 в 0', 000000);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (444444,'Подразделение 4 в 2', 222222);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (555555,'Подразделение 5 в 2', 222222);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (666666,'Подразделение 6 в 4', 444444);
INSERT INTO DEPARTMENT (id, name, chief_dept) values (777777,'Подразделение 7 в 4', 444444);

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



--    3. Напишите запрос на добавление 
--        практикумов 
--        с формой отчётности «Зачёт» 
--            по всем дисциплинам с формой отчётности «Экзамен», 
--            объём которых больше 200 часов. 
--        Количество часов новых дисциплин 
--            должно составлять половину от количества часов 
--            соответствующих старых дисциплин.

INSERT INTO discipline
SELECT d.cipher + 1, CONCAT('Практикум ', d.name), d.hours/2, 'Зачёт'
FROM discipline d
WHERE 
    d.control = 'Экзамен'
    AND d.hours > 200
    
ROLLBACK
    
SELECT *
FROM discipline

--    4. Напишите запрос на удаление пустых групп.

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


--    5. Напишите запрос, 
--    проводящий индексацию на 10 % стипендий 
--    всех студентов магистратуры.

UPDATE student s
SET s.agrant = s.agrant * 1.1
WHERE s.group_name LIKE '%МО'

ROLLBACK

SELECT * FROM student
















