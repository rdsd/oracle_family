CREATE OR REPLACE package family_pkg 
is
    procedure p_remove_duplicate; 
end family_pkg;
/


CREATE OR REPLACE package body family_pkg
as

    procedure p_remove_duplicate
    is
    begin   
    
        delete from family
        where rowid not in (
            select min(rowid)
            from family
            group by first_name, last_name, relation
            );     
        
    end p_remove_duplicate;
end family_pkg;
/
