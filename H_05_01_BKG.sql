CREATE OR REPLACE TRIGGER hire_date_update
BEFORE UPDATE OF job_id ON employees
FOR EACH ROW
BEGIN
  IF :OLD.job_id != :NEW.job_id THEN
     :NEW.hire_date := TRUNC(SYSDATE);
  END IF;
END hire_date_update;
/


---Перевірка початкових даних
SELECT employee_id, job_id, hire_date FROM employees WHERE employee_id BETWEEN 100 AND 206;

---Оновлення поля job_id для одного з employee_id
UPDATE employees
SET job_id = 'NEW_JOB'
WHERE employee_id = 103;

---Перевірка оновлених даних для employee_id = 103
SELECT employee_id, job_id, hire_date FROM employees WHERE employee_id = 103;
