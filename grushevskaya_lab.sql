-- DROP ALL

DROP TABLE GRUSHEVSKAYA_ALBUM;
DROP TABLE GRUSHEVSKAYA_RECORD;
DROP TABLE GRUSHEVSKAYA_SINGER;
DROP TABLE GRUSHEVSKAYA_DICT_COUNTRY;
DROP TABLE GRUSHEVSKAYA_DICT_STYLE;
DROP TYPE GRUSHEVSKAYA_RECORD_ARR;
DROP TYPE GRUSHEVSKAYA_SINGER_TAB;
--DROP TYPE GRUSHEVSKAYA_TIME;
DROP SEQUENCE GRUSHEVSKAYA_NUM_RECORD;
DROP SEQUENCE GRUSHEVSKAYA_NUM_ALBUM;
DROP PACKAGE GRUSHEVSKAYA_EXCEPTIONS;
DROP PACKAGE GRUSHEVSKAYA_PACKAGE;


-- /

--Пакет с исключениями

CREATE OR REPLACE 
PACKAGE GRUSHEVSKAYA_EXCEPTIONS AS
    INVALIDE_TYPE_FIELDS EXCEPTION;
    WARNING_UPDATE EXCEPTION;
    ERROR_RECORD EXCEPTION;
    ERROR_UPDATE_SINGER_IN_RECORD EXCEPTION;
    ERROR_SINGER_DEL EXCEPTION;
    ERROR_ALBUM EXCEPTION;
    ERROR_RECORD_DEL EXCEPTION;
END;
/

-- SEQUENCE для генерации id RECORD

CREATE SEQUENCE GRUSHEVSKAYA_NUM_RECORD
MINVALUE 1
START WITH 1 
INCREMENT BY 1
NOCACHE NOCYCLE;
/
-- SEQUENCE для генерации id ALBUM

CREATE SEQUENCE GRUSHEVSKAYA_NUM_ALBUM
MINVALUE 1
START WITH 1 
INCREMENT BY 1
NOCACHE NOCYCLE;
/
-- COUNTRY - вспомогательная таблица, содержащая словарь стран. 
-- Исключает ситуацию, когда где-то страна "РФ", а где-то "Россия".

CREATE TABLE GRUSHEVSKAYA_DICT_COUNTRY(
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);

-- SINGER – исполнитель (имя, псевдоним или название группы; страна)

CREATE TABLE GRUSHEVSKAYA_SINGER(
    NAME VARCHAR2(100 BYTE),
    COUNTRY VARCHAR2(100 BYTE)
);

ALTER TABLE GRUSHEVSKAYA_SINGER 
    ADD CONSTRAINT GRUSHEVSKAYA_SINGER_PK 
    PRIMARY KEY(NAME) ENABLE;
ALTER TABLE GRUSHEVSKAYA_SINGER 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_SINGER 
    MODIFY (COUNTRY NOT NULL ENABLE);
    
ALTER TABLE GRUSHEVSKAYA_SINGER 
    ADD CONSTRAINT GRUSHEVSKAYA_SINGER_FK 
    FOREIGN KEY (COUNTRY)
    REFERENCES GRUSHEVSKAYA_DICT_COUNTRY (NAME) 
    ON DELETE SET NULL ENABLE;

-- STYLE - вспомогательная таблица, содержащая словарь стилей
-- Исключает ситуацию, когда где-то стиль "Джаз", а где-то "джаз".

CREATE TABLE GRUSHEVSKAYA_DICT_STYLE(
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);

-- RECORD

/
-- Вложенная таблица исполнителей
CREATE TYPE GRUSHEVSKAYA_SINGER_TAB AS TABLE OF VARCHAR2(100 BYTE);
/
-- RECORD – запись (идентификатор, название, время звучания, стиль)
CREATE TABLE GRUSHEVSKAYA_RECORD(
    ID NUMBER(10,0),
    NAME VARCHAR2(100 BYTE),
    TIME INTERVAL DAY (0) TO SECOND (0),
    STYLE VARCHAR2(100 BYTE),
    SINGER_LIST GRUSHEVSKAYA_SINGER_TAB
)NESTED TABLE SINGER_LIST
    STORE AS GRUSHEVSKAYA_SINGER_LIST;

ALTER TABLE GRUSHEVSKAYA_RECORD 
    ADD CONSTRAINT GRUSHEVSKAYA_RECORD_PK 
    PRIMARY KEY(ID) ENABLE;
