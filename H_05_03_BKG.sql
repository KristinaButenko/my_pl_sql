CREATE TABLE kristina.employees2 AS 
SELECT * FROM hr.employees;

INSERT INTO kristina.employees2 (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (301, 'Kristina', 'Butenko', 'z.kristina1988@gmail.com', SYSDATE, 'IT_PROG');

CREATE OR REPLACE VIEW department_employee_count AS
SELECT department_id, COUNT(*) AS employee_count
FROM kristina.employees2
GROUP BY department_id;


DECLARE
    v_recipient VARCHAR2(100) := 'z.kristina1988@gmail.com'; 
    v_subject VARCHAR2(100) := 'Звіт про кількість співробітників';
    v_mes VARCHAR2(5000) := 'Content-Type: text/html; charset=utf-8' || UTL_TCP.CRLF; -- Встановлюємо тип контенту як HTML
    
BEGIN
    v_mes := v_mes || '<html><body><table border="1" cellspacing="0" cellpadding="2" rules="GROUPS" frame="HSIDES">' || UTL_TCP.CRLF;
    v_mes := v_mes || '<thead><tr align="left"><th>Ід посади</th><th>Кількість співробітників</th></tr></thead><tbody>' || UTL_TCP.CRLF;
    
    FOR r IN (
        SELECT 
            job_id, COUNT(1) AS cnt_empl
        FROM 
            kristina.employees2
        GROUP BY 
            job_id
        HAVING 
            COUNT(1) > 2
    ) LOOP
        v_mes := v_mes || '<tr align=left><td>' || r.job_id || '</td><td class="center">' || r.cnt_empl || '</td></tr>';
    END LOOP;

    v_mes := v_mes || '</tbody></table></body></html></br></br> З повагою, Крістіна';

    sys.sendmail(
        p_recipient => v_recipient,
        p_subject => v_subject,
        p_message => v_mes || ' ');
END;
/
