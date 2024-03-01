select stripe_pkg.sf_create_payment_intent() from dual;

select * from debug_memo;

select aop.aop_plsql_pkg.make_aop_request from dual;

select cart_seq.nextval from dual;

begin cart_pkg.sp_finish_cart_checkout; commit; end;

