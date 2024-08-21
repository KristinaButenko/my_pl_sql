CREATE OR REPLACE PACKAGE UTIL AS
    FUNCTION get_job_title (p_employee_id IN NUMBER) RETURN VARCHAR;
    FUNCTION get_dep_name (p_employee_id IN employees.employee_id%TYPE) RETURN VARCHAR2;
    PROCEDURE del_jobs (P_JOB_ID IN JOBS.JOB_ID%TYPE, PO_RESULT OUT VARCHAR2);
END UTIL;
/

CREATE OR REPLACE PACKAGE BODY UTIL AS

FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR IS
    v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT j.job_title
    INTO v_job_title
    FROM employees em
    JOIN jobs j ON em.job_id = j.job_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_job_title;
    
END get_job_title;


FUNCTION get_dep_name (p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE) RETURN VARCHAR2 IS
    v_department_name VARCHAR2(100);
BEGIN
    SELECT dep.department_name
    INTO v_department_name
    FROM departments dep
    JOIN employees em ON dep.department_id = em.department_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_department_name;
        
END get_dep_name;


PROCEDURE DEL_JOBS (P_JOB_ID   IN JOBS.JOB_ID%TYPE,
                    PO_RESULT  OUT VARCHAR2) IS
    v_job_count NUMBER;
BEGIN
    -- Перевірка існування посади
    SELECT COUNT(*)
    INTO v_job_count
    FROM JOBS
    WHERE JOB_ID = P_JOB_ID;

    IF v_job_count = 0 THEN
        PO_RESULT := 'Посада ' || P_JOB_ID || ' не існує';
        RETURN;
    ELSE
        DELETE FROM JOBS WHERE JOB_ID = P_JOB_ID;
        PO_RESULT := 'Посада ' || P_JOB_ID || ' успішно видалена';
    END IF;
    
END DEL_JOBS;
    
END UTIL;
/

DROP FUNCTION get_job_title;
DROP FUNCTION get_dep_name;
DROP PROCEDURE del_jobs;

--- Перевірка
SET SERVEROUTPUT ON;

DECLARE
    v_job_title VARCHAR2(100);
BEGIN
    v_job_title := UTIL.get_job_title(112);
    DBMS_OUTPUT.PUT_LINE('Назва посади: ' || v_job_title);
END;
/
    
    
DECLARE
    v_department_name VARCHAR2(100);
BEGIN
    -- Викликаємо функцію get_dep_name з пакету UTIL для отримання назви департаменту
    v_department_name := UTIL.get_dep_name(101); -- Припустимо, що ідентифікатор співробітника - 101
    -- Виведемо результат
    DBMS_OUTPUT.PUT_LINE('Назва департаменту: ' || v_department_name);
END;
/    
    

DECLARE
    v_result VARCHAR2(100);
BEGIN
    -- Викликаємо процедуру del_jobs з пакету UTIL для видалення посади
    UTIL.del_jobs('AD_PRES', v_result); -- Припустимо, що ми видаляємо посаду з ID 'AD_PRES'
    -- Виведемо результат
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