ALTER TABLE GRUSHEVSKAYA_RECORD 
    MODIFY (ID NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_RECORD 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_RECORD 
    MODIFY (TIME NOT NULL ENABLE);
    
ALTER TABLE GRUSHEVSKAYA_RECORD 
    MODIFY (STYLE NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_RECORD 
    ADD CONSTRAINT GRUSHEVSKAYA_RECORD_FK 
    FOREIGN KEY (STYLE)
    REFERENCES GRUSHEVSKAYA_DICT_STYLE (NAME) 
    ON DELETE SET NULL ENABLE;
    
-- ALBUM

-- Вложенный массив записей
CREATE TYPE GRUSHEVSKAYA_RECORD_ARR AS VARRAY(30) OF NUMBER(10,0);
/
-- ALBUM – альбом (идентификатор, название, стоимость, 
-- количество на складе, количество проданных экземпляров)
CREATE TABLE GRUSHEVSKAYA_ALBUM(
    ID NUMBER(10, 0),
    NAME VARCHAR2(100 BYTE),
    PRICE NUMBER(6,2),
    QUANTITY_IN_STOCK NUMBER(5, 0),
    QUANTITY_OF_SOLD NUMBER(5, 0),
    RECORD_ARRAY GRUSHEVSKAYA_RECORD_ARR
);

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    ADD CONSTRAINT GRUSHEVSKAYA_ALBUM_PK 
    PRIMARY KEY(ID) ENABLE;
ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (ID NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (PRICE NOT NULL ENABLE);
ALTER TABLE GRUSHEVSKAYA_ALBUM 
    ADD CONSTRAINT GRUSHEVSKAYA_ALBUM_CHK1 
    CHECK (PRICE >= 0) ENABLE;

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (QUANTITY_IN_STOCK NOT NULL ENABLE);
ALTER TABLE GRUSHEVSKAYA_ALBUM 
    ADD CONSTRAINT GRUSHEVSKAYA_ALBUM_CHK2 
    CHECK (QUANTITY_IN_STOCK >= 0) ENABLE;

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (QUANTITY_OF_SOLD NOT NULL ENABLE);
ALTER TABLE GRUSHEVSKAYA_ALBUM 
    ADD CONSTRAINT GRUSHEVSKAYA_ALBUM_CHK3 
    CHECK (QUANTITY_OF_SOLD >= 0) ENABLE;

ALTER TABLE GRUSHEVSKAYA_ALBUM 
    MODIFY (RECORD_ARRAY NOT NULL ENABLE);
/

-- Связь «многие-ко-многим» SINGER-RECORD

-- Перед вставкой или обновлением записи
-- удалить NULL-значения исполнителей и уплотнить список исполнителей.
-- При обновлении проверить не пуст ли список исполнителей. 
-- Список исполнителей не должен быть пустым.
-- Если запись содержится в одном из альбомов, 
-- то список исполнителей изменять нельзя.
-- Если подмножество исполнителей не соответствует таблице исполнителей,
-- то отменить вставку или "откатить" обновление
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORDS
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_RECORD
FOR EACH ROW
DECLARE
    LIST_NAME GRUSHEVSKAYA_SINGER_TAB;
    FLAG_RECORD_USES BOOLEAN := FALSE;
BEGIN
    -- Удаление пустот во вл.таб.
    FOR i IN 1..:NEW.SINGER_LIST.COUNT
    LOOP
        IF :NEW.SINGER_LIST(i) IS NULL THEN 
            :NEW.SINGER_LIST.DELETE(i);
        END IF;
    END LOOP;
    :NEW.SINGER_LIST := SET(:NEW.SINGER_LIST);
    -- Список исполнителей не должен быть пуст
    IF UPDATING
       AND :NEW.SINGER_LIST IS EMPTY THEN
        :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('Запись с идентификатором ' 
                || :OLD.ID 
                || ' не была обновлена.');
            DBMS_OUTPUT.PUT_LINE('Список исполнителей обновлять нельзя,' 
                || ' так как исполнитель хотя бы один должен быть.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
    END IF;
    -- Запись уже содержится в одном из альбомов => обновлять исп. нельзя
    FOR ALBUM_ROW IN (SELECT * FROM GRUSHEVSKAYA_ALBUM)
    LOOP
        FOR i IN 1..ALBUM_ROW.RECORD_ARRAY.COUNT
        LOOP
            IF ALBUM_ROW.RECORD_ARRAY(i) = :OLD.ID THEN
                FLAG_RECORD_USES := TRUE;
            END IF;
        END LOOP;
    END LOOP;
    IF UPDATING
        AND FLAG_RECORD_USES
        AND NOT (SET(:NEW.SINGER_LIST) = SET(:OLD.SINGER_LIST)) THEN
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('Запись с идентификатором ' 
                || :OLD.ID 
                || ' не была обновлена.');
            DBMS_OUTPUT.PUT_LINE('Список исполнителей обновлять нельзя,' 
                || ' так как запись уже содержится в одном из альбомов.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
    END IF;
    -- Проверка внеш.кл.
    -- Если подмножество исполнителей не соответствует таблице исполнителей,
    -- то отменить вставку или "откатить" обновление
    SELECT NAME BULK COLLECT INTO LIST_NAME FROM GRUSHEVSKAYA_SINGER;
    IF :NEW.SINGER_LIST NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('Некорректный список исполнителей.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD;
        ELSE
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('Запись с идентификатором ' 
                || :OLD.ID 
                || ' не была обновлена из-за нарушения внешнего ключа (исполнители).');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
        END IF;
    END IF;
END;
/
-- Проверка внеш.кл.
-- Перед удалением исполнителя
-- нужно проверить нет ли у него записей.
-- Если есть, то удалять нельзя.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_SINGERS_DEL
BEFORE DELETE ON GRUSHEVSKAYA_SINGER
FOR EACH ROW
BEGIN
    FOR RECORD_ROW IN (SELECT * FROM GRUSHEVSKAYA_RECORD)
    LOOP
        FOR i IN 1..RECORD_ROW.SINGER_LIST.COUNT
        LOOP
            IF RECORD_ROW.SINGER_LIST(i) = :OLD.NAME THEN                
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_SINGERS_DEL');
                DBMS_OUTPUT.PUT_LINE('Исполнителя с идентификатором ' 
                    || :OLD.NAME 
                    || ' удалять нельзя - у него есть треки.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_SINGER_DEL;
            END IF;
        END LOOP;
    END LOOP;
END;
/
-- Имитация внеш.кл.
-- После обновления исполнителя
-- нужно обновить его имя для всех записей
-- и обновить саму запись
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_SINGERS_UDP
FOR UPDATE OF NAME ON GRUSHEVSKAYA_SINGER
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF VARCHAR2(100 BYTE) INDEX BY PLS_INTEGER;
    SINGERS_CHANGES CHANGES_ARR;
    AFTER EACH ROW IS
    BEGIN
        SINGERS_CHANGES(:OLD.NAME) := :NEW.NAME;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        LIST_NAME GRUSHEVSKAYA_SINGER_TAB;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR RECORD_ROW IN (SELECT * FROM GRUSHEVSKAYA_RECORD)
        LOOP
            FLAG := FALSE;
            LIST_NAME := RECORD_ROW.SINGER_LIST;
            FOR i IN 1..LIST_NAME.COUNT 
            LOOP
                IF SINGERS_CHANGES.EXISTS(LIST_NAME(i)) THEN
                    LIST_NAME(i) := SINGERS_CHANGES(LIST_NAME(i));
                    FLAG := TRUE;
                END IF;
            END LOOP;
            IF FLAG = TRUE THEN
                UPDATE GRUSHEVSKAYA_RECORD
                    SET SINGER_LIST = SET(LIST_NAME)
                    WHERE ID = RECORD_ROW.ID;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- Связь «многие-ко-многим» RECORD-ALBUM

-- Если альбом продан, то добавлять треки нельзя.
-- Перед вставкой или обновлением альбома
-- проверить, что все записи существуют.
-- Если нет, то либо отменить втавку, 
-- либо "откатить" обновление.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_ALBUM
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_ALBUM
FOR EACH ROW
DECLARE
    TYPE UNIQUE_RECORDS IS TABLE OF NUMBER INDEX BY VARCHAR(100);
    LIST_UNIQUE_RECORDS UNIQUE_RECORDS;
    UNIQUE_RECORDS_VARRAY GRUSHEVSKAYA_RECORD_ARR := GRUSHEVSKAYA_RECORD_ARR();
    CURRENT_UNIQUE_RECORD VARCHAR2(100);
    TYPE GRUSHEVSKAYA_RECORD_TAB IS TABLE OF NUMBER(10, 0);
    LIST_ID GRUSHEVSKAYA_RECORD_TAB;    
BEGIN
    IF UPDATING('RECORD_ARRAY') THEN
--         Удаление дубликатов из VARRAY
        FOR k IN 1..:NEW.RECORD_ARRAY.COUNT
        LOOP
            IF NOT :NEW.RECORD_ARRAY(k) IS NULL THEN
                IF NOT LIST_UNIQUE_RECORDS.EXISTS(:NEW.RECORD_ARRAY(k)) THEN
                    LIST_UNIQUE_RECORDS(:NEW.RECORD_ARRAY(k)) := k;
                END IF;                
            END IF;
        END LOOP;
        UNIQUE_RECORDS_VARRAY.EXTEND(30);
        CURRENT_UNIQUE_RECORD := LIST_UNIQUE_RECORDS.FIRST;
        WHILE NOT CURRENT_UNIQUE_RECORD IS NULL
        LOOP
            UNIQUE_RECORDS_VARRAY(LIST_UNIQUE_RECORDS(CURRENT_UNIQUE_RECORD)) := CURRENT_UNIQUE_RECORD;
            CURRENT_UNIQUE_RECORD := LIST_UNIQUE_RECORDS.NEXT(CURRENT_UNIQUE_RECORD);
        END LOOP;
        :NEW.RECORD_ARRAY := UNIQUE_RECORDS_VARRAY;
        -- Если альбом продан, то добавлять треки нельзя.    
        IF :OLD.QUANTITY_OF_SOLD > 0 THEN
            FOR j IN 1..:OLD.RECORD_ARRAY.COUNT
            LOOP
                IF :NEW.RECORD_ARRAY(j) IS NULL AND :OLD.RECORD_ARRAY(j) IS NULL THEN
                    CONTINUE;
                END IF;
                IF :NEW.RECORD_ARRAY(j) IS NULL OR :OLD.RECORD_ARRAY(j) IS NULL THEN
                    :NEW.ID := :OLD.ID;
                    :NEW.NAME := :OLD.NAME;
                    :NEW.PRICE := :OLD.PRICE;
                    :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                    :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                    :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                               
                    DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                    DBMS_OUTPUT.PUT_LINE('Альбом с идентификатором ' 
                        || :OLD.ID 
                        || ' не был обновлен. Нельзя добавлять треки, если альбом продан.');
                    RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
                END IF;
                IF :NEW.RECORD_ARRAY(j) <> :OLD.RECORD_ARRAY(j) THEN
                    :NEW.ID := :OLD.ID;
                    :NEW.NAME := :OLD.NAME;
                    :NEW.PRICE := :OLD.PRICE;
                    :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                    :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                    :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                               
                    DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                    DBMS_OUTPUT.PUT_LINE('Альбом с идентификатором ' 
                        || :OLD.ID 
                        || ' не был обновлен. Нельзя добавлять треки, если альбом продан.');
                    RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- Проверка внеш.кл.
    -- Перед вставкой или обновлением альбома
    -- проверить, что все записи существуют.
    -- Если нет, то либо отменить втавку, 
    -- либо "откатить" обновление.
    SELECT ID BULK COLLECT INTO LIST_ID FROM GRUSHEVSKAYA_RECORD;
    FOR i IN 1..:NEW.RECORD_ARRAY.COUNT
    LOOP
       IF NOT :NEW.RECORD_ARRAY(i) IS NULL
          AND NOT :NEW.RECORD_ARRAY(i) MEMBER LIST_ID THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('Некорректный список записей.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM;
            ELSE
                :NEW.ID := :OLD.ID;
                :NEW.NAME := :OLD.NAME;
                :NEW.PRICE := :OLD.PRICE;
                :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                          
                DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('Альбом с идентификатором ' 
                    || :OLD.ID 
                    || ' не был обновлен из-за нарушения внешнего ключа (записи).');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE;
            END IF;
        END IF;
    END LOOP;    
END;
/
-- Проверка внеш.кл.
-- Перед удалением записи проверить нет ли ее в альбомах.
-- Если есть, то удалять нельзя.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORD_DEL
BEFORE DELETE ON GRUSHEVSKAYA_RECORD
FOR EACH ROW
BEGIN
    FOR ALBUM_ROW IN (SELECT * FROM GRUSHEVSKAYA_ALBUM)
    LOOP
        FOR i IN 1..ALBUM_ROW.RECORD_ARRAY.COUNT
        LOOP
            IF ALBUM_ROW.RECORD_ARRAY(i) = :OLD.ID THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORD_DEL');
                DBMS_OUTPUT.PUT_LINE('Запиь с идентификатором ' 
                    || :OLD.ID 
                    || ' удалять нельзя - она есть в альбоме.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD_DEL;
            END IF;
        END LOOP;
    END LOOP;
END;
/
-- Имитация внеш.кл.
-- После обновления записи 
-- нужно обновить все ее id во всех альбомах
-- и обновить сами альбомы.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORD_UDP
FOR UPDATE OF ID ON GRUSHEVSKAYA_RECORD
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF NUMBER(10,0) INDEX BY PLS_INTEGER;
    RECORD_CHANGES CHANGES_ARR;
    AFTER EACH ROW IS
    BEGIN
        RECORD_CHANGES(:OLD.ID) := :NEW.ID;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        ID_ARR GRUSHEVSKAYA_RECORD_ARR;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR ALBUM_ROW IN (SELECT * FROM GRUSHEVSKAYA_ALBUM)
        LOOP
            FLAG := FALSE;
            ID_ARR := ALBUM_ROW.RECORD_ARRAY;
            FOR i IN 1..ID_ARR.COUNT 
            LOOP
                IF RECORD_CHANGES.EXISTS(ID_ARR(i)) THEN
                    ID_ARR(i) := RECORD_CHANGES(ID_ARR(i));
                    FLAG := TRUE;
                END IF;
            END LOOP;
            IF FLAG = TRUE THEN
                UPDATE GRUSHEVSKAYA_ALBUM
                    SET RECORD_ARRAY = ID_ARR
                    WHERE ID = ALBUM_ROW.ID;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- Пакет GRUSHEVSKAYA_PACKAGE с реализованным функционалом

CREATE OR REPLACE 
PACKAGE GRUSHEVSKAYA_PACKAGE AS
    -- Добавить страну в словарь.
    PROCEDURE ADD_IN_DICT_COUNTRY (
        -- Название страны
        NAME VARCHAR2
    );
    -- Добавить стиль в словарь.
    PROCEDURE ADD_IN_DICT_STYLE (
        -- Название стиля
        NAME VARCHAR2
    );
    
    -- Минимальный функционал
    
    -- 1) Добавить запись (изначально указывается один исполнитель).
    PROCEDURE ADD_RECORD (
        -- Название
        NAME VARCHAR2, 
        -- Количество часов звучания
        HOURS NUMBER,
        -- Количество минут звучания
        MINUTES NUMBER,
        -- Количество секунд звучания
        SECONDS NUMBER,
        -- Стиль из словаря
        STYLE VARCHAR2,
        -- Имя исполнителя
        SINGER VARCHAR2
    );
    -- 2) Добавить исполнителя для записи 
    -- (если указанная запись не добавлена ни в один альбом 
    --  - Условие проверяется на уровне триггера).
    PROCEDURE ADD_SINGER_IN_RECORD (
        -- ID записи
        RECORD_ID NUMBER,
        -- Имя исполнителя
        SINGER_NAME VARCHAR2
    );
    -- 3) Добавить исполнителя.
    PROCEDURE ADD_SINGER (
        -- Имя (ФИО)
        NAME VARCHAR2, 
        -- Страна из словаря
        COUNTRY VARCHAR2
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома с одной записью.
    PROCEDURE ADD_ALBUM (
        -- Название
        NAME VARCHAR2,
        -- Цена (>= 0)
        PRICE NUMBER,
        -- Количество на складе (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- Количество проданных альбомов (>= 0)
        QUANTITY_OF_SOLD NUMBER, 
        -- ID добавляемой записи
        RECORD_ID NUMBER
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома без записей.
    PROCEDURE ADD_ALBUM (
        -- Название
        NAME VARCHAR2,
        -- Цена (>= 0)
        PRICE NUMBER,
        -- Количество на складе (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- Количество проданных альбомов (>= 0)
        QUANTITY_OF_SOLD NUMBER
    );
    -- 5) Добавить трек в альбом 
    -- (если не продано ни одного экземпляра
    --  - Условие проверяется на уровне триггера).
    PROCEDURE ADD_RECORD_IN_ALBUM (
        -- ID альбома
        ALBUM_ID NUMBER,
        -- ID добавляемой записи 
        RECORD_ID NUMBER
    );
    -- 6) Список альбомов в продаже (количество на складе больше 0).
    PROCEDURE PRINT_ALBUMS_IN_STOCK;
    -- 7) Список исполнителей.
    PROCEDURE PRINT_SINGERS;
    -- 8) Поставка альбома
    -- (количество на складе увеличивается на указанное значение).
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        -- ID альбома
        ALBUM_ID NUMBER,
        -- Количество
        QUANTITY NUMBER
    );
    -- 9) Продать альбом 
    -- (количество на складе уменьшается, проданных – увеличивается; 
    -- продать можно только альбомы, в которых есть хотя бы один трек
    --  - Условие проверяется в самой функции). 
    PROCEDURE SELL_ALBUMS(
        -- ID альбома
        ALBUM_ID NUMBER,
        -- Количество
        QUANTITY NUMBER
    );
    -- 10) Удалить исполнителей, у которых нет ни одной записи.
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS;
    
    -- Основной функционал
    
    -- 11) Трек-лист указанного альбома 
    -- с указанием суммарного времени звучания альбома.
    PROCEDURE PRINT_ALBUM_RECORDS(ALBUM_ID NUMBER);
    -- 12) Выручка магазина 
    -- (суммарная стоимость проданных альбомов 
    -- по каждому в отдельности 
    -- и по магазину в целом).
    PROCEDURE PRINT_INCOME;
    -- 13) Удалить трек с указанным номером из альбома 
    -- с пересчётом остальных номеров 
    -- (если не продано ни одного экземпляра альбома
    --  - Условие проверяется на уровне триггера).
    PROCEDURE DELETE_RECORD_FROM_ALBUM(
        -- ID альбома
        ALBUM_ID NUMBER,
        -- Номер звучания записи в альбоме
        RECORD_NUMBER NUMBER
    );
    -- 14) Удалить исполнителя из записи 
    -- (если запись не входит ни в один альбом 
    -- и если этот исполнитель не единственный
    --  - Условия проверяются на уровне триггера). 
    PROCEDURE DELETE_SINGER_FROM_RECORD(
        -- ID записи
        RECORD_ID NUMBER,
        -- Номер исполнителя в списке
        SINGER_NUMBER NUMBER
    );
    -- 15) Определить предпочитаемый музыкальный стиль указанного исполнителя 
    -- (стиль, в котором записано большинство его треков). 
    PROCEDURE PRINT_SINGER_STYLE(
        -- Имя исполнителя
        SINGER_NAME VARCHAR2
    );
    -- 16) Определить предпочитаемый музыкальный стиль 
    -- по каждой стране происхождения исполнителей.
    PROCEDURE PRINT_COUNTRY_STYLE; 
    -- 17) Определить авторство альбомов 
    -- (для каждого альбома выводится 
    -- исполнитель или список исполнителей,
    -- если все треки этого альбома записаны 
    -- одним множеством исполнителей; 
    -- в противном случае выводится «Коллективный сборник»).
    PROCEDURE PRINT_ALBUM_AUTHOR(
        -- ID альбома
        ALBUM_ID NUMBER
    );
