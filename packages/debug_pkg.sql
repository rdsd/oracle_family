create or replace package body debug_pkg
as
    -- procedure to insert memo
    procedure p_debug_memo(i_memo in clob, i_mode in varchar2 default null)
    is
    begin   

        if(i_mode = 'delete') then
            delete from debug_memo;
        end if;

        insert into debug_memo(memo, time_stamp)
        values (i_memo, sysdate);

        commit; --tetstytytyty123

    end p_debug_memo;
end debug_pkg;