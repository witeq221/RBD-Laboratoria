SET SERVEROUTPUT ON;

-- Zadanie 1
DECLARE
  v_kursanci NUMBER;
  v_kursy NUMBER;
  v_wykladowcy NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_kursanci FROM kursanci;
  SELECT COUNT(*) INTO v_kursy FROM kursy;
  SELECT COUNT(*) INTO v_wykladowcy FROM wykladowcy;
  
  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_kursanci);
  DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || v_kursy);
  DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_wykladowcy);
END;
/

-- Zadanie 2
DECLARE
  v_suma NUMBER;
BEGIN
  SELECT SUM(r.cena) INTO v_suma
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';
  
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_suma || ' zł');
END;
/

-- Zadanie 3
DECLARE
  v_miasto VARCHAR2(30) := 'BYDGOSZCZ';
  v_liczba_umow NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_liczba_umow
  FROM umowy
  WHERE miasto = v_miasto;
  
  IF v_liczba_umow = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
  ELSIF v_liczba_umow < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
  ELSIF v_liczba_umow <= 100 THEN
    DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
  END IF;
END;
/

-- Zadanie 4
BEGIN
  FOR r IN (
    SELECT k.kurs_id, r.nazwa, r.godz, r.cena, w.imie, w.nazwisko
    FROM kursy k
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    ORDER BY k.kurs_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzący: ' || r.imie || ' ' || r.nazwisko);
  END LOOP;
END;
/

-- Zadanie 5
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2)
AS
  v_liczba NUMBER;
  v_suma NUMBER;
  v_srednia NUMBER;
BEGIN
  SELECT COUNT(*), SUM(r.cena), AVG(r.cena)
  INTO v_liczba, v_suma, v_srednia
  FROM umowy u
  JOIN kursy k ON u.kurs_id = k.kurs_id
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = p_miasto;

  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_suma || ' zł');
  DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia, 2) || ' zł');
END;
/

BEGIN
  raport_umow_miasto('BYDGOSZCZ');
END;
/

-- Zadanie 6
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
AS
  v_cena NUMBER;
BEGIN
  SELECT r.cena INTO v_cena
  FROM kursy k
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;
  
  RETURN v_cena;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

DECLARE
  v_cena NUMBER;
BEGIN
  v_cena := wartosc_kursu(1);
  DBMS_OUTPUT.PUT_LINE('Cena kursu: ' || v_cena);
END;
/

