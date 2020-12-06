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
        NOT null
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
    MODIFY (name NOT null ENABLE);

ALTER TABLE Grushevskaya_singer 
    MODIFY (country NOT null ENABLE);
    
ALTER TABLE Grushevskaya_singer 
    ADD CONSTRAINT grushevskaya_singer_fk
    FOREIGN KEY (country)
    REFERENCES Grushevskaya_dict_country (name) 
    ON DELETE SET null ENABLE;

-- style - вспомогательная таблица, содержащая словарь стилей
-- Исключает ситуацию, когда где-то стиль "Джаз", а где-то "джаз".

CREATE TABLE Grushevskaya_dict_style(
    -- название стиля
    name Varchar2(100 BYTE)
        PRIMARY KEY
        NOT null
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

-- Связь «многие-ко-многим» SINGER-RECORD

-- Проверка естественных ограничений.
-- Имитация внешнего ключа.
-- Если подмножество исполнителей не соответствует таблице исполнителей,
-- то отменить вставку или "откатить" обновление
CREATE OR REPLACE 
TRIGGER Grushevskaya_tr_on_records
BEFORE INSERT OR UPDATE ON Grushevskaya_record
FOR EACH ROW
DECLARE
    list_name Grushevskaya_singer_tab;
    flag_record_uses Boolean := false;
BEGIN
    -- Проверка на null поля singer_list
    IF :NEW.singer_list IS null THEN
       DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_records');
       DBMS_OUTPUT.PUT_LINE('singer_list не должен быть пустым (null).'); 
       RAISE grushevskaya_exceptions.Error_record;
    END IF;
    -- Удаление пустот во вл.таб.
    FOR i IN 1..:NEW.singer_list.COUNT
    LOOP
        IF :NEW.singer_list(i) IS null THEN 
            :NEW.singer_list.DELETE(i);
        END IF;
    END LOOP;
    :NEW.singer_list := SET(:NEW.singer_list);
    -- Список исполнителей не должен быть пуст
    IF :NEW.singer_list IS empty THEN
        IF INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_records');
           DBMS_OUTPUT.PUT_LINE('singer_list не должен быть пустым (empty).'); 
           RAISE grushevskaya_exceptions.Error_record;
        END IF;
        IF UPDATING THEN
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_records');
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
            DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_records');
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
    SELECT name BULK COLLECT INTO list_name FROM Grushevskaya_singer;
    IF :NEW.singer_list NOT SUBMULTISET OF list_name THEN
        IF INSERTING THEN            
            DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_records');
            DBMS_OUTPUT.PUT_LINE('Некорректный список исполнителей.');
            RAISE grushevskaya_exceptions.Error_record;
        ELSE
            :NEW.id := :OLD.id;
            :NEW.name := :OLD.name;
            :NEW.time := :OLD.time;
            :NEW.style := :OLD.style;
            :NEW.singer_list := :OLD.singer_list;
            DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_records');
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
TRIGGER Grushevskaya_tr_on_singers_del
BEFORE DELETE ON Grushevskaya_singer
FOR EACH ROW
BEGIN
    FOR record_row IN (SELECT * FROM Grushevskaya_record)
    LOOP
        FOR i IN 1..record_row.singer_list.COUNT
        LOOP
            IF record_row.singer_list(i) = :OLD.name THEN                
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_singers_del');
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
TRIGGER Grushevskaya_tr_on_singers_upd
FOR UPDATE OF name ON Grushevskaya_singer
COMPOUND TRIGGER
    TYPE Changes_arr IS TABLE OF Varchar2(100 BYTE) INDEX BY Pls_integer;
    singers_changes Changes_arr;
AFTER EACH ROW IS
    BEGIN
        singers_changes(:OLD.name) := :NEW.name;
    END AFTER EACH ROW;
AFTER STATEMENT IS
        list_name Grushevskaya_singer_tab;
        flag Boolean := false;
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

-- Связь «многие-ко-многим» RECORD-ALBUM

-- Проверка естественных ограничений.
-- Имитация внеш. кл.
-- Перед вставкой или обновлением альбома
-- проверить, что все записи существуют.
-- Если нет, то либо отменить втавку, 
-- либо "откатить" обновление.
CREATE OR REPLACE 
TRIGGER Grushevskaya_tr_on_album
BEFORE INSERT OR UPDATE ON Grushevskaya_album
FOR EACH ROW
DECLARE
    TYPE Unique_records IS TABLE OF Number INDEX BY Varchar(100);
    list_unique_records Unique_records;
    unique_records_varray Grushevskaya_record_arr := Grushevskaya_record_arr();
    current_unique_record Varchar2(100 BYTE);
    TYPE Grushevskaya_record_tab IS TABLE OF Number(10, 0);
    list_id Grushevskaya_record_tab;    
BEGIN
    IF UPDATING('record_array') THEN
        -- Удаление дубликатов из Varray
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
        -- Если альбом продан, то добавлять треки нельзя.    
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
                    DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_album');
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
                    DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_album');
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
    SELECT id BULK COLLECT INTO list_id FROM Grushevskaya_record;
    FOR i IN 1..:NEW.record_array.COUNT
    LOOP
       IF NOT :NEW.record_array(i) IS null
          AND NOT :NEW.record_array(i) MEMBER list_id THEN
            IF INSERTING THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_album');
                DBMS_OUTPUT.PUT_LINE('Некорректный список записей.');
                RAISE grushevskaya_exceptions.Error_album;
            ELSE
                :NEW.id := :OLD.id;
                :NEW.name := :OLD.name;
                :NEW.price := :OLD.price;
                :NEW.quantity_in_stock := :OLD.quantity_in_stock;
                :NEW.quantity_of_sold := :OLD.quantity_of_sold;
                :NEW.record_array := :OLD.record_array;                          
                DBMS_OUTPUT.PUT_LINE('WARNING IN Grushevskaya_tr_on_album');
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
TRIGGER Grushevskaya_tr_on_record_del
BEFORE DELETE ON Grushevskaya_record
FOR EACH ROW
BEGIN
    FOR album_row IN (SELECT * FROM Grushevskaya_album)
    LOOP
        FOR i IN 1..album_row.record_array.COUNT
        LOOP
            IF album_row.record_array(i) = :OLD.id THEN                               
                DBMS_OUTPUT.PUT_LINE('EXCEPTION IN Grushevskaya_tr_on_record_del');
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
TRIGGER Grushevskaya_tr_on_record_udp
FOR UPDATE OF id ON Grushevskaya_record
COMPOUND TRIGGER
    TYPE Changes_arr IS TABLE OF Number(10,0) INDEX BY Pls_integer;
    record_changes Changes_arr;
    AFTER EACH ROW IS
    BEGIN
        record_changes(:OLD.id) := :NEW.id;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        id_arr Grushevskaya_record_arr;
        flag Boolean := false;
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

-- Пакет grushevskaya_package с реализованным функционалом

CREATE OR REPLACE 
PACKAGE grushevskaya_package AS
    -- Добавить страну в словарь.
    PROCEDURE add_in_dict_country (
        -- Название страны
        name Varchar2
    );
    -- Добавить стиль в словарь.
    PROCEDURE add_in_dict_style (
        -- Название стиля
        name Varchar2
    );
    
    -- Минимальный функционал
    
    -- 1) Добавить запись (изначально указывается один исполнитель).
    PROCEDURE add_record (
        -- Название
        name Varchar2, 
        -- Количество часов звучания
        hours Number,
        -- Количество минут звучания
        minutes Number,
        -- Количество секунд звучания
        seconds Number,
        -- Стиль из словаря
        style Varchar2,
        -- Имя исполнителя
        singer Varchar2
    );
    -- 2) Добавить исполнителя для записи 
    -- (если указанная запись не добавлена ни в один альбом 
    --  - Условие проверяется на уровне триггера).
    PROCEDURE add_singer_in_record (
        -- id записи
        record_id Number,
        -- Имя исполнителя
        singer_name Varchar2
    );
    -- 3) Добавить исполнителя.
    PROCEDURE add_singer (
        -- Имя (ФИО)
        name Varchar2, 
        -- Страна из словаря
        country Varchar2
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома с одной записью.
    PROCEDURE add_album (
        -- Название
        name Varchar2,
        -- Цена (>= 0)
        price Number,
        -- Количество на складе (>= 0)
        quantity_in_stock Number,
        -- id добавляемой записи
        record_id Number
    );
    -- 4) Добавить альбом (изначально указывается один трек или ни одного).
    -- Реализация для добавления альбома без записей.
    PROCEDURE add_album (
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
    PROCEDURE add_record_in_album (
        -- id альбома
        album_id Number,
        -- id добавляемой записи 
        record_id Number
    );
    -- 6) Список альбомов в продаже (количество на складе больше 0).
    PROCEDURE print_albums_in_stock;
    -- 7) Список исполнителей.
    PROCEDURE print_singers;
    -- 8) Поставка альбома
    -- (количество на складе увеличивается на указанное значение).
    PROCEDURE add_albums_in_stock (
        -- id альбома
        album_id Number,
        -- Количество
        quantity Number
    );
    -- 9) Продать альбом 
    -- (количество на складе уменьшается, проданных – увеличивается; 
    -- продать можно только альбомы, в которых есть хотя бы один трек
    --  - Условие проверяется в самой функции). 
    PROCEDURE sell_albums (
        -- id альбома
        album_id Number,
        -- Количество
        quantity Number
    );
    -- 10) Удалить исполнителей, у которых нет ни одной записи.
    PROCEDURE delete_singers_without_records;
    
    -- Основной функционал
    
    -- 11) Трек-лист указанного альбома 
    -- с указанием суммарного времени звучания альбома.
    PROCEDURE print_album_records(album_id Number);
    -- 12) Выручка магазина 
    -- (суммарная стоимость проданных альбомов 
    -- по каждому в отдельности 
    -- и по магазину в целом).
    PROCEDURE print_income;
    -- 13) Удалить трек с указанным номером из альбома 
    -- с пересчётом остальных номеров 
    -- (если не продано ни одного экземпляра альбома
    --  - Условие проверяется на уровне триггера).
    PROCEDURE delete_record_from_album (
        -- id альбома
        album_id Number,
        -- Номер звучания записи в альбоме
        record_number Number
    );
    -- 14) Удалить исполнителя из записи 
    -- (если запись не входит ни в один альбом 
    -- и если этот исполнитель не единственный
    --  - Условия проверяются на уровне триггера). 
    PROCEDURE delete_singer_from_record (
        -- id записи
        record_id Number,
        -- Имя исполнителя        
        singer_name Varchar2
    );
    -- 15) Определить предпочитаемый музыкальный стиль указанного исполнителя 
    -- (стиль, в котором записано большинство его треков). 
    PROCEDURE print_singer_style (
        -- Имя исполнителя
        singer_name Varchar2
    );
    -- 16) Определить предпочитаемый музыкальный стиль 
    -- по каждой стране происхождения исполнителей.
    PROCEDURE print_country_style; 
    -- 17) Определить авторство альбомов 
    -- (для каждого альбома выводится 
    -- исполнитель или список исполнителей,
    -- если все треки этого альбома записаны 
    -- одним множеством исполнителей; 
    -- в противном случае выводится «Коллективный сборник»).
    PROCEDURE print_album_author;
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
    
    PROCEDURE add_in_dict_country (
        name Varchar2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_country (name) VALUES (name);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Страна ' || name || ' успешно добавлена.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_in_dict_country');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_in_dict_country;
    
    PROCEDURE add_in_dict_style (
        name Varchar2
    )IS
    BEGIN
        INSERT INTO Grushevskaya_dict_style (name) VALUES (name);
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE('Стиль ' || name || ' успешно добавлен.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_in_dict_style');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_in_dict_style;
    
    PROCEDURE add_record(
        name Varchar2,
        hours Number,
        minutes Number,
        seconds Number,
        style Varchar2,
        singer Varchar2
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_record');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет стиля ' || style || ' в словаре.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSIF SQLCODE = -1873 THEN
            DBMS_OUTPUT.PUT_LINE('Неверное значение времени.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_record; 
    
    PROCEDURE add_singer_in_record (
        record_id Number,
        singer_name Varchar2
    ) IS
        TMP_singer_list Grushevskaya_singer_tab;
    BEGIN
        IF singer_name IS null THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять null-значения.');
            RETURN;
        END IF;
        SELECT singer_list INTO TMP_singer_list 
            FROM Grushevskaya_record
            WHERE id = record_id;
        TMP_singer_list.EXTEND;
        TMP_singer_list(TMP_singer_list.LAST) := singer_name;
        UPDATE Grushevskaya_record
            SET singer_list = TMP_singer_list
            WHERE id = record_id;
        COMMIT;        
        DBMS_OUTPUT.PUT_LINE(
            'Исполнитель ' || singer_name 
            || ' успешно добавлен в запись с id ' || record_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_singer_in_record');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка в несуществующую запись.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_singer_in_record;
    
    PROCEDURE add_singer (
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_singer');
        IF SQLCODE = -02291 THEN
            DBMS_OUTPUT.PUT_LINE('Нет страны ' || country || ' в словаре.');
        ELSIF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_singer;
        
    PROCEDURE add_album (
        name Varchar2,
        price Number,
        quantity_in_stock Number,
        record_id Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr := Grushevskaya_record_arr();
    BEGIN
        RECORD_ARR.EXTEND(30);
        RECORD_ARR(1) := record_id;
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_album');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка несуществующей записи в альбом.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено одно из условий.');
            DBMS_OUTPUT.PUT_LINE('Значение цены не может быть отрицательным.');
            DBMS_OUTPUT.PUT_LINE('Значения количества альбомов в продаже и проданных не могут быть отрицательными.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_album;
        
    PROCEDURE add_album (
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_album');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено ограничение уникальности одного из полей.');
        ELSIF SQLCODE = -1400 THEN
            DBMS_OUTPUT.PUT_LINE('Невозможно вставить null для одного из столбцов.');
        ELSIF SQLCODE = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('Нарушено одно из условий.');
            DBMS_OUTPUT.PUT_LINE('Значение цены не может быть отрицательным.');
            DBMS_OUTPUT.PUT_LINE('Значения количества альбомов в продаже и проданных не могут быть отрицательными.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_album;
    
    PROCEDURE add_record_in_album (
        album_id Number, 
        record_id Number
    )IS
        RECORD_SERIAL_Number Number := -1;
        TMP_RECORD_ARR Grushevskaya_record_arr;
    BEGIN        
        IF record_id IS null THEN
            DBMS_OUTPUT.PUT_LINE('Нельзя вставлять null-значения.');
            RETURN;
        END IF;
        SELECT record_array INTO TMP_RECORD_ARR
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN REVERSE 1..TMP_RECORD_ARR.COUNT
        LOOP
            IF TMP_RECORD_ARR(i) IS null THEN
                RECORD_SERIAL_Number := i;
            END IF;
        END LOOP;
        IF RECORD_SERIAL_Number = -1 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Альбом с id ' 
                || album_id 
                || ' не может содержать больше 30 записей. Запись с id ' 
                || record_id 
                || ' не добавлена.'
            );
        END IF;
        TMP_RECORD_ARR(RECORD_SERIAL_Number) := record_id;
        UPDATE Grushevskaya_album
            SET record_array = TMP_RECORD_ARR
            WHERE id = album_id;            
        COMMIT;      
        DBMS_OUTPUT.PUT_LINE(
            'Запись с id ' || record_id 
            || ' успешно добавлена в альбом с id ' || album_id || '.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_record_in_album');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Вставка в несуществующий альбом.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END add_record_in_album;
    
    PROCEDURE print_albums_in_stock 
    IS
        quantity Number := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Альбомы в продаже:');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album WHERE quantity_in_stock > 0)
        LOOP
            DBMS_OUTPUT.PUT_LINE(ALBUM.name);
            quantity := quantity + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Всего альбомов в продаже: ' || quantity || '.');    
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_albums_in_stock');
        PRINT_MSG_EX(SQLCODE);
    END print_albums_in_stock;
    
    PROCEDURE print_singers
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Все исполнители:');
        FOR singer IN (SELECT * FROM Grushevskaya_singer)
        LOOP
            DBMS_OUTPUT.PUT_LINE(singer.name);
        END LOOP;  
        DBMS_OUTPUT.PUT_LINE('Конец списка исполнителей. Больше нет.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_singers');
        PRINT_MSG_EX(SQLCODE);
    END print_singers;
    
    PROCEDURE add_albums_in_stock (
        album_id Number,
        quantity Number
    ) IS
    BEGIN
        IF quantity <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'В продажу поступило отрицательное ' 
                || 'количество альбомов c id ' 
                || album_id || '. Количество не обновлено.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET quantity_in_stock = quantity_in_stock + quantity
            WHERE id = album_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            'В продажу поступило ' || quantity 
            || ' альбомов c id ' || album_id || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN add_albums_in_stock');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Поставка несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;        
    END add_albums_in_stock;    
    
    PROCEDURE sell_albums(
        album_id Number,
        quantity Number
    ) IS
        RECORD_ARR Grushevskaya_record_arr;
        flag_ONE_RECORD Boolean := false;
        MAX_quantity Number;
    BEGIN
        IF quantity <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Подается отрицательное количество альбомов c id ' 
                || album_id || '. Количество не обновлено.'
            );
            RETURN;
        END IF;
        SELECT record_array INTO RECORD_ARR 
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS null THEN
                flag_ONE_RECORD := true;
            END IF;
        END LOOP;
        IF NOT flag_ONE_RECORD THEN
            DBMS_OUTPUT.PUT_LINE(
                'Продать альбом c id ' 
                || album_id || ' нельзя. В альбоме нет треков.'
            );
            RETURN;
        END IF;
        SELECT quantity_in_stock INTO MAX_quantity 
            FROM Grushevskaya_album
            WHERE id = album_id;
        MAX_quantity := LEAST(MAX_quantity, quantity);
        IF MAX_quantity <= 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Продать альбом c id ' 
                || album_id || ' нельзя. Альбомов нет на складе.'
            );
            RETURN;
        END IF;
        UPDATE Grushevskaya_album
            SET 
                quantity_in_stock = quantity_in_stock - MAX_quantity,
                quantity_of_sold = quantity_of_sold + MAX_quantity
            WHERE id = album_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            'Продано ' || MAX_quantity 
            || ' альбомов c id ' || album_id || '.'
        );
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN sell_albums');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Продажа несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;       
    END sell_albums;
    
    PROCEDURE delete_singers_without_records
    IS
        DEL_singerS_LIST Grushevskaya_singer_tab;
    BEGIN
        SELECT name BULK COLLECT INTO DEL_singerS_LIST FROM Grushevskaya_singer;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
           FOR i IN 1..RECORD.singer_list.COUNT
            LOOP
                FOR k IN 1..DEL_singerS_LIST.COUNT
                LOOP                   
                    IF NOT DEL_singerS_LIST(k) IS null
                       AND NOT RECORD.singer_list(i) IS null
                       AND DEL_singerS_LIST(k) = RECORD.singer_list(i) THEN
                        DEL_singerS_LIST(k) := null;
                    END IF;                
                END LOOP;
            END LOOP;
        END LOOP;
        FOR j IN 1..DEL_singerS_LIST.COUNT
        LOOP
            IF NOT DEL_singerS_LIST(j) IS null THEN
                DELETE FROM Grushevskaya_singer
                WHERE name = DEL_singerS_LIST(j);
                DBMS_OUTPUT.PUT_LINE(
                    'Удален исполнитель ' 
                    || DEL_singerS_LIST(j) || '.'
                );
            END IF;
        END LOOP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Исполнители без записей удалены успешно.');
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN delete_singers_without_records');
        PRINT_MSG_EX(SQLCODE);
    END delete_singers_without_records;    
    
    PROCEDURE print_album_records(
        album_id Number
    ) IS
        ALBUM_name Varchar2(100 BYTE);
        RECORD_ARR Grushevskaya_record_arr;
        RECORD Grushevskaya_record%ROWTYPE;
        time INTERVAL DAY(0) TO SECOND(0) := NUMTODSINTERVAL(0, 'SECOND');
        singerS Varchar2(300) := '';
    BEGIN
        SELECT name INTO ALBUM_name
            FROM Grushevskaya_album
            WHERE id = album_id;
        DBMS_OUTPUT.PUT_LINE('Альбом №' || album_id || ' с именем ' || ALBUM_name);
        SELECT record_array INTO RECORD_ARR
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN 1..RECORD_ARR.COUNT
        LOOP
            IF NOT RECORD_ARR(i) IS null THEN
                SELECT * INTO RECORD FROM Grushevskaya_record 
                    WHERE id = RECORD_ARR(i);
                singerS := '-';
                FOR j IN 1..RECORD.singer_list.COUNT
                LOOP
                    singerS := singerS || ' ' || RECORD.singer_list(j);
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
                    || singerS
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_album_records');
        IF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Печать несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END print_album_records;
    
    PROCEDURE print_income
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_income');
        PRINT_MSG_EX(SQLCODE);
    END print_income;    
    
    PROCEDURE delete_record_from_album (
        album_id Number,
        record_number Number
    ) IS
        TMP_RECORD_ARR Grushevskaya_record_arr;
        TMP_quantity_of_sold Number;
    BEGIN
        SELECT quantity_of_sold INTO TMP_quantity_of_sold
            FROM Grushevskaya_album
            WHERE id = album_id;
        IF TMP_quantity_of_sold > 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'Удалить трек №' 
                || record_number || ' нельзя, так как альбом продан'
            );
            RETURN;
        END IF;
        SELECT record_array INTO TMP_RECORD_ARR 
            FROM Grushevskaya_album
            WHERE id = album_id;
        FOR i IN record_number..TMP_RECORD_ARR.COUNT-1
        LOOP
            TMP_RECORD_ARR(i) := TMP_RECORD_ARR(i+1);
        END LOOP;
        TMP_RECORD_ARR(TMP_RECORD_ARR.COUNT) := null;
        UPDATE Grushevskaya_album
            SET record_array = TMP_RECORD_ARR
            WHERE id = album_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Трек №' || record_number || ' удален');            
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_album THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN delete_record_from_album');
        IF SQLCODE = -6532 THEN
            DBMS_OUTPUT.PUT_LINE('Индекс превышает пределы.');        
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Удаление несуществующего альбома.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;    
    END delete_record_from_album;    
    
    PROCEDURE delete_singer_from_record(
        record_id Number,
        singer_name Varchar2
    ) IS
        TMP_singer_list Grushevskaya_singer_tab;
        singer_Number Number := 0;
    BEGIN
        SELECT singer_list INTO TMP_singer_list 
            FROM Grushevskaya_record
            WHERE id = record_id;
        FOR i IN 1..TMP_singer_list.COUNT
        LOOP
            IF TMP_singer_list(i) = singer_name THEN
                SINGER_Number := i;
            END IF;
        END LOOP;
        TMP_singer_list.DELETE(SINGER_Number);        
        UPDATE Grushevskaya_record
            SET singer_list = TMP_singer_list
            WHERE id = record_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(
            'Исполнитель ' || singer_name || ' под №' || SINGER_Number || ' удален.'
        );
    EXCEPTION
    WHEN grushevskaya_exceptions.Error_update_singer_in_record THEN
        RETURN;
    WHEN grushevskaya_exceptions.Warning_update THEN
        RETURN;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN delete_singer_from_record');
        IF SQLCODE = -12899 THEN
            DBMS_OUTPUT.PUT_LINE('Значение для одного из столбцов слишком велико.');       
        ELSIF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Удаление из несуществующего исполнителя невозможно.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;        
    END delete_singer_from_record;
        
    PROCEDURE print_singer_style(
        singer_name Varchar2
    ) IS
        COUNT_SINGER_IN_TABLE Number := 0;
        TYPE SINGER_style IS TABLE OF Number INDEX BY Varchar2(100 BYTE);
        SINGER_style_LIST SINGER_style;
        CURRENT_ELEM Varchar2(100 BYTE);
        MAX_style Varchar2(100 BYTE);
    BEGIN
        SELECT COUNT(name) INTO COUNT_SINGER_IN_TABLE 
            FROM Grushevskaya_singer
            WHERE name = singer_name;
        IF COUNT_SINGER_IN_TABLE = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Исполнитель не найден.');
            RETURN;
        END IF;
        FOR RECORD IN (SELECT * FROM Grushevskaya_record)
        LOOP
            FOR i IN 1..RECORD.singer_list.COUNT
            LOOP
                IF RECORD.singer_list(i) = singer_name THEN
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
        WHILE NOT CURRENT_ELEM IS null
        LOOP  
            IF SINGER_style_LIST(CURRENT_ELEM) > SINGER_style_LIST(MAX_style) THEN
                MAX_style := CURRENT_ELEM;
            END IF;
            CURRENT_ELEM := SINGER_style_LIST.NEXT(CURRENT_ELEM);
        END LOOP;
        IF MAX_style IS null THEN
            DBMS_OUTPUT.PUT_LINE('У исполнителя нет записей.');
            RETURN;
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            'Наиболее популярный стиль у ' 
            || singer_name || ' - '  || MAX_style || '.'
        );       
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_singer_style');
        PRINT_MSG_EX(SQLCODE);
    END print_singer_style;
    
    PROCEDURE print_country_style
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
        WHILE NOT CURRENT_country IS null
        LOOP
            MAX_style := country_style_LIST(CURRENT_country).FIRST;
            CURRENT_style := country_style_LIST(CURRENT_country).FIRST;
            WHILE NOT CURRENT_style IS null
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
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_country_style');
        PRINT_MSG_EX(SQLCODE);
    END print_country_style; 
    
    PROCEDURE print_album_author
    IS
        TYPE ALL_album_id IS TABLE OF Varchar2(100 BYTE);
        album_id ALL_album_id;
        TYPE ALBUM_SINGER IS TABLE OF Number INDEX BY Varchar2(100 BYTE);
        ALBUM_singer_list ALBUM_SINGER;
        SINGERS Grushevskaya_singer_tab;
        RECORD_COUNT Number;
        CURRENT_SINGER Varchar(100 BYTE);
        flag_GROUP Boolean;
    BEGIN   
        DBMS_OUTPUT.PUT_LINE('Авторство альбомов.');
        FOR ALBUM IN (SELECT * FROM Grushevskaya_album)
        LOOP
            RECORD_COUNT := 0;
            ALBUM_singer_list.DELETE;
            FOR i IN 1..ALBUM.record_array.COUNT
            LOOP
                IF NOT ALBUM.record_array(i) IS null THEN
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
            flag_GROUP := false;
            CURRENT_SINGER := ALBUM_singer_list.FIRST;
            WHILE NOT CURRENT_SINGER IS null
            LOOP
                IF ALBUM_singer_list(CURRENT_SINGER) <> RECORD_COUNT THEN
                    flag_GROUP := true;
                END IF;
                CURRENT_SINGER := ALBUM_singer_list.NEXT(CURRENT_SINGER);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(
                'Авторство альбома ' || ALBUM.name || ' с id ' || ALBUM.id || 
                '.'
            );
            IF flag_GROUP THEN
                DBMS_OUTPUT.PUT_LINE('Коллективный сборник.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Исполнители:');
                CURRENT_SINGER := ALBUM_singer_list.FIRST;
                IF CURRENT_SINGER IS null THEN
                    DBMS_OUTPUT.PUT_LINE('Исполнителей в альбоме нет.');
                END IF;
                WHILE NOT CURRENT_SINGER IS null
                LOOP
                    DBMS_OUTPUT.PUT_LINE(CURRENT_SINGER);
                    CURRENT_SINGER := ALBUM_singer_list.NEXT(CURRENT_SINGER);
                END LOOP;
            END IF; 
        END LOOP;        
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION IN print_album_author');
        IF SQLCODE = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Печать авторства несуществующего альбома невозможна.');
        ELSE
            PRINT_MSG_EX(SQLCODE);
        END IF;
    END print_album_author;
END;

