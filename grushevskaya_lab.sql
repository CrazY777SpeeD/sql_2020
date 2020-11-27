-- DROP ALL

DROP TABLE GRUSHEVSKAYA_ALBUM;
DROP TABLE GRUSHEVSKAYA_RECORD;
DROP TABLE GRUSHEVSKAYA_SINGER;
DROP TABLE GRUSHEVSKAYA_DICT_COUNTRY;
DROP TABLE GRUSHEVSKAYA_DICT_STYLE;
DROP TYPE GRUSHEVSKAYA_RECORD_ARR;
DROP TYPE GRUSHEVSKAYA_SINGER_TAB;
--DROP TYPE GRUSHEVSKAYA_TIME;
--DROP SEQUENCE GRUSHEVSKAYA_NUM_RECORD;
--DROP SEQUENCE GRUSHEVSKAYA_NUM_ALBUM;
DROP PACKAGE GRUSHEVSKAYA_EXCEPTIONS;
DROP PACKAGE GRUSHEVSKAYA_PACKAGE;


--/

--����� � ������������

CREATE OR REPLACE 
PACKAGE GRUSHEVSKAYA_EXCEPTIONS AS
    INVALIDE_TYPE_FIELDS EXCEPTION;
    ERROR_RECORD EXCEPTION;
    ERROR_UPDATE_SINGER_IN_RECORD EXCEPTION;
    ERROR_SINGER_DEL EXCEPTION;
    ERROR_ALBUM EXCEPTION;
    ERROR_RECORD_DEL EXCEPTION;
END;
/

-- SEQUENCE ��� ��������� id RECORD

CREATE SEQUENCE GRUSHEVSKAYA_NUM_RECORD
MINVALUE 1
START WITH 1 
INCREMENT BY 1
NOCACHE NOCYCLE;
/
-- SEQUENCE ��� ��������� id ALBUM

CREATE SEQUENCE GRUSHEVSKAYA_NUM_ALBUM
MINVALUE 1
START WITH 1 
INCREMENT BY 1
NOCACHE NOCYCLE;
/
-- COUNTRY - ��������������� �������, ���������� ������� �����. 
-- ��������� ��������, ����� ���-�� ������ "��", � ���-�� "������".

CREATE TABLE GRUSHEVSKAYA_DICT_COUNTRY(
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);

-- SINGER � ����������� (���, ��������� ��� �������� ������; ������)

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

-- STYLE - ��������������� �������, ���������� ������� ������
-- ��������� ��������, ����� ���-�� ����� "����", � ���-�� "����".

CREATE TABLE GRUSHEVSKAYA_DICT_STYLE(
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);

-- RECORD

/
-- ��������� ������� ������������
CREATE TYPE GRUSHEVSKAYA_SINGER_TAB AS TABLE OF VARCHAR2(100 BYTE);
/
-- RECORD � ������ (�������������, ��������, ����� ��������, �����)
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

-- ��������� ������ �������
CREATE TYPE GRUSHEVSKAYA_RECORD_ARR AS VARRAY(30) OF NUMBER(10,0);
/
-- ALBUM � ������ (�������������, ��������, ���������, 
-- ���������� �� ������, ���������� ��������� �����������)
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

-- ����� �������-��-������ SINGER-RECORD

-- ����� �������� ��� ����������� ������
-- ������� NULL-�������� ������������ � ��������� ������ ������������.
-- ��� ���������� ��������� �� ���� �� ������ ������������. 
-- ������ ������������ �� ������ ���� ������.
-- ���� ������ ���������� � ����� �� ��������, 
-- �� ������ ������������ �������� ������.
-- ���� ������������ ������������ �� ������������� ������� ������������,
-- �� �������� ������� ��� "��������" ����������
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORDS
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_RECORD
FOR EACH ROW
DECLARE
    LIST_NAME GRUSHEVSKAYA_SINGER_TAB;
    FLAG_RECORD_USES BOOLEAN := FALSE;