END;
/
CREATE OR REPLACE
PACKAGE BODY GRUSHEVSKAYA_PACKAGE AS
    PROCEDURE PRINT_MSG_EX(SQLCODE NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Ой. Неизвестное исключение.');
        DBMS_OUTPUT.PUT_LINE('Код: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Сообщение: ' || SQLERRM(SQLCODE));        
    END PRINT_MSG_EX;
    
    PROCEDURE ADD_IN_DICT_COUNTRY (
        NAME VARCHAR2
    )IS
    BEGIN
        INSERT INTO GRUSHEVSKAYA_DICT_COUNTRY (NAME) VALUES (NAME);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Страна ' || NAME || ' успешно добавлена.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_COUNTRY');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_IN_DICT_COUNTRY;
    
    PROCEDURE ADD_IN_DICT_STYLE (
        NAME VARCHAR2
    )IS
    BEGIN
        INSERT INTO GRUSHEVSKAYA_DICT_STYLE (NAME) VALUES (NAME);
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE('Стиль ' || NAME || ' успешно добавлен.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_STYLE');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_IN_DICT_STYLE;
    
    PROCEDURE ADD_RECORD(
        NAME VARCHAR2,
        HOURS NUMBER,
        MINUTES NUMBER,
        SECONDS NUMBER,
        STYLE VARCHAR2,
        SINGER VARCHAR2
    ) IS
        TIME INTERVAL DAY(0) TO SECOND(0);
    BEGIN
        TIME := NUMTODSINTERVAL(HOURS, 'HOUR') 
            + NUMTODSINTERVAL(MINUTES, 'MINUTE') 
            + NUMTODSINTERVAL(SECONDS, 'SECOND');
        INSERT INTO GRUSHEVSKAYA_RECORD (ID, NAME, TIME, STYLE, SINGER_LIST)
            VALUES (
            GRUSHEVSKAYA_NUM_RECORD.NEXTVAL, 
            NAME, 
            TIME, 
            STYLE, 
            GRUSHEVSKAYA_SINGER_TAB(SINGER)
        );
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            'Запись ' || NAME 
            || ' с ID ' || GRUSHEVSKAYA_NUM_RECORD.CURRVAL 
            || ' успешно добавлена.'
        );
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет стиля ' || STYLE || ' в словаре.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSIF SQLCODE = -1873 THEN
            DBMS_OUTPUT.PUT_LINE('Неверное значение времени.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_RECORD; 
    
    PROCEDURE ADD_SINGER_IN_RECORD (
        RECORD_ID NUMBER,
        SINGER_NAME VARCHAR2
    ) IS
        TMP_SINGER_LIST GRUSHEVSKAYA_SINGER_TAB;
    BEGIN
        IF SINGER_NAME IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять NULL-значения.');
            RETURN;
        END IF;
        SELECT SINGER_LIST INTO TMP_SINGER_LIST 
            FROM GRUSHEVSKAYA_RECORD
            WHERE ID = RECORD_ID;
        TMP_SINGER_LIST.EXTEND;
        TMP_SINGER_LIST(TMP_SINGER_LIST.LAST) := SINGER_NAME;
        UPDATE GRUSHEVSKAYA_RECORD
            SET SINGER_LIST = TMP_SINGER_LIST
            WHERE ID = RECORD_ID;
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            'Исполнитель ' || SINGER_NAME 
            || ' успешно добавлен в запись с ID ' || RECORD_ID || '.'
        );
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER_IN_RECORD');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка в несуществующую запись.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_SINGER_IN_RECORD;
    
    PROCEDURE ADD_SINGER (
        NAME VARCHAR2,
        COUNTRY VARCHAR2
    ) IS
    BEGIN
        INSERT INTO GRUSHEVSKAYA_SINGER (NAME, COUNTRY)
            VALUES (NAME, COUNTRY);
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Исполнитель ' || NAME || ' успешно добавлен.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет страны ' || COUNTRY || ' в словаре.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_SINGER;
        
    PROCEDURE ADD_ALBUM (
        NAME VARCHAR2,
        PRICE NUMBER,
        QUANTITY_IN_STOCK NUMBER,
        QUANTITY_OF_SOLD NUMBER, 
        RECORD_ID NUMBER
    ) IS
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR := GRUSHEVSKAYA_RECORD_ARR();
    BEGIN
        RECORD_ARR.EXTEND(30);
        RECORD_ARR(1) := RECORD_ID;
        INSERT INTO GRUSHEVSKAYA_ALBUM (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARRAY
        ) VALUES (
            GRUSHEVSKAYA_NUM_ALBUM.NEXTVAL, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Альбом ' || NAME || ' с ID ' || GRUSHEVSKAYA_NUM_ALBUM.CURRVAL || ' успешно добавлен.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка несуществующей записи в альбом.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено одно из условий.');
            DBMS_OUTPUT.PUT_LINE('Значение цены не может быть отрицательным.');
            DBMS_OUTPUT.PUT_LINE('Значения количества альбомов в продаже и проданных не могут быть отрицательными.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_ALBUM;
        
    PROCEDURE ADD_ALBUM (
        NAME VARCHAR2,
        PRICE NUMBER,
        QUANTITY_IN_STOCK NUMBER,
        QUANTITY_OF_SOLD NUMBER
    ) IS
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR := GRUSHEVSKAYA_RECORD_ARR();
    BEGIN
        RECORD_ARR.EXTEND(30);
        INSERT INTO GRUSHEVSKAYA_ALBUM (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARRAY
        ) VALUES (
            GRUSHEVSKAYA_NUM_ALBUM.NEXTVAL, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Альбом ' || NAME || ' с ID ' || GRUSHEVSKAYA_NUM_ALBUM.CURRVAL || ' успешно добавлен.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено одно из условий.');
            DBMS_OUTPUT.PUT_LINE('Значение цены не может быть отрицательным.');
            DBMS_OUTPUT.PUT_LINE('Значения количества альбомов в продаже и проданных не могут быть отрицательными.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_ALBUM;
    
    PROCEDURE ADD_RECORD_IN_ALBUM (
        ALBUM_ID NUMBER, 
        RECORD_ID NUMBER
    )IS
        RECORD_SERIAL_NUMBER NUMBER := -1;
        TMP_RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
    BEGIN        
        IF RECORD_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять NULL-значения.');
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO TMP_RECORD_ARR
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        FOR i IN REVERSE 1..TMP_RECORD_ARR.COUNT
        LOOP
            IF TMP_RECORD_ARR(i) IS NULL THEN
                RECORD_SERIAL_NUMBER := i;
            END IF;
        END LOOP;
        IF RECORD_SERIAL_NUMBER = -1 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Альбом с ID ' 
                || ALBUM_ID 
                || ' не может содержать больше 30 записей. Запись с ID ' 
                || RECORD_ID 
                || ' не добавлена.'
            );
        END IF;
        TMP_RECORD_ARR(RECORD_SERIAL_NUMBER) := RECORD_ID;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET RECORD_ARRAY = TMP_RECORD_ARR
            WHERE ID = ALBUM_ID;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            'Запись с ID ' || RECORD_ID 
            || ' успешно добавлена в альбом с ID ' || ALBUM_ID || '.'
        );
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD_IN_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка в несуществующий альбом.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_RECORD_IN_ALBUM;
    
    PROCEDURE PRINT_ALBUMS_IN_STOCK 
    IS
        QUANTITY NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Альбомы в продаже:');
        FOR ALBUM IN (SELECT * FROM GRUSHEVSKAYA_ALBUM WHERE QUANTITY_IN_STOCK > 0)
        LOOP
            DBMS_OUTPUT.PUT_LINE(ALBUM.NAME);
            QUANTITY := QUANTITY + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Всего альбомов в продаже: ' || QUANTITY || '.');    
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_ALBUMS_IN_STOCK');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_ALBUMS_IN_STOCK;
    
    PROCEDURE PRINT_SINGERS
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Все исполнители:');
        FOR SINGER IN (SELECT * FROM GRUSHEVSKAYA_SINGER)
        LOOP
            DBMS_OUTPUT.PUT_LINE(SINGER.NAME);
        END LOOP;    
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_SINGERS');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_SINGERS;
    
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        ALBUM_ID NUMBER,
        QUANTITY NUMBER
    ) IS
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('В продажу поступило отрицательное ' 
                || 'количество альбомов c ID ' 
                || ALBUM_ID || '. Количество не обновлено.');
            RETURN;
        END IF;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET QUANTITY_IN_STOCK = QUANTITY_IN_STOCK + QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('В продажу поступило ' 
            || QUANTITY || ' альбомов c ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUMS_IN_STOCK');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Поставка несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;        
    END ADD_ALBUMS_IN_STOCK;    
    
    PROCEDURE SELL_ALBUMS(
        ALBUM_ID NUMBER,
        QUANTITY NUMBER
    ) IS
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
        FLAG_ONE_RECORD BOOLEAN := FALSE;
        MAX_QUANTITY NUMBER;
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('Подается отрицательное количество альбомов c ID ' 
                || ALBUM_ID || '. Количество не обновлено.');
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO RECORD_ARR 
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                FLAG_ONE_RECORD := TRUE;
            END IF;
        END LOOP;
        IF NOT FLAG_ONE_RECORD THEN
            DBMS_OUTPUT.PUT_LINE('Продать альбом c ID ' 
                || ALBUM_ID || ' нельзя. В альбоме нет треков.');
            RETURN;
        END IF;
        SELECT QUANTITY_IN_STOCK INTO MAX_QUANTITY 
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        MAX_QUANTITY := LEAST(MAX_QUANTITY, QUANTITY);
        IF MAX_QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('Продать альбом c ID ' 
                || ALBUM_ID || ' нельзя. Альбомов нет на складе.');
            RETURN;
        END IF;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET 
                QUANTITY_IN_STOCK = QUANTITY_IN_STOCK - MAX_QUANTITY,
                QUANTITY_OF_SOLD = QUANTITY_OF_SOLD + MAX_QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Продано ' || MAX_QUANTITY 
            || ' альбомов c ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN SELL_ALBUMS');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Продажа несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;       
    END SELL_ALBUMS;
    
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS
    IS
        DEL_SINGERS_LIST GRUSHEVSKAYA_SINGER_TAB;
    BEGIN
        SELECT NAME BULK COLLECT INTO DEL_SINGERS_LIST FROM GRUSHEVSKAYA_SINGER;
        FOR RECORD IN (SELECT * FROM GRUSHEVSKAYA_RECORD)
        LOOP
           FOR i IN 1..RECORD.SINGER_LIST.COUNT
            LOOP
                FOR k IN 1..DEL_SINGERS_LIST.COUNT
                LOOP                   
                    IF NOT DEL_SINGERS_LIST(k) IS NULL
                       AND NOT RECORD.SINGER_LIST(i) IS NULL
                       AND DEL_SINGERS_LIST(k) = RECORD.SINGER_LIST(i) THEN
                        DEL_SINGERS_LIST(k) := NULL;
                    END IF;                
                END LOOP;
            END LOOP;
        END LOOP;
        FOR j IN 1..DEL_SINGERS_LIST.COUNT
        LOOP
            IF NOT DEL_SINGERS_LIST(j) IS NULL THEN
                DELETE FROM GRUSHEVSKAYA_SINGER
                WHERE NAME = DEL_SINGERS_LIST(j);
                DBMS_OUTPUT.PUT_LINE('Удален исполнитель ' 
                    || DEL_SINGERS_LIST(j) || '.');
            END IF;
        END LOOP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Исполнители без записей удалены успешно.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN DELETE_SINGERS_WITHOUT_RECORDS');
        PRINT_MSG_EX(SQLCODE);
    END DELETE_SINGERS_WITHOUT_RECORDS;    
    
    PROCEDURE PRINT_ALBUM_RECORDS(
        ALBUM_ID NUMBER
    ) IS
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
        RECORD GRUSHEVSKAYA_RECORD%ROWTYPE;
        TIME INTERVAL DAY(0) TO SECOND(0) := NUMTODSINTERVAL(0, 'SECOND');
        SINGERS VARCHAR2(300) := '';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Альбом №' || ALBUM_ID);
        SELECT RECORD_ARRAY INTO RECORD_ARR
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                SELECT * INTO RECORD FROM GRUSHEVSKAYA_RECORD 
                    WHERE ID = RECORD_ARR(i);
                SINGERS := '-';
                FOR j IN 1..RECORD.SINGER_LIST.COUNT
                LOOP
                    SINGERS := SINGERS || ' ' || RECORD.SINGER_LIST(j);
                END LOOP;
                DBMS_OUTPUT.PUT_LINE(
                    '№' 
                    || LPAD(i, 2, '0')
                    || ' ' 
                    || RECORD.STYLE
                    || ', ' 
                    || LPAD(EXTRACT(HOUR FROM RECORD.TIME), 2, '0') || ':' 
                    || LPAD(EXTRACT(MINUTE FROM RECORD.TIME), 2, '0') || ':' 
                    || LPAD(EXTRACT(SECOND FROM RECORD.TIME), 2, '0')
                    || ' ' 
                    || RECORD.NAME
                    || ' ' 
                    || SINGERS
                );
                TIME := RECORD.TIME + TIME;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(
            'Общее время звучания: '
            || LPAD(EXTRACT(HOUR FROM TIME), 2, '0') || ':' 
            || LPAD(EXTRACT(MINUTE FROM TIME), 2, '0') || ':' 
            || LPAD(EXTRACT(SECOND FROM TIME), 2, '0')
            || '.'
        );        
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_ALBUM_RECORDS');
        IF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Печать несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END PRINT_ALBUM_RECORDS;
    
    PROCEDURE PRINT_INCOME
    IS
        TOTAL_INCOME NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Выручка магазина');
        FOR ALBUM IN (SELECT * FROM GRUSHEVSKAYA_ALBUM)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Альбомов ID ' 
                || ALBUM.ID 
                || ' с именем ' 
                || ALBUM.NAME
                || ' продано на сумму: '
                || ALBUM.PRICE * ALBUM.QUANTITY_OF_SOLD
            );
            TOTAL_INCOME := TOTAL_INCOME + ALBUM.PRICE * ALBUM.QUANTITY_OF_SOLD;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Выручка магазина в целом: ' || TOTAL_INCOME || '.');       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_INCOME');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_INCOME;    
    
    PROCEDURE DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID NUMBER,
        RECORD_NUMBER NUMBER
    ) IS
        TMP_RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
        TMP_QUANTITY_OF_SOLD NUMBER;
    BEGIN
        SELECT QUANTITY_OF_SOLD INTO TMP_QUANTITY_OF_SOLD
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        IF TMP_QUANTITY_OF_SOLD > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Удалить трек №' 
                || RECORD_NUMBER || ' нельзя, так как альбом продан');
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO TMP_RECORD_ARR 
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        FOR i IN RECORD_NUMBER..TMP_RECORD_ARR.COUNT-1
        LOOP
            TMP_RECORD_ARR(i) := TMP_RECORD_ARR(i+1);
        END LOOP;
        TMP_RECORD_ARR(TMP_RECORD_ARR.COUNT) := NULL;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET RECORD_ARRAY = TMP_RECORD_ARR
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Трек №' || RECORD_NUMBER || ' удален');            
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN DELETE_RECORD_FROM_ALBUM');
        IF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');        
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Удаление несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;    
    END DELETE_RECORD_FROM_ALBUM;    
    
    PROCEDURE DELETE_SINGER_FROM_RECORD(
        RECORD_ID NUMBER,
        SINGER_NUMBER NUMBER
    ) IS
        TMP_SINGER_LIST GRUSHEVSKAYA_SINGER_TAB;
    BEGIN
        SELECT SINGER_LIST INTO TMP_SINGER_LIST 
            FROM GRUSHEVSKAYA_RECORD
            WHERE ID = RECORD_ID;            
        TMP_SINGER_LIST.DELETE(SINGER_NUMBER);        
        UPDATE GRUSHEVSKAYA_RECORD
            SET SINGER_LIST = TMP_SINGER_LIST
            WHERE ID = RECORD_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Исполнитель №' || SINGER_NUMBER || ' удален.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_UPDATE_SINGER_IN_RECORD THEN
        RETURN;
    WHEN GRUSHEVSKAYA_EXCEPTIONS.WARNING_UPDATE THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN DELETE_SINGER_FROM_RECORD');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');       
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Удаление из несуществующего исполнителя невозможно.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;        
    END DELETE_SINGER_FROM_RECORD;
        
    PROCEDURE PRINT_SINGER_STYLE(
        SINGER_NAME VARCHAR2
    ) IS
        TYPE SINGER_STYLE IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
        SINGER_STYLE_LIST SINGER_STYLE;
        CURRENT_ELEM VARCHAR2(100);
        MAX_STYLE VARCHAR2(100);
    BEGIN
        FOR RECORD IN (SELECT * FROM GRUSHEVSKAYA_RECORD)
        LOOP
            FOR i IN 1..RECORD.SINGER_LIST.COUNT
            LOOP
                IF RECORD.SINGER_LIST(i) = SINGER_NAME THEN
                    IF SINGER_STYLE_LIST.EXISTS(RECORD.STYLE) THEN
                        SINGER_STYLE_LIST(RECORD.STYLE) := 
                            SINGER_STYLE_LIST(RECORD.STYLE) 
                            + 1;
                    ELSE
                        SINGER_STYLE_LIST(RECORD.STYLE) := 1;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
        MAX_STYLE := SINGER_STYLE_LIST.FIRST;
        CURRENT_ELEM := SINGER_STYLE_LIST.FIRST;
        WHILE NOT CURRENT_ELEM IS NULL
        LOOP  
            IF SINGER_STYLE_LIST(CURRENT_ELEM) > SINGER_STYLE_LIST(MAX_STYLE) THEN
                MAX_STYLE := CURRENT_ELEM;
            END IF;
            CURRENT_ELEM := SINGER_STYLE_LIST.NEXT(CURRENT_ELEM);
        END LOOP;
        IF MAX_STYLE IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Исполнитель не найден.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Наиболее популярный стиль у ' 
            || SINGER_NAME || ' - '  || MAX_STYLE || '.');       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_SINGER_STYLE');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_SINGER_STYLE;
    
    PROCEDURE PRINT_COUNTRY_STYLE
    IS
        TYPE SINGER_STYLE IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
        TYPE COUNTRY_STYLE IS TABLE OF SINGER_STYLE INDEX BY VARCHAR2(100);
        COUNTRY_STYLE_LIST COUNTRY_STYLE;
        TMP_COUNTRY VARCHAR2(100);
        CURRENT_COUNTRY VARCHAR2(100);
        CURRENT_STYLE VARCHAR2(100);
        MAX_STYLE VARCHAR2(100);
    BEGIN
        FOR RECORD IN (SELECT * FROM GRUSHEVSKAYA_RECORD)
        LOOP
            FOR i IN 1..RECORD.SINGER_LIST.COUNT
            LOOP
                SELECT COUNTRY INTO TMP_COUNTRY 
                    FROM GRUSHEVSKAYA_SINGER 
                    WHERE NAME =  RECORD.SINGER_LIST(i);
                IF COUNTRY_STYLE_LIST.EXISTS(TMP_COUNTRY)
                   AND COUNTRY_STYLE_LIST(TMP_COUNTRY).EXISTS(RECORD.STYLE) THEN
                    COUNTRY_STYLE_LIST(TMP_COUNTRY)(RECORD.STYLE) := 
                        COUNTRY_STYLE_LIST(TMP_COUNTRY)(RECORD.STYLE) 
                        + 1;
                ELSE
                    COUNTRY_STYLE_LIST(TMP_COUNTRY)(RECORD.STYLE) := 1;
                END IF; 
            END LOOP;
        END LOOP;
        CURRENT_COUNTRY := COUNTRY_STYLE_LIST.FIRST;
        WHILE NOT CURRENT_COUNTRY IS NULL
        LOOP
            MAX_STYLE := COUNTRY_STYLE_LIST(CURRENT_COUNTRY).FIRST;
            CURRENT_STYLE := COUNTRY_STYLE_LIST(CURRENT_COUNTRY).FIRST;
            WHILE NOT CURRENT_STYLE IS NULL
            LOOP  
                IF COUNTRY_STYLE_LIST(CURRENT_COUNTRY)(CURRENT_STYLE) 
                   > COUNTRY_STYLE_LIST(CURRENT_COUNTRY)(MAX_STYLE) THEN
                    MAX_STYLE := CURRENT_STYLE;
                END IF;
                CURRENT_STYLE := COUNTRY_STYLE_LIST(CURRENT_COUNTRY).NEXT(CURRENT_STYLE);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Наиболее популярный стиль в '  
                || CURRENT_COUNTRY || ' - ' || MAX_STYLE || '.');
            CURRENT_COUNTRY := COUNTRY_STYLE_LIST.NEXT(CURRENT_COUNTRY);
        END LOOP;       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_COUNTRY_STYLE');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_COUNTRY_STYLE; 
    
    PROCEDURE PRINT_ALBUM_AUTHOR(
        ALBUM_ID NUMBER
    ) IS
        TYPE ALBUM_SINGER IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
        ALBUM_SINGER_LIST ALBUM_SINGER;
        SINGERS GRUSHEVSKAYA_SINGER_TAB;
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
        RECORD_COUNT NUMBER := 0;
        CURRENT_SINGER VARCHAR(100);
        FLAG_GROUP BOOLEAN := FALSE;
    BEGIN
        SELECT RECORD_ARRAY INTO RECORD_ARR
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                RECORD_COUNT := RECORD_COUNT + 1;
                SELECT SINGER_LIST INTO SINGERS
                    FROM GRUSHEVSKAYA_RECORD
                    WHERE ID = RECORD_ARR(i);
                FOR j IN 1..SINGERS.COUNT
                LOOP
                    IF ALBUM_SINGER_LIST.EXISTS(SINGERS(j))THEN
                        ALBUM_SINGER_LIST(SINGERS(j)) := 
                            ALBUM_SINGER_LIST(SINGERS(j)) 
                            + 1;
                    ELSE
                        ALBUM_SINGER_LIST(SINGERS(j)) := 1;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        CURRENT_SINGER := ALBUM_SINGER_LIST.FIRST;
        WHILE NOT CURRENT_SINGER IS NULL
        LOOP
            IF ALBUM_SINGER_LIST(CURRENT_SINGER) <> RECORD_COUNT THEN
                FLAG_GROUP := TRUE;
            END IF;
            CURRENT_SINGER := ALBUM_SINGER_LIST.NEXT(CURRENT_SINGER);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Авторство альбома с ID ' || ALBUM_ID || '.');
        IF FLAG_GROUP THEN
            DBMS_OUTPUT.PUT_LINE('Коллективный сборник.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Исполнители');
            CURRENT_SINGER := ALBUM_SINGER_LIST.FIRST;
            WHILE NOT CURRENT_SINGER IS NULL
            LOOP
                DBMS_OUTPUT.PUT_LINE(CURRENT_SINGER);
                CURRENT_SINGER := ALBUM_SINGER_LIST.NEXT(CURRENT_SINGER);
            END LOOP;
        END IF;       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_ALBUM_AUTHOR');
        IF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Печать авторства несуществующего альбома невозможна.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END PRINT_ALBUM_AUTHOR;
