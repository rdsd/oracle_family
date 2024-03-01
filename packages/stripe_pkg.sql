create or replace package stripe_pkg
is


end stripe_pkg;

/

create or replace package body stripe_pkg
is


    function sf_create_payment_intent
    return varchar2
    is    
        l_p_name apex_application_global.vc_arr2;
        l_p_value apex_application_global.vc_arr2;
        l_client_secret varchar2(2000);
        l_resp clob;
    begin
        apex_web_service.g_request_headers(1).name := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer' || 'secrek key';
        
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/x-form-url-encoded';
        
        apex_web_service.g_request_headers(1).name := 'indepotencyKey';
        apex_web_service.g_request_headers(1).value := 'uniqueid';
        
        apex_web_service.g_request_headers(1).name := 'stripe-account';
        apex_web_service.g_request_headers(1).value := 'connectedaccountid';
        
        l_p_name(1) := 'amount';
        l_p_value(1) := '100';
        
        l_resp := apex_web_service.make_rest_request(
                        p_url => 'https://api.stripe.com/v1/payment_intents',
                        p_http_method => 'post',
                        p_param_name => l_p_name,
                        p_param_value => l_p_value
                        );
                        
        apex_json.parse(l_resp);
        l_client_secret := apex_json.get_varchar2(p_path=>'client_secret');
        
        return l_client_secret;
    end sf_create_payment_intent;

end stripe_pkg;

/