BEGIN
    -- �������� ������ �� ��.���.
    FOR i IN 1..:NEW.SINGER_LIST.COUNT
    LOOP
        IF :NEW.SINGER_LIST(i) IS NULL THEN 
            :NEW.SINGER_LIST.DELETE(i);
        END IF;
    END LOOP;
    :NEW.SINGER_LIST := SET(:NEW.SINGER_LIST);
    -- ������ ������������ �� ������ ���� ����
    IF UPDATING
       AND :NEW.SINGER_LIST IS EMPTY THEN
        :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ���������.');
            DBMS_OUTPUT.PUT_LINE('������ ������������ ��������� ������,' 
                || ' ��� ��� ����������� ���� �� ���� ������ ����.');
            RETURN;
    END IF;
    -- ������ ��� ���������� � ����� �� �������� => ��������� ���. ������
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
            DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ���������.');
            DBMS_OUTPUT.PUT_LINE('������ ������������ ��������� ������,' 
                || ' ��� ��� ������ ��� ���������� � ����� �� ��������.');
            RETURN;
    END IF;
    -- �������� ����.��.
    -- ���� ������������ ������������ �� ������������� ������� ������������,
    -- �� �������� ������� ��� "��������" ����������
    SELECT NAME BULK COLLECT INTO LIST_NAME FROM GRUSHEVSKAYA_SINGER;
    IF :NEW.SINGER_LIST NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('������������ ������ ������������.');
            RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD;
        ELSE
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ��������� ��-�� ��������� �������� ����� (�����������).');
            RETURN;
        END IF;
    END IF;