END;
/
DECLARE 
BEGIN
    -- Тестовые данные    
    
    -- Альбом Thriller
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('США');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('Великобритания');
    
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Постдиско');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Поп-музыка');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Софт-рок');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Фанк');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Хард-рок');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Ритм-н-блюз');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Джаз');
    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Майкл Джексон', 'США');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Пол Маккартни', 'Великобритания');

    --1
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Wanna Be Startin’ Somethin’', 0, 6, 30, 'Постдиско', 'Майкл Джексон');    
    --2
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Baby Be Mine', 0, 4, 20, 'Поп-музыка', 'Майкл Джексон');    
    --3
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The Girl Is Mine', 0, 3, 41, 'Софт-рок', 'Майкл Джексон');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(3, 'Пол Маккартни');    
    --4
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Thriller', 0, 5, 58, 'Фанк', 'Майкл Джексон');    
    --5
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Beat It', 0, 4, 18, 'Хард-рок', 'Майкл Джексон');    
    --6
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Billie Jean', 0, 4, 50, 'Фанк', 'Майкл Джексон');    
    --7
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Human Nature', 0, 4, 6, 'Ритм-н-блюз', 'Майкл Джексон');    
    --8
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Pretty Young Thing', 0, 3, 58, 'Джаз', 'Майкл Джексон');    
    --9
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The Lady in My Life', 0, 5, 0, 'Ритм-н-блюз', 'Майкл Джексон');
    
    --1
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'Thriller', 
        PRICE => 792.50, 
        QUANTITY_IN_STOCK => 225, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 1
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 2
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 3
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 4
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 5
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 6
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 7
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 8
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 9
    );
    
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 1, QUANTITY => 37);
    
    -- Альбом Millennium
    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Backstreet Boys', 'США');

    --10
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Larger than life', 0, 3, 52, 'Поп-музыка', 'Backstreet Boys');
    --11
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('I want it that way', 0, 3, 33, 'Поп-музыка', 'Backstreet Boys'); 
    --12
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Show me the meaning of being lonely', 0, 3, 54, 'Поп-музыка', 'Backstreet Boys'); 
    --13
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('It’s gotta be you', 0, 2, 56, 'Поп-музыка', 'Backstreet Boys'); 
    --14
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('I need you tonight', 0, 4, 23, 'Поп-музыка', 'Backstreet Boys'); 
    --15
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Don’t want you back', 0, 3, 25, 'Поп-музыка', 'Backstreet Boys'); 
    --16
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Don’t wanna lose you now', 0, 3, 54, 'Поп-музыка', 'Backstreet Boys'); 
    --17
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The one', 0, 3, 46, 'Поп-музыка', 'Backstreet Boys'); 
    --18
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Back to your heart', 0, 4, 21, 'Поп-музыка', 'Backstreet Boys');  
    --19
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Spanish eyes', 0, 3, 53, 'Поп-музыка', 'Backstreet Boys');  
    --20
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('No one else comes close', 0, 3, 42, 'Поп-музыка', 'Backstreet Boys');  
    --21
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The perfect fan', 0, 4, 13, 'Поп-музыка', 'Backstreet Boys');    

    --2
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'Millennium', 
        PRICE => 836.24, 
        QUANTITY_IN_STOCK => 75, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 11
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 13
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 14
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 15
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 16
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 17
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 18
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 19
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 20
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 21
    );
    
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 2, QUANTITY => 42);
    
    -- ABBA Gold: Greatest Hits
    
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('Швеция');
    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('ABBA', 'Швеция');
    
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Диско');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('Баллада');
    
    --22 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Dancing Queen', 0, 3, 51, 'Диско', 'ABBA'); 
    --23 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Knowing Me, Knowing You', 0, 4, 3, 'Поп-музыка', 'ABBA'); 
    --24 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Take a Chance on Me', 0, 4, 6, 'Поп-музыка', 'ABBA'); 
    --25 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Mamma Mia', 0, 3, 33, 'Поп-музыка', 'ABBA'); 
    --26 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Lay All Your Love on Me', 0, 4, 35, 'Диско', 'ABBA'); 
    --27 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Super Trouper', 0, 4, 13, 'Поп-музыка', 'ABBA'); 
    --28 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('I Have a Dream', 0, 4, 42, 'Баллада', 'ABBA'); 
    --29 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The Winner Takes It All', 0, 4, 54, 'Баллада', 'ABBA'); 
    --30 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Money, Money, Money', 0, 3, 5, 'Поп-музыка', 'ABBA'); 
    --31 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('SOS', 0, 3, 23, 'Поп-музыка', 'ABBA'); 
    --32 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Chiquitita', 0, 5, 26, 'Поп-музыка', 'ABBA');  
    --33 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Fernando', 0, 4, 14, 'Поп-музыка', 'ABBA');  
    --34 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Voulez-Vous', 0, 5, 9, 'Диско', 'ABBA');  
    --35 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Gimme! Gimme! Gimme!', 0, 4, 46, 'Диско', 'ABBA');  
    --36 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Does Your Mother Know', 0, 3, 15, 'Поп-музыка', 'ABBA');  
    --37 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('One of Us', 0, 3, 56, 'Поп-музыка', 'ABBA');  
    --38 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('The Name of the Game', 0, 4, 51, 'Поп-музыка', 'ABBA');  
    --39 
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Thank You for the Music', 0, 3, 51, 'Баллада', 'ABBA');  
    --40
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Waterloo', 0, 2, 42, 'Поп-музыка', 'ABBA'); 
    
    --3
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'ABBA Gold: Greatest Hits', 
        PRICE => 921.34, 
        QUANTITY_IN_STOCK => 341, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 22
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 23
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 24
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 25
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 26
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 27
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 28
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 29
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 30
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 31
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 32
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 33
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 34
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 35
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 36
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 37
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 38
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 39
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 3,
        RECORD_ID => 40
    );  
        
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 3, QUANTITY => 142);
        
    -- Валентина Толкунова & Лев Лещенко
        
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('Россия');
    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Валентина Толкунова', 'Россия');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Лев Лещенко', 'Россия');    
      
    --41
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Старт даёт Москва', 0, 2, 52, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(41, 'Лев Лещенко'); 
    --42
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Добрые приметы', 0, 2, 16, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(42, 'Лев Лещенко'); 
    --43
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Олимпийский Мишка', 0, 3, 32, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(43, 'Лев Лещенко');    
    --44
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Вальс влюблённых', 0, 2, 34, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(44, 'Лев Лещенко');
    --45
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Ночной звонок', 0, 4, 54, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(45, 'Лев Лещенко');
    --46
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Осень', 0, 3, 49, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(46, 'Лев Лещенко');
    
    --4
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'Валентина Толкунова и Лев Лещенко', 
        PRICE => 127.99, 
        QUANTITY_IN_STOCK => 51, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 41
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 4,
        RECORD_ID => 42
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 4,
        RECORD_ID => 43
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 4,
        RECORD_ID => 44
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 4,
        RECORD_ID => 45
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 4,
        RECORD_ID => 46
    );
    
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 4, QUANTITY => 7);
    
    -- Разное
    
    --5
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'Разное', 
        PRICE => 87.99, 
        QUANTITY_IN_STOCK => 10, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 3
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 4
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 8
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 12
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 16
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 17
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 23
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 29
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 32
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 38
    );
    
    
    -- Пустой альбом
    --6 
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'Пустой альбом', 
        PRICE => 0, 
        QUANTITY_IN_STOCK => 0, 
        QUANTITY_OF_SOLD => 0
    );
    
    -- Невостребованные исполнители  
        
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Иванов Иван', 'Россия');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Сидоров Алексей', 'Россия');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Петров Петр', 'Россия');
    
    -- Песня без альбома
    
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('СССР');
    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Иосиф Кобзон', 'Россия');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Майя Кристалинская', 'СССР');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('Эдуард Хиль', 'Россия');
    
    --47
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('Песня остаётся с человеком', 0, 3, 49, 'Поп-музыка', 'Валентина Толкунова');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(47, 'Лев Лещенко');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(47, 'Иосиф Кобзон');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(47, 'Майя Кристалинская');    
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(47, 'Эдуард Хиль');    
    
END;













