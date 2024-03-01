BEGIN
   EXECUTE IMMEDIATE
    'DROP TABLE  cart';    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/
    
BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE cart
    (
        id INTEGER,
        creation_date date default sysdate,
        update_date date,
        payment_amount NUMBER,
        constraint cart_pk primary key (id)
    )';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE cart_seq
        minvalue 1
        maxvalue 999999999999
        start with 1
        increment by 1
        nocache';
    
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/