END;
/
-- �������� ����.��.
-- ����� ��������� �����������
-- ����� ��������� ��� �� � ���� �������.
-- ���� ����, �� ������� ������.
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
                DBMS_OUTPUT.PUT_LINE('����������� � ��������������� ' 
                    || :OLD.NAME 
                    || ' ������� ������ - � ���� ���� �����.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_SINGER_DEL;
            END IF;
        END LOOP;
    END LOOP;
END;
/
-- �������� ����.��.
-- ����� ���������� �����������
-- ����� �������� ��� ��� ��� ���� �������
-- � �������� ���� ������
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

-- ����� �������-��-������ RECORD-ALBUM

-- ���� ������ ������, �� ��������� ����� ������.
-- ����� �������� ��� ����������� �������
-- ���������, ��� ��� ������ ����������.
-- ���� ���, �� ���� �������� ������, 
-- ���� "��������" ����������.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_ALBUM
BEFORE INSERT OR UPDATE ON GRUSHEVSKAYA_ALBUM
FOR EACH ROW
DECLARE
    TYPE GRUSHEVSKAYA_RECORD_TAB IS TABLE OF NUMBER(10, 0);
    LIST_ID GRUSHEVSKAYA_RECORD_TAB;
BEGIN
    -- ���� ������ ������, �� ��������� ����� ������.
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
                DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                    || :OLD.ID 
                    || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.');
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
                DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                    || :OLD.ID 
                    || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.');
                RETURN;          
            END IF;
        END LOOP;
    END IF;
    -- �������� ����.��.
    -- ����� �������� ��� ����������� �������
    -- ���������, ��� ��� ������ ����������.
    -- ���� ���, �� ���� �������� ������, 
    -- ���� "��������" ����������.
    SELECT ID BULK COLLECT INTO LIST_ID FROM GRUSHEVSKAYA_RECORD;
    FOR i IN 1..:NEW.RECORD_ARRAY.COUNT
    LOOP
       IF NOT :NEW.RECORD_ARRAY(i) IS NULL
          AND NOT LIST_ID.EXISTS(:NEW.RECORD_ARRAY(i)) THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('������������ ������ �������.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM;
            ELSE
                :NEW.ID := :OLD.ID;
                :NEW.NAME := :OLD.NAME;
                :NEW.PRICE := :OLD.PRICE;
                :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                          
                DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('������ � ��������������� ' 
                    || :OLD.ID 
                    || ' �� ��� �������� ��-�� ��������� �������� ����� (������).');
                RETURN;
            END IF;
        END IF;
    END LOOP;    
END;
/
-- �������� ����.��.
-- ����� ��������� ������ ��������� ��� �� �� � ��������.
-- ���� ����, �� ������� ������.
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
                DBMS_OUTPUT.PUT_LINE('����� � ��������������� ' 
                    || :OLD.ID 
                    || ' ������� ������ - ��� ���� � �������.');
                RAISE GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD_DEL;
            END IF;
        END LOOP;
    END LOOP;
END;
/
-- �������� ����.��.
-- ����� ���������� ������ 
-- ����� �������� ��� �� id �� ���� ��������
-- � �������� ���� �������.
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

-- ����� GRUSHEVSKAYA_PACKAGE � ������������� ������������

CREATE OR REPLACE 
PACKAGE GRUSHEVSKAYA_PACKAGE AS
    -- �������� ������ � �������.
    PROCEDURE ADD_IN_DICT_COUNTRY (
        -- �������� ������
        NAME VARCHAR2
    );
    -- �������� ����� � �������.
    PROCEDURE ADD_IN_DICT_STYLE (
        -- �������� �����
        NAME VARCHAR2
    );
    
    -- ����������� ����������
    
    -- 1) �������� ������ (���������� ����������� ���� �����������).
    PROCEDURE ADD_RECORD (
        -- ID ������
        ID NUMBER, 
        -- ��������
        NAME VARCHAR2, 
        -- ���������� ����� ��������
        HOURS NUMBER,
        -- ���������� ����� ��������
        MINUTES NUMBER,
        -- ���������� ������ ��������
        SECONDS NUMBER,
        -- ����� �� �������
        STYLE VARCHAR2,
        -- ��� �����������
        SINGER VARCHAR2
    );
    PROCEDURE ADD_RECORD (
        -- ��������
        NAME VARCHAR2, 
        -- ���������� ����� ��������
        HOURS NUMBER,
        -- ���������� ����� ��������
        MINUTES NUMBER,
        -- ���������� ������ ��������
        SECONDS NUMBER,
        -- ����� �� �������
        STYLE VARCHAR2,
        -- ��� �����������
        SINGER VARCHAR2
    );
    -- 2) �������� ����������� ��� ������ 
    -- (���� ��������� ������ �� ��������� �� � ���� ������ 
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE ADD_SINGER_IN_RECORD (
        -- ID ������
        RECORD_ID NUMBER,
        -- ��� �����������
        SINGER_NAME VARCHAR2
    );
    -- 3) �������� �����������.
    PROCEDURE ADD_SINGER (
        -- ��� (���)
        NAME VARCHAR2, 
        -- ������ �� �������
        COUNTRY VARCHAR2
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� � ����� �������.
    PROCEDURE ADD_ALBUM (
        -- ID �������
        ID NUMBER,
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- ���������� ��������� �������� (>= 0)
        QUANTITY_OF_SOLD NUMBER, 
        -- ID ����������� ������
        RECORD_ID NUMBER,
        -- ����� �������� ������ � �������
        RECORD_SERIAL_NUMBER NUMBER
    );
    PROCEDURE ADD_ALBUM (
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- ���������� ��������� �������� (>= 0)
        QUANTITY_OF_SOLD NUMBER, 
        -- ID ����������� ������
        RECORD_ID NUMBER,
        -- ����� �������� ������ � �������
        RECORD_SERIAL_NUMBER NUMBER
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� ��� �������.
    PROCEDURE ADD_ALBUM (
        -- ID �������
        ID NUMBER,
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- ���������� ��������� �������� (>= 0)
        QUANTITY_OF_SOLD NUMBER
    );
    PROCEDURE ADD_ALBUM (
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- ���������� ��������� �������� (>= 0)
        QUANTITY_OF_SOLD NUMBER
    );
    -- 5) �������� ���� � ������ 
    -- (���� �� ������� �� ������ ����������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE ADD_RECORD_IN_ALBUM (
        -- ID �������
        ALBUM_ID NUMBER,
        -- ID ����������� ������ 
        RECORD_ID NUMBER,
        -- ����� �������� ������ � �������
        RECORD_SERIAL_NUMBER NUMBER
    );
    -- 6) ������ �������� � ������� (���������� �� ������ ������ 0).
    PROCEDURE PRINT_ALBUMS_IN_STOCK;
    -- 7) ������ ������������.
    PROCEDURE PRINT_SINGERS;
    -- 8) �������� �������
    -- (���������� �� ������ ������������� �� ��������� ��������).
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        -- ID �������
        ALBUM_ID NUMBER,
        -- ����������
        QUANTITY NUMBER
    );
    -- 9) ������� ������ 
    -- (���������� �� ������ �����������, ��������� � �������������; 
    -- ������� ����� ������ �������, � ������� ���� ���� �� ���� ����
    --  - ������� ����������� � ����� �������). 
    PROCEDURE SELL_ALBUMS(
        -- ID �������
        ALBUM_ID NUMBER,
        -- ����������
        QUANTITY NUMBER
    );
    -- 10) ������� ������������, � ������� ��� �� ����� ������.
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS;
    
    -- �������� ����������
    
    -- 11) ����-���� ���������� ������� 
    -- � ��������� ���������� ������� �������� �������.
    PROCEDURE PRINT_ALBUM_RECORDS(ALBUM_ID NUMBER);
    -- 12) ������� �������� 
    -- (��������� ��������� ��������� �������� 
    -- �� ������� � ����������� 
    -- � �� �������� � �����).
    PROCEDURE PRINT_INCOME;
    -- 13) ������� ���� � ��������� ������� �� ������� 
    -- � ���������� ��������� ������� 
    -- (���� �� ������� �� ������ ���������� �������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE DELETE_RECORD_FROM_ALBUM(
        -- ID �������
        ALBUM_ID NUMBER,
        -- ����� �������� ������ � �������
        RECORD_NUMBER NUMBER
    );
    -- 14) ������� ����������� �� ������ 
    -- (���� ������ �� ������ �� � ���� ������ 
    -- � ���� ���� ����������� �� ������������
    --  - ������� ����������� �� ������ ��������). 
    PROCEDURE DELETE_SINGER_FROM_RECORD(
        -- ID ������
        RECORD_ID NUMBER,
        -- ����� ����������� � ������
        SINGER_NUMBER NUMBER
    );
    -- 15) ���������� �������������� ����������� ����� ���������� ����������� 
    -- (�����, � ������� �������� ����������� ��� ������). 
    PROCEDURE PRINT_SINGER_STYLE(
        -- ��� �����������
        SINGER_NAME VARCHAR2
    );
    -- 16) ���������� �������������� ����������� ����� 
    -- �� ������ ������ ������������� ������������.
    PROCEDURE PRINT_COUNTRY_STYLE; 
    -- 17) ���������� ��������� �������� 
    -- (��� ������� ������� ��������� 
    -- ����������� ��� ������ ������������,
    -- ���� ��� ����� ����� ������� �������� 
    -- ����� ���������� ������������; 
    -- � ��������� ������ ��������� ������������� �������).
    PROCEDURE PRINT_ALBUM_AUTHOR(
        -- ID �������
        ALBUM_ID NUMBER
    );
