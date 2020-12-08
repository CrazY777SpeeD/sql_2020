DECLARE 
BEGIN
    DBMS_OUTPUT.PUT_LINE('----- Очистка таблиц -----');
    DELETE FROM GRUSHEVSKAYA_ALBUM;
    DELETE FROM GRUSHEVSKAYA_RECORD;
    DELETE FROM GRUSHEVSKAYA_SINGER;
    DELETE FROM GRUSHEVSKAYA_DICT_COUNTRY;
    DELETE FROM GRUSHEVSKAYA_DICT_STYLE;
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление данных -----');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление NULL country -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY(NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление числа в country -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY(1250);
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление повторно country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_1 country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_1', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление повторно singer_1 country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_1', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_7 с несуществующей country_8 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_7', 'country_8');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление style_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление NULL style -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE(NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление повторное style_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление style_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записи 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_1', 0, 1, 10, 'style_2', 'singer_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записи song_7 c несуществующим стилем -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_7', 0, 1, 10, 'style_5', 'singer_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_2  country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_2', 'country_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Повторное добавление singer_2 country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_2', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_2 в запись 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Повтороное добавление singer_2 в запись 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_2 в несуществующую запись 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1000, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление singer_2 в NULL запись -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(NULL, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление несуществующего singer_1000 в запись 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_1000');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление NULL в запись 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_1', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => 10, 
        RECORD_ID => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 100 с отрицательными значениями кол-ва -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_100', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => -10,
        RECORD_ID => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 100 с отрицательной ценой -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_100', 
        PRICE => -100.50, 
        QUANTITY_IN_STOCK => 10, 
        RECORD_ID => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 100 с несуществующей записью 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_100', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => 10, 
        RECORD_ID => 1000
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записи 2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_2', 0, 2, 50, 'style_1', 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записи 2 в альбом 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Повторное добавление записи 2 в альбом 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление несуществующей записи 100 в альбом 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 100
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записи 1 в несуществующий альбом 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1000,
        RECORD_ID => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 2 без записей -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_2', 
        PRICE => 123.50, 
        QUANTITY_IN_STOCK => 5
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записей 3, 4 и 5 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_3', 0, 1, 37, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_4', 0, 2, 12, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(5, 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_5', 0, 1, 42, 'style_1', 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(6, 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(6, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление записей 3, 4 и 5 в альбом 2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 4
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 5
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 5,
        RECORD_ID => 6
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление альбома 3 без записей -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        NAME => 'album_3', 
        PRICE => 555.50, 
        QUANTITY_IN_STOCK => 0
    );   
    
    
    DBMS_OUTPUT.PUT_LINE('----- Печать альбомов в продаже -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUMS_IN_STOCK;
    
    DBMS_OUTPUT.PUT_LINE('----- Печать исполнителей -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGERS;
    
    DBMS_OUTPUT.PUT_LINE('----- Привоз -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 1, QUANTITY => 8);
    
    DBMS_OUTPUT.PUT_LINE('----- Привоз отрицательного количества -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 1, QUANTITY => -3);
    
    DBMS_OUTPUT.PUT_LINE('----- Продажа -----');
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 5, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 5, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 6, QUANTITY => 8);
    
    DBMS_OUTPUT.PUT_LINE('----- Продажа отрицательного количества -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 2, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 5, QUANTITY => -5);
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление исполнителя 3 без записей -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_3', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля исполнителя 3 без записей -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_3'
    );    
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителей без записей -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGERS_WITHOUT_RECORDS;   
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля несуществующего исполнителя 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_3'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление исполнителя 4 без записей -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_4', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_5', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_6', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_7', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителей без записей -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGERS_WITHOUT_RECORDS;  
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 5);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 6);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков несуществующего альбома 4 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 4);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать прибыли -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_INCOME;
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление записи из альбома 1000 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1000,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление несущ. записи из альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1,
        RECORD_NUMBER => 0
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление записи из альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1,
        RECORD_NUMBER => 2
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 5);
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление записи из альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 5,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 5);
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление записи из альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 5,
        RECORD_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 5);
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 6);
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление записи из альбома 3 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 6,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать треков альбома 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 6);
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителя из записи 1 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 1,
        SINGER_NAME => 'singer_1'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление песни 6 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_6', 0, 5, 15, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(7, 'singer_2');
    
   
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителя из несущ. записи 1000 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 1000,
        SINGER_NAME => 'singer_1'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителя из записи 6 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 7,
        SINGER_NAME => 'singer_1'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Удаление исполнителя из записи 5 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 6,
        SINGER_NAME => 'singer_2'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля исполнителя 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_1'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля исполнителя 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_2'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля исполнителя 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_3'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- Печать стиля исполнителя NULL -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('----- печать стилей стран -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_COUNTRY_STYLE;
    
    DBMS_OUTPUT.PUT_LINE('----- Печать авторства альбомов -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR; 
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление песни 7 с ошибкой времени сек -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_7', 8, 9, 85, 'style_1', 'singer_1');
    
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление песни 8 с ошибкой времени мин -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_8', 8, 95, 5, 'style_1', 'singer_1');
    
    
    DBMS_OUTPUT.PUT_LINE('----- Добавление песни 9 с ошибкой времени час -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD('song_9', 78, 5, 8, 'style_1', 'singer_1');
END;