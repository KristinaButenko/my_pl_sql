DECLARE
    v_date DATE := TO_DATE('30.04.2023', 'DD.MM.YYYY');
    v_day NUMBER;
BEGIN
    v_day := TO_NUMBER(TO_CHAR(v_date, 'DD'));
    
    IF v_date = LAST_DAY(TRUNC(SYSDATE)) THEN
        DBMS_OUTPUT.PUT_LINE('Виплата зарплати');
    ELSIF v_day = 15 THEN
        DBMS_OUTPUT.PUT_LINE('Виплата авансу');
    ELSIF v_day < 15 THEN
        DBMS_OUTPUT.PUT_LINE('Чекаємо на аванс');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Чекаємо на зарплату');
    END IF;
END;
/