END;
/
CREATE OR REPLACE
PACKAGE BODY GRUSHEVSKAYA_PACKAGE AS
    PROCEDURE PRINT_MSG_EX(SQLCODE NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('��. ����������� ����������.');
        DBMS_OUTPUT.PUT_LINE('���: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('���������: ' || SQLERRM(SQLCODE));        
    END PRINT_MSG_EX;
    
    PROCEDURE ADD_IN_DICT_COUNTRY (
        NAME VARCHAR2
    )IS
    BEGIN
        INSERT INTO GRUSHEVSKAYA_DICT_COUNTRY (NAME) VALUES (NAME);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������ ' || NAME || ' ������� ���������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_COUNTRY');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
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
        DBMS_OUTPUT.PUT_LINE('����� ' || NAME || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_STYLE');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
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
        TIME INTERVAL DAY(0) TO SECOND(0);
    BEGIN
        TIME := NUMTODSINTERVAL(HOURS, 'HOUR') 
            + NUMTODSINTERVAL(MINUTES, 'MINUTE') 
            + NUMTODSINTERVAL(SECONDS, 'SECOND');
        INSERT INTO GRUSHEVSKAYA_RECORD (ID, NAME, TIME, STYLE, SINGER_LIST)
            VALUES (ID, NAME, TIME, STYLE, GRUSHEVSKAYA_SINGER_TAB(SINGER));
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE('������ ' || NAME || ' � ID ' || ID || ' ������� ���������.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_RECORD THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('��� ����� ' || STYLE || ' � �������.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_RECORD; 
    
    PROCEDURE ADD_RECORD(
        NAME VARCHAR2,
        HOURS NUMBER,
        MINUTES NUMBER,
        SECONDS NUMBER,
        STYLE VARCHAR2,
        SINGER VARCHAR2
    ) IS        
    BEGIN
        ADD_RECORD(GRUSHEVSKAYA_NUM_RECORD.NEXTVAL, NAME, HOURS, MINUTES, SECONDS, STYLE, SINGER);
    END ADD_RECORD;
    
    PROCEDURE ADD_SINGER_IN_RECORD (
        RECORD_ID NUMBER,
        SINGER_NAME VARCHAR2
    ) IS
        TMP_SINGER_LIST GRUSHEVSKAYA_SINGER_TAB;
    BEGIN
        IF SINGER_NAME IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
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
        DBMS_OUTPUT.PUT_LINE('����������� ' || SINGER_NAME || ' ������� �������� � ������ � ID ' || RECORD_ID || '.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER_IN_RECORD');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('������� � �������������� ������.');
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
        DBMS_OUTPUT.PUT_LINE('����������� ' || NAME || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('��� ������ ' || COUNTRY || ' � �������.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
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
        DBMS_OUTPUT.PUT_LINE('������ ' || NAME || ' � ID ' || ID || ' ������� ��������.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� �������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('������� �������������� ������ � ������.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ���� �� �������.');
            DBMS_OUTPUT.PUT_LINE('�������� ���� �� ����� ���� �������������.');
            DBMS_OUTPUT.PUT_LINE('�������� ���������� �������� � ������� � ��������� �� ����� ���� ��������������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_ALBUM;
    
    PROCEDURE ADD_ALBUM (
        NAME VARCHAR2,
        PRICE NUMBER,
        QUANTITY_IN_STOCK NUMBER,
        QUANTITY_OF_SOLD NUMBER, 
        RECORD_ID NUMBER,
        RECORD_SERIAL_NUMBER NUMBER
    ) IS
    BEGIN
        ADD_ALBUM (
            GRUSHEVSKAYA_NUM_ALBUM.NEXTVAL,
            NAME,
            PRICE,
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD, 
            RECORD_ID,
            RECORD_SERIAL_NUMBER
        );
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
        DBMS_OUTPUT.PUT_LINE('������ ' || NAME || ' � ID ' || ID || ' ������� ��������.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� �������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ���� �� �������.');
            DBMS_OUTPUT.PUT_LINE('�������� ���� �� ����� ���� �������������.');
            DBMS_OUTPUT.PUT_LINE('�������� ���������� �������� � ������� � ��������� �� ����� ���� ��������������.');
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
    BEGIN
        ADD_ALBUM (
            GRUSHEVSKAYA_NUM_ALBUM.NEXTVAL,
            NAME,
            PRICE,
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD
        );
    END ADD_ALBUM;
    
    PROCEDURE ADD_RECORD_IN_ALBUM (
        ALBUM_ID NUMBER, 
        RECORD_ID NUMBER,
        RECORD_SERIAL_NUMBER NUMBER
    )IS
        TMP_RECORD_ARR GRUSHEVSKAYA_RECORD_ARR;
    BEGIN        
        IF RECORD_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
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
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || RECORD_ID || ' ������� ��������� � ������ � ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD_IN_ALBUM');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� �������.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('������� � �������������� ������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_RECORD_IN_ALBUM;
    
    PROCEDURE PRINT_ALBUMS_IN_STOCK 
    IS
        QUANTITY NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('������� � �������:');
        FOR ALBUM IN (SELECT * FROM GRUSHEVSKAYA_ALBUM WHERE QUANTITY_IN_STOCK > 0)
        LOOP
            DBMS_OUTPUT.PUT_LINE(ALBUM.NAME);
            QUANTITY := QUANTITY + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('����� �������� � �������: ' || QUANTITY || '.');    
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_ALBUMS_IN_STOCK');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_ALBUMS_IN_STOCK;
    
    PROCEDURE PRINT_SINGERS
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('��� �����������:');
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
            DBMS_OUTPUT.PUT_LINE('� ������� ��������� ������������� ' 
                || '���������� �������� c ID ' 
                || ALBUM_ID || '. ���������� �� ���������.');
            RETURN;
        END IF;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET QUANTITY_IN_STOCK = QUANTITY_IN_STOCK + QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('� ������� ��������� ' 
            || QUANTITY || ' �������� c ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUMS_IN_STOCK');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
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
            DBMS_OUTPUT.PUT_LINE('�������� ������������� ���������� �������� c ID ' 
                || ALBUM_ID || '. ���������� �� ���������.');
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
            DBMS_OUTPUT.PUT_LINE('������� ������ c ID ' 
                || ALBUM_ID || ' ������. � ������� ��� ������.');
            RETURN;
        END IF;
        SELECT QUANTITY_IN_STOCK INTO MAX_QUANTITY 
            FROM GRUSHEVSKAYA_ALBUM
            WHERE ID = ALBUM_ID;
        MAX_QUANTITY := LEAST(MAX_QUANTITY, QUANTITY);
        IF MAX_QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('������� ������ c ID ' 
                || ALBUM_ID || ' ������. �������� ��� �� ������.');
            RETURN;
        END IF;
        UPDATE GRUSHEVSKAYA_ALBUM
            SET 
                QUANTITY_IN_STOCK = QUANTITY_IN_STOCK - MAX_QUANTITY,
                QUANTITY_OF_SOLD = QUANTITY_OF_SOLD + MAX_QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������� ' || MAX_QUANTITY 
            || ' �������� c ID ' || ALBUM_ID || '.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN SELL_ALBUMS');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
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
                DBMS_OUTPUT.PUT_LINE('������ ����������� ' 
                    || DEL_SINGERS_LIST(j) || '.');
            END IF;
        END LOOP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('����������� ��� ������� ������� �������.');
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
        DBMS_OUTPUT.PUT_LINE('������ �' || ALBUM_ID);
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
                    '�' 
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
            '����� ����� ��������: '
            || LPAD(EXTRACT(HOUR FROM TIME), 2, '0') || ':' 
            || LPAD(EXTRACT(MINUTE FROM TIME), 2, '0') || ':' 
            || LPAD(EXTRACT(SECOND FROM TIME), 2, '0')
            || '.'
        );        
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_ALBUM_RECORDS');
        IF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������������� �������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END PRINT_ALBUM_RECORDS;
    
    PROCEDURE PRINT_INCOME
    IS
        TOTAL_INCOME NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('������� ��������');
        FOR ALBUM IN (SELECT * FROM GRUSHEVSKAYA_ALBUM)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                '�������� ID ' 
                || ALBUM.ID 
                || ' � ������ ' 
                || ALBUM.NAME
                || ' ������� �� �����: '
                || ALBUM.PRICE * ALBUM.QUANTITY_OF_SOLD
            );
            TOTAL_INCOME := TOTAL_INCOME + ALBUM.PRICE * ALBUM.QUANTITY_OF_SOLD;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('������� �������� � �����: ' || TOTAL_INCOME || '.');       
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
            DBMS_OUTPUT.PUT_LINE('������� ���� �' 
                || RECORD_NUMBER || ' ������, ��� ��� ������ ������');
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
        DBMS_OUTPUT.PUT_LINE('���� �' || RECORD_NUMBER || ' ������');            
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_ALBUM THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN DELETE_RECORD_FROM_ALBUM');
        IF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� �������.');        
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��������������� �������.');
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
        DBMS_OUTPUT.PUT_LINE('����������� �' || SINGER_NUMBER || ' ������.');
    EXCEPTION
    WHEN GRUSHEVSKAYA_EXCEPTIONS.ERROR_UPDATE_SINGER_IN_RECORD THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN DELETE_SINGER_FROM_RECORD');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');       
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('�������� �� ��������������� ����������� ����������.');
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
            DBMS_OUTPUT.PUT_LINE('����������� �� ������.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE('�������� ���������� ����� � ' 
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
            DBMS_OUTPUT.PUT_LINE('�������� ���������� ����� � '  
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
        DBMS_OUTPUT.PUT_LINE('��������� ������� � ID ' || ALBUM_ID || '.');
        IF FLAG_GROUP THEN
            DBMS_OUTPUT.PUT_LINE('������������ �������.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('�����������');
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
            DBMS_OUTPUT.PUT_LINE('������ ��������� ��������������� ������� ����������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END PRINT_ALBUM_AUTHOR;
END;
--/
--DECLARE 
--BEGIN
--    -- �������� ������
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_3');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_4');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_5');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_6');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_3');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_4');
--    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_5');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_1', 'nick_1', 'country_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_2', 'nick_2', 'country_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_3', 'nick_3', 'country_3');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_4', 'nick_4', 'country_4');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_5', 'nick_4', 'country_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_6', 'nick_5', 'country_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_7', 'nick_5', 'country_5');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_8', 'nick_5', 'country_6');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_9', 'nick_6', 'country_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_10', 'nick_6', 'country_3');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_11', 'nick_7', 'country_4');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_12', 'nick_8', 'country_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_13', 'nick_9', 'country_5');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_14', 'nick_9', 'country_5');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_15', 'nick_9', 'country_6');
--
--
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(1, 'song_1', 0, 1, 01, 'style_1', 'singer_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_2');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(2, 'song_2', 0, 1, 02, 'style_1', 'singer_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(2, 'singer_2');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(3, 'song_3', 0, 1, 03, 'style_1', 'singer_1');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(3, 'singer_2');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(4, 'song_4', 0, 1, 04, 'style_2', 'singer_2');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(4, 'singer_3');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(5, 'song_5', 0, 1, 05, 'style_2', 'singer_3');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(5, 'singer_4');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(6, 'song_6', 0, 1, 06, 'style_3', 'singer_5');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(6, 'singer_7');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(7, 'song_7', 0, 1, 07, 'style_4', 'singer_11');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(8, 'song_8', 0, 1, 07, 'style_5', 'singer_11');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(8, 'singer_7'); 
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(9, 'song_9', 0, 1, 09, 'style_5', 'singer_9');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(9, 'singer_13'); 
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(10, 'song_10', 0, 1, 10, 'style_4', 'singer_4');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(10, 'singer_9'); 
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(10, 'singer_11'); 
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(10, 'singer_13'); 
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(10, 'singer_14'); 
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(10, 'singer_15'); 
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(11, 'song_11', 0, 1, 11, 'style_3', 'singer_9');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(12, 'song_12', 0, 1, 12, 'style_3', 'singer_9');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(13, 'song_13', 0, 1, 13, 'style_1', 'singer_7');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(14, 'song_14', 0, 1, 14, 'style_5', 'singer_11');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(15, 'song_15', 0, 1, 15, 'style_2', 'singer_11');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(16, 'song_16', 0, 1, 16, 'style_2', 'singer_11');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(17, 'song_17', 0, 1, 17, 'style_2', 'singer_11');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(18, 'song_18', 0, 1, 18, 'style_1', 'singer_13');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(19, 'song_19', 0, 1, 19, 'style_3', 'singer_13');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(20, 'song_20', 0, 1, 20, 'style_4', 'singer_13');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(20, 'singer_7'); 
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(21, 'song_21', 0, 1, 21, 'style_4', 'singer_13');
--    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(21, 'singer_7'); 
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(22, 'song_22', 0, 1, 22, 'style_3', 'singer_14');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(23, 'song_23', 0, 1, 23, 'style_5', 'singer_15');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(24, 'song_24', 0, 1, 24, 'style_3', 'singer_15');
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(25, 'song_25', 0, 1, 25, 'style_3', 'singer_15');
--
--
--    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
--        ID => 1, 
--        NAME => 'album_1', 
--        PRICE => 100.50, 
--        QUANTITY_IN_STOCK => 25, 
--        QUANTITY_OF_SOLD => 0, 
--        RECORD_ID => 1, 
--        RECORD_SERIAL_NUMBER => 1
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 1,
--        RECORD_ID => 2, 
--        RECORD_SERIAL_NUMBER => 2
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 1,
--        RECORD_ID => 3, 
--        RECORD_SERIAL_NUMBER => 3
--    );
--    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 1, QUANTITY => 25);
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
--        ID => 2, 
--        NAME => 'album_2', 
--        PRICE => 123.55, 
--        QUANTITY_IN_STOCK => 225, 
--        QUANTITY_OF_SOLD => 0, 
--        RECORD_ID => 1, 
--        RECORD_SERIAL_NUMBER => 23
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 2, 
--        RECORD_SERIAL_NUMBER => 2
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 3, 
--        RECORD_SERIAL_NUMBER => 3
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 4, 
--        RECORD_SERIAL_NUMBER => 4
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 5, 
--        RECORD_SERIAL_NUMBER => 5
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 7, 
--        RECORD_SERIAL_NUMBER => 7
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 8, 
--        RECORD_SERIAL_NUMBER => 8
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 9, 
--        RECORD_SERIAL_NUMBER => 10
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 10, 
--        RECORD_SERIAL_NUMBER => 9
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 11, 
--        RECORD_SERIAL_NUMBER => 13
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 12, 
--        RECORD_SERIAL_NUMBER => 11
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 13, 
--        RECORD_SERIAL_NUMBER => 12
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 14, 
--        RECORD_SERIAL_NUMBER => 14
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 15, 
--        RECORD_SERIAL_NUMBER => 15
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 12, 
--        RECORD_SERIAL_NUMBER => 11
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 16, 
--        RECORD_SERIAL_NUMBER => 16
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 17, 
--        RECORD_SERIAL_NUMBER => 17
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 18, 
--        RECORD_SERIAL_NUMBER => 18
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 19, 
--        RECORD_SERIAL_NUMBER => 19
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 20, 
--        RECORD_SERIAL_NUMBER => 20
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 21, 
--        RECORD_SERIAL_NUMBER => 21
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 22, 
--        RECORD_SERIAL_NUMBER => 24
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 23, 
--        RECORD_SERIAL_NUMBER => 1
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 24, 
--        RECORD_SERIAL_NUMBER => 22
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 2,
--        RECORD_ID => 25, 
--        RECORD_SERIAL_NUMBER => 6
--    );
--    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 2, QUANTITY => 37);
--        
--    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
--        ID => 3, 
--        NAME => 'album_3', 
--        PRICE => 293.41, 
--        QUANTITY_IN_STOCK => 73, 
--        QUANTITY_OF_SOLD => 0, 
--        RECORD_ID => 7, 
--        RECORD_SERIAL_NUMBER => 1
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 3,
--        RECORD_ID => 8, 
--        RECORD_SERIAL_NUMBER => 5
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 3,
--        RECORD_ID => 14, 
--        RECORD_SERIAL_NUMBER => 6
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 3,
--        RECORD_ID => 15, 
--        RECORD_SERIAL_NUMBER => 2
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 3,
--        RECORD_ID => 16, 
--        RECORD_SERIAL_NUMBER => 4
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 3,
--        RECORD_ID => 17, 
--        RECORD_SERIAL_NUMBER => 3
--    );
--    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 3, QUANTITY => 11);
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
--        ID => 4, 
--        NAME => 'album_4', 
--        PRICE => 24.41, 
--        QUANTITY_IN_STOCK => 89, 
--        QUANTITY_OF_SOLD => 0
--    );
--    
--    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
--        ID => 5, 
--        NAME => 'album_5', 
--        PRICE => 65.71, 
--        QUANTITY_IN_STOCK => 19, 
--        QUANTITY_OF_SOLD => 0
--    );    
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 5,
--        RECORD_ID => 23, 
--        RECORD_SERIAL_NUMBER => 2
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 5,
--        RECORD_ID => 24, 
--        RECORD_SERIAL_NUMBER => 1
--    );
--    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
--        ALBUM_ID => 5,
--        RECORD_ID => 25, 
--        RECORD_SERIAL_NUMBER => 3
--    );     
--END;












