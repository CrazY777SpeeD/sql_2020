--------------------------------------------------------
--  File created - среда-ноября-04-2020   
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
    ) RETURN SELF AS RESULT
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
REM INSERTING into GRUSHEVSKAYA_DICT_COUNTRY
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_COUNTRY (NAME) values ('country_1');
REM INSERTING into GRUSHEVSKAYA_DICT_STYLE
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_DICT_STYLE (NAME) values ('style_1');
REM INSERTING into GRUSHEVSKAYA_RECORD
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_RECORD (ID,NAME,TIME,STYLE,SINGER_LIST) values ('1','song_1',gdv.GRUSHEVSKAYA_TIME(0, 1, 10),'style_1',gdv.GRUSHEVSKAYA_SINGER_TAB('singer_1'));
REM INSERTING into GRUSHEVSKAYA_SINGER
SET DEFINE OFF;
Insert into GRUSHEVSKAYA_SINGER (NAME,NICKNAME,COUNTRY) values ('singer_1','nick_1','country_1');
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_ALBUM_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "GRUSHEVSKAYA_ALBUM_PK" ON "GRUSHEVSKAYA_ALBUM" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0012165
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0012165" ON "GRUSHEVSKAYA_DICT_COUNTRY" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0012172
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0012172" ON "GRUSHEVSKAYA_DICT_STYLE" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0012173
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C0012173" ON "GRUSHEVSKAYA_RECORD" ("SYS_NC0000800009$") 
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
--  DDL for Index SYS_FK0000074425N00008$
--------------------------------------------------------

  CREATE INDEX "SYS_FK0000074425N00008$" ON "GRUSHEVSKAYA_SINGER_LIST" ("NESTED_TABLE_ID") 
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
    SELECT ID BULK COLLECT INTO LIST_ID FROM GRUSHEVSKAYA_RECORD;
    FOR i IN 1..:NEW.RECORD_ARRAY.COUNT
    LOOP
        IF NOT LIST_ID.EXISTS(:NEW.RECORD_ARRAY(i)) THEN
            IF INSERTING THEN
                DBMS_OUTPUT.PUT_LINE('Некорректный список записей.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM;
            ELSE
                :NEW.ID := :OLD.ID;
                :NEW.NAME := :OLD.NAME;
                :NEW.PRICE := :OLD.PRICE;
                :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;
                DBMS_OUTPUT.PUT_LINE('Альбом с идентификатором ' 
                    || :OLD.ID 
                    || ' не был обновлен из-за нарушения внешнего ключа.');
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
BEGIN
    FOR i IN 1..:NEW.SINGER_LIST.COUNT
    LOOP
        IF :NEW.SINGER_LIST(i) IS NULL THEN 
            :NEW.SINGER_LIST.DELETE(i);
        END IF;
    END LOOP;
    :NEW.SINGER_LIST := SET(:NEW.SINGER_LIST);
    SELECT NAME BULK COLLECT INTO LIST_NAME FROM GRUSHEVSKAYA_SINGER;
    IF :NEW.SINGER_LIST NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN
            DBMS_OUTPUT.PUT_LINE('Некорректный список исполнителей.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD;
        ELSE
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('Запись с идентификатором ' 
                || :OLD.ID 
                || ' не была обновлена из-за нарушения внешнего ключа.');
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
    SELECT ID BULK COLLECT INTO LIST_ID FROM GRUSHEVSKAYA_RECORD;
    FOR i IN 1..:NEW.RECORD_ARRAY.COUNT
    LOOP
        IF NOT LIST_ID.EXISTS(:NEW.RECORD_ARRAY(i)) THEN
            IF INSERTING THEN
                DBMS_OUTPUT.PUT_LINE('Некорректный список записей.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM;
            ELSE
                :NEW.ID := :OLD.ID;
                :NEW.NAME := :OLD.NAME;
                :NEW.PRICE := :OLD.PRICE;
                :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;
                DBMS_OUTPUT.PUT_LINE('Альбом с идентификатором ' 
                    || :OLD.ID 
                    || ' не был обновлен из-за нарушения внешнего ключа.');
                RETURN;
            END IF;
        END IF;
    END LOOP;    
END;

/
ALTER TRIGGER "GRUSHEVSKAYA_TR_ON_ALBUM" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GRUSHEVSKAYA_TR_ON_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GRUSHEVSKAYA_TR_ON_RECORDS" 
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_RECORD
FOR EACH ROW
DECLARE
    LIST_NAME GRUSHEVSKAYA_SINGER_TAB;
BEGIN
    FOR i IN 1..:NEW.SINGER_LIST.COUNT
    LOOP
        IF :NEW.SINGER_LIST(i) IS NULL THEN 
            :NEW.SINGER_LIST.DELETE(i);
        END IF;
    END LOOP;
    :NEW.SINGER_LIST := SET(:NEW.SINGER_LIST);
    SELECT NAME BULK COLLECT INTO LIST_NAME FROM GRUSHEVSKAYA_SINGER;
    IF :NEW.SINGER_LIST NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN
            DBMS_OUTPUT.PUT_LINE('Некорректный список исполнителей.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD;
        ELSE
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('Запись с идентификатором ' 
                || :OLD.ID 
                || ' не была обновлена из-за нарушения внешнего ключа.');
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
--  DDL for Package GRUSHEVSKAYA_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "GRUSHEVSKAYA_EXCEPTIONS" AS
    INVALIDE_TYPE_FIELDS EXCEPTION;
    ERROR_RECORD EXCEPTION;
    ERROR_SINGER_DEL EXCEPTION;
    ERROR_ALBUM EXCEPTION;
    ERROR_RECORD_DEL EXCEPTION;
    LONG_VARCHAR2 EXCEPTION;
END;

/
--------------------------------------------------------
--  DDL for Package GRUSHEVSKAYA_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "GRUSHEVSKAYA_PACKAGE" AS
    PROCEDURE ADD_IN_DICT_COUNTRY (
        NAME VARCHAR2
    );
    PROCEDURE ADD_IN_DICT_STYLE (
        NAME VARCHAR2
    );
    PROCEDURE ADD_RECORD (
        ID NUMBER, 
        NAME VARCHAR2, 
        HOURS NUMBER,
        MINUTES NUMBER,
        SECONDS NUMBER,
        STYLE VARCHAR2,
        SINGER VARCHAR2
    );
    PROCEDURE ADD_SINGER (
        NAME VARCHAR2, 
        NICKNAME VARCHAR2, 
        COUNTRY VARCHAR2
    );
--    FUNCTION disc_hours RETURN NUMBER;
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
