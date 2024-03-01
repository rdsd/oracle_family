begin
    insert into report(report_id, report_name, report_aop_function)
    values(report_seq.nextval, 'members_report', 'sf_print_members_report');
    
    commit;
end;    