begin
    stripe_pkg.sp_create_test_connected_account;
end; 

begin
    stripe_pkg.sp_accept_terms_by_connected_acct('acct_1O2nUePt1Tpx2vqU');
end;   