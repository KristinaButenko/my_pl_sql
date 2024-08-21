TYPE rec_region_emp IS RECORD (region_name     VARCHAR2(50),
                                   employee_count  NUMBER);
TYPE tab_region_emp IS TABLE OF rec_region_emp;



FUNCTION get_region_cnt_emp(p_department_id NUMBER DEFAULT NULL) 
RETURN tab_region_emp PIPELINED IS
       v_record rec_region_emp;
CURSOR cur IS

SELECT 
    r.region_name, 
    COUNT(e.employee_id) AS emp_count
FROM 
    HR.regions r
JOIN 
    HR.countries c ON r.region_id = c.region_id
JOIN 
    HR.locations l ON c.country_id = l.country_id
JOIN 
    HR.departments dep ON l.location_id = dep.location_id
JOIN 
    HR.employees e ON dep.department_id = e.department_id
WHERE 
    e.department_id = null OR null IS null
GROUP BY 
    r.region_name;
    
BEGIN
        OPEN cur;
        LOOP
            FETCH cur INTO v_record;
            EXIT WHEN cur%NOTFOUND;
            PIPE ROW(v_record);
        END LOOP;
        CLOSE cur;
        RETURN;

END get_region_cnt_emp;


SELECT * FROM TABLE(util.get_region_cnt_emp);
