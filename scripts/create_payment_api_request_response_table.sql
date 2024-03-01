BEGIN
   EXECUTE IMMEDIATE
    'DROP TABLE  stripe_api_request_response';    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/
    
BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE stripe_api_request_response
    (
        id INTEGER,
        cart_id INTEGER,
        api_type varchar2(120),
        request_clob CLOB,
        request_date date default sysdate,
        payment_intent_id VARCHAR2(2000),
        response_status VARCHAR2(1000),
        response_clob CLOB,
        constraint stripe_api_request_response_pk primary key (id)
    )';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE stripe_api_request_response_seq
        minvalue 1
        maxvalue 999999999999
        start with 1
        increment by 1
        nocache';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/
        
        