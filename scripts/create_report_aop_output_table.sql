BEGIN
   EXECUTE IMMEDIATE
    'DROP TABLE  report_aop_output';    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/
    
BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE report_aop_output
    (
        output_id INTEGER,
        report_id INTEGER,
        log_id INTEGER,
        report_output_blob blob, 
        report_output_filename varchar2(1000),
        report_output_mime_type varchar2(120),
        report_output_date date default sysdate, 
        template_blob blob,
        report_user_id integer,
        constraint report_aop_output_pk primary key (output_id)
    )';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE report_aop_output_seq
        minvalue 1
        maxvalue 999999999999
        start with 1
        increment by 1
        nocache';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE report_log_seq
        minvalue 1
        maxvalue 999999999999
        start with 1
        increment by 1
        nocache';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/