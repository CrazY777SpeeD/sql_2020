--------------------------------------------------------
--  File created - понедельник-ноября-16-2020   
--------------------------------------------------------
DROP TYPE "GRUSHEVSKAYA_RECORD_ARR";
DROP TYPE "GRUSHEVSKAYA_SINGER_TAB";
DROP TYPE "GRUSHEVSKAYA_TIME";
DROP TABLE "GRUSHEVSKAYA_ALBUM" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_DICT_COUNTRY" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_DICT_STYLE" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_RECORD" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_SINGER" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_SINGER_LIST" cascade constraints;
DROP PACKAGE "GRUSHEVSKAYA_EXCEPTIONS";
DROP PACKAGE "GRUSHEVSKAYA_PACKAGE";
--------------------------------------------------------
--  DDL for Type GRUSHEVSKAYA_RECORD_ARR
--------------------------------------------------------

  CREATE OR REPLACE TYPE "GRUSHEVSKAYA_RECORD_ARR" AS VARRAY(30) OF NUMBER(10,0);

/
--------------------------------------------------------
--  DDL for Type GRUSHEVSKAYA_SINGER_TAB
--------------------------------------------------------

  CREATE OR REPLACE TYPE "GRUSHEVSKAYA_SINGER_TAB" AS TABLE OF VARCHAR2(100 BYTE);

