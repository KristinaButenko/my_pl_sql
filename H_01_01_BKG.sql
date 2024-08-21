DECLARE
    v_year NUMBER := 2012;
    v_check_year NUMBER;
BEGIN
    v_check_year := MOD(v_year, 4);
    
    IF v_check_year = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Високосний рік');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Не високосний рік');
    END IF;
END;
/
