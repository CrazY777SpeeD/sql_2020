--------------------------------------------------------
--  File created - понедельник-ноября-16-2020   
--------------------------------------------------------
DROP TYPE "GRUSHEVSKAYA_RECORD_ARR";
DROP TYPE "GRUSHEVSKAYA_SINGER_TAB";
DROP TYPE "GRUSHEVSKAYA_TIME";
DROP TABLE "GRUSHEVSKAYA_SINGER_LIST" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_SINGER" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_RECORD" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_DICT_STYLE" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_DICT_COUNTRY" cascade constraints;
DROP TABLE "GRUSHEVSKAYA_ALBUM" cascade constraints;
DROP PACKAGE "GRUSHEVSKAYA_PACKAGE";
DROP PACKAGE "GRUSHEVSKAYA_EXCEPTIONS";
DROP PACKAGE BODY "GRUSHEVSKAYA_PACKAGE";
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
--  DDL for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_SINGER" 
   (	"NAME" VARCHAR2(100 BYTE), 
	"NICKNAME" VARCHAR2(100 BYTE), 
	"COUNTRY" VARCHAR2(100 BYTE)
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
--  DDL for Table GRUSHEVSKAYA_DICT_STYLE
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_DICT_STYLE" 
   (	"NAME" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_DICT_COUNTRY
--------------------------------------------------------

  CREATE TABLE "GRUSHEVSKAYA_DICT_COUNTRY" 
   (	"NAME" VARCHAR2(100 BYTE)
   ) ;
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
REM INSERTING into GRUSHEVSKAYA_SINGER
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_1','nick_1','country_1');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_2','nick_2','country_2');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_3','nick_3','country_3');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_4','nick_4','country_4');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_5','nick_4','country_1');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_6','nick_5','country_1');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_7','nick_5','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_8','nick_5','country_6');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_9','nick_6','country_2');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_10','nick_6','country_3');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_11','nick_7','country_4');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_12','nick_8','country_2');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_13','nick_9','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_14','nick_9','country_5');
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_15','nick_9','country_6');
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
REM INSERTING into GRUSHEVSKAYA_DICT_STYLE
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_1');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_2');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_3');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_4');
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_5');
REM INSERTING into GRUSHEVSKAYA_DICT_COUNTRY
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_1');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_2');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_3');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_4');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_5');
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_6');
REM INSERTING into GRUSHEVSKAYA_ALBUM
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('1','album_1','100,5','0','25',gdv.GRUSHEVSKAYA_RECORD_ARR(1, 2, 3, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('2','album_2','123,55','188','37',gdv.GRUSHEVSKAYA_RECORD_ARR(23, 2, 3, 4, 5, 25, 7, 8, 10, 9, 12, 13, 11, 14, 15, 16, 17, 18, 19, 20, 21, 24, 1, 22, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('3','album_3','293,41','62','11',gdv.GRUSHEVSKAYA_RECORD_ARR(7, 15, 17, 16, 8, 14, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('4','album_4','24,41','89','0',gdv.GRUSHEVSKAYA_RECORD_ARR(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
Insert into GRUSHEVSKAYA_ALBUM (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) values ('5','album_5','65,71','19','0',gdv.GRUSHEVSKAYA_RECORD_ARR(24, 23, 25, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--------------------------------------------------------
--  DDL for Index SYS_FK0000080230N00008$
--------------------------------------------------------

  CREATE INDEX "SYS_FK0000080230N00008$" ON "GRUSHEVSKAYA_SINGER_LIST" ("NESTED_TABLE_ID") 
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
--  DDL for Index SYS_C0019328
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019328" ON "GRUSHEVSKAYA_RECORD" ("SYS_NC0000800009$") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_RECORD_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_RECORD_PK" ON "GRUSHEVSKAYA_RECORD" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0019327
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019327" ON "GRUSHEVSKAYA_DICT_STYLE" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0019320
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0019320" ON "GRUSHEVSKAYA_DICT_COUNTRY" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_ALBUM_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_ALBUM_PK" ON "GRUSHEVSKAYA_ALBUM" ("ID") 
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
--  DDL for Package Body GRUSHEVSKAYA_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "GRUSHEVSKAYA_PACKAGE" AS
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
        ID NUMBER, 
        NAME VARCHAR2,
        HOURS NUMBER,
        MINUTES NUMBER,
        SECONDS NUMBER,
        STYLE VARCHAR2,
        SINGER VARCHAR2
    ) IS
        TIME GRUSHEVSKAYA_TIME;
    BEGIN
        TIME := NEW GRUSHEVSKAYA_TIME(HOURS, MINUTES, SECONDS);
        INSERT INTO GRUSHEVSKAYA_RECORD (ID, NAME, TIME, STYLE, SINGER_LIST)
            VALUES (ID, NAME, TIME, STYLE, GRUSHEVSKAYA_SINGER_TAB(SINGER));
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE('Запись ' || NAME || ' с ID ' || ID || ' успешно добавлена.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD THEN
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
        DBMS_OUTPUT.PUT_LINE('Исполнитель ' || SINGER_NAME || ' успешно добавлен в запись с ID ' || RECORD_ID || '.');
    EXCEPTION
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
        NICKNAME VARCHAR2, 
        COUNTRY VARCHAR2
    ) IS
    BEGIN
        INSERT INTO GRUSHEVSKAYA_SINGER (NAME, NICKNAME, COUNTRY)
            VALUES (NAME, NICKNAME, COUNTRY);
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
        ID NUMBER,
        NAME VARCHAR2,
        PRICE NUMBER,
        QUANTITY_IN_STOCK NUMBER,
        QUANTITY_OF_SOLD NUMBER, 
        RECORD_ID NUMBER,
        RECORD_SERIAL_NUMBER NUMBER
    ) IS
        RECORD_ARR GRUSHEVSKAYA_RECORD_ARR := GRUSHEVSKAYA_RECORD_ARR();
    BEGIN
        RECORD_ARR.EXTEND(30);
        RECORD_ARR(RECORD_SERIAL_NUMBER) := RECORD_ID;
        INSERT INTO GRUSHEVSKAYA_ALBUM (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARRAY
        ) VALUES (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Альбом ' || NAME || ' с ID ' || ID || ' успешно добавлен.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
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
        ID NUMBER,
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
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Альбом ' || NAME || ' с ID ' || ID || ' успешно добавлен.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
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
        RECORD_ID NUMBER,
        RECORD_SERIAL_NUMBER NUMBER
    )IS
        TMP_RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
    BEGIN        
        IF RECORD_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять NULL-значения.');
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO TMP_RECORD_ARR
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        TMP_RECORD_ARR(RECORD_SERIAL_NUMBER) := RECORD_ID;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET RECORD_ARRAY = TMP_RECORD_ARR
            WHERE ID = ALBUM_ID;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Запись с ID ' || RECORD_ID || ' успешно добавлена в альбом с ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
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
        TIME GRUSHEVSKAYA_TIME := GRUSHEVSKAYA_TIME(0, 0, 0);
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
                    || RECORD.TIME.PRINT
                    || ' ' 
                    || RECORD.NAME
                    || ' ' 
                    || SINGERS
                );
                TIME := RECORD.TIME.ACCUMULATE(TIME);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Общее время звучания: ' || TIME.PRINT || '.');        
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
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_PK" PRIMARY KEY ("NAME") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_UK" UNIQUE ("NAME", "NICKNAME") ENABLE;
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_SINGER" MODIFY ("COUNTRY" NOT NULL ENABLE);
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
--  Constraints for Table GRUSHEVSKAYA_DICT_STYLE
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_DICT_STYLE" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_DICT_STYLE" ADD PRIMARY KEY ("NAME") ENABLE;
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_DICT_COUNTRY
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_DICT_COUNTRY" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "GRUSHEVSKAYA_DICT_COUNTRY" ADD PRIMARY KEY ("NAME") ENABLE;
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
--  Ref Constraints for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_FK" FOREIGN KEY ("COUNTRY")
	  REFERENCES "GRUSHEVSKAYA_DICT_COUNTRY" ("NAME") ON DELETE SET NULL ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  ALTER TABLE "GRUSHEVSKAYA_RECORD" ADD CONSTRAINT "GRUSHEVSKAYA_RECORD_FK" FOREIGN KEY ("STYLE")
	  REFERENCES "GRUSHEVSKAYA_DICT_STYLE" ("NAME") ON DELETE SET NULL ENABLE;
