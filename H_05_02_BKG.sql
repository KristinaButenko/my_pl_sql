CREATE OR REPLACE DIRECTORY FILES_FROM_SERVER AS 'C:\files_from_server';

CREATE TABLE external_projects (
  project_id NUMBER,
  project_name VARCHAR2(100),
  department_id NUMBER
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY FILES_FROM_SERVER
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
    (
      project_id CHAR(10),
      project_name CHAR(100),
      department_id CHAR(10)
    )
  )
  LOCATION ('projects.csv')
)
REJECT LIMIT UNLIMITED;


CREATE OR REPLACE VIEW rep_project_dep_v AS
SELECT
  d.department_name,
  COUNT(e.employee_id) AS employee_count,
  COUNT(DISTINCT e.manager_id) AS unique_manager_count,
  SUM(e.salary) AS total_salary
FROM
  external_projects p
  JOIN employees e ON p.department_id = e.department_id
  JOIN departments d ON p.department_id = d.department_id
GROUP BY
  d.department_name;
  
  
DECLARE
  CURSOR cur_report IS
    SELECT department_name, employee_count, unique_manager_count, total_salary
    FROM rep_project_dep_v;
  l_output UTL_FILE.FILE_TYPE;
  l_line VARCHAR2(1000);
BEGIN
  -- Відкрити файл для запису
  l_output := UTL_FILE.FOPEN('FILES_FROM_SERVER', 'projects.csv', 'w');

  -- Записати заголовок у файл
  UTL_FILE.PUT_LINE(l_output, 'Department Name,Employee Count,Unique Manager Count,Total Salary');

  -- Цикл по записах з представлення
  FOR rec IN cur_report LOOP
    l_line := rec.department_name || ',' ||
              rec.employee_count || ',' ||
              rec.unique_manager_count || ',' ||
              rec.total_salary;
    UTL_FILE.PUT_LINE(l_output, l_line);
  END LOOP;

  -- Закрити файл
  UTL_FILE.FCLOSE(l_output);
EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.IS_OPEN(l_output) THEN
      UTL_FILE.FCLOSE(l_output);
    END IF;
    RAISE;
END;
/  