-- Zadanie 7
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER)
AS
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE kursant_id = p_kursant_id;
  
  DBMS_OUTPUT.PUT_LINE('Kursant: ' || v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

BEGIN
  pokaz_kursanta(1);
END;
/

-- Zadanie 7 (wariant dodatkowy z wyszukiwaniem po nazwisku)
CREATE OR REPLACE PROCEDURE pokaz_kursanta_nazwisko(p_nazwisko IN VARCHAR2)
AS
  v_imie kursanci.imie%TYPE;
BEGIN
  SELECT imie INTO v_imie
  FROM kursanci
  WHERE nazwisko = p_nazwisko;
  
  DBMS_OUTPUT.PUT_LINE('Znaleziono: ' || v_imie || ' ' || p_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o nazwisku: ' || p_nazwisko);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: Znaleziono więcej niż jedną osobę o nazwisku ' || p_nazwisko);
END;
/

BEGIN
  pokaz_kursanta_nazwisko('NOWAK');
END;
/

-- Zadanie 8
DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id, ku.imie, ku.nazwisko, r.nazwa, r.cena
    FROM umowy u
    JOIN kursanci ku ON u.kursant_id = ku.kursant_id
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';
    
  v_umowa c_umowy%ROWTYPE;
BEGIN
  OPEN c_umowy;
  LOOP
    FETCH c_umowy INTO v_umowa;
    EXIT WHEN c_umowy%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Umowa ' || v_umowa.umowa_id || ' | ' || v_umowa.imie || ' ' || v_umowa.nazwisko || ' | ' || v_umowa.nazwa || ' | ' || v_umowa.cena || ' zł');
  END LOOP;
  CLOSE c_umowy;
END;
/

-- Zadanie 9
CREATE OR REPLACE PROCEDURE raport_umow_szczecin
AS
BEGIN
  FOR r IN (
    SELECT u.umowa_id, ku.imie, ku.nazwisko, rod.nazwa, rod.cena, u.miasto
    FROM umowy u
    JOIN mv_kursanci_filia ku ON u.kursant_id = ku.kursant_id
    JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id
    JOIN mv_rodzaje_filia rod ON k.rodzaj_id = rod.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Umowa ' || r.umowa_id || ' | ' || r.imie || ' ' || r.nazwisko || ' | ' || r.nazwa || ' | ' || r.cena || ' zł | ' || r.miasto);
  END LOOP;
END;
/

BEGIN
  raport_umow_szczecin;
END;
/

-- Zadanie 10
CREATE OR REPLACE PROCEDURE raport_uczelni
AS
  v_liczba_b NUMBER;
  v_suma_b NUMBER;
  v_max_b VARCHAR2(100);
  v_pop_b VARCHAR2(100);
  
  v_liczba_s NUMBER;
  v_suma_s NUMBER;
  v_max_s VARCHAR2(100);
  v_pop_s VARCHAR2(100);
BEGIN
  DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
  DBMS_OUTPUT.PUT_LINE('--------------------');
  
  SELECT COUNT(*), SUM(r.cena) INTO v_liczba_b, v_suma_b
  FROM umowy u 
  JOIN kursy k ON u.kurs_id = k.kurs_id 
  JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';
  
  BEGIN
    SELECT nazwa INTO v_max_b FROM (SELECT r.nazwa FROM kursy k JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id ORDER BY r.cena DESC) WHERE ROWNUM = 1;
    SELECT nazwa INTO v_pop_b FROM (SELECT r.nazwa FROM umowy u JOIN kursy k ON u.kurs_id = k.kurs_id JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id WHERE u.miasto = 'BYDGOSZCZ' GROUP BY r.nazwa ORDER BY COUNT(*) DESC) WHERE ROWNUM = 1;
  EXCEPTION 
    WHEN OTHERS THEN 
      v_max_b := '-'; 
      v_pop_b := '-'; 
  END;

  DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_b);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_suma_b || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_max_b);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_pop_b);
  DBMS_OUTPUT.PUT_LINE('');

  SELECT COUNT(*), SUM(rod.cena) INTO v_liczba_s, v_suma_s
  FROM umowy u 
  JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id 
  JOIN mv_rodzaje_filia rod ON k.rodzaj_id = rod.rodzaj_id
  WHERE u.miasto = 'SZCZECIN';
  
  BEGIN
    SELECT nazwa INTO v_max_s FROM (SELECT rod.nazwa FROM mv_kursy_filia k JOIN mv_rodzaje_filia rod ON k.rodzaj_id = rod.rodzaj_id ORDER BY rod.cena DESC) WHERE ROWNUM = 1;
    SELECT nazwa INTO v_pop_s FROM (SELECT rod.nazwa FROM umowy u JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id JOIN mv_rodzaje_filia rod ON k.rodzaj_id = rod.rodzaj_id WHERE u.miasto = 'SZCZECIN' GROUP BY rod.nazwa ORDER BY COUNT(*) DESC) WHERE ROWNUM = 1;
  EXCEPTION 
    WHEN OTHERS THEN 
      v_max_s := '-'; 
      v_pop_s := '-'; 
  END;

  DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
  DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_s);
  DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_suma_s || ' zł');
  DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_max_s);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_pop_s);
  DBMS_OUTPUT.PUT_LINE('--------------------');
  DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
  DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umów: ' || (v_liczba_b + v_liczba_s));
  DBMS_OUTPUT.PUT_LINE('Łączna wartość wszystkich umów: ' || (v_suma_b + v_suma_s) || ' zł');
END;
/

BEGIN
  raport_uczelni;
END;
/
