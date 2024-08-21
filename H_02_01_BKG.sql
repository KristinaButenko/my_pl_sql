DECLARE
  v_employee_id hr.employees.employee_id%TYPE := 110;
  v_job_id hr.employees.job_id%TYPE;
  v_job_title hr.jobs.job_title%TYPE;
BEGIN
  -- Знаходимо ід посади для заданого employee_id
  SELECT job_id INTO v_job_id
  FROM hr.employees
  WHERE employee_id = v_employee_id;

  -- Знаходимо назву посади для отриманого job_id
  SELECT job_title INTO v_job_title
  FROM hr.jobs
  WHERE job_id = v_job_id;

  -- Виводимо інформацію на екран
  DBMS_OUTPUT.PUT_LINE('Посада співробітника: ' || v_employee_id || ' - ' || v_job_title);
END;
/
