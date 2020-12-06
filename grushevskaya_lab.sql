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
    Warning_update EXCEPTION;
    Error_record EXCEPTION;
    Error_update_singer_in_record EXCEPTION;
    Error_singer_del EXCEPTION;
    Error_album EXCEPTION;
    Error_record_del EXCEPTION;
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

-- country - ��������������� �������, ���������� ������� �����. 
-- ��������� ��������, ����� ���-�� ������ "��", � ���-�� "������".

CREATE TABLE Grushevskaya_dict_country(
    -- �������� ������
    name Varchar2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('��������������');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('������');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('����');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('���');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('������');
/
-- singer � ����������� (���, ��������� ��� �������� ������; ������)

CREATE TABLE Grushevskaya_singer(
    -- ���, ��������� ��� �������� ������
    name Varchar2(100 BYTE),
    -- ������
    country Varchar2(100 BYTE)
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('����� �������','���');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('��� ���������','��������������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Backstreet Boys','���');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('ABBA','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('��������� ���������','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('��� �������','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('������� �������','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('����� ������','������');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('���� �������������','����');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
/
-- ����������� �� SINGER
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT grushevskaya_singer_pk
    PRIMARY KEY(name) ENABLE;
ALTER TABLE Grushevskaya_singer 
    MODIFY (name NOT NULL ENABLE);

ALTER TABLE Grushevskaya_singer 
    MODIFY (country NOT NULL ENABLE);
    
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT grushevskaya_singer_fk
    FOREIGN KEY (country)
    REFERENCES Grushevskaya_dict_country (name) 
    ON DELETE SET NULL ENABLE;

-- style - ��������������� �������, ���������� ������� ������
-- ��������� ��������, ����� ���-�� ����� "����", � ���-�� "����".

CREATE TABLE Grushevskaya_dict_style(
    -- �������� �����
    name Varchar2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('�������');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('����');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('�����');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('���-������');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('���������');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-�-����');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-���');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('����');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-���');

-- RECORD

/
-- ��������� ������� ������������
CREATE TYPE Grushevskaya_singer_tab AS TABLE OF Varchar2(100 BYTE);
/
-- record � ������ 
-- (�������������, ��������, ����� ��������, 
-- �����, ������ ������������)
CREATE TABLE Grushevskaya_record (
    -- �������������
    id Number(10,0),
    -- ��������
    name Varchar2(100 BYTE),
    -- ����� ��������
    time INTERVAL DAY (0) TO SECOND (0),
    -- �����
    style Varchar2(100 BYTE),
    -- ������ ������������
    singer_list Grushevskaya_singer_tab
) NESTED TABLE Singer_list
    STORE AS Grushevskaya_singer_list;
--/
---- �������� ������
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('1','Wanna Be Startin� Somethin�','+00 00:06:30.000000','���������', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('2','Baby Be Mine','+00 00:04:20.000000','���-������', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('3','The Girl Is Mine','+00 00:03:41.000000','����-���', Grushevskaya_singer_tab('����� �������', '��� ���������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('4','Thriller','+00 00:05:58.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('5','Beat It','+00 00:04:18.000000','����-���', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('6','Billie Jean','+00 00:04:50.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('7','Human Nature','+00 00:04:06.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('8','Pretty Young Thing','+00 00:03:58.000000','����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('9','The Lady in My Life','+00 00:05:00.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('10','Larger than life','+00 00:03:52.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('11','I want it that way','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('12','Show me the meaning of being lonely','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('13','It�s gotta be you','+00 00:02:56.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('14','I need you tonight','+00 00:04:23.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('15','Don�t want you back','+00 00:03:25.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('16','Don�t wanna lose you now','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('17','The one','+00 00:03:46.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('18','Back to your heart','+00 00:04:21.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('19','Spanish eyes','+00 00:03:53.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('20','No one else comes close','+00 00:03:42.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('21','The perfect fan','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('22','Dancing Queen','+00 00:03:51.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('23','Knowing Me, Knowing You','+00 00:04:03.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('24','Take a Chance on Me','+00 00:04:06.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('25','Mamma Mia','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('26','Lay All Your Love on Me','+00 00:04:35.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('27','Super Trouper','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('28','I Have a Dream','+00 00:04:42.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('29','The Winner Takes It All','+00 00:04:54.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('30','Money, Money, Money','+00 00:03:05.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('31','SOS','+00 00:03:23.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('32','Chiquitita','+00 00:05:26.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('33','Fernando','+00 00:04:14.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('34','Voulez-Vous','+00 00:05:09.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('35','Gimme! Gimme! Gimme!','+00 00:04:46.000000','�����', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('36','Does Your Mother Know','+00 00:03:15.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('37','One of Us','+00 00:03:56.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('38','The Name of the Game','+00 00:04:51.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('39','Thank You for the Music','+00 00:03:51.000000','�������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('40','Waterloo','+00 00:02:42.000000','���-������', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('41','����� ��� ������','+00 00:02:52.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('42','������ �������','+00 00:02:16.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('43','����������� �����','+00 00:03:32.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('44','����� ���������','+00 00:02:34.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('45','������ ������','+00 00:04:54.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('46','�����','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('47','����� ������� � ���������','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������', '����� ������', '���� �������������', '������ ����'));
/
-- ����������� �� RECORD
ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT grushevskaya_record_pk 
    PRIMARY KEY(id) ENABLE;
ALTER TABLE Grushevskaya_record 
    MODIFY (id NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (name NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (time NOT NULL ENABLE);
    
ALTER TABLE Grushevskaya_record 
    MODIFY (style NOT NULL ENABLE);

ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT grushevskaya_record_fk
    FOREIGN KEY (style)
    REFERENCES Grushevskaya_dict_style (name) 
    ON DELETE SET NULL ENABLE;
    
-- ALBUM

-- ��������� ������ �������
CREATE TYPE Grushevskaya_record_arr AS Varray(30) OF Number(10,0);
/
-- ALBUM � ������ (�������������, ��������, ���������, 
-- ���������� �� ������, ���������� ��������� �����������,
-- ������ �������)
CREATE TABLE Grushevskaya_album (
    -- �������������    
    id Number(10, 0),
    -- ��������
    name Varchar2(100 BYTE),
    -- ���������
    price Number(6,2),
    -- ���������� �� ������
    quantity_in_stock Number(5, 0),
    -- ���������� ��������� �����������
    quantity_of_sold Number(5, 0),
    -- ������ (������) �������
    record_array Grushevskaya_record_arr
);
--/
---- �������� ������
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('1','Thriller','792,5','188','37', Grushevskaya_record_arr(1, 2, 3, 4, 5, 6, 7, 8, 9, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('2','Millennium','836,24','33','42', Grushevskaya_record_arr(11, 13, 14, 15, 16, 17, 18, 19, 20, 21, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('3','ABBA Gold: Greatest Hits','921,34','199','142', Grushevskaya_record_arr(22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('4','��������� ��������� � ��� �������','127,99','44','7', Grushevskaya_record_arr(41, 42, 43, 44, 45, 46, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('5','������','87,99','10','0', Grushevskaya_record_arr(3, 4, 8, 12, 16, 17, 23, 29, 32, 38, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('6','������ ������','0','0','0', Grushevskaya_record_arr(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
/
-- ����������� �� ALBUM
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_pk
    PRIMARY KEY(id) ENABLE;
ALTER TABLE Grushevskaya_album 
    MODIFY (id NOT NULL ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (name NOT NULL ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (price NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk1 
    CHECK (price >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (quantity_in_stock NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk2 
    CHECK (quantity_in_stock >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (quantity_of_sold NOT NULL ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk3 
    CHECK (quantity_of_sold >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (record_array NOT NULL ENABLE);
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
    -- �������� �� NULL ���� singer_list
    IF :NEW.singer_list IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
       DBMS_OUTPUT.PUT_LINE('singer_list �� ������ ���� ������ (NULL).'); 
       RAISE grushevskaya_exceptions.Error_record;
    END IF;
    -- �������� ������ �� ��.���.
    FOR i IN 1..:NEW.singer_list.COUNT
    LOOP
        IF :NEW.singer_list(i) IS NULL THEN 
            :NEW.singer_list.DELETE(i);
        END IF;
    END LOOP;
    :NEW.singer_list := SET(:NEW.singer_list);
    -- ������ ������������ �� ������ ���� ����
    IF :NEW.singer_list IS EMPTY THEN
        IF INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
           DBMS_OUTPUT.PUT_LINE('singer_list �� ������ ���� ������ (EMPTY).'); 
           RAISE grushevskaya_exceptions.Error_record;
        END IF;
        IF UPDATING THEN
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.id 
                || ' �� ���� ���������.'
            );
            DBMS_OUTPUT.PUT_LINE(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ����������� ���� �� ���� ������ ����.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- ������ ��� ���������� � ����� �� �������� => ��������� ���. ������    
    IF UPDATING THEN
        FOR ALBUM_ROW IN (SELECT * FROM Grushevskaya_album)
        LOOP
            FOR i IN 1..ALBUM_ROW.record_array.COUNT
            LOOP
                IF ALBUM_ROW.record_array(i) = :OLD.id THEN
                    FLAG_RECORD_USES := TRUE;
                END IF;
            END LOOP;
        END LOOP;
        IF FLAG_RECORD_USES
           AND NOT (SET(:NEW.singer_list) = SET(:OLD.singer_list)) THEN
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.id 
                || ' �� ���� ���������.'
            );
            DBMS_OUTPUT.PUT_LINE(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ������ ��� ���������� � ����� �� ��������.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- �������� ����.��.
    -- ���� ������������ ������������ �� ������������� ������� ������������,
    -- �� �������� ������� ��� "��������" ����������
    SELECT name BULK COLLECT INTO LIST_NAME FROM Grushevskaya_singer;
    IF :NEW.singer_list NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('������������ ������ ������������.');
            RAISE grushevskaya_exceptions.Error_record;
        ELSE
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                '������ � ��������������� ' 
                || :OLD.id 
                || ' �� ���� ��������� ��-�� ��������� �������� ����� (�����������).'
            );
            RAISE grushevskaya_exceptions.Warning_update;
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
        FOR i IN 1..RECORD_ROW.singer_list.COUNT
        LOOP
            IF RECORD_ROW.singer_list(i) = :OLD.name THEN                
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_SINGERS_DEL');
                DBMS_OUTPUT.PUT_LINE(
                    '����������� � ��������������� ' 
                    || :OLD.name 
                    || ' ������� ������ - � ���� ���� �����.'
                );
                RAISE grushevskaya_exceptions.Error_singer_del;
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
FOR UPDATE OF name ON Grushevskaya_singer
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF Varchar2(100 BYTE) INDEX BY PLS_INTEGER;
    SINGERS_CHANGES CHANGES_ARR;
AFTER EACH ROW IS
    BEGIN
        SINGERS_CHANGES(:OLD.name) := :NEW.name;
    END AFTER EACH ROW;
AFTER STATEMENT IS
        LIST_NAME Grushevskaya_singer_tab;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR RECORD_ROW IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FLAG := FALSE;
            LIST_NAME := RECORD_ROW.singer_list;
            FOR i IN 1..LIST_NAME.COUNT 
            LOOP
                IF SINGERS_CHANGES.EXISTS(LIST_NAME(i)) THEN
                    LIST_NAME(i) := SINGERS_CHANGES(LIST_NAME(i));
                    FLAG := TRUE;
                END IF;
            END LOOP;
            IF FLAG = TRUE THEN
                UPDATE Grushevskaya_record
                    SET singer_list = SET(LIST_NAME)
                    WHERE id = RECORD_ROW.id;
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
    TYPE UNIQUE_RECORDS IS TABLE OF Number INDEX BY Varchar(100);
    LIST_UNIQUE_RECORDS UNIQUE_RECORDS;
    UNIQUE_RECORDS_Varray Grushevskaya_record_arr := Grushevskaya_record_arr();
    CURRENT_UNIQUE_RECORD Varchar2(100 BYTE);
    TYPE Grushevskaya_record_TAB IS TABLE OF Number(10, 0);
    LIST_id Grushevskaya_record_TAB;    
BEGIN
    IF UPDATING('record_array') THEN
        -- �������� ���������� �� Varray
        FOR k IN 1..:NEW.record_array.COUNT
        LOOP
            IF NOT :NEW.record_array(k) IS NULL THEN
                IF NOT LIST_UNIQUE_RECORDS.EXISTS(:NEW.record_array(k)) THEN
                    LIST_UNIQUE_RECORDS(:NEW.record_array(k)) := k;
                END IF;                
            END IF;
        END LOOP;
        UNIQUE_RECORDS_Varray.EXTEND(30);
        CURRENT_UNIQUE_RECORD := LIST_UNIQUE_RECORDS.FIRST;
        WHILE NOT CURRENT_UNIQUE_RECORD IS NULL
        LOOP
            UNIQUE_RECORDS_Varray(LIST_UNIQUE_RECORDS(CURRENT_UNIQUE_RECORD)) := CURRENT_UNIQUE_RECORD;
            CURRENT_UNIQUE_RECORD := LIST_UNIQUE_RECORDS.NEXT(CURRENT_UNIQUE_RECORD);
        END LOOP;
        :NEW.record_array := UNIQUE_RECORDS_Varray;
        -- ���� ������ ������, �� ��������� ����� ������.    
        IF :OLD.quantity_of_sold > 0 THEN
            FOR j IN 1..:OLD.record_array.COUNT
            LOOP
                IF :NEW.record_array(j) IS NULL AND :OLD.record_array(j) IS NULL THEN
                    CONTINUE;
                END IF;
                IF :NEW.record_array(j) IS NULL OR :OLD.record_array(j) IS NULL THEN
                    :NEW.id := :OLD.id;
                    :NEW.name := :OLD.name;
                    :NEW.price := :OLD.price;
                    :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                    :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                    :NEW.record_array := :OLD.record_array;                               
                    DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                    DBMS_OUTPUT.PUT_LINE(
                        '������ � ��������������� ' 
                        || :OLD.id 
                        || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.'
                    );
                    RAISE grushevskaya_exceptions.Warning_update;
                END IF;
                IF :NEW.record_array(j) <> :OLD.record_array(j) THEN
                    :NEW.id := :OLD.id;
                    :NEW.name := :OLD.name;
                    :NEW.price := :OLD.price;
                    :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                    :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                    :NEW.record_array := :OLD.record_array;                               
                    DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                    DBMS_OUTPUT.PUT_LINE(
                        '������ � ��������������� ' 
                        || :OLD.id 
                        || ' �� ��� ��������. ������ ��������� �����, ���� ������ ������.'
                    );
                    RAISE grushevskaya_exceptions.Warning_update;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- �������� ����.��.
    -- ����� �������� ��� ����������� �������
    -- ���������, ��� ��� ������ ����������.
    -- ���� ���, �� ���� �������� ������, 
    -- ���� "��������" ����������.
    SELECT id BULK COLLECT INTO LIST_id FROM Grushevskaya_record;
    FOR i IN 1..:NEW.record_array.COUNT
    LOOP
       IF NOT :NEW.record_array(i) IS NULL
          AND NOT :NEW.record_array(i) MEMBER LIST_id THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('������������ ������ �������.');
                RAISE grushevskaya_exceptions.Error_album;
            ELSE
                :NEW.id := :OLD.id;
                :NEW.name := :OLD.name;
                :NEW.price := :OLD.price;
                :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                :NEW.record_array := :OLD.record_array;                          
                DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE(
                    '������ � ��������������� ' 
                    || :OLD.id 
                    || ' �� ��� �������� ��-�� ��������� �������� ����� (������).'
                );
                RAISE grushevskaya_exceptions.Warning_update;
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
        FOR i IN 1..ALBUM_ROW.record_array.COUNT
        LOOP
            IF ALBUM_ROW.record_array(i) = :OLD.id THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORD_DEL');
                DBMS_OUTPUT.PUT_LINE(
                    '����� � ��������������� ' 
                    || :OLD.id 
                    || ' ������� ������ - ��� ���� � �������.'
                );
                RAISE grushevskaya_exceptions.Error_record_del;
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
FOR UPDATE OF id ON Grushevskaya_record
COMPOUND TRIGGER
    TYPE CHANGES_ARR IS TABLE OF Number(10,0) INDEX BY PLS_INTEGER;
    RECORD_CHANGES CHANGES_ARR;
    AFTER EACH ROW IS
    BEGIN
        RECORD_CHANGES(:OLD.id) := :NEW.id;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        id_ARR Grushevskaya_record_arr;
        FLAG BOOLEAN := FALSE;
    BEGIN
        FOR ALBUM_ROW IN (SELECT * FROM Grushevskaya_album)
        LOOP
            FLAG := FALSE;
            id_ARR := ALBUM_ROW.record_array;
            FOR i IN 1..id_ARR.COUNT 
            LOOP
                IF RECORD_CHANGES.EXISTS(id_ARR(i)) THEN
                    id_ARR(i) := RECORD_CHANGES(id_ARR(i));
                    FLAG := TRUE;
                END IF;
            END LOOP;
            IF FLAG = TRUE THEN
                UPDATE Grushevskaya_album
                    SET record_array = id_ARR
                    WHERE id = ALBUM_ROW.id;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- ����� grushevskaya_package � ������������� ������������

CREATE OR REPLACE 
PACKAGE grushevskaya_package AS
    -- �������� ������ � �������.
    PROCEDURE ADD_IN_DICT_country (
        -- �������� ������
        name Varchar2
    );
    -- �������� ����� � �������.
    PROCEDURE ADD_IN_DICT_style (
        -- �������� �����
        name Varchar2
    );
    
    -- ����������� ����������
    
    -- 1) �������� ������ (���������� ����������� ���� �����������).
    PROCEDURE ADD_RECORD (
        -- ��������
        name Varchar2, 
        -- ���������� ����� ��������
        HOURS Number,
        -- ���������� ����� ��������
        MINUTES Number,
        -- ���������� ������ ��������
        SECONDS Number,
        -- ����� �� �������
        style Varchar2,
        -- ��� �����������
        SINGER Varchar2
    );
    -- 2) �������� ����������� ��� ������ 
    -- (���� ��������� ������ �� ��������� �� � ���� ������ 
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE ADD_SINGER_IN_RECORD (
        -- id ������
        RECORD_id Number,
        -- ��� �����������
        SINGER_NAME Varchar2
    );
    -- 3) �������� �����������.
    PROCEDURE ADD_SINGER (
        -- ��� (���)
        name Varchar2, 
        -- ������ �� �������
        country Varchar2
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� � ����� �������.
    PROCEDURE ADD_ALBUM (
        -- ��������
        name Varchar2,
        -- ���� (>= 0)
        price Number,
        -- ���������� �� ������ (>= 0)
        quantity_in_stock Number,
        -- id ����������� ������
        RECORD_id Number
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� ��� �������.
    PROCEDURE ADD_ALBUM (
        -- ��������
        name Varchar2,
        -- ���� (>= 0)
        price Number,
        -- ���������� �� ������ (>= 0)
        quantity_in_stock Number
    );
    -- 5) �������� ���� � ������ 
    -- (���� �� ������� �� ������ ����������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE ADD_RECORD_IN_ALBUM (
        -- id �������
        ALBUM_id Number,
        -- id ����������� ������ 
        RECORD_id Number
    );
    -- 6) ������ �������� � ������� (���������� �� ������ ������ 0).
    PROCEDURE PRINT_ALBUMS_IN_STOCK;
    -- 7) ������ ������������.
    PROCEDURE PRINT_SINGERS;
    -- 8) �������� �������
    -- (���������� �� ������ ������������� �� ��������� ��������).
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        -- id �������
        ALBUM_id Number,
        -- ����������
        QUANTITY Number
    );
    -- 9) ������� ������ 
    -- (���������� �� ������ �����������, ��������� � �������������; 
    -- ������� ����� ������ �������, � ������� ���� ���� �� ���� ����
    --  - ������� ����������� � ����� �������). 
    PROCEDURE SELL_ALBUMS(
        -- id �������
        ALBUM_id Number,
        -- ����������
        QUANTITY Number
    );
    -- 10) ������� ������������, � ������� ��� �� ����� ������.
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS;
    
    -- �������� ����������
    
    -- 11) ����-���� ���������� ������� 
    -- � ��������� ���������� ������� �������� �������.
    PROCEDURE PRINT_ALBUM_RECORDS(ALBUM_id Number);
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
        -- id �������
        ALBUM_id Number,
        -- ����� �������� ������ � �������
        RECORD_Number Number
    );
    -- 14) ������� ����������� �� ������ 
    -- (���� ������ �� ������ �� � ���� ������ 
    -- � ���� ���� ����������� �� ������������
    --  - ������� ����������� �� ������ ��������). 
    PROCEDURE DELETE_SINGER_FROM_RECORD(
        -- id ������
        RECORD_id Number,
        -- ��� �����������        
        SINGER_name Varchar2
    );
    -- 15) ���������� �������������� ����������� ����� ���������� ����������� 
    -- (�����, � ������� �������� ����������� ��� ������). 
    PROCEDURE PRINT_SINGER_style(
        -- ��� �����������
        SINGER_name Varchar2
    );
    -- 16) ���������� �������������� ����������� ����� 
    -- �� ������ ������ ������������� ������������.
    PROCEDURE PRINT_country_style; 
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
    PROCEDURE PRINT_MSG_EX(SQLCODE Number) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('��. ����������� ����������.');
        DBMS_OUTPUT.PUT_LINE('���: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('���������: ' || SQLERRM(SQLCODE));        
    END PRINT_MSG_EX;
    
    PROCEDURE ADD_IN_DICT_country (
        name Varchar2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_country (name) VALUES (name);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������ ' || name || ' ������� ���������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_country');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_IN_DICT_country;
    
    PROCEDURE ADD_IN_DICT_style (
        name Varchar2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_style (name) VALUES (name);
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE('����� ' || name || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_style');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ��� ������ �� �������� ������� ������.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('�������� ����������� ������������ ������ �� �����.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('���������� �������� NULL ��� ������ �� ��������.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END ADD_IN_DICT_style;
    
    PROCEDURE ADD_RECORD(
        name Varchar2,
        HOURS Number,
        MINUTES Number,
        SECONDS Number,
        style Varchar2,
        SINGER Varchar2
    ) IS
        time INTERVAL DAY(0) TO SECOND(0);
    BEGIN
        time := NUMTODSINTERVAL(HOURS, 'HOUR') 
            + NUMTODSINTERVAL(MINUTES, 'MINUTE') 
            + NUMTODSINTERVAL(SECONDS, 'SECOND');
        INSERT INTO Grushevskaya_record (id, name, time, style, singer_list)
            VALUES (
            Grushevskaya_num_record.NEXTVAL, 
            name, 
            time, 
            style, 
            Grushevskaya_singer_tab(SINGER)
        );
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || name 
            || ' � id ' || Grushevskaya_num_record.CURRVAL 
            || ' ������� ���������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('��� ����� ' || style || ' � �������.');
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
        RECORD_id Number,
        SINGER_name Varchar2
    ) IS
        TMP_singer_list Grushevskaya_singer_tab;
    BEGIN
        IF SINGER_name IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
            RETURN;
        END IF;
        SELECT singer_list INTO TMP_singer_list 
            FROM Grushevskaya_record
            WHERE id = RECORD_id;
        TMP_singer_list.EXTEND;
        TMP_singer_list(TMP_singer_list.LAST) := SINGER_name;
        UPDATE Grushevskaya_record
            SET singer_list = TMP_singer_list
            WHERE id = RECORD_id;
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            '����������� ' || SINGER_name 
            || ' ������� �������� � ������ � id ' || RECORD_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        name Varchar2,
        country Varchar2
    ) IS
    BEGIN
        INSERT INTO Grushevskaya_singer (name, country)
            VALUES (name, country);
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('����������� ' || name || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('��� ������ ' || country || ' � �������.');
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
        name Varchar2,
        price Number,
        quantity_in_stock Number,
        RECORD_id Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        RECORD_ARR.EXTEND(30);
        RECORD_ARR(1) := RECORD_id;
        INSERT INTO Grushevskaya_album (
            id, 
            name, 
            price, 
            quantity_in_stock,
            quantity_of_sold,
            record_array
        ) VALUES (
            Grushevskaya_num_album.NEXTVAL, 
            name, 
            price, 
            quantity_in_stock,
            0,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || name 
            || ' � id ' || Grushevskaya_num_album.CURRVAL 
            || ' ������� ��������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        name Varchar2,
        price Number,
        quantity_in_stock Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        RECORD_ARR.EXTEND(30);
        INSERT INTO Grushevskaya_album (
            id, 
            name, 
            price, 
            quantity_in_stock,
            quantity_of_sold,
            record_array
        ) VALUES (
            Grushevskaya_num_album.NEXTVAL, 
            name, 
            price, 
            quantity_in_stock,
            0,
            RECORD_ARR
        );
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ ' || name 
            || ' � id ' || Grushevskaya_num_album.CURRVAL 
            || ' ������� ��������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        ALBUM_id Number, 
        RECORD_id Number
    )IS
        RECORD_SERIAL_Number Number := -1;
        TMP_RECORD_ARR Grushevskaya_record_arr;
    BEGIN        
        IF RECORD_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('������ ��������� NULL-��������.');
            RETURN;
        END IF;
        SELECT record_array INTO TMP_RECORD_ARR
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        FOR i IN REVERSE 1..TMP_RECORD_ARR.COUNT
        LOOP
            IF TMP_RECORD_ARR(i) IS NULL THEN
                RECORD_SERIAL_Number := i;
            END IF;
        END LOOP;
        IF RECORD_SERIAL_Number = -1 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������ � id ' 
                || ALBUM_id 
                || ' �� ����� ��������� ������ 30 �������. ������ � id ' 
                || RECORD_id 
                || ' �� ���������.'
            );
        END IF;
        TMP_RECORD_ARR(RECORD_SERIAL_Number) := RECORD_id;
        UPDATE Grushevskaya_album
            SET record_array = TMP_RECORD_ARR
            WHERE id = ALBUM_id;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            '������ � id ' || RECORD_id 
            || ' ������� ��������� � ������ � id ' || ALBUM_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        QUANTITY Number := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('������� � �������:');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album WHERE quantity_in_stock > 0)
        LOOP
            DBMS_OUTPUT.PUT_LINE(ALBUM.name);
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
            DBMS_OUTPUT.PUT_LINE(SINGER.name);
        END LOOP;  
        DBMS_OUTPUT.PUT_LINE('����� ������ ������������. ������ ���.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_SINGERS');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_SINGERS;
    
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        ALBUM_id Number,
        QUANTITY Number
    ) IS
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '� ������� ��������� ������������� ' 
                || '���������� �������� c id ' 
                || ALBUM_id || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET quantity_in_stock = quantity_in_stock + QUANTITY
            WHERE id = ALBUM_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '� ������� ��������� ' || QUANTITY 
            || ' �������� c id ' || ALBUM_id || '.'
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
        ALBUM_id Number,
        QUANTITY Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr;
        FLAG_ONE_RECORD BOOLEAN := FALSE;
        MAX_QUANTITY Number;
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '�������� ������������� ���������� �������� c id ' 
                || ALBUM_id || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        SELECT record_array INTO RECORD_ARR 
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                FLAG_ONE_RECORD := TRUE;
            END IF;
        END LOOP;
        IF NOT FLAG_ONE_RECORD THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ������ c id ' 
                || ALBUM_id || ' ������. � ������� ��� ������.'
            );
            RETURN;
        END IF;
        SELECT quantity_in_stock INTO MAX_QUANTITY 
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        MAX_QUANTITY := LEAST(MAX_QUANTITY, QUANTITY);
        IF MAX_QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ������ c id ' 
                || ALBUM_id || ' ������. �������� ��� �� ������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET 
                quantity_in_stock = quantity_in_stock - MAX_QUANTITY,
                quantity_of_sold = quantity_of_sold + MAX_QUANTITY
            WHERE id = ALBUM_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '������� ' || MAX_QUANTITY 
            || ' �������� c id ' || ALBUM_id || '.'
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
        SELECT name BULK COLLECT INTO DEL_SINGERS_LIST FROM Grushevskaya_singer;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
           FOR i IN 1..RECORD.singer_list.COUNT
            LOOP
                FOR k IN 1..DEL_SINGERS_LIST.COUNT
                LOOP                   
                    IF NOT DEL_SINGERS_LIST(k) IS NULL
                       AND NOT RECORD.singer_list(i) IS NULL
                       AND DEL_SINGERS_LIST(k) = RECORD.singer_list(i) THEN
                        DEL_SINGERS_LIST(k) := NULL;
                    END IF;                
                END LOOP;
            END LOOP;
        END LOOP;
        FOR j IN 1..DEL_SINGERS_LIST.COUNT
        LOOP
            IF NOT DEL_SINGERS_LIST(j) IS NULL THEN
                DELETE FROM Grushevskaya_singer
                WHERE name = DEL_SINGERS_LIST(j);
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
        ALBUM_id Number
    ) IS
        ALBUM_name Varchar2(100 BYTE);
        RECORD_ARR Grushevskaya_record_arr;
        RECORD Grushevskaya_record%ROWTYPE;
        time INTERVAL DAY(0) TO SECOND(0) := NUMTODSINTERVAL(0, 'SECOND');
        SINGERS Varchar2(300) := '';
    BEGIN
        SELECT name INTO ALBUM_name
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        DBMS_OUTPUT.PUT_LINE('������ �' || ALBUM_id || ' � ������ ' || ALBUM_name);
        SELECT record_array INTO RECORD_ARR
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS NULL THEN
                SELECT * INTO RECORD FROM Grushevskaya_record 
                    WHERE id = RECORD_ARR(i);
                SINGERS := '-';
                FOR j IN 1..RECORD.singer_list.COUNT
                LOOP
                    SINGERS := SINGERS || ' ' || RECORD.singer_list(j);
                END LOOP;
                DBMS_OUTPUT.PUT_LINE(
                    '�' 
                    || LPAD(i, 2, '0')
                    || ' ' 
                    || RECORD.style
                    || ', ' 
                    || LPAD(EXTRACT(HOUR FROM RECORD.time), 2, '0') || ':' 
                    || LPAD(EXTRACT(MINUTE FROM RECORD.time), 2, '0') || ':' 
                    || LPAD(EXTRACT(SECOND FROM RECORD.time), 2, '0')
                    || ' ' 
                    || RECORD.name
                    || ' ' 
                    || SINGERS
                );
                time := RECORD.time + time;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(
            '����� ����� ��������: '
            || LPAD(EXTRACT(HOUR FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(MINUTE FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(SECOND FROM time), 2, '0')
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
        TOTAL_INCOME Number := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('������� ��������');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                '�������� id ' 
                || ALBUM.id 
                || ' � ������ ' 
                || ALBUM.name
                || ' ������� �� �����: '
                || ALBUM.price * ALBUM.quantity_of_sold
            );
            TOTAL_INCOME := TOTAL_INCOME + ALBUM.price * ALBUM.quantity_of_sold;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('������� �������� � �����: ' || TOTAL_INCOME || '.');       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_INCOME');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_INCOME;    
    
    PROCEDURE DELETE_RECORD_FROM_ALBUM(
        ALBUM_id Number,
        RECORD_Number Number
    ) IS
        TMP_RECORD_ARR Grushevskaya_record_arr;
        TMP_quantity_of_sold Number;
    BEGIN
        SELECT quantity_of_sold INTO TMP_quantity_of_sold
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        IF TMP_quantity_of_sold > 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '������� ���� �' 
                || RECORD_Number || ' ������, ��� ��� ������ ������'
            );
            RETURN;
        END IF;
        SELECT record_array INTO TMP_RECORD_ARR 
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        FOR i IN RECORD_Number..TMP_RECORD_ARR.COUNT-1
        LOOP
            TMP_RECORD_ARR(i) := TMP_RECORD_ARR(i+1);
        END LOOP;
        TMP_RECORD_ARR(TMP_RECORD_ARR.COUNT) := NULL;
        UPDATE Grushevskaya_album
            SET record_array = TMP_RECORD_ARR
            WHERE id = ALBUM_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('���� �' || RECORD_Number || ' ������');            
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        RECORD_id Number,
        SINGER_name Varchar2
    ) IS
        TMP_singer_list Grushevskaya_singer_tab;
        SINGER_Number Number := 0;
    BEGIN
        SELECT singer_list INTO TMP_singer_list 
            FROM Grushevskaya_record
            WHERE id = RECORD_id;
        FOR i IN 1..TMP_singer_list.COUNT
        LOOP
            IF TMP_singer_list(i) = SINGER_name THEN
                SINGER_Number := i;
            END IF;
        END LOOP;
        TMP_singer_list.DELETE(SINGER_Number);        
        UPDATE Grushevskaya_record
            SET singer_list = TMP_singer_list
            WHERE id = RECORD_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            '����������� ' || SINGER_name || ' ��� �' || SINGER_Number || ' ������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_update_singer_in_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        
    PROCEDURE PRINT_SINGER_style(
        SINGER_name Varchar2
    ) IS
        COUNT_SINGER_IN_TABLE Number := 0;
        TYPE SINGER_style IS TABLE OF Number INDEX BY Varchar2(100 BYTE);
        SINGER_style_LIST SINGER_style;
        CURRENT_ELEM Varchar2(100 BYTE);
        MAX_style Varchar2(100 BYTE);
    BEGIN
        SELECT COUNT(name) INTO COUNT_SINGER_IN_TABLE 
            FROM Grushevskaya_singer
            WHERE name = SINGER_name;
        IF COUNT_SINGER_IN_TABLE = 0 THEN
            DBMS_OUTPUT.PUT_LINE('����������� �� ������.');
            RETURN;
        END IF;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..RECORD.singer_list.COUNT
            LOOP
                IF RECORD.singer_list(i) = SINGER_name THEN
                    IF SINGER_style_LIST.EXISTS(RECORD.style) THEN
                        SINGER_style_LIST(RECORD.style) := 
                            SINGER_style_LIST(RECORD.style) 
                            + 1;
                    ELSE
                        SINGER_style_LIST(RECORD.style) := 1;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
        MAX_style := SINGER_style_LIST.FIRST;
        CURRENT_ELEM := SINGER_style_LIST.FIRST;
        WHILE NOT CURRENT_ELEM IS NULL
        LOOP  
            IF SINGER_style_LIST(CURRENT_ELEM) > SINGER_style_LIST(MAX_style) THEN
                MAX_style := CURRENT_ELEM;
            END IF;
            CURRENT_ELEM := SINGER_style_LIST.NEXT(CURRENT_ELEM);
        END LOOP;
        IF MAX_style IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('� ����������� ��� �������.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            '�������� ���������� ����� � ' 
            || SINGER_name || ' - '  || MAX_style || '.'
        );       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_SINGER_style');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_SINGER_style;
    
    PROCEDURE PRINT_country_style
    IS
        TYPE SINGER_style IS TABLE OF Number INDEX BY Varchar2(100 BYTE);
        TYPE COUNTRY_style IS TABLE OF SINGER_style INDEX BY Varchar2(100 BYTE);
        COUNTRY_style_LIST COUNTRY_style;
        TMP_COUNTRY Varchar2(100 BYTE);
        CURRENT_COUNTRY Varchar2(100 BYTE);
        CURRENT_style Varchar2(100 BYTE);
        MAX_style Varchar2(100 BYTE);
    BEGIN
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..RECORD.singer_list.COUNT
            LOOP
                SELECT country INTO TMP_country 
                    FROM Grushevskaya_singer 
                    WHERE name =  RECORD.singer_list(i);
                IF country_style_LIST.EXISTS(TMP_country)
                   AND country_style_LIST(TMP_country).EXISTS(RECORD.style) THEN
                    country_style_LIST(TMP_country)(RECORD.style) := 
                        country_style_LIST(TMP_country)(RECORD.style) 
                        + 1;
                ELSE
                    country_style_LIST(TMP_country)(RECORD.style) := 1;
                END IF; 
            END LOOP;
        END LOOP;
        CURRENT_country := country_style_LIST.FIRST;
        WHILE NOT CURRENT_country IS NULL
        LOOP
            MAX_style := country_style_LIST(CURRENT_country).FIRST;
            CURRENT_style := country_style_LIST(CURRENT_country).FIRST;
            WHILE NOT CURRENT_style IS NULL
            LOOP  
                IF country_style_LIST(CURRENT_country)(CURRENT_style) 
                   > country_style_LIST(CURRENT_country)(MAX_style) THEN
                    MAX_style := CURRENT_style;
                END IF;
                CURRENT_style := country_style_LIST(CURRENT_country).NEXT(CURRENT_style);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(
                '�������� ���������� ����� � '  
                || CURRENT_country || ' - ' || MAX_style || '.'
            );
            CURRENT_country := country_style_LIST.NEXT(CURRENT_country);
        END LOOP;       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN PRINT_country_style');
        PRINT_MSG_EX(SQLCODE);
    END PRINT_country_style; 
    
    PROCEDURE PRINT_ALBUM_AUTHOR
    IS
        TYPE ALL_ALBUM_id IS TABLE OF Varchar2(100 BYTE);
        ALBUM_id ALL_ALBUM_id;
        TYPE ALBUM_SINGER IS TABLE OF Number INDEX BY Varchar2(100 BYTE);
        ALBUM_singer_list ALBUM_SINGER;
        SINGERS Grushevskaya_singer_tab;
        RECORD_COUNT Number;
        CURRENT_SINGER Varchar(100 BYTE);
        FLAG_GROUP BOOLEAN;
    BEGIN   
        DBMS_OUTPUT.PUT_LINE('��������� ��������.');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
        LOOP
            RECORD_COUNT := 0;
            ALBUM_singer_list.DELETE;
            FOR i IN 1..ALBUM.record_array.COUNT
            LOOP
                IF NOT ALBUM.record_array(i) IS NULL THEN
                    RECORD_COUNT := RECORD_COUNT + 1;
                    SELECT singer_list INTO SINGERS
                        FROM Grushevskaya_record
                        WHERE id = ALBUM.record_array(i);
                    FOR j IN 1..SINGERS.COUNT
                    LOOP
                        IF ALBUM_singer_list.EXISTS(SINGERS(j))THEN
                            ALBUM_singer_list(SINGERS(j)) := 
                                ALBUM_singer_list(SINGERS(j)) 
                                + 1;
                        ELSE
                            ALBUM_singer_list(SINGERS(j)) := 1;
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;
            FLAG_GROUP := FALSE;
            CURRENT_SINGER := ALBUM_singer_list.FIRST;
            WHILE NOT CURRENT_SINGER IS NULL
            LOOP
                IF ALBUM_singer_list(CURRENT_SINGER) <> RECORD_COUNT THEN
                    FLAG_GROUP := TRUE;
                END IF;
                CURRENT_SINGER := ALBUM_singer_list.NEXT(CURRENT_SINGER);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(
                '��������� ������� ' || ALBUM.name || ' � id ' || ALBUM.id || 
                '.'
            );
            IF FLAG_GROUP THEN
                DBMS_OUTPUT.PUT_LINE('������������ �������.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('�����������:');
                CURRENT_SINGER := ALBUM_singer_list.FIRST;
                IF CURRENT_SINGER IS NULL THEN
                    DBMS_OUTPUT.PUT_LINE('������������ � ������� ���.');
                END IF;
                WHILE NOT CURRENT_SINGER IS NULL
                LOOP
                    DBMS_OUTPUT.PUT_LINE(CURRENT_SINGER);
                    CURRENT_SINGER := ALBUM_singer_list.NEXT(CURRENT_SINGER);
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

