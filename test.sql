DECLARE 
BEGIN
    DBMS_OUTPUT.PUT_LINE('----- ������� ������ -----');
    DELETE FROM GRUSHEVSKAYA_ALBUM;
    DELETE FROM GRUSHEVSKAYA_RECORD;
    DELETE FROM GRUSHEVSKAYA_SINGER;
    DELETE FROM GRUSHEVSKAYA_DICT_COUNTRY;
    DELETE FROM GRUSHEVSKAYA_DICT_STYLE;
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ -----');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� NULL country -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY(NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ����� � country -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY(1250);
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� �������� country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_COUNTRY('country_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_1 nick_1 country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_1', 'nick_1', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� �������� singer_1 nick_1 country_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_1', 'nick_1', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_1 � �������������� country_8 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_7', 'nick_1', 'country_3');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� style_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� NULL style -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE(NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ��������� style_1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� style_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_IN_DICT_STYLE('style_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(1, 'song_1', 0, 1, 10, 'style_2', 'singer_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ c �������������� ������ -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(7, 'song_7', 0, 1, 10, 'style_5', 'singer_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_2 nick_2 country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_2', 'nick_2', 'country_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ��������� ���������� singer_2 nick_2 country_2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_2', 'nick_2', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_2 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ���������� singer_2 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_2 � �������������� ������ 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1000, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� singer_2 � NULL ������ -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(NULL, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ��������������� singer_1000 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, 'singer_1000');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� NULL � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(1, NULL);
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 1, 
        NAME => 'album_1', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => 10, 
        QUANTITY_OF_SOLD => 0, 
        RECORD_ID => 1, 
        RECORD_SERIAL_NUMBER => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 100 � �������������� ���������� ���-�� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 100, 
        NAME => 'album_100', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => -10, 
        QUANTITY_OF_SOLD => -10, 
        RECORD_ID => 1, 
        RECORD_SERIAL_NUMBER => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 100 � ������������� ����� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 100, 
        NAME => 'album_100', 
        PRICE => -100.50, 
        QUANTITY_IN_STOCK => 10, 
        QUANTITY_OF_SOLD => 10, 
        RECORD_ID => 1, 
        RECORD_SERIAL_NUMBER => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 100 � �������������� ������� 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 100, 
        NAME => 'album_100', 
        PRICE => 100.50, 
        QUANTITY_IN_STOCK => 10, 
        QUANTITY_OF_SOLD => 10, 
        RECORD_ID => 1000, 
        RECORD_SERIAL_NUMBER => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ 2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(2, 'song_2', 0, 2, 50, 'style_1', 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ 2 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 2, 
        RECORD_SERIAL_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ��������� ���������� ������ 2 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 2, 
        RECORD_SERIAL_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� �������������� ������ 100 � ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 100, 
        RECORD_SERIAL_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ 1 � �������������� ������ 1000 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1000,
        RECORD_ID => 1, 
        RECORD_SERIAL_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������ 1 � ������ 1 � � ��������� �� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 1,
        RECORD_ID => 1, 
        RECORD_SERIAL_NUMBER => 31
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 2 ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 2, 
        NAME => 'album_2', 
        PRICE => 123.50, 
        QUANTITY_IN_STOCK => 5, 
        QUANTITY_OF_SOLD => 0
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 3, 4 � 5 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(3, 'song_3', 0, 1, 37, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(4, 'song_4', 0, 2, 12, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(4, 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(5, 'song_5', 0, 1, 42, 'style_1', 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(5, 'singer_2');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(5, 'singer_2');
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 3, 4 � 5 � ������ 2 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 3, 
        RECORD_SERIAL_NUMBER => 1
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 4, 
        RECORD_SERIAL_NUMBER => 8
    );
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD_IN_ALBUM(
        ALBUM_ID => 2,
        RECORD_ID => 5, 
        RECORD_SERIAL_NUMBER => 4
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ������� 3 ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => 3, 
        NAME => 'album_3', 
        PRICE => 555.50, 
        QUANTITY_IN_STOCK => 0, 
        QUANTITY_OF_SOLD => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� NULL ������� ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUM(
        ID => NULL, 
        NAME => 'album_3', 
        PRICE => 555.50, 
        QUANTITY_IN_STOCK => 0, 
        QUANTITY_OF_SOLD => 10
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ �������� � ������� -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUMS_IN_STOCK;
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������������ -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGERS;
    
    DBMS_OUTPUT.PUT_LINE('----- ������ -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 1, QUANTITY => 8);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ �������������� ���������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 1, QUANTITY => -3);
    
    DBMS_OUTPUT.PUT_LINE('----- ������� -----');
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 2, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 2, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 3, QUANTITY => 8);
    
    DBMS_OUTPUT.PUT_LINE('----- ������� �������������� ���������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_ALBUMS_IN_STOCK(ALBUM_ID => 2, QUANTITY => 8);
    GRUSHEVSKAYA_PACKAGE.SELL_ALBUMS(ALBUM_ID => 2, QUANTITY => -5);
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ����������� 3 ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_3', 'nick_3', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������������ ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGERS_WITHOUT_RECORDS;   
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ����������� 4 ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_4', 'nick_4', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_5', 'nick_4', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_6', 'nick_4', 'country_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER('singer_7', 'nick_4', 'country_1');
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������������ ��� ������� -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGERS_WITHOUT_RECORDS;  
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 2);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 3);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ��������������� ������� 4 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 4);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������� -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_INCOME;
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������ �� ������� 1000 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1000,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- �������� �����. ������ �� ������� -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1,
        RECORD_NUMBER => 0
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������ �� ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 1,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������ �� ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 2,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 2);
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������ �� ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 2,
        RECORD_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 2);
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 3);
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ������ �� ������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_RECORD_FROM_ALBUM(
        ALBUM_ID => 2,
        RECORD_NUMBER => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 3);
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ����������� �� ������ 1 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 1,
        SINGER_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ���������� ����� 6 -----');
    GRUSHEVSKAYA_PACKAGE.ADD_RECORD(6, 'song_6', 0, 5, 15, 'style_1', 'singer_1');
    GRUSHEVSKAYA_PACKAGE.ADD_SINGER_IN_RECORD(6, 'singer_2');
    
    
    DBMS_OUTPUT.PUT_LINE('----- �������� �����. ����������� �� ������ 6 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 6,
        SINGER_NUMBER => 8
    );
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ����������� �� �����. ������ 1000 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 1000,
        SINGER_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ����������� �� ������ 6 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 6,
        SINGER_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- �������� ����������� �� ������ 5 -----');
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGER_FROM_RECORD(
        RECORD_ID => 5,
        SINGER_NUMBER => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ����� ����������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_1'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ����� ����������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_2'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ����� ����������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_3'
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ����� ����������� NULL -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ������ ����� -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_COUNTRY_STYLE;
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ��������� ������� 1 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 1
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ��������� ������� 2 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 2
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ��������� ������� 3 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 3
    );
    
    DBMS_OUTPUT.PUT_LINE('----- ������ ��������� ������� 4 -----');
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 4
    );
END;