/
--------------------------------------------------------
--  DDL for Type GRUSHEVSKAYA_TIME
--------------------------------------------------------

  CREATE OR REPLACE TYPE "GRUSHEVSKAYA_TIME" AS OBJECT(
    HOURS NUMBER(2,0),
    MINUTES NUMBER(2,0),
    SECONDS NUMBER(2,0),
    CONSTRUCTOR FUNCTION GRUSHEVSKAYA_TIME(
        HOURS IN NUMBER DEFAULT 0,
        MINUTES IN NUMBER DEFAULT 0,
        SECONDS IN NUMBER DEFAULT 0
    ) RETURN SELF AS RESULT,
    MEMBER FUNCTION ACCUMULATE(
        TIME GRUSHEVSKAYA_TIME
    ) RETURN GRUSHEVSKAYA_TIME,
    MEMBER FUNCTION PRINT RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY "GRUSHEVSKAYA_TIME" AS 
    CONSTRUCTOR FUNCTION GRUSHEVSKAYA_TIME(
        HOURS IN NUMBER DEFAULT 0,
        MINUTES IN NUMBER DEFAULT 0,
        SECONDS IN NUMBER DEFAULT 0
        ) RETURN SELF AS RESULT AS
    BEGIN
        IF HOURS IS NULL OR MINUTES IS NULL OR SECONDS IS NULL THEN 
            RAISE GRUSHEVSKAYA_EXCEPTIONS.INVALIDE_TYPE_FIELDS;
        END IF;
        IF HOURS > 23 OR MINUTES > 60 OR SECONDS > 60 THEN 
            RAISE GRUSHEVSKAYA_EXCEPTIONS.INVALIDE_TYPE_FIELDS;
        END IF;
        SELF.HOURS := HOURS;
        SELF.MINUTES := MINUTES;
        SELF.SECONDS := SECONDS;
        RETURN;
    END GRUSHEVSKAYA_TIME;    

    MEMBER FUNCTION ACCUMULATE(
        TIME GRUSHEVSKAYA_TIME
    ) RETURN GRUSHEVSKAYA_TIME
    IS
        RESULT_SECONDS NUMBER := 0;
        RESULT_MINUTES NUMBER := 0;
        RESULT_HOURS NUMBER := 0;
        RESULT_TIME GRUSHEVSKAYA_TIME;
    BEGIN
        RESULT_SECONDS := MOD(SELF.SECONDS + TIME.SECONDS, 60);
        RESULT_MINUTES := (
                SELF.MINUTES 
                + TIME.MINUTES 
                + FLOOR((SELF.SECONDS + TIME.SECONDS) / 60)
            ) MOD 60;
        RESULT_HOURS := MOD(
                SELF.HOURS 
                + TIME.HOURS 
                + FLOOR(
                    (
                        SELF.MINUTES 
                        + TIME.MINUTES 
                        + FLOOR((SELF.SECONDS + TIME.SECONDS) / 60)
                     ) / 60), 
            24);
        RESULT_TIME := GRUSHEVSKAYA_TIME(
            RESULT_HOURS,
            RESULT_MINUTES,
            RESULT_SECONDS
        );
        RETURN RESULT_TIME;
    END ACCUMULATE;

    MEMBER FUNCTION PRINT RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD(SELF.HOURS, 2, '0') || ':' 
            || LPAD(SELF.MINUTES, 2, '0') || ':' 
            || LPAD(SELF.SECONDS, 2, '0');
    END PRINT;
END;

/
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_ALBUM
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_ALBUM" 
   (	"ID" NUMBER(10,0), 
	"NAME" VARCHAR2(100 BYTE), 
	"PRICE" NUMBER(6,2), 
	"QUANTITY_IN_STOCK" NUMBER(5,0), 
	"QUANTITY_OF_SOLD" NUMBER(5,0), 
	"RECORD_ARRAY" "GRUSHEVSKAYA_RECORD_ARR" 
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_DICT_COUNTRY
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_DICT_COUNTRY" 
   (	"NAME" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_DICT_STYLE
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_DICT_STYLE" 
   (	"NAME" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_RECORD" 
   (	"ID" NUMBER(10,0), 
	"NAME" VARCHAR2(100 BYTE), 
	"TIME" "GRUSHEVSKAYA_TIME" , 
	"STYLE" VARCHAR2(100 BYTE), 
	"SINGER_LIST" "GRUSHEVSKAYA_SINGER_TAB" 
   ) 
 NESTED TABLE "SINGER_LIST" STORE AS "GRUSHEVSKAYA_SINGER_LIST"
 RETURN AS VALUE;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_SINGER" 
   (	"NAME" VARCHAR2(100 BYTE), 
	"NICKNAME" VARCHAR2(100 BYTE), 
	"COUNTRY" VARCHAR2(100 BYTE)
   ) ;
REM INSERTING into GRUSHEVSKAYA_ALBUM
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('1','album_1','100,5','0','25',gdv.GRUSHEVSKAYA_RECORD_ARR(1, 2, 3, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('2','album_2','123,55','188','37',gdv.GRUSHEVSKAYA_RECORD_ARR(23, 2, 3, 4, 5, 25, 7, 8, 10, 9, 12, 13, 11, 14, 15, 16, 17, 18, 19, 20, 21, 24, 1, 22, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('3','album_3','293,41','62','11',gdv.GRUSHEVSKAYA_RECORD_ARR(7, 15, 17, 16, 8, 14, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('4','album_4','24,41','89','0',gdv.GRUSHEVSKAYA_RECORD_ARR(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('5','album_5','65,71','19','0',gdv.GRUSHEVSKAYA_RECORD_ARR(24, 23, 25, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
REM INSERTING into GRUSHEVSKAYA_DICT_COUNTRY
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_1');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_2');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_3');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_4');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_5');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_6');
REM INSERTING into GRUSHEVSKAYA_DICT_STYLE
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_1');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_2');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_3');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_4');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_5');
REM INSERTING into GRUSHEVSKAYA_RECORD
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('1','song_1',gdv.GRUSHEVSKAYA_TIME(0, 1, 1),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_1', 'singer_2'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('2','song_2',gdv.GRUSHEVSKAYA_TIME(0, 1, 2),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_1', 'singer_2'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('3','song_3',gdv.GRUSHEVSKAYA_TIME(0, 1, 3),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_1', 'singer_2'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('4','song_4',gdv.GRUSHEVSKAYA_TIME(0, 1, 4),'style_2',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_2', 'singer_3'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('5','song_5',gdv.GRUSHEVSKAYA_TIME(0, 1, 5),'style_2',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_3', 'singer_4'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('6','song_6',gdv.GRUSHEVSKAYA_TIME(0, 1, 6),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_5', 'singer_7'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('7','song_7',gdv.GRUSHEVSKAYA_TIME(0, 1, 7),'style_4',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('8','song_8',gdv.GRUSHEVSKAYA_TIME(0, 1, 7),'style_5',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11', 'singer_7'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('9','song_9',gdv.GRUSHEVSKAYA_TIME(0, 1, 9),'style_5',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_9', 'singer_13'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('10','song_10',gdv.GRUSHEVSKAYA_TIME(0, 1, 10),'style_4',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_4', 'singer_9', 'singer_11', 'singer_13', 'singer_14', 'singer_15'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('11','song_11',gdv.GRUSHEVSKAYA_TIME(0, 1, 11),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_9'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('12','song_12',gdv.GRUSHEVSKAYA_TIME(0, 1, 12),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_9'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('13','song_13',gdv.GRUSHEVSKAYA_TIME(0, 1, 13),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_7'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('14','song_14',gdv.GRUSHEVSKAYA_TIME(0, 1, 14),'style_5',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('15','song_15',gdv.GRUSHEVSKAYA_TIME(0, 1, 15),'style_2',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('16','song_16',gdv.GRUSHEVSKAYA_TIME(0, 1, 16),'style_2',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('17','song_17',gdv.GRUSHEVSKAYA_TIME(0, 1, 17),'style_2',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_11'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('18','song_18',gdv.GRUSHEVSKAYA_TIME(0, 1, 18),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_13'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('19','song_19',gdv.GRUSHEVSKAYA_TIME(0, 1, 19),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_13'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('20','song_20',gdv.GRUSHEVSKAYA_TIME(0, 1, 20),'style_4',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_13', 'singer_7'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('21','song_21',gdv.GRUSHEVSKAYA_TIME(0, 1, 21),'style_4',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_13', 'singer_7'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('22','song_22',gdv.GRUSHEVSKAYA_TIME(0, 1, 22),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_14'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('23','song_23',gdv.GRUSHEVSKAYA_TIME(0, 1, 23),'style_5',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_15'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('24','song_24',gdv.GRUSHEVSKAYA_TIME(0, 1, 24),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_15'));
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('25','song_25',gdv.GRUSHEVSKAYA_TIME(0, 1, 25),'style_3',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_15'));
REM INSERTING into GRUSHEVSKAYA_SINGER
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_1','nick_1','country_1');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_2','nick_2','country_2');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_3','nick_3','country_3');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_4','nick_4','country_4');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_5','nick_4','country_1');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_7','nick_5','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_9','nick_6','country_2');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_11','nick_7','country_4');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_13','nick_9','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_14','nick_9','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_15','nick_9','country_6');
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_ALBUM_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_ALBUM_PK" ON "GRUSHEVSKAYA_ALBUM" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0019268
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019268" ON "GRUSHEVSKAYA_DICT_COUNTRY" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0019275
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019275" ON "GRUSHEVSKAYA_DICT_STYLE" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0019276
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019276" ON "GRUSHEVSKAYA_RECORD" ("SYS_NC0000800009$") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_RECORD_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_RECORD_PK" ON "GRUSHEVSKAYA_RECORD" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_SINGER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_SINGER_PK" ON "GRUSHEVSKAYA_SINGER" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_SINGER_UK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_SINGER_UK" ON "GRUSHEVSKAYA_SINGER" ("NAME", "NICKNAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_FK0000080190N00008$
--------------------------------------------------------

  CREATE INDEX "SYS_FK0000080190N00008$" ON "GRUSHEVSKAYA_SINGER_LIST" ("NESTED_TABLE_ID") 
  ;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_ALBUM
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_ALBUM" 
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_ALBUM
FOR EACH ROW
DECLARE
    TYPE GRUSHEVSKAYA_RECORD_TAB IS TABLE OF NUMBER(10, 0);
    LIST_ID GRUSHEVSKAYA_RECORD_TAB;
BEGIN
    -- Если альбом продан, то добавлять треки нельзя.
    IF UPDATING('RECORD_ARRAY') AND :OLD.QUANTITY_OF_SOLD > 0 THEN
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
                RETURN;
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
                RETURN;          
            END IF;
        END LOOP;
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
          AND NOT LIST_ID.EXISTS(:NEW.RECORD_ARRAY(i)) THEN
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
                RETURN;
            END IF;
        END IF;
    END LOOP;    
END;

/
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_ALBUM" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORD_DEL
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_DEL" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_DEL" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORD_UDP
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_UDP" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_UDP" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORDS" 
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
            RETURN;
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
            RETURN;
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
            RETURN;
        END IF;
    END IF;
END;

/
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORDS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_SINGERS_DEL
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_DEL" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_DEL" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_SINGERS_UDP
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_UDP" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_UDP" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_ALBUM
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_ALBUM" 
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_ALBUM
FOR EACH ROW
DECLARE
    TYPE GRUSHEVSKAYA_RECORD_TAB IS TABLE OF NUMBER(10, 0);
    LIST_ID GRUSHEVSKAYA_RECORD_TAB;
BEGIN
    -- Если альбом продан, то добавлять треки нельзя.
    IF UPDATING('RECORD_ARRAY') AND :OLD.QUANTITY_OF_SOLD > 0 THEN
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
                RETURN;
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
                RETURN;          
            END IF;
        END LOOP;
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
          AND NOT LIST_ID.EXISTS(:NEW.RECORD_ARRAY(i)) THEN
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
                RETURN;
            END IF;
        END IF;
    END LOOP;    
END;

/
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_ALBUM" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORD_UDP
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_UDP" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_UDP" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORD_DEL
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_DEL" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORD_DEL" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORDS" 
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
            RETURN;
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
            RETURN;
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
            RETURN;
        END IF;
    END IF;
END;

/
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_RECORDS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_SINGERS_UDP
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_UDP" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_UDP" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_SINGERS_DEL
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_DEL" 
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
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_SINGERS_DEL" ENABLE;
--------------------------------------------------------
--  DDL for Package GRUSHEVSKAYA_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "GRUSHEVSKAYA_EXCEPTIONS" AS
    INVALIDE_TYPE_FIELDS EXCEPTION;
    ERROR_RECORD EXCEPTION;
    ERROR_UPDATE_SINGER_IN_RECORD EXCEPTION;
    ERROR_SINGER_DEL EXCEPTION;
    ERROR_ALBUM EXCEPTION;
    ERROR_RECORD_DEL EXCEPTION;
END;

/
--------------------------------------------------------
--  DDL for Package GRUSHEVSKAYA_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "GRUSHEVSKAYA_PACKAGE" AS
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
        -- ID записи
        ID NUMBER, 
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
        -- Псевдоним, группа
        NICKNAME VARCHAR2, 
        -- Страна из словаря
        COUNTRY VARCHAR2
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома с одной записью.
    PROCEDURE ADD_ALBUM (
        -- ID альбома
        ID NUMBER,
        -- Название
        NAME VARCHAR2,
        -- Цена (>= 0)
        PRICE NUMBER,
        -- Количество на складе (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- Количество проданных альбомов (>= 0)
        QUANTITY_OF_SOLD NUMBER, 
        -- ID добавляемой записи
        RECORD_ID NUMBER,
        -- Номер звучания записи в альбоме
        RECORD_SERIAL_NUMBER NUMBER
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома без записей.
    PROCEDURE ADD_ALBUM (
        -- ID альбома
        ID NUMBER,
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
        RECORD_ID NUMBER,
        -- Номер звучания записи в альбоме
        RECORD_SERIAL_NUMBER NUMBER
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
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_ALBUM
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK1" CHECK (PRICE >= 0) ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK2" CHECK (QUANTITY_IN_STOCK >= 0) ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK3" CHECK (QUANTITY_OF_SOLD >= 0) ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_PK" PRIMARY KEY ("ID") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("PRICE" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("QUANTITY_IN_STOCK" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("QUANTITY_OF_SOLD" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_ALBUM" MODIFY ("RECORD_ARRAY" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_DICT_COUNTRY
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_DICT_COUNTRY" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_DICT_COUNTRY" ADD PRIMARY KEY ("NAME") ENABLE;
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_DICT_STYLE
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_DICT_STYLE" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_DICT_STYLE" ADD PRIMARY KEY ("NAME") ENABLE;
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_RECORD" ADD CONSTRAINT "GRUSHEVSKAYA_RECORD_PK" PRIMARY KEY ("ID") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_RECORD" ADD UNIQUE ("SINGER_LIST") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_RECORD" MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_RECORD" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_RECORD" MODIFY ("TIME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_RECORD" MODIFY ("STYLE" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_PK" PRIMARY KEY ("NAME") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_UK" UNIQUE ("NAME", "NICKNAME") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" MODIFY ("COUNTRY" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_RECORD" ADD CONSTRAINT "GRUSHEVSKAYA_RECORD_FK" FOREIGN KEY ("STYLE")
	  REFERENCES "GRUSHEVSKAYA_DICT_STYLE" ("NAME") ON DELETE SET NULL ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_FK" FOREIGN KEY ("COUNTRY")
	  REFERENCES "GRUSHEVSKAYA_DICT_COUNTRY" ("NAME") ON DELETE SET NULL ENABLE;
