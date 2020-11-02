--------------------------------------------------------
--  File created - понедельник-но€бр€-02-2020   
--------------------------------------------------------
DROP TYPE "gdv"."GRUSHEVSKAYA_RECORD_ARR";
DROP TYPE "gdv"."GRUSHEVSKAYA_SINGER_TAB";
DROP TABLE "gdv"."GRUSHEVSKAYA_RECORD";
DROP TABLE "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE";
DROP TABLE "gdv"."GRUSHEVSKAYA_SINGER";
DROP TABLE "gdv"."GRUSHEVSKAYA_ALBUM";
DROP TABLE "gdv"."GRUSHEVSKAYA_SINGER_LIST";
--------------------------------------------------------
--  DDL for Type GRUSHEVSKAYA_RECORD_ARR
--------------------------------------------------------

  CREATE OR REPLACE TYPE "gdv"."GRUSHEVSKAYA_RECORD_ARR" AS VARRAY(30) OF NUMBER(10,0);

/
--------------------------------------------------------
--  DDL for Type GRUSHEVSKAYA_SINGER_TAB
--------------------------------------------------------

  CREATE OR REPLACE TYPE "gdv"."GRUSHEVSKAYA_SINGER_TAB" AS TABLE OF VARCHAR2(1);

/
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  CREATE TABLE "gdv"."GRUSHEVSKAYA_RECORD" 
   (	"ID" NUMBER(10,0), 
	"NAME" VARCHAR2(100 BYTE), 
	"TIME" TIMESTAMP (6), 
	"STYLE" VARCHAR2(100 BYTE), 
	"SINGER_LIST" "gdv"."GRUSHEVSKAYA_SINGER_TAB" 
   ) 
 NESTED TABLE "SINGER_LIST" STORE AS "GRUSHEVSKAYA_SINGER_LIST"
 RETURN AS VALUE;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_DICTIONARY_STYLE
--------------------------------------------------------

  CREATE TABLE "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE" 
   (	"NAME" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  CREATE TABLE "gdv"."GRUSHEVSKAYA_SINGER" 
   (	"NAME" VARCHAR2(100 BYTE), 
	"NICKNAME" VARCHAR2(100 BYTE), 
	"COUNTRY" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table GRUSHEVSKAYA_ALBUM
--------------------------------------------------------

  CREATE TABLE "gdv"."GRUSHEVSKAYA_ALBUM" 
   (	"ID" NUMBER(10,0), 
	"NAME" VARCHAR2(100 BYTE), 
	"PRICE" NUMBER(6,2), 
	"QUANTITY_IN_STOCK" NUMBER(5,0), 
	"QUANTITY_OF_SOLD" NUMBER(5,0), 
	"RECORD_ARRAY" "gdv"."GRUSHEVSKAYA_RECORD_ARR" 
   ) ;
REM INSERTING into "gdv".GRUSHEVSKAYA_RECORD
SET DEFINE OFF;
REM INSERTING into "gdv".GRUSHEVSKAYA_DICTIONARY_STYLE
SET DEFINE OFF;
REM INSERTING into "gdv".GRUSHEVSKAYA_SINGER
SET DEFINE OFF;
REM INSERTING into "gdv".GRUSHEVSKAYA_ALBUM
SET DEFINE OFF;
--------------------------------------------------------
--  DDL for Index SYS_C0010859
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."SYS_C0010859" ON "gdv"."GRUSHEVSKAYA_RECORD" ("SYS_NC0000500006$") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_RECORD_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."GRUSHEVSKAYA_RECORD_PK" ON "gdv"."GRUSHEVSKAYA_RECORD" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_C0010858
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."SYS_C0010858" ON "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_SINGER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."GRUSHEVSKAYA_SINGER_PK" ON "gdv"."GRUSHEVSKAYA_SINGER" ("NAME") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_SINGER_UK
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."GRUSHEVSKAYA_SINGER_UK" ON "gdv"."GRUSHEVSKAYA_SINGER" ("NAME", "NICKNAME") 
  ;
--------------------------------------------------------
--  DDL for Index GRUSHEVSKAYA_ALBUM_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "gdv"."GRUSHEVSKAYA_ALBUM_PK" ON "gdv"."GRUSHEVSKAYA_ALBUM" ("ID") 
  ;
--------------------------------------------------------
--  DDL for Index SYS_FK0000073463N00005$
--------------------------------------------------------

  CREATE INDEX "gdv"."SYS_FK0000073463N00005$" ON "gdv"."GRUSHEVSKAYA_SINGER_LIST" ("NESTED_TABLE_ID") 
  ;
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" ADD CONSTRAINT "GRUSHEVSKAYA_RECORD_PK" PRIMARY KEY ("ID") ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" ADD UNIQUE ("SINGER_LIST") ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" MODIFY ("TIME" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_DICTIONARY_STYLE
--------------------------------------------------------

  ALTER TABLE "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE" ADD PRIMARY KEY ("NAME") ENABLE;
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_SINGER
--------------------------------------------------------

  ALTER TABLE "gdv"."GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_PK" PRIMARY KEY ("NAME") ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_SINGER" ADD CONSTRAINT "GRUSHEVSKAYA_SINGER_UK" UNIQUE ("NAME", "NICKNAME") ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_SINGER" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_SINGER" MODIFY ("COUNTRY" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table GRUSHEVSKAYA_ALBUM
--------------------------------------------------------

  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK1" CHECK ("PRICE" >= 0) ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK2" CHECK ("QUANTITY_IN_STOCK" >= 0) ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_CHK3" CHECK ("QUANTITY_OF_SOLD" >= 0) ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" ADD CONSTRAINT "GRUSHEVSKAYA_ALBUM_PK" PRIMARY KEY ("ID") ENABLE;
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("PRICE" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("QUANTITY_IN_STOCK" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("QUANTITY_OF_SOLD" NOT NULL ENABLE);
 
  ALTER TABLE "gdv"."GRUSHEVSKAYA_ALBUM" MODIFY ("RECORD_ARRAY" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table GRUSHEVSKAYA_RECORD
--------------------------------------------------------

  ALTER TABLE "gdv"."GRUSHEVSKAYA_RECORD" ADD CONSTRAINT "GRUSHEVSKAYA_RECORD_FK" FOREIGN KEY ("STYLE")
	  REFERENCES "gdv"."GRUSHEVSKAYA_DICTIONARY_STYLE" ("NAME") ON DELETE SET NULL ENABLE;
