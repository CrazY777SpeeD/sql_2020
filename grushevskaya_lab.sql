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
    START WITH 48
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- SEQUENCE ��� ��������� id ALBUM
-- ��-�� �������� ������ ���������� � 7

CREATE SEQUENCE Grushevskaya_num_album
    MINVALUE 1
    START WITH 7
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- country - ��������������� �������, ���������� ������� �����. 
-- ��������� ��������, ����� ���-�� ������ "��", � ���-�� "������".

CREATE TABLE Grushevskaya_dict_country(
    -- �������� ������
    name VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT null
);
/
INSERT INTO Grushevskaya_dict_country (name) VALUES ('��������������');
INSERT INTO Grushevskaya_dict_country (name) VALUES ('������');
INSERT INTO Grushevskaya_dict_country (name) VALUES ('����');
INSERT INTO Grushevskaya_dict_country (name) VALUES ('���');
INSERT INTO Grushevskaya_dict_country (name) VALUES ('������');
/
-- singer � ����������� (���, ��������� ��� �������� ������; ������)

CREATE TABLE Grushevskaya_singer(
    -- ���, ��������� ��� �������� ������
    name VARCHAR2(100 BYTE),
    -- ������
    country VARCHAR2(100 BYTE)
);
/
-- �������� ������
INSERT INTO Grushevskaya_singer (name,country) VALUES ('����� �������','���');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('��� ���������','��������������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('Backstreet Boys','���');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('ABBA','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('��������� ���������','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('��� �������','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('������� �������','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('����� ������','������');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('���� �������������','����');
INSERT INTO Grushevskaya_singer (name,country) VALUES ('������ ����','������');
/
-- ����������� �� SINGER
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT grushevskaya_singer_pk
    PRIMARY KEY(name) ENABLE;
ALTER TABLE Grushevskaya_singer 
    MODIFY (name NOT null ENABLE);

ALTER TABLE Grushevskaya_singer 
    MODIFY (country NOT null ENABLE);
    
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT grushevskaya_singer_fk
    FOREIGN KEY (country)
    REFERENCES Grushevskaya_dict_country (name) 
    ON DELETE SET null ENABLE;

-- style - ��������������� �������, ���������� ������� ������
-- ��������� ��������, ����� ���-�� ����� "����", � ���-�� "����".

CREATE TABLE Grushevskaya_dict_style(
    -- �������� �����
    name VARCHAR2(100 BYTE)
        PRIMARY KEY
        NOT null
);
/
-- �������� ������
INSERT INTO Grushevskaya_dict_style (name) VALUES ('�������');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('����');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('�����');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('���-������');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('���������');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-�-����');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-���');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('����');
INSERT INTO Grushevskaya_dict_style (name) VALUES ('����-���');

-- RECORD

/
-- ��������� ������� ������������
CREATE TYPE Grushevskaya_singer_tab AS TABLE OF VARCHAR2(100 BYTE);
/
-- record � ������ 
-- (�������������, ��������, ����� ��������, 
-- �����, ������ ������������)
CREATE TABLE Grushevskaya_record (
    -- �������������
    id NUMBER(10,0),
    -- ��������
    name VARCHAR2(100 BYTE),
    -- ����� ��������
    time INTERVAL DAY (0) TO SECOND (0),
    -- �����
    style VARCHAR2(100 BYTE),
    -- ������ ������������
    singer_list Grushevskaya_singer_tab
) NESTED TABLE Singer_list
    STORE AS Grushevskaya_singer_list;
/
-- �������� ������
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('1','Wanna Be Startin� Somethin�','+00 00:06:30.000000','���������', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('2','Baby Be Mine','+00 00:04:20.000000','���-������', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('3','The Girl Is Mine','+00 00:03:41.000000','����-���', Grushevskaya_singer_tab('����� �������', '��� ���������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('4','Thriller','+00 00:05:58.000000','����', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('5','Beat It','+00 00:04:18.000000','����-���', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('6','Billie Jean','+00 00:04:50.000000','����', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('7','Human Nature','+00 00:04:06.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('8','Pretty Young Thing','+00 00:03:58.000000','����', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('9','The Lady in My Life','+00 00:05:00.000000','����-�-����', Grushevskaya_singer_tab('����� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('10','Larger than life','+00 00:03:52.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('11','I want it that way','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('12','Show me the meaning of being lonely','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('13','It�s gotta be you','+00 00:02:56.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('14','I need you tonight','+00 00:04:23.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('15','Don�t want you back','+00 00:03:25.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('16','Don�t wanna lose you now','+00 00:03:54.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('17','The one','+00 00:03:46.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('18','Back to your heart','+00 00:04:21.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('19','Spanish eyes','+00 00:03:53.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('20','No one else comes close','+00 00:03:42.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('21','The perfect fan','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('Backstreet Boys'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('22','Dancing Queen','+00 00:03:51.000000','�����', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('23','Knowing Me, Knowing You','+00 00:04:03.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('24','Take a Chance on Me','+00 00:04:06.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('25','Mamma Mia','+00 00:03:33.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('26','Lay All Your Love on Me','+00 00:04:35.000000','�����', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('27','Super Trouper','+00 00:04:13.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('28','I Have a Dream','+00 00:04:42.000000','�������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('29','The Winner Takes It All','+00 00:04:54.000000','�������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('30','Money, Money, Money','+00 00:03:05.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('31','SOS','+00 00:03:23.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('32','Chiquitita','+00 00:05:26.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('33','Fernando','+00 00:04:14.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('34','Voulez-Vous','+00 00:05:09.000000','�����', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('35','Gimme! Gimme! Gimme!','+00 00:04:46.000000','�����', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('36','Does Your Mother Know','+00 00:03:15.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('37','One of Us','+00 00:03:56.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('38','The Name of the Game','+00 00:04:51.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('39','Thank You for the Music','+00 00:03:51.000000','�������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('40','Waterloo','+00 00:02:42.000000','���-������', Grushevskaya_singer_tab('ABBA'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('41','����� ��� ������','+00 00:02:52.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('42','������ �������','+00 00:02:16.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('43','����������� �����','+00 00:03:32.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('44','����� ���������','+00 00:02:34.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('45','������ ������','+00 00:04:54.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('46','�����','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������'));
INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('47','����� ������� � ���������','+00 00:03:49.000000','���-������', Grushevskaya_singer_tab('��������� ���������', '��� �������', '����� ������', '���� �������������', '������ ����'));
/
-- ����������� �� RECORD
ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT grushevskaya_record_pk 
    PRIMARY KEY(id) ENABLE;
ALTER TABLE Grushevskaya_record 
    MODIFY (id NOT null ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (name NOT null ENABLE);

ALTER TABLE Grushevskaya_record 
    MODIFY (time NOT null ENABLE);
    
ALTER TABLE Grushevskaya_record 
    MODIFY (style NOT null ENABLE);

ALTER TABLE Grushevskaya_record 
    ADD CONSTRAINT grushevskaya_record_fk
    FOREIGN KEY (style)
    REFERENCES Grushevskaya_dict_style (name) 
    ON DELETE SET null ENABLE;
    
-- ALBUM

-- ��������� ������ �������
CREATE TYPE Grushevskaya_record_arr AS Varray(30) OF NUMBER(10,0);
/
-- ALBUM � ������ (�������������, ��������, ���������, 
-- ���������� �� ������, ���������� ��������� �����������,
-- ������ �������)
CREATE TABLE Grushevskaya_album (
    -- �������������    
    id NUMBER(10, 0),
    -- ��������
    name VARCHAR2(100 BYTE),
    -- ���������
    price NUMBER(6,2),
    -- ���������� �� ������
    quantity_in_stock NUMBER(5, 0),
    -- ���������� ��������� �����������
    quantity_of_sold NUMBER(5, 0),
    -- ������ (������) �������
    record_array Grushevskaya_record_arr
);
/
-- �������� ������
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('1','Thriller','792,5','188','37', Grushevskaya_record_arr(1, 2, 3, 4, 5, 6, 7, 8, 9, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('2','Millennium','836,24','33','42', Grushevskaya_record_arr(11, 13, 14, 15, 16, 17, 18, 19, 20, 21, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('3','ABBA Gold: Greatest Hits','921,34','199','142', Grushevskaya_record_arr(22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, null, null, null, null, null, null, null, null, null, null, null));
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('4','��������� ��������� � ��� �������','127,99','44','7', Grushevskaya_record_arr(41, 42, 43, 44, 45, 46, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('5','������','87,99','10','0', Grushevskaya_record_arr(3, 4, 8, 12, 16, 17, 23, 29, 32, 38, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('6','������ ������','0','0','0', Grushevskaya_record_arr(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
/
-- ����������� �� ALBUM
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_pk
    PRIMARY KEY(id) ENABLE;
ALTER TABLE Grushevskaya_album 
    MODIFY (id NOT null ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (name NOT null ENABLE);

ALTER TABLE Grushevskaya_album 
    MODIFY (price NOT null ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk1 
    CHECK (price >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (quantity_in_stock NOT null ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk2 
    CHECK (quantity_in_stock >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (quantity_of_sold NOT null ENABLE);
ALTER TABLE Grushevskaya_album 
    ADD CONSTRAINT grushevskaya_album_chk3 
    CHECK (quantity_of_sold >= 0) ENABLE;

ALTER TABLE Grushevskaya_album 
    MODIFY (record_array NOT null ENABLE);
/

-- ����� �������-��-������ SINGER-RECORD

-- �������� ������������ �����������.
-- �������� �������� �����.
-- ���� ������������ ������������ �� ������������� ������� ������������,
-- �� �������� ������� ��� "��������" ����������
CREATE OR REPLACE 
TRIGGER Grushevskaya_tr_on_records
BEFORE INSERT OR UPDATE ON Grushevskaya_record
FOR EACH ROW
DECLARE
    list_name Grushevskaya_singer_tab;
    flag_record_uses BOOLEAN := false;
BEGIN
    -- �������� �� null ���� singer_list
    IF :NEW.singer_list IS null THEN
       dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_records');
       dbms_output.put_line('singer_list �� ������ ���� ������ (null).'); 
       RAISE grushevskaya_exceptions.Error_record;
    END IF;
    -- �������� ������ �� ��.���.
    FOR i IN 1..:NEW.singer_list.COUNT
    LOOP
        IF :NEW.singer_list(i) IS null THEN 
            :NEW.singer_list.DELETE(i);
        END IF;
    END LOOP;
    :NEW.singer_list := SET(:NEW.singer_list);
    -- ������ ������������ �� ������ ���� ����
    IF :NEW.singer_list IS empty THEN
        IF INSERTING THEN
           dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_records');
           dbms_output.put_line('singer_list �� ������ ���� ������ (empty).'); 
           RAISE grushevskaya_exceptions.Error_record;
        END IF;
        IF UPDATING THEN
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            dbms_output.put_line('WARNING IN Grushevskaya_tr_on_records');
            dbms_output.put_line(
                '������ � ��������������� ' 
                || :OLD.id 
                || ' �� ���� ���������.'
            );
            dbms_output.put_line(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ����������� ���� �� ���� ������ ����.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- ������ ��� ���������� � ����� �� �������� => ��������� ���. ������    
    IF UPDATING THEN
        FOR album_row IN (SELECT * FROM Grushevskaya_album)
        LOOP
            FOR i IN 1..album_row.record_array.COUNT
            LOOP
                IF album_row.record_array(i) = :OLD.id THEN
                    flag_record_uses := true;
                END IF;
            END LOOP;
        END LOOP;
        IF flag_record_uses
           AND NOT (SET(:NEW.singer_list) = SET(:OLD.singer_list)) THEN
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            dbms_output.put_line('WARNING IN Grushevskaya_tr_on_records');
            dbms_output.put_line(
                '������ � ��������������� ' 
                || :OLD.id 
                || ' �� ���� ���������.'
            );
            dbms_output.put_line(
                '������ ������������ ��������� ������,' 
                || ' ��� ��� ������ ��� ���������� � ����� �� ��������.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- �������� ����.��.
    -- ���� ������������ ������������ �� ������������� ������� ������������,
    -- �� �������� ������� ��� "��������" ����������
    SELECT name BULK COLLECT INTO list_name FROM Grushevskaya_singer;
    IF :NEW.singer_list NOT SUBMULTISET OF list_name THEN
        IF INSERTING THEN            
            dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_records');
            dbms_output.put_line('������������ ������ ������������.');
            RAISE grushevskaya_exceptions.Error_record;
        ELSE
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            dbms_output.put_line('WARNING IN Grushevskaya_tr_on_records');
            dbms_output.put_line(
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
TRIGGER Grushevskaya_tr_on_singers_del
BEFORE DELETE ON Grushevskaya_singer
FOR EACH ROW
BEGIN
    FOR record_row IN (SELECT * FROM Grushevskaya_record)
    LOOP
        FOR i IN 1..record_row.singer_list.COUNT
        LOOP
            IF record_row.singer_list(i) = :OLD.name THEN                
                dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_singers_del');
                dbms_output.put_line(
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
TRIGGER Grushevskaya_tr_on_singers_upd
FOR UPDATE OF name ON Grushevskaya_singer
COMPOUND TRIGGER
    TYPE Changes_arr IS TABLE OF VARCHAR2(100 BYTE) INDEX BY PLS_INTEGER;
    singers_changes Changes_arr;
AFTER EACH ROW IS
    BEGIN
        singers_changes(:OLD.name) := :NEW.name;
    END AFTER EACH ROW;
AFTER STATEMENT IS
        list_name Grushevskaya_singer_tab;
        flag BOOLEAN := false;
    BEGIN
        FOR record_row IN (SELECT * FROM Grushevskaya_record)
        LOOP
            flag := false;
            list_name := record_row.singer_list;
            FOR i IN 1..list_name.COUNT 
            LOOP
                IF singers_changes.EXISTS(list_name(i)) THEN
                    list_name(i) := singers_changes(list_name(i));
                    flag := true;
                END IF;
            END LOOP;
            IF flag = true THEN
                UPDATE Grushevskaya_record
                    SET singer_list = SET(list_name)
                    WHERE id = record_row.id;
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
TRIGGER Grushevskaya_tr_on_album
BEFORE INSERT OR UPDATE ON Grushevskaya_album
FOR EACH ROW
DECLARE
    TYPE Unique_records IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    list_unique_records Unique_records;
    unique_records_varray Grushevskaya_record_arr := Grushevskaya_record_arr();
    current_unique_record VARCHAR2(100 BYTE);
    TYPE Grushevskaya_record_tab IS TABLE OF NUMBER(10, 0);
    list_id Grushevskaya_record_tab;    
BEGIN
    IF UPDATING('record_array') THEN
        -- �������� ���������� �� Varray
        FOR k IN 1..:NEW.record_array.COUNT
        LOOP
            IF NOT :NEW.record_array(k) IS null THEN
                IF NOT list_unique_records.EXISTS(:NEW.record_array(k)) THEN
                    list_unique_records(:NEW.record_array(k)) := k;
                END IF;                
            END IF;
        END LOOP;
        unique_records_varray.EXTEND(30);
        current_unique_record := list_unique_records.FIRST;
        WHILE NOT current_unique_record IS null
        LOOP
            unique_records_varray(list_unique_records(current_unique_record)) := current_unique_record;
            current_unique_record := list_unique_records.NEXT(current_unique_record);
        END LOOP;
        :NEW.record_array := unique_records_varray;
        -- ���� ������ ������, �� ��������� ����� ������.    
        IF :OLD.quantity_of_sold > 0 THEN
            FOR j IN 1..:OLD.record_array.COUNT
            LOOP
                IF :NEW.record_array(j) IS null AND :OLD.record_array(j) IS null THEN
                    CONTINUE;
                END IF;
                IF :NEW.record_array(j) IS null OR :OLD.record_array(j) IS null THEN
                    :NEW.id := :OLD.id;
                    :NEW.name := :OLD.name;
                    :NEW.price := :OLD.price;
                    :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                    :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                    :NEW.record_array := :OLD.record_array;                               
                    dbms_output.put_line('WARNING IN Grushevskaya_tr_on_album');
                    dbms_output.put_line(
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
                    dbms_output.put_line('WARNING IN Grushevskaya_tr_on_album');
                    dbms_output.put_line(
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
    SELECT id BULK COLLECT INTO list_id FROM Grushevskaya_record;
    FOR i IN 1..:NEW.record_array.COUNT
    LOOP
       IF NOT :NEW.record_array(i) IS null
          AND NOT :NEW.record_array(i) MEMBER list_id THEN
            IF INSERTING THEN                               
                dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_album');
                dbms_output.put_line('������������ ������ �������.');
                RAISE grushevskaya_exceptions.Error_album;
            ELSE
                :NEW.id := :OLD.id;
                :NEW.name := :OLD.name;
                :NEW.price := :OLD.price;
                :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                :NEW.record_array := :OLD.record_array;                          
                dbms_output.put_line('WARNING IN Grushevskaya_tr_on_album');
                dbms_output.put_line(
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
TRIGGER Grushevskaya_tr_on_record_del
BEFORE DELETE ON Grushevskaya_record
FOR EACH ROW
BEGIN
    FOR album_row IN (SELECT * FROM Grushevskaya_album)
    LOOP
        FOR i IN 1..album_row.record_array.COUNT
        LOOP
            IF album_row.record_array(i) = :OLD.id THEN                               
                dbms_output.put_line('EXCEPTION IN Grushevskaya_tr_on_record_del');
                dbms_output.put_line(
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
TRIGGER Grushevskaya_tr_on_record_udp
FOR UPDATE OF id ON Grushevskaya_record
COMPOUND TRIGGER
    TYPE Changes_arr IS TABLE OF NUMBER(10,0) INDEX BY PLS_INTEGER;
    record_changes Changes_arr;
    AFTER EACH ROW IS
    BEGIN
        record_changes(:OLD.id) := :NEW.id;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        id_arr Grushevskaya_record_arr;
        flag BOOLEAN := false;
    BEGIN
        FOR album_row IN (SELECT * FROM Grushevskaya_album)
        LOOP
            flag := false;
            id_arr := album_row.record_array;
            FOR i IN 1..id_arr.COUNT 
            LOOP
                IF record_changes.EXISTS(id_arr(i)) THEN
                    id_arr(i) := record_changes(id_arr(i));
                    flag := true;
                END IF;
            END LOOP;
            IF flag = true THEN
                UPDATE Grushevskaya_album
                    SET record_array = id_arr
                    WHERE id = album_row.id;
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- ����� grushevskaya_package � ������������� ������������

CREATE OR REPLACE 
PACKAGE grushevskaya_package AS
    -- �������� ������ � �������.
    PROCEDURE add_in_dict_country (
        -- �������� ������
        name VARCHAR2
    );
    -- �������� ����� � �������.
    PROCEDURE add_in_dict_style (
        -- �������� �����
        name VARCHAR2
    );
    
    -- ����������� ����������
    
    -- 1) �������� ������ (���������� ����������� ���� �����������).
    PROCEDURE add_record (
        -- ��������
        name VARCHAR2, 
        -- ���������� ����� ��������
        hours NUMBER,
        -- ���������� ����� ��������
        minutes NUMBER,
        -- ���������� ������ ��������
        seconds NUMBER,
        -- ����� �� �������
        style VARCHAR2,
        -- ��� �����������
        singer VARCHAR2
    );
    -- 2) �������� ����������� ��� ������ 
    -- (���� ��������� ������ �� ��������� �� � ���� ������ 
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE add_singer_in_record (
        -- id ������
        record_id NUMBER,
        -- ��� �����������
        singer_name VARCHAR2
    );
    -- 3) �������� �����������.
    PROCEDURE add_singer (
        -- ��� (���)
        name VARCHAR2, 
        -- ������ �� �������
        country VARCHAR2
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� � ����� �������.
    PROCEDURE add_album (
        -- ��������
        name VARCHAR2,
        -- ���� (>= 0)
        price NUMBER,
        -- ���������� �� ������ (>= 0)
        quantity_in_stock NUMBER,
        -- id ����������� ������
        record_id NUMBER
    );
    -- 4) �������� ������ (���������� ����������� ���� ���� ��� �� ������).
    -- ���������� ��� ���������� ������� ��� �������.
    PROCEDURE add_album (
        -- ��������
        name VARCHAR2,
        -- ���� (>= 0)
        price NUMBER,
        -- ���������� �� ������ (>= 0)
        quantity_in_stock NUMBER
    );
    -- 5) �������� ���� � ������ 
    -- (���� �� ������� �� ������ ����������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE add_record_in_album (
        -- id �������
        album_id NUMBER,
        -- id ����������� ������ 
        record_id NUMBER
    );
    -- 6) ������ �������� � ������� (���������� �� ������ ������ 0).
    PROCEDURE print_albums_in_stock;
    -- 7) ������ ������������.
    PROCEDURE print_singers;
    -- 8) �������� �������
    -- (���������� �� ������ ������������� �� ��������� ��������).
    PROCEDURE add_albums_in_stock (
        -- id �������
        album_id NUMBER,
        -- ����������
        quantity NUMBER
    );
    -- 9) ������� ������ 
    -- (���������� �� ������ �����������, ��������� � �������������; 
    -- ������� ����� ������ �������, � ������� ���� ���� �� ���� ����
    --  - ������� ����������� � ����� �������). 
    PROCEDURE sell_albums (
        -- id �������
        album_id NUMBER,
        -- ����������
        quantity NUMBER
    );
    -- 10) ������� ������������, � ������� ��� �� ����� ������.
    PROCEDURE delete_singers_without_records;
    
    -- �������� ����������
    
    -- 11) ����-���� ���������� ������� 
    -- � ��������� ���������� ������� �������� �������.
    PROCEDURE print_album_records(album_id NUMBER);
    -- 12) ������� �������� 
    -- (��������� ��������� ��������� �������� 
    -- �� ������� � ����������� 
    -- � �� �������� � �����).
    PROCEDURE print_income;
    -- 13) ������� ���� � ��������� ������� �� ������� 
    -- � ���������� ��������� ������� 
    -- (���� �� ������� �� ������ ���������� �������
    --  - ������� ����������� �� ������ ��������).
    PROCEDURE delete_record_from_album (
        -- id �������
        album_id NUMBER,
        -- ����� �������� ������ � �������
        record_number NUMBER
    );
    -- 14) ������� ����������� �� ������ 
    -- (���� ������ �� ������ �� � ���� ������ 
    -- � ���� ���� ����������� �� ������������
    --  - ������� ����������� �� ������ ��������). 
    PROCEDURE delete_singer_from_record (
        -- id ������
        record_id NUMBER,
        -- ��� �����������        
        singer_name VARCHAR2
    );
    -- 15) ���������� �������������� ����������� ����� ���������� ����������� 
    -- (�����, � ������� �������� ����������� ��� ������). 
    PROCEDURE print_singer_style (
        -- ��� �����������
        singer_name VARCHAR2
    );
    -- 16) ���������� �������������� ����������� ����� 
    -- �� ������ ������ ������������� ������������.
    PROCEDURE print_country_style; 
    -- 17) ���������� ��������� �������� 
    -- (��� ������� ������� ��������� 
    -- ����������� ��� ������ ������������,
    -- ���� ��� ����� ����� ������� �������� 
    -- ����� ���������� ������������; 
    -- � ��������� ������ ��������� ������������� �������).
    PROCEDURE print_album_author;
END;
/
CREATE OR REPLACE
PACKAGE BODY grushevskaya_package AS
    PROCEDURE print_msg_ex(sqlcode NUMBER) IS
    BEGIN
        dbms_output.put_line('��. ����������� ����������.');
        dbms_output.put_line('���: ' || sqlcode);
        dbms_output.put_line('���������: ' || SQLERRM(sqlcode));        
    END print_msg_ex;
    
    PROCEDURE add_in_dict_country (
        name VARCHAR2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_country (name) VALUES (name);
        COMMIT;
        dbms_output.put_line('������ ' || name || ' ������� ���������.');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_in_dict_country');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_in_dict_country;
    
    PROCEDURE add_in_dict_style (
        name VARCHAR2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_style (name) VALUES (name);
        COMMIT;        
        dbms_output.put_line('����� ' || name || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_in_dict_style');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_in_dict_style;
    
    PROCEDURE add_record(
        name VARCHAR2,
        hours NUMBER,
        minutes NUMBER,
        seconds NUMBER,
        style VARCHAR2,
        singer VARCHAR2
    ) IS
        time INTERVAL DAY(0) TO SECOND(0);
    BEGIN
        time := NUMTODSINTERVAL(hours, 'HOUR') 
            + NUMTODSINTERVAL(minutes, 'MINUTE') 
            + NUMTODSINTERVAL(seconds, 'SECOND');
        INSERT INTO Grushevskaya_record (id, name, time, style, singer_list)
            VALUES (
            Grushevskaya_num_record.NEXTVAL, 
            name, 
            time, 
            style, 
            Grushevskaya_singer_tab(singer)
        );
        COMMIT;        
        dbms_output.put_line(
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
        dbms_output.put_line('EXCEPTION IN add_record');
        IF sqlcode = -02291 THEN
            dbms_output.put_line('��� ����� ' || style || ' � �������.');
        ELSIF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSIF sqlcode = -1873 THEN
            dbms_output.put_line('�������� �������� �������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_record; 
    
    PROCEDURE add_singer_in_record (
        record_id NUMBER,
        singer_name VARCHAR2
    ) IS
        tmp_singer_list Grushevskaya_singer_tab;
    BEGIN
        IF singer_name IS null THEN
            dbms_output.put_line('������ ��������� null-��������.');
            RETURN;
        END IF;
        SELECT singer_list INTO tmp_singer_list 
            FROM Grushevskaya_record
            WHERE id = record_id;
        tmp_singer_list.EXTEND;
        tmp_singer_list(tmp_singer_list.LAST) := singer_name;
        UPDATE Grushevskaya_record
            SET singer_list = tmp_singer_list
            WHERE id = record_id;
        COMMIT;        
        dbms_output.put_line(
            '����������� ' || singer_name 
            || ' ������� �������� � ������ � id ' || record_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_singer_in_record');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('������� � �������������� ������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_singer_in_record;
    
    PROCEDURE add_singer (
        name VARCHAR2,
        country VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Grushevskaya_singer (name, country)
            VALUES (name, country);
        COMMIT;      
        dbms_output.put_line('����������� ' || name || ' ������� ��������.');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_singer');
        IF sqlcode = -02291 THEN
            dbms_output.put_line('��� ������ ' || country || ' � �������.');
        ELSIF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_singer;
        
    PROCEDURE add_album (
        name VARCHAR2,
        price NUMBER,
        quantity_in_stock NUMBER,
        record_id NUMBER
    ) IS
        record_arr Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        record_arr.EXTEND(30);
        record_arr(1) := record_id;
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
            record_arr
        );
        COMMIT;      
        dbms_output.put_line(
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
        dbms_output.put_line('EXCEPTION IN add_album');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -6532 THEN
            dbms_output.put_line('������ ��������� �������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('������� �������������� ������ � ������.');
        ELSIF sqlcode = -2290 THEN
            dbms_output.put_line('�������� ���� �� �������.');
            dbms_output.put_line('�������� ���� �� ����� ���� �������������.');
            dbms_output.put_line('�������� ���������� �������� � ������� � ��������� �� ����� ���� ��������������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_album;
        
    PROCEDURE add_album (
        name VARCHAR2,
        price NUMBER,
        quantity_in_stock NUMBER
    ) IS
        record_arr Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        record_arr.EXTEND(30);
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
            record_arr
        );
        COMMIT;      
        dbms_output.put_line(
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
        dbms_output.put_line('EXCEPTION IN add_album');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -6532 THEN
            dbms_output.put_line('������ ��������� �������.');
        ELSIF sqlcode = -1 THEN
            dbms_output.put_line('�������� ����������� ������������ ������ �� �����.');
        ELSIF sqlcode = -1400 THEN
            dbms_output.put_line('���������� �������� null ��� ������ �� ��������.');
        ELSIF sqlcode = -2290 THEN
            dbms_output.put_line('�������� ���� �� �������.');
            dbms_output.put_line('�������� ���� �� ����� ���� �������������.');
            dbms_output.put_line('�������� ���������� �������� � ������� � ��������� �� ����� ���� ��������������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_album;
    
    PROCEDURE add_record_in_album (
        album_id NUMBER, 
        record_id NUMBER
    )IS
        record_serial_number NUMBER := -1;
        tmp_record_arr Grushevskaya_record_arr;
    BEGIN        
        IF record_id IS null THEN
            dbms_output.put_line('������ ��������� null-��������.');
            RETURN;
        END IF;
        SELECT record_array INTO tmp_record_arr
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN REVERSE 1..tmp_record_arr.COUNT
        LOOP
            IF tmp_record_arr(i) IS null THEN
                record_serial_number := i;
            END IF;
        END LOOP;
        IF record_serial_number = -1 THEN
            dbms_output.put_line(
                '������ � id ' 
                || album_id 
                || ' �� ����� ��������� ������ 30 �������. ������ � id ' 
                || record_id 
                || ' �� ���������.'
            );
        END IF;
        tmp_record_arr(record_serial_number) := record_id;
        UPDATE Grushevskaya_album
            SET record_array = tmp_record_arr
            WHERE id = album_id;            
        COMMIT;      
        dbms_output.put_line(
            '������ � id ' || record_id 
            || ' ������� ��������� � ������ � id ' || album_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_record_in_album');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = -6532 THEN
            dbms_output.put_line('������ ��������� �������.');
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('������� � �������������� ������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END add_record_in_album;
    
    PROCEDURE print_albums_in_stock 
    IS
        quantity NUMBER := 0;
    BEGIN
        dbms_output.put_line('������� � �������:');
        FOR album IN (SELECT * FROM Grushevskaya_album WHERE quantity_in_stock > 0)
        LOOP
            dbms_output.put_line(album.name);
            quantity := quantity + 1;
        END LOOP;
        dbms_output.put_line('����� �������� � �������: ' || quantity || '.');    
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_albums_in_stock');
        print_msg_ex(sqlcode);
    END print_albums_in_stock;
    
    PROCEDURE print_singers
    IS
    BEGIN
        dbms_output.put_line('��� �����������:');
        FOR singer IN (SELECT * FROM Grushevskaya_singer)
        LOOP
            dbms_output.put_line(singer.name);
        END LOOP;  
        dbms_output.put_line('����� ������ ������������. ������ ���.');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_singers');
        print_msg_ex(sqlcode);
    END print_singers;
    
    PROCEDURE add_albums_in_stock (
        album_id NUMBER,
        quantity NUMBER
    ) IS
    BEGIN
        IF quantity <= 0 THEN
            dbms_output.put_line(
                '� ������� ��������� ������������� ' 
                || '���������� �������� c id ' 
                || album_id || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET quantity_in_stock = quantity_in_stock + quantity
            WHERE id = album_id;
        COMMIT;
        dbms_output.put_line(
            '� ������� ��������� ' || quantity 
            || ' �������� c id ' || album_id || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN add_albums_in_stock');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('�������� ��������������� �������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;        
    END add_albums_in_stock;    
    
    PROCEDURE sell_albums(
        album_id NUMBER,
        quantity NUMBER
    ) IS
        record_arr Grushevskaya_record_arr;
        flag_one_record BOOLEAN := false;
        max_quantity NUMBER;
    BEGIN
        IF quantity <= 0 THEN
            dbms_output.put_line(
                '�������� ������������� ���������� �������� c id ' 
                || album_id || '. ���������� �� ���������.'
            );
            RETURN;
        END IF;
        SELECT record_array INTO record_arr 
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN 1..record_arr.COUNT
        LOOP
            IF NOT record_arr(i) IS null THEN
                flag_one_record := true;
            END IF;
        END LOOP;
        IF NOT flag_one_record THEN
            dbms_output.put_line(
                '������� ������ c id ' 
                || album_id || ' ������. � ������� ��� ������.'
            );
            RETURN;
        END IF;
        SELECT quantity_in_stock INTO max_quantity 
            FROM Grushevskaya_album
            WHERE id = album_id;
        max_quantity := LEAST(max_quantity, quantity);
        IF max_quantity <= 0 THEN
            dbms_output.put_line(
                '������� ������ c id ' 
                || album_id || ' ������. �������� ��� �� ������.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET 
                quantity_in_stock = quantity_in_stock - max_quantity,
                quantity_of_sold = quantity_of_sold + max_quantity
            WHERE id = album_id;
        COMMIT;
        dbms_output.put_line(
            '������� ' || max_quantity 
            || ' �������� c id ' || album_id || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN sell_albums');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('������� ��������������� �������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;       
    END sell_albums;
    
    PROCEDURE delete_singers_without_records
    IS
        del_singers_list Grushevskaya_singer_tab;
    BEGIN
        SELECT name BULK COLLECT INTO del_singers_list FROM Grushevskaya_singer;
        FOR record IN (SELECT * FROM Grushevskaya_record)
        LOOP
           FOR i IN 1..record.singer_list.COUNT
            LOOP
                FOR k IN 1..del_singers_list.COUNT
                LOOP                   
                    IF NOT del_singers_list(k) IS null
                       AND NOT record.singer_list(i) IS null
                       AND del_singers_list(k) = record.singer_list(i) THEN
                        del_singers_list(k) := null;
                    END IF;                
                END LOOP;
            END LOOP;
        END LOOP;
        FOR j IN 1..del_singers_list.COUNT
        LOOP
            IF NOT del_singers_list(j) IS null THEN
                DELETE FROM Grushevskaya_singer
                WHERE name = del_singers_list(j);
                dbms_output.put_line(
                    '������ ����������� ' 
                    || del_singers_list(j) || '.'
                );
            END IF;
        END LOOP;
        COMMIT;
        dbms_output.put_line('����������� ��� ������� ������� �������.');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN delete_singers_without_records');
        print_msg_ex(sqlcode);
    END delete_singers_without_records;    
    
    PROCEDURE print_album_records(
        album_id NUMBER
    ) IS
        album_name VARCHAR2(100 BYTE);
        record_arr Grushevskaya_record_arr;
        record Grushevskaya_record%ROWTYPE;
        time INTERVAL DAY(0) TO SECOND(0) := NUMTODSINTERVAL(0, 'SECOND');
        singers VARCHAR2(300) := '';
    BEGIN
        SELECT name INTO album_name
            FROM Grushevskaya_album
            WHERE id = album_id;
        dbms_output.put_line('������ �' || album_id || ' � ������ ' || album_name);
        SELECT record_array INTO record_arr
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN 1..record_arr.COUNT
        LOOP
            IF NOT record_arr(i) IS null THEN
                SELECT * INTO record FROM Grushevskaya_record 
                    WHERE id = record_arr(i);
                singers := '-';
                FOR j IN 1..record.singer_list.COUNT
                LOOP
                    singers := singers || ' ' || record.singer_list(j);
                END LOOP;
                dbms_output.put_line(
                    '�' 
                    || LPAD(i, 2, '0')
                    || ' ' 
                    || record.style
                    || ', ' 
                    || LPAD(EXTRACT(hour FROM record.time), 2, '0') || ':' 
                    || LPAD(EXTRACT(minute FROM record.time), 2, '0') || ':' 
                    || LPAD(EXTRACT(second FROM record.time), 2, '0')
                    || ' ' 
                    || record.name
                    || ' ' 
                    || singers
                );
                time := record.time + time;
            END IF;
        END LOOP;
        dbms_output.put_line(
            '����� ����� ��������: '
            || LPAD(EXTRACT(hour FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(minute FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(second FROM time), 2, '0')
            || '.'
        );        
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_album_records');
        IF sqlcode = 100 THEN
            dbms_output.put_line('������ ��������������� �������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END print_album_records;
    
    PROCEDURE print_income
    IS
        total_income NUMBER := 0;
    BEGIN
        dbms_output.put_line('������� ��������');
        FOR album IN (SELECT * FROM Grushevskaya_album)
        LOOP
            dbms_output.put_line(
                '�������� id ' 
                || album.id 
                || ' � ������ ' 
                || album.name
                || ' ������� �� �����: '
                || album.price * album.quantity_of_sold
            );
            total_income := total_income + album.price * album.quantity_of_sold;
        END LOOP;
        dbms_output.put_line('������� �������� � �����: ' || total_income || '.');       
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_income');
        print_msg_ex(sqlcode);
    END print_income;    
    
    PROCEDURE delete_record_from_album (
        album_id NUMBER,
        record_number NUMBER
    ) IS
        tmp_record_arr Grushevskaya_record_arr;
        tmp_quantity_of_sold NUMBER;
    BEGIN
        SELECT quantity_of_sold INTO tmp_quantity_of_sold
            FROM Grushevskaya_album
            WHERE id = album_id;
        IF tmp_quantity_of_sold > 0 THEN
            dbms_output.put_line(
                '������� ���� �' 
                || record_number 
                || ' ������, ��� ��� ������ ������'
            );
            RETURN;
        END IF;
        SELECT record_array INTO tmp_record_arr 
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN record_number..tmp_record_arr.COUNT - 1
        LOOP
            tmp_record_arr(i) := tmp_record_arr(i + 1);
        END LOOP;
        tmp_record_arr(tmp_record_arr.COUNT) := null;
        UPDATE Grushevskaya_album
            SET record_array = tmp_record_arr
            WHERE id = album_id;
        COMMIT;
        dbms_output.put_line('���� �' || record_number || ' ������');            
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN delete_record_from_album');
        IF sqlcode = -6532 THEN
            dbms_output.put_line('������ ��������� �������.');        
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('�������� ��������������� �������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;    
    END delete_record_from_album;    
    
    PROCEDURE delete_singer_from_record (
        record_id NUMBER,
        singer_name VARCHAR2
    ) IS
        tmp_singer_list Grushevskaya_singer_tab;
        singer_number NUMBER := 0;
    BEGIN
        SELECT singer_list INTO tmp_singer_list 
            FROM Grushevskaya_record
            WHERE id = record_id;
        FOR i IN 1..tmp_singer_list.COUNT
        LOOP
            IF tmp_singer_list(i) = singer_name THEN
                singer_number := i;
            END IF;
        END LOOP;
        tmp_singer_list.DELETE(singer_number);        
        UPDATE Grushevskaya_record
            SET singer_list = tmp_singer_list
            WHERE id = record_id;
        COMMIT;
        dbms_output.put_line(
            '����������� ' || singer_name || ' ��� �' || singer_number || ' ������.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_update_singer_in_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN delete_singer_from_record');
        IF sqlcode = -12899 THEN
            dbms_output.put_line('�������� ��� ������ �� �������� ������� ������.');       
        ELSIF sqlcode = 100 THEN
            dbms_output.put_line('�������� �� ��������������� ����������� ����������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;        
    END delete_singer_from_record;
        
    PROCEDURE print_singer_style (
        singer_name VARCHAR2
    ) IS
        count_singer_in_table NUMBER := 0;
        TYPE Singer_style IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        singer_style_list Singer_style;
        current_elem VARCHAR2(100 BYTE);
        max_style VARCHAR2(100 BYTE);
    BEGIN
        SELECT COUNT(name) INTO count_singer_in_table 
            FROM Grushevskaya_singer
            WHERE name = singer_name;
        IF count_singer_in_table = 0 THEN
            dbms_output.put_line('����������� �� ������.');
            RETURN;
        END IF;
        FOR record IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..record.singer_list.COUNT
            LOOP
                IF record.singer_list(i) = singer_name THEN
                    IF singer_style_list.EXISTS(record.style) THEN
                        singer_style_list(record.style) := 
                            singer_style_list(record.style) 
                            + 1;
                    ELSE
                        singer_style_list(record.style) := 1;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
        max_style := singer_style_list.FIRST;
        current_elem := singer_style_list.FIRST;
        WHILE NOT current_elem IS null
        LOOP  
            IF singer_style_list(current_elem) > singer_style_list(max_style) THEN
                max_style := current_elem;
            END IF;
            current_elem := singer_style_list.NEXT(current_elem);
        END LOOP;
        IF max_style IS null THEN
            dbms_output.put_line('� ����������� ��� �������.');
            RETURN;
        END IF;
        dbms_output.put_line(
            '�������� ���������� ����� � ' 
            || singer_name || ' - '  || max_style || '.'
        );       
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_singer_style');
        print_msg_ex(sqlcode);
    END print_singer_style;
    
    PROCEDURE print_country_style
    IS
        TYPE Singer_style IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        TYPE Country_style IS TABLE OF Singer_style INDEX BY VARCHAR2(100 BYTE);
        country_style_list Country_style;
        tmp_country VARCHAR2(100 BYTE);
        current_country VARCHAR2(100 BYTE);
        current_style VARCHAR2(100 BYTE);
        max_style VARCHAR2(100 BYTE);
    BEGIN
        FOR record IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..record.singer_list.COUNT
            LOOP
                SELECT country INTO tmp_country 
                    FROM Grushevskaya_singer 
                    WHERE name =  record.singer_list(i);
                IF country_style_list.EXISTS(tmp_country)
                   AND country_style_list(tmp_country).EXISTS(record.style) THEN
                    country_style_list(tmp_country)(record.style) := 
                        country_style_list(tmp_country)(record.style) 
                        + 1;
                ELSE
                    country_style_list(tmp_country)(record.style) := 1;
                END IF; 
            END LOOP;
        END LOOP;
        current_country := country_style_list.FIRST;
        WHILE NOT current_country IS null
        LOOP
            max_style := country_style_list(current_country).FIRST;
            current_style := country_style_list(current_country).FIRST;
            WHILE NOT current_style IS null
            LOOP  
                IF country_style_list(current_country)(current_style) 
                   > country_style_list(current_country)(max_style) THEN
                    max_style := current_style;
                END IF;
                current_style := country_style_list(current_country).NEXT(current_style);
            END LOOP;
            dbms_output.put_line(
                '�������� ���������� ����� � '  
                || current_country || ' - ' || max_style || '.'
            );
            current_country := country_style_list.NEXT(current_country);
        END LOOP;       
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_country_style');
        print_msg_ex(sqlcode);
    END print_country_style; 
    
    PROCEDURE print_album_author
    IS
        TYPE All_album_id IS TABLE OF VARCHAR2(100 BYTE);
        album_id All_album_id;
        TYPE Album_singer IS TABLE OF NUMBER INDEX BY VARCHAR2(100 BYTE);
        album_singer_list Album_singer;
        singers Grushevskaya_singer_tab;
        record_count NUMBER;
        current_singer VARCHAR2(100 BYTE);
        flag_group BOOLEAN;
    BEGIN   
        dbms_output.put_line('��������� ��������.');
        FOR album IN (SELECT * FROM Grushevskaya_album)
        LOOP
            record_count := 0;
            album_singer_list.DELETE;
            FOR i IN 1..album.record_array.COUNT
            LOOP
                IF NOT album.record_array(i) IS null THEN
                    record_count := record_count + 1;
                    SELECT singer_list INTO singers
                        FROM Grushevskaya_record
                        WHERE id = album.record_array(i);
                    FOR j IN 1..singers.COUNT
                    LOOP
                        IF album_singer_list.EXISTS(singers(j))THEN
                            album_singer_list(singers(j)) := 
                                album_singer_list(singers(j)) 
                                + 1;
                        ELSE
                            album_singer_list(singers(j)) := 1;
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;
            flag_group := false;
            current_singer := album_singer_list.FIRST;
            WHILE NOT current_singer IS null
            LOOP
                IF album_singer_list(current_singer) <> record_count THEN
                    flag_group := true;
                END IF;
                current_singer := album_singer_list.NEXT(current_singer);
            END LOOP;
            dbms_output.put_line(
                '��������� ������� ' || album.name 
                || ' � id ' || album.id || '.'
            );
            IF flag_group THEN
                dbms_output.put_line('������������ �������.');
            ELSE
                dbms_output.put_line('�����������:');
                current_singer := album_singer_list.FIRST;
                IF current_singer IS null THEN
                    dbms_output.put_line('������������ � ������� ���.');
                END IF;
                WHILE NOT current_singer IS null
                LOOP
                    dbms_output.put_line(current_singer);
                    current_singer := album_singer_list.NEXT(current_singer);
                END LOOP;
            END IF; 
        END LOOP;        
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('EXCEPTION IN print_album_author');
        IF sqlcode = 100 THEN
            dbms_output.put_line('������ ��������� ��������������� ������� ����������.');
        ELSE
            print_msg_ex(sqlcode);
        END IF;
    END print_album_author;
END;

