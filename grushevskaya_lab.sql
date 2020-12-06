-- �������� ���������� ������ �������� ��

DROP TABLE Grushevskaya_album;
DROP TABLE Grushevskaya_record;
DROP TABLE Grushevskaya_singer;
DROP TABLE Grushevskaya_dict_country;
DROP TABLE Grushevskaya_dict_style;
DROP TYPE Grushevskaya_record_arr;
DROP TYPE Grushevskaya_singer_tab;
DROP SEQUENCE Grushevskaya_num_record;
DROP SEQUENCE Grushevskaya_num_album;
DROP PACKAGE grushevskaya_exceptions;
DROP PACKAGE grushevskaya_package;
 /

--����� � ������������

CREATE OR REPLACE 
PACKAGE grushevskaya_exceptions AS
    INVALIDE_TYPE_FIELDS EXCEPTION;
    WARNING_UPDATE EXCEPTION;
    ERROR_RECORD EXCEPTION;
    ERROR_UPDATE_SINGER_IN_RECORD EXCEPTION;
    ERROR_SINGER_DEL EXCEPTION;
    ERROR_ALBUM EXCEPTION;
    ERROR_RECORD_DEL EXCEPTION;
END;
/

-- SEQUENCE ��� ��������� id RECORD
-- ��-�� �������� ������ ���������� � 48

CREATE SEQUENCE Grushevskaya_num_record
    MINVALUE 1
    START WITH 1 --48
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- SEQUENCE ��� ��������� id ALBUM
-- ��-�� �������� ������ ���������� � 7

CREATE SEQUENCE Grushevskaya_num_album
    MINVALUE 1
    START WITH 1 --7
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- COUNTRY - ��������������� �������, ���������� ������� �����. 
-- ��������� ��������, ����� ���-�� ������ "��", � ���-�� "������".

