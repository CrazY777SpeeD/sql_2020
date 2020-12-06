-- Удаление предыдущей версии объектов БД

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

--Пакет с исключениями

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

-- SEQUENCE для генерации id RECORD
-- из-за тестовых данных начинается с 48

CREATE SEQUENCE Grushevskaya_num_record
    MINVALUE 1
    START WITH 1 --48
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- SEQUENCE для генерации id ALBUM
-- из-за тестовых данных начинается с 7

CREATE SEQUENCE Grushevskaya_num_album
    MINVALUE 1
    START WITH 1 --7
    INCREMENT BY 1
    NOCACHE NOCYCLE;
/

-- country - вспомогательная таблица, содержащая словарь стран. 
-- Исключает ситуацию, когда где-то страна "РФ", а где-то "Россия".

CREATE TABLE Grushevskaya_dict_country(
    -- название страны
    name Varchar2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('Великобритания');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('Россия');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('СССР');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('США');
--INSERT INTO Grushevskaya_dict_country (name) VALUES ('Швеция');
/
-- singer – исполнитель (имя, псевдоним или название группы; страна)

CREATE TABLE Grushevskaya_singer(
    -- имя, псевдоним или название группы
    name Varchar2(100 BYTE),
    -- страна
    country Varchar2(100 BYTE)
);
--/
---- Тестовые данные
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Майкл Джексон','США');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Пол Маккартни','Великобритания');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Backstreet Boys','США');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('ABBA','Швеция');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Валентина Толкунова','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Лев Лещенко','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Иванов Иван','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Сидоров Алексей','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Петров Петр','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Иосиф Кобзон','Россия');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Майя Кристалинская','СССР');
--INSERT INTO Grushevskaya_singer (name,country) VALUES ('Эдуард Хиль','Россия');
/
-- Ограничения на SINGER
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

-- style - вспомогательная таблица, содержащая словарь стилей
-- Исключает ситуацию, когда где-то стиль "Джаз", а где-то "джаз".

CREATE TABLE Grushevskaya_dict_style(
    -- название стиля
    name Varchar2(100 BYTE)
        PRIMARY KEY
        NOT NULL
);
--/
---- Тестовые данные
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Баллада');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Джаз');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Диско');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Поп-музыка');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Постдиско');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Ритм-н-блюз');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Софт-рок');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Фанк');
--INSERT INTO Grushevskaya_dict_style (name) VALUES ('Хард-рок');

-- RECORD

/
-- Вложенная таблица исполнителей
CREATE TYPE Grushevskaya_singer_tab AS TABLE OF Varchar2(100 BYTE);
/
-- record – запись 
-- (идентификатор, название, время звучания, 
-- стиль, список исполнителей)
CREATE TABLE Grushevskaya_record (
    -- идентификатор
    id Number(10,0),
    -- название
    name Varchar2(100 BYTE),
    -- время звучания
    time INTERVAL DAY (0) TO SECOND (0),
    -- стиль
    style Varchar2(100 BYTE),
    -- список исполнителей
    singer_list Grushevskaya_singer_tab
) NESTED TABLE Singer_list
    STORE AS Grushevskaya_singer_list;
