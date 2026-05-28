CREATE DATABASE LINK dblinkFilia 
CONNECT TO RBD1_ST20 IDENTIFIED BY start123 
USING 'baza11b';

CREATE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;
CREATE SYNONYM kursyFilia FOR kursy@dblinkFilia;
