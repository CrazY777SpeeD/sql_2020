DECLARE 
BEGIN
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUMS_IN_STOCK;
    GRUSHEVSKAYA_PACKAGE.PRINT_INCOME;
    GRUSHEVSKAYA_PACKAGE.PRINT_COUNTRY_STYLE;
    
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGERS;
    GRUSHEVSKAYA_PACKAGE.DELETE_SINGERS_WITHOUT_RECORDS;  
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGERS;
    
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 1);
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 2);
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 3);
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 4);
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_RECORDS(ALBUM_ID => 5);
    
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_1'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_2'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_3'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_4'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_5'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_6'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_7'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_8'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_9'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_10'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_11'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_12'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_13'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_14'
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_SINGER_STYLE(
        SINGER_NAME => 'singer_15'
    );
    
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 1
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 2
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 3
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 4
    );
    GRUSHEVSKAYA_PACKAGE.PRINT_ALBUM_AUTHOR(
        ALBUM_ID => 5
    );
END;