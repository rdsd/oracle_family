CREATE OR REPLACE package report_pkg
is
    g_app_aop_url varchar2(200) := 'https://api.apexofficeprint.com/';
    g_app_api_key varchar2(100) := 'CC299F8C365E591AE055043998A2C4EE';
    
    g_app_pdf_mime_type varchar2(100) := 'application/pdf';
    g_app_csv_mime_type varchar2(100) := 'application/csv';
    g_app_xlsx_mime_type varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    g_app_docx_mime_type varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    

    function sf_get_aop_version
    return varchar2;
    
    function sf_print_members_report
    return clob;
    
    procedure sp_report_template_upload(
        i_report_id in integer,
        i_template_name in varchar2
    );
    
    function sf_get_aop_report(i_report_id in integer, i_report_type in varchar2, o_report_log_id out integer)
    return blob;

end report_pkg;
/


CREATE OR REPLACE package body report_pkg
is

    function sf_get_aop_version
    return varchar2
    is
    begin
        return aop_plsql_pkg.c_aop_version;
    end sf_get_aop_version;
    
    function sf_get_json(i_json clob)
    return clob
    is
        l_json clob;
        l_buffered_text varchar2(3000);
        l_amount pls_integer := 2000;
        l_offset pls_integer := 1;
        l_req_len integer;
    begin
        l_req_len := dbms_lob.getlength(i_json);
        
        --we need to split large clobs in chunks so that they can be copied
        if l_req_len <= 4000 then
           l_json :=  i_json;
        else
            while(l_offset < l_req_len)
            loop
                dbms_lob.read(
                    i_json,
                    l_amount,
                    l_offset,
                    l_buffered_text
                );
                
                l_offset := l_offset + l_amount;
                
                dbms_lob.append(l_json,l_buffered_text);
            end loop;    
        end if;
        
        return l_json;
    
    end sf_get_json;
    
    function sf_print_members_report
    return clob
    is   
        l_report_blob       blob;
        l_report_sql        clob;
        l_report_template   blob;
        l_report_json       clob;
        l_report_output_filename varchar2(1000);
    begin
        
        l_report_sql := 'select first_name, last_name from family';    
        
        
        
        l_report_output_filename := 'members_report.pdf';
        l_report_output_filename := 'members_report.docx';
        
        apex_json.initialize_clob_output;
        apex_json.open_array('');
        apex_json.open_object;
        apex_json.write('filename',l_report_output_filename);
        
        apex_json.open_array('data');
        apex_json.open_object;
        
        apex_json.open_array('MEMBERS_IG');
        
        for m in (select first_name, last_name from family)
        loop
            apex_json.open_object;
            apex_json.write('FIRST_NAME',m.first_name);
            apex_json.write('LAST_NAME',m.last_name);
            apex_json.close_object;
        end loop;
        
        apex_json.close_array;
        
        apex_json.close_object;
        apex_json.close_all;
        
        l_report_json := sf_get_json(apex_json.get_clob_output);
        apex_json.free_output; 
        
        debug_pkg.p_debug_memo('here');
        debug_pkg.p_debug_memo(l_report_json);
        dbms_output.put_line(l_report_json);      
        
        debug_pkg.p_debug_memo('end');
        
        --commit;
                            
        return  l_report_json;                   
    exception when others then
        debug_pkg.p_debug_memo(sqlerrm || dbms_utility.format_error_backtrace);
    end sf_print_members_report;
    
    procedure sp_report_template_upload(
        i_report_id in integer,
        i_template_name in varchar2
    )
    is
        l_cnt integer;
        l_template_size integer;
        l_template_mime varchar2(120);
        l_template_blob blob;
        l_new_template_id integer;
    begin
        debug_pkg.p_debug_memo('begin sp_report_template_upload i_report_id: ' || i_report_id, 'delete');
        
        select dbms_lob.getlength(blob_content), mime_type, blob_content
        into l_template_size, l_template_mime, l_template_blob
        from apex_application_temp_files -- wwv_flow_files
        where upper(name) = upper(i_template_name);
        
        debug_pkg.p_debug_memo('l_mime: ' || l_template_mime);
        
        l_new_template_id := report_aop_template_seq.nextval;
        
        insert into report_aop_template(template_id, report_id, template_type, template_blob, template_filename, template_upload_user)
        values(l_new_template_id,i_report_id, l_template_mime, l_template_blob, library_pkg.sf_get_upload_filename(i_template_name), 1);
        
        if l_template_mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' then
            update report
            set pdf_template_id = l_new_template_id,
                docx_template_id = l_new_template_id
            where report_id = i_report_id;
        elsif l_template_mime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.spreadsheet' then
            update report
            set xlsx_template_id = l_new_template_id
            where report_id = i_report_id;
        else
            NULL;
        end if;
            
    end sp_report_template_upload;
    
    function sf_get_aop_report(i_report_id in integer, i_report_type in varchar2, o_report_log_id out integer)
    return blob
    is
        l_report_name varchar2(120);
        l_report_blob        blob;
        l_report_aop_function varchar2(200);
        l_strsql      clob;
        l_report_json  clob;
        l_report_output_filename varchar2(120);
        l_report_template blob;
        l_report_log_id integer;
        l_report_mime_type varchar2(1000);
    begin
        debug_pkg.p_debug_memo('starting print i_report_id: ' || i_report_id, 'delete');
        
        if i_report_type in ('pdf','docx') then
            select r.report_name, report_aop_function, rat.template_blob
            into l_report_name, l_report_aop_function, l_report_template
            from report r
            inner join report_aop_template rat on (r.report_id = rat.report_id and rat.template_id = r.pdf_template_id)
            where r.report_id = i_report_id;
        elsif i_report_type = 'xlsx' then
            select r.report_name, report_aop_function, rat.template_blob
            into l_report_name, l_report_aop_function, l_report_template
            from report r
            inner join report_aop_template rat on (r.report_id = rat.report_id and rat.template_id = r.xlsx_template_id)
            where r.report_id = i_report_id;
        else
             debug_pkg.p_debug_memo('null template', '');
 
        end if;    
        
        if i_report_type in ('pdf') then
             l_report_output_filename := l_report_name || '.pdf';
             l_report_mime_type := g_app_pdf_mime_type;
        elsif  i_report_type in ('docx') then
             l_report_output_filename := l_report_name || '.docx';
             l_report_mime_type := g_app_docx_mime_type;
        elsif  i_report_type in ('xlsx') then
             l_report_output_filename := l_report_name || '.xlsx';
             l_report_mime_type := g_app_xlsx_mime_type;
        else
            null;
        end if;    
            
        debug_pkg.p_debug_memo('radha l_report_output_filename: ' || l_report_output_filename, '');

        l_strsql := 'select report_pkg.' || l_report_aop_function || ' from dual';
        
        execute immediate l_strsql into l_report_json;
        
        debug_pkg.p_debug_memo('l_report_json ' || l_report_json, '');
        
        l_report_blob := aop_plsql_pkg.make_aop_request
                            (
                                p_aop_url => g_app_aop_url,
                                p_api_key => g_app_api_key,
                                p_aop_mode => 'Development',
                                p_json          => l_report_json,
                                --p_json => '[{"filename":"members_report.pdf","data":[{"member":[{"first_name":"Reet","last_name":"d"}] }] }]',
                                p_template    => l_report_template,
                                p_template_type => 'docx',
                               -- p_outout_typee => 'pdf',
                               -- p_template_type => 'xlsx',
                                --p_output_type =>i_report_type,
                                p_output_type => 'docx',
                                p_aop_remote_debug => 'No',
                                p_output_encoding => 'raw'
                            );
                            
        l_report_log_id := report_log_seq.nextval;                    
        
        insert into report_aop_output (output_id, report_id, log_id, report_output_blob, report_output_filename, report_output_mime_type, template_blob)
        values (report_aop_output_seq.nextval, i_report_id, l_report_log_id, l_report_blob, l_report_output_filename, l_report_mime_type, l_report_template);     
        
        o_report_log_id := l_report_log_id;
        
        return l_report_blob;
        
    exception when others then           
        debug_pkg.p_debug_memo(sqlerrm || dbms_utility.format_error_backtrace);
    end sf_get_aop_report; 
end report_pkg;
/