CREATE TABLE Grushevskaya_dict_country(
    -- �������� ������
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
--INSERT INTO Grushevskaya_dict_country (NAME) VALUES ('��������������');
--INSERT INTO Grushevskaya_dict_country (NAME) VALUES ('������');
--INSERT INTO Grushevskaya_dict_country (NAME) VALUES ('����');
--INSERT INTO Grushevskaya_dict_country (NAME) VALUES ('���');
--INSERT INTO Grushevskaya_dict_country (NAME) VALUES ('������');
/
-- SINGER � ����������� (���, ��������� ��� �������� ������; ������)

CREATE TABLE Grushevskaya_singer(
    -- ���, ��������� ��� �������� ������
    NAME VARCHAR2(100 BYTE),
    -- ������
    COUNTRY VARCHAR2(100 BYTE)
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('����� �������','���');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('��� ���������','��������������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('Backstreet Boys','���');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('ABBA','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('��������� ���������','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('��� �������','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('������ ����','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('������� �������','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('������ ����','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('����� ������','������');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('���� �������������','����');
--INSERT INTO Grushevskaya_singer (NAME,COUNTRY) VALUES ('������ ����','������');
/
-- ����������� �� SINGER
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT Grushevskaya_singer_pk
    PRIMARY KEY(NAME) ENABLE;
ALTER TABLE Grushevskaya_singer 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE Grushevskaya_singer 
    MODIFY (COUNTRY NOT NULL ENABLE);
    
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT Grushevskaya_singer_fk
    FOREIGN KEY (COUNTRY)
    REFERENCES Grushevskaya_dict_country (NAME) 
    ON DELETE SET NULL ENABLE;

-- STYLE - ��������������� �������, ���������� ������� ������
-- ��������� ��������, ����� ���-�� ����� "����", � ���-�� "����".

CREATE TABLE Grushevskaya_dict_style(
    -- �������� �����
    NAME VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('�������');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('����');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('�����');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('���-������');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('���������');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('����-�-����');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('����-���');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('����');
--INSERT INTO Grushevskaya_dict_style (NAME) VALUES ('����-���');

-- RECORD

/
-- ��������� ������� ������������
CREATE TYPE Grushevskaya_singer_tab AS TABLE OF VARCHAR2(100 BYTE);
/
-- RECORD � ������ (�������������, ��������, ����� ��������, 
-- �����, ������ ������������)
CREATE TABLE Grushevskaya_record(
    -- �������������
    ID NUMBER(10,0),
    -- ��������
    NAME VARCHAR2(100 BYTE),
    -- ����� ��������
    TIME INTERVAL DAY (0) TO SECOND (0),
    -- �����
    STYLE VARCHAR2(100 BYTE),
    -- ������ ������������
    SINGER_LIST Grushevskaya_singer_tab
)NESTED TABLE SINGER_LIST
    STORE AS Grushevskaya_singer_list;
--/
---- �������� ������
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('1','Wanna Be Startin� Somethin�','+00 00:06:30.000000','���������', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('2','Baby Be Mine','+00 00:04:20.000000','���-������', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('3','The Girl Is Mine','+00 00:03:41.000000','����-���', Grushevskaya_singer_tab('����� �������', '��� ���������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('4','Thriller','+00 00:05:58.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('5','Beat It','+00 00:04:18.000000','����-���', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('6','Billie Jean','+00 00:04:50.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('7','Human Nature','+00 00:04:06.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('8','Pretty Young Thing','+00 00:03:58.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('9','The Lady in My Life','+00 00:05:00.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('10','Larger than life','+00 00:03:52.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('11','I want it that way','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('12','Show me the meaning of being lonely','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('13','It�s gotta be you','+00 00:02:56.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('14','I need you tonight','+00 00:04:23.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('15','Don�t want you back','+00 00:03:25.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('16','Don�t wanna lose you now','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('17','The one','+00 00:03:46.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('18','Back to your heart','+00 00:04:21.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('19','Spanish eyes','+00 00:03:53.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('20','No one else comes close','+00 00:03:42.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('21','The perfect fan','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('22','Dancing Queen','+00 00:03:51.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('23','Knowing Me, Knowing You','+00 00:04:03.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('24','Take a Chance on Me','+00 00:04:06.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('25','Mamma Mia','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('26','Lay All Your Love on Me','+00 00:04:35.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('27','Super Trouper','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('28','I Have a Dream','+00 00:04:42.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('29','The Winner Takes It All','+00 00:04:54.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('30','Money, Money, Money','+00 00:03:05.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('31','SOS','+00 00:03:23.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('32','Chiquitita','+00 00:05:26.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('33','Fernando','+00 00:04:14.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('34','Voulez-Vous','+00 00:05:09.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('35','Gimme! Gimme! Gimme!','+00 00:04:46.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('36','Does Your Mother Know','+00 00:03:15.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('37','One of Us','+00 00:03:56.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('38','The Name of the Game','+00 00:04:51.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('39','Thank You for the Music','+00 00:03:51.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('40','Waterloo','+00 00:02:42.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('41','����� ��� ������','+00 00:02:52.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('42','������ �������','+00 00:02:16.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('43','����������� �����','+00 00:03:32.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('44','����� ���������','+00 00:02:34.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('45','������ ������','+00 00:04:54.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('46','�����','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (ID,NAME,TIME,STYLE,SINGER_LIST) VALUES ('47','����� ������� � ���������','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������', '����� ������', '���� �������������', '������ ����'));
/
-- ����������� �� RECORD
ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT Grushevskaya_record_pk 
    PRIMARY KEY(ID) ENABLE;
ALTER TABLE Grushevskaya_record 
    MODIFY (ID NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (TIME NOT NULL ENABLE);
    
ALTER TABLE Grushevskaya_record 
    MODIFY (STYLE NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT Grushevskaya_record_fk
    FOREIGN KEY (STYLE)
    REFERENCES Grushevskaya_dict_style (NAME) 
    ON DELETE SET NULL ENABLE;
    
-- ALBUM

-- ��������� ������ �������
CREATE TYPE Grushevskaya_record_arr AS VARRAY(30) OF NUMBER(10,0);
/
-- ALBUM � ������ (�������������, ��������, ���������, 
-- ���������� �� ������, ���������� ��������� �����������,
-- ������ �������)
CREATE TABLE Grushevskaya_album(
    -- �������������    
    ID NUMBER(10, 0),
    -- ��������
    NAME VARCHAR2(100 BYTE),
    -- ���������
    PRICE NUMBER(6,2),
    -- ���������� �� ������
    QUANTITY_IN_STOCK NUMBER(5, 0),
    -- ���������� ��������� �����������
    QUANTITY_OF_SOLD NUMBER(5, 0),
    -- ������ (������) �������
    RECORD_ARRAY Grushevskaya_record_arr
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('1','Thriller','792,5','188','37', Grushevskaya_record_arr(1, 2, 3, 4, 5, 6, 7, 8, 9, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('2','Millennium','836,24','33','42', Grushevskaya_record_arr(11, 13, 14, 15, 16, 17, 18, 19, 20, 21, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('3','ABBA Gold: Greatest Hits','921,34','199','142', Grushevskaya_record_arr(22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('4','��������� ��������� � ��� �������','127,99','44','7', Grushevskaya_record_arr(41, 42, 43, 44, 45, 46, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('5','������','87,99','10','0', Grushevskaya_record_arr(3, 4, 8, 12, 16, 17, 23, 29, 32, 38, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (ID,NAME,PRICE,QUANTITY_IN_STOCK,QUANTITY_OF_SOLD,RECORD_ARRAY) VALUES ('6','������ ������','0','0','0', Grushevskaya_record_arr(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
/
-- ����������� �� ALBUM
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT Grushevskaya_album_pk
    PRIMARY KEY(ID) ENABLE;
ALTER TABLE Grushevskaya_album 
    MODIFY (ID NOT NULL ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (NAME NOT NULL ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (PRICE NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT Grushevskaya_album_chk1 
    CHECK (PRICE >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (QUANTITY_IN_STOCK NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT Grushevskaya_album_chk2 
    CHECK (QUANTITY_IN_STOCK >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (QUANTITY_OF_SOLD NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT Grushevskaya_album_chk3 
    CHECK (QUANTITY_OF_SOLD >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (RECORD_ARRAY NOT NULL ENABLE);
/

-- ����� �������-��-������ SINGER-RECORD

-- �������� ������������ �����������.
-- �������� �������� �����.
-- ���� ������������ ������������ �� ������������� ������� ������������,
-- �� �������� ������� ��� "��������" ����������
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORDS
BEFORE INSERT OR UPDATE ON Grushevskaya_record
FOR EACH ROW
DECLARE
    LIST_NAME Grushevskaya_singer_tab;
    FLAG_RECORD_USES BOOLEAN := FALSE;
BEGIN
    -- �������� �� NULL ���� SINGER_LIST
    IF :NEW.SINGER_LIST IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
       DBMS_OUTPUT.PUT_LINE('SINGER_LIST �� ������ ���� ������ (NULL).'); 
       RAISE grushevskaya_exceptions.ERROR_RECORD;
    END IF;
    -- �������� ������ �� ��.���.
    FOR i IN 1..:NEW.SINGER_LIST.COUNT
    LOOP
        IF :NEW.SINGER_LIST(i) IS NULL THEN 
            :NEW.SINGER_LIST.DELETE(i);
        END IF;
    END LOOP;
    :NEW.SINGER_LIST := SET(:NEW.SINGER_LIST);
    -- ������ ������������ �� ������ ���� ����
    IF :NEW.SINGER_LIST IS EMPTY THEN
        IF INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
           DBMS_OUTPUT.PUT_LINE('SINGER_LIST �� ������ ���� ������ (EMPTY).'); 
           RAISE grushevskaya_exceptions.ERROR_RECORD;
        END IF;
        IF UPDATING THEN
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ���������.'
            );
            DBMS_OUTPUT.PUT_LINE(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ����������� ���� �� ���� ������ ����.'
            );
            RAISE grushevskaya_exceptions.WARNING_UPDATE;
        END IF;
    END IF;
    -- ������ ��� ���������� � ����� �� �������� => ��������� ���. ������    
    IF UPDATING THEN
        FOR ALBUM_ROW IN (SELECT * FROM Grushevskaya_album)
        LOOP
            FOR i IN 1..ALBUM_ROW.RECORD_ARRAY.COUNT
            LOOP
                IF ALBUM_ROW.RECORD_ARRAY(i) = :OLD.ID THEN
                    FLAG_RECORD_USES := TRUE;
                END IF;
            END LOOP;
        END LOOP;
        IF FLAG_RECORD_USES
           AND NOT (SET(:NEW.SINGER_LIST) = SET(:OLD.SINGER_LIST)) THEN
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ���������.'
            );
            DBMS_OUTPUT.PUT_LINE(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ������ ��� ���������� � ����� �� ��������.'
            );
            RAISE grushevskaya_exceptions.WARNING_UPDATE;
        END IF;
    END IF;
    -- �������� ����.��.
    -- ���� ������������ ������������ �� ������������� ������� ������������,
    -- �� �������� ������� ��� "��������" ����������
    SELECT NAME BULK COLLECT INTO LIST_NAME FROM Grushevskaya_singer;
    IF :NEW.SINGER_LIST NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('������������ ������ ������������.');
            RAISE grushevskaya_exceptions.ERROR_RECORD;
        ELSE
            :NEW.ID := :OLD.ID;
            :NEW.NAME := :OLD.NAME;
            :NEW.TIME := :OLD.TIME;
            :NEW.STYLE := :OLD.STYLE;
            :NEW.SINGER_LIST := :OLD.SINGER_LIST;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.ID 
                || ' �� ���� ��������� ��-�� ��������� �������� ����� (�����������).'
            );
            RAISE grushevskaya_exceptions.WARNING_UPDATE;
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
BEFORE DELETE ON Grushevskaya_singer
FOR EACH ROW
BEGIN
    FOR RECORD_ROW IN (SELECT * FROM Grushevskaya_record)
    LOOP
        FOR i IN 1..RECORD_ROW.SINGER_LIST.COUNT
        LOOP
            IF RECORD_ROW.SINGER_LIST(i) = :OLD.NAME THEN                
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_SINGERS_DEL');
                DBMS_OUTPUT.PUT_LINE(
                    '����������� � ��������������� ' 
                    || :OLD.NAME 
                    || ' ������� ������ - � ���� ���� �����.'
                );
                RAISE grushevskaya_exceptions.ERROR_SINGER_DEL;
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
FOR UPDATE OF NAME ON Grushevskaya_singer
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF VARCHAR2(100 BYTE) INDEX BY PLS_INTEGER;
    SINGERS_CHANGES CHANGES_ARR;
AFTER EACH ROW IS
    BEGIN
        SINGERS_CHANGES(:OLD.NAME) := :NEW.NAME;
    END AFTER EACH ROW;
AFTER STATEMENT IS
        LIST_NAME Grushevskaya_singer_tab;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR RECORD_ROW IN (SELECT * FROM Grushevskaya_record)
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
                UPDATE Grushevskaya_record
                    SET SINGER_LIST = SET(LIST_NAME)
                    WHERE ID = RECORD_ROW.ID;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- ����� �������-��-������ RECORD-ALBUM

-- �������� ������������ �����������.
-- �������� ����. ��.
-- ����� �������� ��� ����������� �������
-- ���������, ��� ��� ������ ����������.
-- ���� ���, �� ���� �������� ������, 
-- ���� "��������" ����������.
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_ALBUM
BEFORE INSERT OR UPDATE ON Grushevskaya_album
FOR EACH ROW
DECLARE
    TYPE UNIQUE_RECORDS IS TABLE OF NUMBER INDEX BY VARCHAR(100);
    LIST_UNIQUE_RECORDS UNIQUE_RECORDS;
    UNIQUE_RECORDS_VARRAY Grushevskaya_record_arr := Grushevskaya_record_arr();
    CURRENT_UNIQUE_RECORD VARCHAR2(100 BYTE);
    TYPE Grushevskaya_record_TAB IS TABLE OF NUMBER(10, 0);
    LIST_ID Grushevskaya_record_TAB;    
BEGIN
    IF UPDATING('RECORD_ARRAY') THEN
        -- �������� ���������� �� VARRAY
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
        -- ���� ������ ������, �� ��������� ����� ������.    
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
                    DBMS_OUTPUT.PUT_LINE(
                        '������ � ��������������� ' 
                        || :OLD.ID 
                        || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.'
                    );
                    RAISE grushevskaya_exceptions.WARNING_UPDATE;
                END IF;
                IF :NEW.RECORD_ARRAY(j) <> :OLD.RECORD_ARRAY(j) THEN
                    :NEW.ID := :OLD.ID;
                    :NEW.NAME := :OLD.NAME;
                    :NEW.PRICE := :OLD.PRICE;
                    :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                    :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                    :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                               
                    DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                    DBMS_OUTPUT.PUT_LINE(
                        '������ � ��������������� ' 
                        || :OLD.ID 
                        || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.'
                    );
                    RAISE grushevskaya_exceptions.WARNING_UPDATE;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- �������� ����.��.
    -- ����� �������� ��� ����������� �������
    -- ���������, ��� ��� ������ ����������.
    -- ���� ���, �� ���� �������� ������, 
    -- ���� "��������" ����������.
    SELECT ID BULK COLLECT INTO LIST_ID FROM Grushevskaya_record;
    FOR i IN 1..:NEW.RECORD_ARRAY.COUNT
    LOOP
       IF NOT :NEW.RECORD_ARRAY(i) IS NULL
          AND NOT :NEW.RECORD_ARRAY(i) MEMBER LIST_ID THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('������������ ������ �������.');
                RAISE grushevskaya_exceptions.ERROR_ALBUM;
            ELSE
                :NEW.ID := :OLD.ID;
                :NEW.NAME := :OLD.NAME;
                :NEW.PRICE := :OLD.PRICE;
                :NEW.QUANTITY_IN_STOCK := :OLD.QUANTITY_IN_STOCK;
                :NEW.QUANTITY_OF_SOLD := :OLD.QUANTITY_OF_SOLD;
                :NEW.RECORD_ARRAY := :OLD.RECORD_ARRAY;                          
                DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE(
                    '������ � ��������������� ' 
                    || :OLD.ID 
                    || ' �� ��� �������� ��-�� ��������� �������� ����� (������).'
                );
                RAISE grushevskaya_exceptions.WARNING_UPDATE;
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
BEFORE DELETE ON Grushevskaya_record
FOR EACH ROW
BEGIN
    FOR ALBUM_ROW IN (SELECT * FROM Grushevskaya_album)
    LOOP
        FOR i IN 1..ALBUM_ROW.RECORD_ARRAY.COUNT
        LOOP
            IF ALBUM_ROW.RECORD_ARRAY(i) = :OLD.ID THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORD_DEL');
                DBMS_OUTPUT.PUT_LINE(
                    '����� � ��������������� ' 
                    || :OLD.ID 
                    || ' ������� ������ - ��� ���� � �������.'
                );
                RAISE grushevskaya_exceptions.ERROR_RECORD_DEL;
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
FOR UPDATE OF ID ON Grushevskaya_record
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF NUMBER(10,0) INDEX BY PLS_INTEGER;
    RECORD_CHANGES CHANGES_ARR;
    AFTER EACH ROW IS
    BEGIN
        RECORD_CHANGES(:OLD.ID) := :NEW.ID;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        ID_ARR Grushevskaya_record_arr;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR ALBUM_ROW IN (SELECT * FROM Grushevskaya_album)
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
                UPDATE Grushevskaya_album
                    SET RECORD_ARRAY = ID_ARR
                    WHERE ID = ALBUM_ROW.ID;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- ����� grushevskaya_package � ������������� ������������

CREATE OR REPLACE 
PACKAGE grushevskaya_package AS
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
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER,
        -- ID ����������� ������
        RECORD_ID NUMBER
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� ��� �������.
    PROCEDURE ADD_ALBUM (
        -- ��������
        NAME VARCHAR2,
        -- ���� (>= 0)
        PRICE NUMBER,
        -- ���������� �� ������ (>= 0)
        QUANTITY_IN_STOCK NUMBER
    );
    -- 5) �������� ���� � ������ 
    -- (���� �� ������� �� ������ ����������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE ADD_RECORD_IN_ALBUM (
        -- ID �������
        ALBUM_ID NUMBER,
        -- ID ����������� ������ 
        RECORD_ID NUMBER
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
        -- ��� �����������        
        SINGER_NAME VARCHAR2
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
    PROCEDURE PRINT_ALBUM_AUTHOR;
END;
/
CREATE OR REPLACE
PACKAGE BODY grushevskaya_package AS
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
        INSERT INTO Grushevskaya_dict_country (NAME) VALUES (NAME);
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
        INSERT INTO Grushevskaya_dict_style (NAME) VALUES (NAME);
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
        INSERT INTO Grushevskaya_record (ID, NAME, TIME, STYLE, SINGER_LIST)
            VALUES (
            Grushevskaya_num_record.NEXTVAL, 
            NAME, 
            TIME, 
            STYLE, 
            Grushevskaya_singer_tab(SINGER)
        );
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || NAME 
            || ' � ID ' || Grushevskaya_num_record.CURRVAL 
            || ' ������� ���������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_RECORD THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
        ELSIF SQLCODE = -1873 THEN
            DBMS_OUTPUT.PUT_LINE('�������� �������� �������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_RECORD; 
    
    PROCEDURE ADD_SINGER_IN_RECORD (
        RECORD_ID NUMBER,
        SINGER_NAME VARCHAR2
    ) IS
        TMP_SINGER_LIST Grushevskaya_singer_tab;
    BEGIN
        IF SINGER_NAME IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
            RETURN;
        END IF;
        SELECT SINGER_LIST INTO TMP_SINGER_LIST 
            FROM Grushevskaya_record
            WHERE ID = RECORD_ID;
        TMP_SINGER_LIST.EXTEND;
        TMP_SINGER_LIST(TMP_SINGER_LIST.LAST) := SINGER_NAME;
        UPDATE Grushevskaya_record
            SET SINGER_LIST = TMP_SINGER_LIST
            WHERE ID = RECORD_ID;
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            '����������� ' || SINGER_NAME 
            || ' ������� �������� � ������ � ID ' || RECORD_ID || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
        RETURN;
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
        INSERT INTO Grushevskaya_singer (NAME, COUNTRY)
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
        NAME VARCHAR2,
        PRICE NUMBER,
        QUANTITY_IN_STOCK NUMBER,
        RECORD_ID NUMBER
    ) IS
        RECORD_ARR Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        RECORD_ARR.EXTEND(30);
        RECORD_ARR(1) := RECORD_ID;
        INSERT INTO Grushevskaya_album (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARRAY
        ) VALUES (
            Grushevskaya_num_album.NEXTVAL, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            0,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || NAME 
            || ' � ID ' || Grushevskaya_num_album.CURRVAL 
            || ' ������� ��������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_ALBUM THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
        QUANTITY_IN_STOCK NUMBER
    ) IS
        RECORD_ARR Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        RECORD_ARR.EXTEND(30);
        INSERT INTO Grushevskaya_album (
            ID, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            QUANTITY_OF_SOLD,
            RECORD_ARRAY
        ) VALUES (
            Grushevskaya_num_album.NEXTVAL, 
            NAME, 
            PRICE, 
            QUANTITY_IN_STOCK,
            0,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || NAME 
            || ' � ID ' || Grushevskaya_num_album.CURRVAL 
            || ' ������� ��������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_ALBUM THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
    
    PROCEDURE ADD_RECORD_IN_ALBUM (
        ALBUM_ID NUMBER, 
        RECORD_ID NUMBER
    )IS
        RECORD_SERIAL_NUMBER NUMBER := -1;
        TMP_RECORD_ARR Grushevskaya_record_arr;
    BEGIN        
        IF RECORD_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO TMP_RECORD_ARR
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        FOR i IN REVERSE 1..TMP_RECORD_ARR.COUNT
        LOOP
            IF TMP_RECORD_ARR(i) IS NULL THEN
                RECORD_SERIAL_NUMBER := i;
            END IF;
        END LOOP;
        IF RECORD_SERIAL_NUMBER = -1 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������ � ID ' 
                || ALBUM_ID 
                || ' �� ����� ��������� ������ 30 �������. ������ � ID ' 
                || RECORD_ID 
                || ' �� ���������.'
            );
        END IF;
        TMP_RECORD_ARR(RECORD_SERIAL_NUMBER) := RECORD_ID;
        UPDATE Grushevskaya_album
            SET RECORD_ARRAY = TMP_RECORD_ARR
            WHERE ID = ALBUM_ID;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ � ID ' || RECORD_ID 
            || ' ������� ��������� � ������ � ID ' || ALBUM_ID || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_ALBUM THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album WHERE QUANTITY_IN_STOCK > 0)
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
        FOR SINGER IN (SELECT * FROM Grushevskaya_singer)
        LOOP
            DBMS_OUTPUT.PUT_LINE(SINGER.NAME);
        END LOOP;  
        DBMS_OUTPUT.PUT_LINE('����� ������ ������������. ������ ���.');
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
            DBMS_OUTPUT.PUT_LINE(
                '� ������� ��������� ������������� ' 
                || '���������� �������� c ID ' 
                || ALBUM_ID || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET QUANTITY_IN_STOCK = QUANTITY_IN_STOCK + QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '� ������� ��������� ' || QUANTITY 
            || ' �������� c ID ' || ALBUM_ID || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_ALBUMS_IN_STOCK');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��������������� �������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;        
    END ADD_ALBUMS_IN_STOCK;    
    
    PROCEDURE SELL_ALBUMS(
        ALBUM_ID NUMBER,
        QUANTITY NUMBER
    ) IS
        RECORD_ARR Grushevskaya_record_arr;
        FLAG_ONE_RECORD BOOLEAN := FALSE;
        MAX_QUANTITY NUMBER;
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '�������� ������������� ���������� �������� c ID ' 
                || ALBUM_ID || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO RECORD_ARR 
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                FLAG_ONE_RECORD := TRUE;
            END IF;
        END LOOP;
        IF NOT FLAG_ONE_RECORD THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ������ c ID ' 
                || ALBUM_ID || ' ������. � ������� ��� ������.'
            );
            RETURN;
        END IF;
        SELECT QUANTITY_IN_STOCK INTO MAX_QUANTITY 
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        MAX_QUANTITY := LEAST(MAX_QUANTITY, QUANTITY);
        IF MAX_QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ������ c ID ' 
                || ALBUM_ID || ' ������. �������� ��� �� ������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET 
                QUANTITY_IN_STOCK = QUANTITY_IN_STOCK - MAX_QUANTITY,
                QUANTITY_OF_SOLD = QUANTITY_OF_SOLD + MAX_QUANTITY
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '������� ' || MAX_QUANTITY 
            || ' �������� c ID ' || ALBUM_ID || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN SELL_ALBUMS');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('������� ��������������� �������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;       
    END SELL_ALBUMS;
    
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS
    IS
        DEL_SINGERS_LIST Grushevskaya_singer_tab;
    BEGIN
        SELECT NAME BULK COLLECT INTO DEL_SINGERS_LIST FROM Grushevskaya_singer;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
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
                DELETE FROM Grushevskaya_singer
                WHERE NAME = DEL_SINGERS_LIST(j);
                DBMS_OUTPUT.PUT_LINE(
                    '������ ����������� ' 
                    || DEL_SINGERS_LIST(j) || '.'
                );
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
        ALBUM_NAME VARCHAR2(100 BYTE);
        RECORD_ARR Grushevskaya_record_arr;
        RECORD Grushevskaya_record%ROWTYPE;
        TIME INTERVAL DAY(0) TO SECOND(0) := NUMTODSINTERVAL(0, 'SECOND');
        SINGERS VARCHAR2(300) := '';
    BEGIN
        SELECT NAME INTO ALBUM_NAME
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        DBMS_OUTPUT.PUT_LINE('������ �' || ALBUM_ID || ' � ������ ' || ALBUM_NAME);
        SELECT RECORD_ARRAY INTO RECORD_ARR
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                SELECT * INTO RECORD FROM Grushevskaya_record 
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
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
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
        TMP_RECORD_ARR Grushevskaya_record_arr;
        TMP_QUANTITY_OF_SOLD NUMBER;
    BEGIN
        SELECT QUANTITY_OF_SOLD INTO TMP_QUANTITY_OF_SOLD
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        IF TMP_QUANTITY_OF_SOLD > 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ���� �' 
                || RECORD_NUMBER || ' ������, ��� ��� ������ ������'
            );
            RETURN;
        END IF;
        SELECT RECORD_ARRAY INTO TMP_RECORD_ARR 
            FROM Grushevskaya_album
            WHERE ID = ALBUM_ID;
        FOR i IN RECORD_NUMBER..TMP_RECORD_ARR.COUNT-1
        LOOP
            TMP_RECORD_ARR(i) := TMP_RECORD_ARR(i+1);
        END LOOP;
        TMP_RECORD_ARR(TMP_RECORD_ARR.COUNT) := NULL;
        UPDATE Grushevskaya_album
            SET RECORD_ARRAY = TMP_RECORD_ARR
            WHERE ID = ALBUM_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('���� �' || RECORD_NUMBER || ' ������');            
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_ALBUM THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
        SINGER_NAME VARCHAR2
    ) IS
        TMP_SINGER_LIST Grushevskaya_singer_tab;
        SINGER_NUMBER NUMBER := 0;
    BEGIN
        SELECT SINGER_LIST INTO TMP_SINGER_LIST 
            FROM Grushevskaya_record
            WHERE ID = RECORD_ID;
        FOR i IN 1..TMP_SINGER_LIST.COUNT
        LOOP
            IF TMP_SINGER_LIST(i) = SINGER_NAME THEN
                SINGER_NUMBER := i;
            END IF;
        END LOOP;
        TMP_SINGER_LIST.DELETE(SINGER_NUMBER);        
        UPDATE Grushevskaya_record
            SET SINGER_LIST = TMP_SINGER_LIST
            WHERE ID = RECORD_ID;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '����������� ' || SINGER_NAME || ' ��� �' || SINGER_NUMBER || ' ������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.ERROR_UPDATE_SINGER_IN_RECORD THEN
        RETURN;
    WHEN grushevskaya_exceptions.WARNING_UPDATE THEN
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
        COUNT_SINGER_IN_TABLE NUMBER := 0;
        TYPE SINGER_STYLE IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        SINGER_STYLE_LIST SINGER_STYLE;
        CURRENT_ELEM VARCHAR2(100 BYTE);
        MAX_STYLE VARCHAR2(100 BYTE);
    BEGIN
        SELECT COUNT(NAME) INTO COUNT_SINGER_IN_TABLE 
            FROM Grushevskaya_singer
            WHERE NAME = SINGER_NAME;
        IF COUNT_SINGER_IN_TABLE = 0 THEN
            DBMS_OUTPUT.PUT_LINE('����������� �� ������.');
            RETURN;
        END IF;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
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
            DBMS_OUTPUT.PUT_LINE('� ����������� ��� �������.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            '�������� ���������� ����� � ' 
            || SINGER_NAME || ' - '  || MAX_STYLE || '.'
        );       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_SINGER_STYLE');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_SINGER_STYLE;
    
    PROCEDURE PRINT_COUNTRY_STYLE
    IS
        TYPE SINGER_STYLE IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        TYPE COUNTRY_STYLE IS TABLE OF SINGER_STYLE INDEX BY VARCHAR2(100 BYTE);
        COUNTRY_STYLE_LIST COUNTRY_STYLE;
        TMP_COUNTRY VARCHAR2(100 BYTE);
        CURRENT_COUNTRY VARCHAR2(100 BYTE);
        CURRENT_STYLE VARCHAR2(100 BYTE);
        MAX_STYLE VARCHAR2(100 BYTE);
    BEGIN
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..RECORD.SINGER_LIST.COUNT
            LOOP
                SELECT COUNTRY INTO TMP_COUNTRY 
                    FROM Grushevskaya_singer 
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
            DBMS_OUTPUT.PUT_LINE(
                '�������� ���������� ����� � '  
                || CURRENT_COUNTRY || ' - ' || MAX_STYLE || '.'
            );
            CURRENT_COUNTRY := COUNTRY_STYLE_LIST.NEXT(CURRENT_COUNTRY);
        END LOOP;       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_COUNTRY_STYLE');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_COUNTRY_STYLE; 
    
    PROCEDURE PRINT_ALBUM_AUTHOR
    IS
        TYPE ALL_ALBUM_ID IS TABLE OF VARCHAR2(100 BYTE);
        ALBUM_ID ALL_ALBUM_ID;
        TYPE ALBUM_SINGER IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        ALBUM_SINGER_LIST ALBUM_SINGER;
        SINGERS Grushevskaya_singer_tab;
        RECORD_COUNT NUMBER;
        CURRENT_SINGER VARCHAR(100 BYTE);
        FLAG_GROUP BOOLEAN;
    BEGIN   
        DBMS_OUTPUT.PUT_LINE('��������� ��������.');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
        LOOP
            RECORD_COUNT := 0;
            ALBUM_SINGER_LIST.DELETE;
            FOR i IN 1..ALBUM.RECORD_ARRAY.COUNT
            LOOP
                IF NOT ALBUM.RECORD_ARRAY(i) IS NULL THEN
                    RECORD_COUNT := RECORD_COUNT + 1;
                    SELECT SINGER_LIST INTO SINGERS
                        FROM Grushevskaya_record
                        WHERE ID = ALBUM.RECORD_ARRAY(i);
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
            FLAG_GROUP := FALSE;
            CURRENT_SINGER := ALBUM_SINGER_LIST.FIRST;
            WHILE NOT CURRENT_SINGER IS NULL
            LOOP
                IF ALBUM_SINGER_LIST(CURRENT_SINGER) <> RECORD_COUNT THEN
                    FLAG_GROUP := TRUE;
                END IF;
                CURRENT_SINGER := ALBUM_SINGER_LIST.NEXT(CURRENT_SINGER);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(
                '��������� ������� ' || ALBUM.NAME || ' � ID ' || ALBUM.ID || 
                '.'
            );
            IF FLAG_GROUP THEN
                DBMS_OUTPUT.PUT_LINE('������������ �������.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('�����������:');
                CURRENT_SINGER := ALBUM_SINGER_LIST.FIRST;
                IF CURRENT_SINGER IS NULL THEN
                    DBMS_OUTPUT.PUT_LINE('������������ � ������� ���.');
                END IF;
                WHILE NOT CURRENT_SINGER IS NULL
                LOOP
                    DBMS_OUTPUT.PUT_LINE(CURRENT_SINGER);
                    CURRENT_SINGER := ALBUM_SINGER_LIST.NEXT(CURRENT_SINGER);
                END LOOP;
            END IF; 
        END LOOP;        
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