--/
---- Тестовые данные
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('1','Wanna Be Startin’ Somethin’','+00 00:06:30.000000','Постдиско', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('2','Baby Be Mine','+00 00:04:20.000000','Поп-музыка', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('3','The Girl Is Mine','+00 00:03:41.000000','Софт-рок', Grushevskaya_singer_tab('Майкл Джексон', 'Пол Маккартни'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('4','Thriller','+00 00:05:58.000000','Фанк', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('5','Beat It','+00 00:04:18.000000','Хард-рок', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('6','Billie Jean','+00 00:04:50.000000','Фанк', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('7','Human Nature','+00 00:04:06.000000','Ритм-н-блюз', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('8','Pretty Young Thing','+00 00:03:58.000000','Джаз', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('9','The Lady in My Life','+00 00:05:00.000000','Ритм-н-блюз', Grushevskaya_singer_tab('Майкл Джексон'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('10','Larger than life','+00 00:03:52.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('11','I want it that way','+00 00:03:33.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('12','Show me the meaning of being lonely','+00 00:03:54.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('13','It’s gotta be you','+00 00:02:56.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('14','I need you tonight','+00 00:04:23.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('15','Don’t want you back','+00 00:03:25.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('16','Don’t wanna lose you now','+00 00:03:54.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('17','The one','+00 00:03:46.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('18','Back to your heart','+00 00:04:21.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('19','Spanish eyes','+00 00:03:53.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('20','No one else comes close','+00 00:03:42.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('21','The perfect fan','+00 00:04:13.000000','Поп-музыка', Grushevskaya_singer_tab('Backstreet Boys'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('22','Dancing Queen','+00 00:03:51.000000','Диско', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('23','Knowing Me, Knowing You','+00 00:04:03.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('24','Take a Chance on Me','+00 00:04:06.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('25','Mamma Mia','+00 00:03:33.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('26','Lay All Your Love on Me','+00 00:04:35.000000','Диско', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('27','Super Trouper','+00 00:04:13.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('28','I Have a Dream','+00 00:04:42.000000','Баллада', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('29','The Winner Takes It All','+00 00:04:54.000000','Баллада', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('30','Money, Money, Money','+00 00:03:05.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('31','SOS','+00 00:03:23.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('32','Chiquitita','+00 00:05:26.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('33','Fernando','+00 00:04:14.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('34','Voulez-Vous','+00 00:05:09.000000','Диско', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('35','Gimme! Gimme! Gimme!','+00 00:04:46.000000','Диско', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('36','Does Your Mother Know','+00 00:03:15.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('37','One of Us','+00 00:03:56.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('38','The Name of the Game','+00 00:04:51.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('39','Thank You for the Music','+00 00:03:51.000000','Баллада', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('40','Waterloo','+00 00:02:42.000000','Поп-музыка', Grushevskaya_singer_tab('ABBA'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('41','Старт даёт Москва','+00 00:02:52.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('42','Добрые приметы','+00 00:02:16.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('43','Олимпийский Мишка','+00 00:03:32.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('44','Вальс влюблённых','+00 00:02:34.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('45','Ночной звонок','+00 00:04:54.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('46','Осень','+00 00:03:49.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко'));
--INSERT INTO Grushevskaya_record (id,name,time,style,singer_list) VALUES ('47','Песня остаётся с человеком','+00 00:03:49.000000','Поп-музыка', Grushevskaya_singer_tab('Валентина Толкунова', 'Лев Лещенко', 'Иосиф Кобзон', 'Майя Кристалинская', 'Эдуард Хиль'));
/
-- Ограничения на RECORD
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

-- Вложенный массив записей
CREATE TYPE Grushevskaya_record_arr AS Varray(30) OF Number(10,0);
/
-- ALBUM – альбом (идентификатор, название, стоимость, 
-- количество на складе, количество проданных экземпляров,
-- список записей)
CREATE TABLE Grushevskaya_album (
    -- идентификатор    
    id Number(10, 0),
    -- название
    name Varchar2(100 BYTE),
    -- стоимость
    price Number(6,2),
    -- количество на складе
    quantity_in_stock Number(5, 0),
    -- количество проданных экземпляров
    quantity_of_sold Number(5, 0),
    -- список (массив) записей
    record_array Grushevskaya_record_arr
);
--/
---- Тестовые данные
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('1','Thriller','792,5','188','37', Grushevskaya_record_arr(1, 2, 3, 4, 5, 6, 7, 8, 9, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('2','Millennium','836,24','33','42', Grushevskaya_record_arr(11, 13, 14, 15, 16, 17, 18, 19, 20, 21, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('3','ABBA Gold: Greatest Hits','921,34','199','142', Grushevskaya_record_arr(22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('4','Валентина Толкунова и Лев Лещенко','127,99','44','7', Grushevskaya_record_arr(41, 42, 43, 44, 45, 46, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('5','Разное','87,99','10','0', Grushevskaya_record_arr(3, 4, 8, 12, 16, 17, 23, 29, 32, 38, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
--INSERT INTO Grushevskaya_album (id,name,price,quantity_in_stock,quantity_of_sold,record_array) VALUES ('6','Пустой альбом','0','0','0', Grushevskaya_record_arr(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
/
-- Ограничения на ALBUM
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

-- Связь «многие-ко-многим» SINGER-RECORD

-- Проверка естественных ограничений.
-- Имитация внешнего ключа.
-- Если подмножество исполнителей не соответствует таблице исполнителей,
-- то отменить вставку или "откатить" обновление
CREATE OR REPLACE 
TRIGGER GRUSHEVSKAYA_TR_ON_RECORDS
BEFORE INSERT OR UPDATE ON Grushevskaya_record
FOR EACH ROW
DECLARE
    LIST_NAME Grushevskaya_singer_tab;
    FLAG_RECORD_USES BOOLEAN := FALSE;
BEGIN
    -- Проверка на NULL поля singer_list
    IF :NEW.singer_list IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
       DBMS_OUTPUT.PUT_LINE('singer_list не должен быть пустым (NULL).'); 
       RAISE grushevskaya_exceptions.Error_record;
    END IF;
    -- Удаление пустот во вл.таб.
    FOR i IN 1..:NEW.singer_list.COUNT
    LOOP
        IF :NEW.singer_list(i) IS NULL THEN 
            :NEW.singer_list.DELETE(i);
        END IF;
    END LOOP;
    :NEW.singer_list := SET(:NEW.singer_list);
    -- Список исполнителей не должен быть пуст
    IF :NEW.singer_list IS EMPTY THEN
        IF INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
           DBMS_OUTPUT.PUT_LINE('singer_list не должен быть пустым (EMPTY).'); 
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
                'Запись с идентификатором ' 
                || :OLD.id 
                || ' не была обновлена.'
            );
            DBMS_OUTPUT.PUT_LINE(
                'Список исполнителей обновлять нельзя,' 
                || ' так как исполнитель хотя бы один должен быть.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- Запись уже содержится в одном из альбомов => обновлять исп. нельзя    
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
                'Запись с идентификатором ' 
                || :OLD.id 
                || ' не была обновлена.'
            );
            DBMS_OUTPUT.PUT_LINE(
                'Список исполнителей обновлять нельзя,' 
                || ' так как запись уже содержится в одном из альбомов.'
            );
            RAISE grushevskaya_exceptions.Warning_update;
        END IF;
    END IF;
    -- Проверка внеш.кл.
    -- Если подмножество исполнителей не соответствует таблице исполнителей,
    -- то отменить вставку или "откатить" обновление
    SELECT name BULK COLLECT INTO LIST_NAME FROM Grushevskaya_singer;
    IF :NEW.singer_list NOT SUBMULTISET OF LIST_NAME THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE('Некорректный список исполнителей.');
            RAISE grushevskaya_exceptions.Error_record;
        ELSE
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN GRUSHEVSKAYA_TR_ON_RECORDS');
            DBMS_OUTPUT.PUT_LINE(
                'Запись с идентификатором ' 
                || :OLD.id 
                || ' не была обновлена из-за нарушения внешнего ключа (исполнители).'
            );
            RAISE grushevskaya_exceptions.Warning_update;
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
                    'Исполнителя с идентификатором ' 
                    || :OLD.name 
                    || ' удалять нельзя - у него есть треки.'
                );
                RAISE grushevskaya_exceptions.Error_singer_del;
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

-- Связь «многие-ко-многим» RECORD-ALBUM

-- Проверка естественных ограничений.
-- Имитация внеш. кл.
-- Перед вставкой или обновлением альбома
-- проверить, что все записи существуют.
-- Если нет, то либо отменить втавку, 
-- либо "откатить" обновление.
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
        -- Удаление дубликатов из Varray
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
        -- Если альбом продан, то добавлять треки нельзя.    
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
                        'Альбом с идентификатором ' 
                        || :OLD.id 
                        || ' не был обновлен. Нельзя добавлять треки, если альбом продан.'
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
                        'Альбом с идентификатором ' 
                        || :OLD.id 
                        || ' не был обновлен. Нельзя добавлять треки, если альбом продан.'
                    );
                    RAISE grushevskaya_exceptions.Warning_update;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- Проверка внеш.кл.
    -- Перед вставкой или обновлением альбома
    -- проверить, что все записи существуют.
    -- Если нет, то либо отменить втавку, 
    -- либо "откатить" обновление.
    SELECT id BULK COLLECT INTO LIST_id FROM Grushevskaya_record;
    FOR i IN 1..:NEW.record_array.COUNT
    LOOP
       IF NOT :NEW.record_array(i) IS NULL
          AND NOT :NEW.record_array(i) MEMBER LIST_id THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN GRUSHEVSKAYA_TR_ON_ALBUM');
                DBMS_OUTPUT.PUT_LINE('Некорректный список записей.');
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
                    'Альбом с идентификатором ' 
                    || :OLD.id 
                    || ' не был обновлен из-за нарушения внешнего ключа (записи).'
                );
                RAISE grushevskaya_exceptions.Warning_update;
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
                    'Запиь с идентификатором ' 
                    || :OLD.id 
                    || ' удалять нельзя - она есть в альбоме.'
                );
                RAISE grushevskaya_exceptions.Error_record_del;
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

-- Пакет grushevskaya_package с реализованным функционалом

CREATE OR REPLACE 
PACKAGE grushevskaya_package AS
    -- Добавить страну в словарь.
    PROCEDURE ADD_IN_DICT_country (
        -- Название страны
        name Varchar2
    );
    -- Добавить стиль в словарь.
    PROCEDURE ADD_IN_DICT_style (
        -- Название стиля
        name Varchar2
    );
    
    -- Минимальный функционал
    
    -- 1) Добавить запись (изначально указывается один исполнитель).
    PROCEDURE ADD_RECORD (
        -- Название
        name Varchar2, 
        -- Количество часов звучания
        HOURS Number,
        -- Количество минут звучания
        MINUTES Number,
        -- Количество секунд звучания
        SECONDS Number,
        -- Стиль из словаря
        style Varchar2,
        -- Имя исполнителя
        SINGER Varchar2
    );
    -- 2) Добавить исполнителя для записи 
    -- (если указанная запись не добавлена ни в один альбом 
    --  - Условие проверяется на уровне триггера).
    PROCEDURE ADD_SINGER_IN_RECORD (
        -- id записи
        RECORD_id Number,
        -- Имя исполнителя
        SINGER_NAME Varchar2
    );
    -- 3) Добавить исполнителя.
    PROCEDURE ADD_SINGER (
        -- Имя (ФИО)
        name Varchar2, 
        -- Страна из словаря
        country Varchar2
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома с одной записью.
    PROCEDURE ADD_ALBUM (
        -- Название
        name Varchar2,
        -- Цена (>= 0)
        price Number,
        -- Количество на складе (>= 0)
        quantity_in_stock Number,
        -- id добавляемой записи
        RECORD_id Number
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома без записей.
    PROCEDURE ADD_ALBUM (
        -- Название
        name Varchar2,
        -- Цена (>= 0)
        price Number,
        -- Количество на складе (>= 0)
        quantity_in_stock Number
    );
    -- 5) Добавить трек в альбом 
    -- (если не продано ни одного экземпляра
    --  - Условие проверяется на уровне триггера).
    PROCEDURE ADD_RECORD_IN_ALBUM (
        -- id альбома
        ALBUM_id Number,
        -- id добавляемой записи 
        RECORD_id Number
    );
    -- 6) Список альбомов в продаже (количество на складе больше 0).
    PROCEDURE PRINT_ALBUMS_IN_STOCK;
    -- 7) Список исполнителей.
    PROCEDURE PRINT_SINGERS;
    -- 8) Поставка альбома
    -- (количество на складе увеличивается на указанное значение).
    PROCEDURE ADD_ALBUMS_IN_STOCK (
        -- id альбома
        ALBUM_id Number,
        -- Количество
        QUANTITY Number
    );
    -- 9) Продать альбом 
    -- (количество на складе уменьшается, проданных – увеличивается; 
    -- продать можно только альбомы, в которых есть хотя бы один трек
    --  - Условие проверяется в самой функции). 
    PROCEDURE SELL_ALBUMS(
        -- id альбома
        ALBUM_id Number,
        -- Количество
        QUANTITY Number
    );
    -- 10) Удалить исполнителей, у которых нет ни одной записи.
    PROCEDURE DELETE_SINGERS_WITHOUT_RECORDS;
    
    -- Основной функционал
    
    -- 11) Трек-лист указанного альбома 
    -- с указанием суммарного времени звучания альбома.
    PROCEDURE PRINT_ALBUM_RECORDS(ALBUM_id Number);
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
        -- id альбома
        ALBUM_id Number,
        -- Номер звучания записи в альбоме
        RECORD_Number Number
    );
    -- 14) Удалить исполнителя из записи 
    -- (если запись не входит ни в один альбом 
    -- и если этот исполнитель не единственный
    --  - Условия проверяются на уровне триггера). 
    PROCEDURE DELETE_SINGER_FROM_RECORD(
        -- id записи
        RECORD_id Number,
        -- Имя исполнителя        
        SINGER_name Varchar2
    );
    -- 15) Определить предпочитаемый музыкальный стиль указанного исполнителя 
    -- (стиль, в котором записано большинство его треков). 
    PROCEDURE PRINT_SINGER_style(
        -- Имя исполнителя
        SINGER_name Varchar2
    );
    -- 16) Определить предпочитаемый музыкальный стиль 
    -- по каждой стране происхождения исполнителей.
    PROCEDURE PRINT_country_style; 
    -- 17) Определить авторство альбомов 
    -- (для каждого альбома выводится 
    -- исполнитель или список исполнителей,
    -- если все треки этого альбома записаны 
    -- одним множеством исполнителей; 
    -- в противном случае выводится «Коллективный сборник»).
    PROCEDURE PRINT_ALBUM_AUTHOR;
END;
/
CREATE OR REPLACE
PACKAGE BODY grushevskaya_package AS
    PROCEDURE PRINT_MSG_EX(SQLCODE Number) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Ой. Неизвестное исключение.');
        DBMS_OUTPUT.PUT_LINE('Код: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Сообщение: ' || SQLERRM(SQLCODE));        
    END PRINT_MSG_EX;
    
    PROCEDURE ADD_IN_DICT_country (
        name Varchar2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_country (name) VALUES (name);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Страна ' || name || ' успешно добавлена.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_country');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
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
        DBMS_OUTPUT.PUT_LINE('Стиль ' || name || ' успешно добавлен.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_IN_DICT_style');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить NULL для одного из столбцов.');
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
            'Запись ' || name 
            || ' с id ' || Grushevskaya_num_record.CURRVAL 
            || ' успешно добавлена.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_RECORD');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет стиля ' || style || ' в словаре.');
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
        RECORD_id Number,
        SINGER_name Varchar2
    ) IS
        TMP_singer_list Grushevskaya_singer_tab;
    BEGIN
        IF SINGER_name IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять NULL-значения.');
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
            'Исполнитель ' || SINGER_name 
            || ' успешно добавлен в запись с id ' || RECORD_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        name Varchar2,
        country Varchar2
    ) IS
    BEGIN
        INSERT INTO Grushevskaya_singer (name, country)
            VALUES (name, country);
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE('Исполнитель ' || name || ' успешно добавлен.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN ADD_SINGER');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет страны ' || country || ' в словаре.');
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
            'Альбом ' || name 
            || ' с id ' || Grushevskaya_num_album.CURRVAL 
            || ' успешно добавлен.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
            'Альбом ' || name 
            || ' с id ' || Grushevskaya_num_album.CURRVAL 
            || ' успешно добавлен.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        ALBUM_id Number, 
        RECORD_id Number
    )IS
        RECORD_SERIAL_Number Number := -1;
        TMP_RECORD_ARR Grushevskaya_record_arr;
    BEGIN        
        IF RECORD_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять NULL-значения.');
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
                'Альбом с id ' 
                || ALBUM_id 
                || ' не может содержать больше 30 записей. Запись с id ' 
                || RECORD_id 
                || ' не добавлена.'
            );
        END IF;
        TMP_RECORD_ARR(RECORD_SERIAL_Number) := RECORD_id;
        UPDATE Grushevskaya_album
            SET record_array = TMP_RECORD_ARR
            WHERE id = ALBUM_id;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            'Запись с id ' || RECORD_id 
            || ' успешно добавлена в альбом с id ' || ALBUM_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
        QUANTITY Number := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Альбомы в продаже:');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album WHERE quantity_in_stock > 0)
        LOOP
            DBMS_OUTPUT.PUT_LINE(ALBUM.name);
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
        FOR SINGER IN (SELECT * FROM Grushevskaya_singer)
        LOOP
            DBMS_OUTPUT.PUT_LINE(SINGER.name);
        END LOOP;  
        DBMS_OUTPUT.PUT_LINE('Конец списка исполнителей. Больше нет.');
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
                'В продажу поступило отрицательное ' 
                || 'количество альбомов c id ' 
                || ALBUM_id || '. Количество не обновлено.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET quantity_in_stock = quantity_in_stock + QUANTITY
            WHERE id = ALBUM_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            'В продажу поступило ' || QUANTITY 
            || ' альбомов c id ' || ALBUM_id || '.'
        );
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
        ALBUM_id Number,
        QUANTITY Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr;
        FLAG_ONE_RECORD BOOLEAN := FALSE;
        MAX_QUANTITY Number;
    BEGIN
        IF QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Подается отрицательное количество альбомов c id ' 
                || ALBUM_id || '. Количество не обновлено.'
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
                'Продать альбом c id ' 
                || ALBUM_id || ' нельзя. В альбоме нет треков.'
            );
            RETURN;
        END IF;
        SELECT quantity_in_stock INTO MAX_QUANTITY 
            FROM Grushevskaya_album
            WHERE id = ALBUM_id;
        MAX_QUANTITY := LEAST(MAX_QUANTITY, QUANTITY);
        IF MAX_QUANTITY <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Продать альбом c id ' 
                || ALBUM_id || ' нельзя. Альбомов нет на складе.'
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
            'Продано ' || MAX_QUANTITY 
            || ' альбомов c id ' || ALBUM_id || '.'
        );
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
                    'Удален исполнитель ' 
                    || DEL_SINGERS_LIST(j) || '.'
                );
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
        DBMS_OUTPUT.PUT_LINE('Альбом №' || ALBUM_id || ' с именем ' || ALBUM_name);
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
                    '№' 
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
            'Общее время звучания: '
            || LPAD(EXTRACT(HOUR FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(MINUTE FROM time), 2, '0') || ':' 
            || LPAD(EXTRACT(SECOND FROM time), 2, '0')
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
        TOTAL_INCOME Number := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Выручка магазина');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Альбомов id ' 
                || ALBUM.id 
                || ' с именем ' 
                || ALBUM.name
                || ' продано на сумму: '
                || ALBUM.price * ALBUM.quantity_of_sold
            );
            TOTAL_INCOME := TOTAL_INCOME + ALBUM.price * ALBUM.quantity_of_sold;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Выручка магазина в целом: ' || TOTAL_INCOME || '.');       
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
                'Удалить трек №' 
                || RECORD_Number || ' нельзя, так как альбом продан'
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
        DBMS_OUTPUT.PUT_LINE('Трек №' || RECORD_Number || ' удален');            
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
            'Исполнитель ' || SINGER_name || ' под №' || SINGER_Number || ' удален.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_update_singer_in_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
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
            DBMS_OUTPUT.PUT_LINE('Исполнитель не найден.');
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
            DBMS_OUTPUT.PUT_LINE('У исполнителя нет записей.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            'Наиболее популярный стиль у ' 
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
                'Наиболее популярный стиль в '  
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
        DBMS_OUTPUT.PUT_LINE('Авторство альбомов.');
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
                'Авторство альбома ' || ALBUM.name || ' с id ' || ALBUM.id || 
                '.'
            );
            IF FLAG_GROUP THEN
                DBMS_OUTPUT.PUT_LINE('Коллективный сборник.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Исполнители:');
                CURRENT_SINGER := ALBUM_singer_list.FIRST;
                IF CURRENT_SINGER IS NULL THEN
                    DBMS_OUTPUT.PUT_LINE('Исполнителей в альбоме нет.');
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
            DBMS_OUTPUT.PUT_LINE('Печать авторства несуществующего альбома невозможна.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END PRINT_ALBUM_AUTHOR;
END;

