PROCEDURE check_work_time IS
  BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') THEN
       raise_application_error(-20205, 'Ви можете вносити зміни лише у робочі дні');
    END IF;
    
  END check_work_time;
  
  
  PROCEDURE del_jobs (p_job_id IN jobs.job_id%TYPE,
                      po_result OUT VARCHAR2) IS
    v_delete_no_data_found EXCEPTION;
  BEGIN
    -- Перевірка робочого дня
    check_work_time;

    BEGIN
      DELETE FROM jobs WHERE job_id = p_job_id;

      IF SQL%ROWCOUNT = 0 THEN
        RAISE v_delete_no_data_found;
      ELSE
        po_result := 'Посада ' || p_job_id || ' успішно видалена';
      END IF;

    EXCEPTION
      WHEN v_delete_no_data_found THEN
        raise_application_error(-20004, 'Посада ' || p_job_id || ' не існує');
      WHEN OTHERS THEN
        raise_application_error(-20003, 'Виникла помилка при видаленні посади. ' || SQLERRM);
    END;
  END del_jobs;
