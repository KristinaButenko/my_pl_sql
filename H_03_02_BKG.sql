CREATE OR REPLACE FUNCTION get_dep_name (p_employee_id IN employees.employee_id%TYPE) RETURN VARCHAR2 IS
    v_department_name VARCHAR2(100);
BEGIN
    -- Отримуємо назву департаменту
    SELECT dep.department_name
    INTO v_department_name
    FROM departments dep
    JOIN employees em ON dep.department_id = em.department_id
    WHERE em.employee_id = p_employee_id;

    -- Повертаємо назву департаменту
    RETURN v_department_name;
        
END get_dep_name;
/


SELECT 
    em.employee_id,
    em.first_name,
    em.last_name,
    get_job_title(employee_id) as job_title,
    get_dep_name(department_id) as department_name
FROM 
    employees em;
