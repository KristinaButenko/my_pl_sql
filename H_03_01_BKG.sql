create or replace PROCEDURE DEL_JOBS (P_JOB_ID   IN JOBS.JOB_ID%TYPE,
                                      PO_RESULT  OUT VARCHAR2) IS
    v_job_count NUMBER;
BEGIN
    -- Перевірка існування посади
    SELECT COUNT(*)
    INTO v_job_count
    FROM JOBS
    WHERE JOB_ID = P_JOB_ID;

    IF v_job_count = 0 THEN
        -- Якщо посади не існує, записуємо вихідний параметр і припиняємо виконання
        PO_RESULT := 'Посада ' || P_JOB_ID || ' не існує';
        RETURN;
    ELSE
        -- Інакше видаляємо посаду
        DELETE FROM JOBS WHERE JOB_ID = P_JOB_ID;
        -- Записуємо успішне повідомлення у вихідний параметр
        PO_RESULT := 'Посада ' || P_JOB_ID || ' успішно видалена';
    END IF;
    
END DEL_JOBS;
/
