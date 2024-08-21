CREATE TABLE interbank_index_ua_history (trade_date DATE,
                                         index_value NUMBER,
                                         special VARCHAR2(1));
                                         
   
CREATE OR REPLACE FUNCTION get_nbu_api_data RETURN CLOB IS
    req  UTL_HTTP.REQ;
    resp UTL_HTTP.RESP;
    buffer VARCHAR2(32767);
    clob_data CLOB;
BEGIN
    req := UTL_HTTP.BEGIN_REQUEST('https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json');
    resp := UTL_HTTP.GET_RESPONSE(req);
    DBMS_LOB.CREATETEMPORARY(clob_data, TRUE);

    BEGIN
        LOOP
            UTL_HTTP.READ_TEXT(resp, buffer, 32767);
            DBMS_LOB.WRITEAPPEND(clob_data, LENGTH(buffer), buffer);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            UTL_HTTP.END_RESPONSE(resp);
    END;

    RETURN clob_data;
END;
/  


CREATE OR REPLACE VIEW interbank_index_ua_v AS
SELECT
    TO_DATE(t.dt, 'DD.MM.YYYY') AS trade_date,
    TO_NUMBER(t.value) AS index_value,
    t.special AS special
FROM
    json_table(
        get_nbu_api_data(),
        '$[*]'
        COLUMNS (
            dt VARCHAR2(10) PATH '$.dt',
            value VARCHAR2(20) PATH '$.value',
            special VARCHAR2(1) PATH '$.special'
        )
    ) t;
    

CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history (trade_date, index_value, special)
    SELECT trade_date, index_value, special FROM interbank_index_ua_v;
    COMMIT;
END;
/


BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'DOWNLOAD_IBANK_INDEX_UA_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN download_ibank_index_ua; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=9; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );
END;
/


---------------------------------

--створюємо таблицю interbank_index_ua_history
CREATE TABLE interbank_index_ua_history (
    dt       DATE,
    id_api   VARCHAR2(100),
    value    NUMBER,
    special  VARCHAR2(100)
);

SELECT *
FROM interbank_index_ua_history;

--створюємо view interbank_index_ua_v на основі виклику API через функцію SYS.GET_NBU
CREATE VIEW interbank_index_ua_v AS
SELECT TO_DATE(tt.dt, 'DD.MM.YYYY') AS DT, tt.id_api, tt.value, tt.special
FROM (SELECT sys.get_nbu(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value
      FROM dual) t
CROSS JOIN json_table(
    json_value, '$[*]'
        COLUMNS(
            dt       VARCHAR2(100) PATH '$.dt',
            id_api   VARCHAR2(100) PATH '$.id_api',
            value    NUMBER        PATH '$.value',
            special  VARCHAR2(100) PATH '$.special'
        )
) tt;

SELECT *
FROM interbank_index_ua_v;

--створюємо PROCEDURE download_ibank_index_ua
CREATE PROCEDURE download_ibank_index_ua AS

BEGIN

    INSERT INTO interbank_index_ua_history (dt, id_api, value, special)
    SELECT dt, id_api, value, special
    FROM interbank_index_ua_v;
    --COMMIT;

END download_ibank_index_ua;
/


BEGIN
    download_ibank_index_ua;
END;

--створюємо scheduler
BEGIN
  sys.dbms_scheduler.create_job(job_name            => 'ibank_index_ua_update',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'begin download_ibank_index_ua(); end;',
                                start_date          => SYSDATE,
                                repeat_interval     => 'FREQ=DAILY; BYHOUR=9',
                                end_date            => NULL,
                                enabled             => TRUE,
                                auto_drop           => FALSE,
                                comments            => 'Оновлення курсу валют');
END;
/
