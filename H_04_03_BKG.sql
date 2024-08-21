PROCEDURE to_log(p_appl_proc IN VARCHAR2, 
                 p_message IN VARCHAR2) IS
  PRAGMA autonomous_transaction;
  BEGIN
      INSERT INTO logs(id, appl_proc, message)
      VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
      COMMIT;
  END to_log;


FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER IS
    v_sum_price_sales NUMBER;
    v_sql_stmt VARCHAR2(2000);
  BEGIN
    -- Перевірка значення параметра p_table
    IF p_table NOT IN ('products', 'products_old') THEN
      to_log('get_sum_price_sales', 'Неприпустиме значення! Очікується products або products_old');
      raise_application_error(-20001, 'Неприпустиме значення! Очікується products або products_old');
    END IF;

    -- Формування динамічного SQL запиту
    v_sql_stmt := 'SELECT SUM(price_sales) FROM ' || p_table;

    -- Виконання динамічного SQL запиту
    EXECUTE IMMEDIATE v_sql_stmt INTO v_sum_price_sales;

    -- Повернення результату
    RETURN v_sum_price_sales;

  EXCEPTION
    WHEN OTHERS THEN
      -- Запис в лог про помилку при виконанні запиту
      to_log('get_sum_price_sales', 'Помилка при виконанні запиту: ' || SQLERRM);
      RAISE;
  END get_sum_price_sales;
