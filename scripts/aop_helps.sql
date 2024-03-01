select reprot_pkg.sf_get_aop_version from dual;

begin
    insert into report(id, name, aop_template)
    values(report_seq.nextval,'members_report',null);
    
    commit;
end;
/

select report_pkg.sf_print_members_report from dual;

select apex_web_service.make_rest_request('https://www.google.com','GET') from dual;

select aop_plsql_pkg.make_aop_request
    (
        p_aop_url => 'https://api.apexofficeprint.com/',
        p_api_key => 'CC299F8C365E591AE055043998A2C4EE',
        p_aop_mode => 'Development',
        p_json => '[{"filename":"members_report.pdf","data":[{"member":[{"first_name":"Rita","last_name":"mun"}] }]',
        p_template    => l_report_template,
        p_template_type => 'docx',
        p_output_type => 'pdf',
        p_aop_remote_debug => 'No'
    ) 
from dual;                            