BEGIN
   EXECUTE IMMEDIATE
    'DROP TABLE  report';    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/
    
BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE report
    (
        report_id INTEGER,
        report_name varchar2(1000),
        creation_date date default sysdate,
        report_sql clob,
        report_aop_function varchar2(200),
        pdf_template_id integer,
        xlsx_template_id integer,
        docx_template_id integer, 
        constraint report_pk primary key (id)
    )';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE report_seq
        minvalue 1
        maxvalue 999999999999
        start with 1
        increment by 1
        nocache';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/