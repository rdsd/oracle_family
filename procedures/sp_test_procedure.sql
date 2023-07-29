CREATE OR REPLACE PROCEDURE sp_test_procedure
IS
    l_name VARCHAR2(120);
BEGIN
    
    l_name := 'rert';
    
    dbms_output.put_line('Name: ' || l_name);--hjhjhh
END sp_test_procedure;