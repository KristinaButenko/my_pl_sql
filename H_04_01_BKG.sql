PROCEDURE check_work_time IS
  BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') THEN
       raise_application_error(-20205, 'Ви можете вносити зміни лише у робочі дні');
    END IF;
    
  END check_work_time;
  

PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
                       p_job_title  IN VARCHAR2,
                       p_min_salary IN NUMBER,
                       p_max_salary IN NUMBER DEFAULT NULL,
                       po_err       OUT VARCHAR2) IS
v_max_salary jobs.max_salarY%TYPE;  
salary_err EXCEPTION;
                       
 BEGIN
       -- Виклик процедури перевірки робочих днів
       check_work_time;
       
       IF p_max_salary IS NULL THEN
          v_max_salary := p_min_salary * c_percent_of_min_salary;
       ELSE
          v_max_salary := p_max_salary;
       END IF;
       
 BEGIN
       IF (p_min_salary < gc_min_salary OR p_max_salary < gc_min_salary) THEN
           RAISE salary_err;
       ELSE
           INSERT INTO kristina.jobs(job_id, job_title, min_salary, max_salary)
           VALUES (p_job_id, p_job_title, p_min_salary, v_max_salary);
           COMMIT;
           po_err := 'Посада '||p_job_id||' успішно додана';
       END IF;    
           
 EXCEPTION
       WHEN salary_err THEN
       raise_application_error(-20001, 'Передана зарплата менша за 2000');
       WHEN dup_val_on_index THEN
       raise_application_error(-20002, 'Посада '||p_job_id||' вже існує');
       WHEN OTHERS THEN
       raise_application_error(-20003, 'Виникла помилка при додаванні нової посади. '|| SQLERRM);
       END;

END add_new_jobs;

