require 'T.pm';
use Test::More;
plan tests => 8;

%hash = &send_request('/pbx/index.pl?mod=Tenant&action=addtenant&domain_name=test.managedlogix&domain_description=it is teannt for test,and should be deleted');
is ($hash{stat}, 'ok', "tenant Added Successfully: $hash{data}{domain_uuid}");


%hash2 = &database_select_as_hash("select 1, domain_name from v_domains where domain_uuid='$hash{data}{domain_uuid}'", 'name');
like ($hash2{1}{name}, qr/test\.?/, "tenant - test is added into db");

%hash5 = &send_request("/pbx/index.pl?mod=Tenant&action=gettenantlist");
is($hash5{stat} , 'ok', "Get Tenant List OK!");

%hash6 = &send_request("/pbx/index.pl?mod=Tenant&action=gettenant&domain_uuid=$hash{data}{domain_uuid}");
is($hash6{stat}, 'ok', "Get Tenant domain_uuid=$hash{data}{domain_uuid} OK!");

$descr = 'updated';
%hash7 = &send_request("/pbx/index.pl?mod=Tenant&action=edittenant", [domain_name => 'test.managedlogix', domain_description => $descr,domain_uuid => $hash{data}{domain_uuid}]);

is ($hash7{stat}, 'ok', "Update tenant ok!");

%hash8  = &database_select_as_hash("select 1,domain_uuid,domain_name,domain_description from v_domains where domain_uuid='$hash{data}{domain_uuid}'", 'uuid,name,descr');
is ($hash8{1}{descr}, $descr, 'check editaction ok!');

%hash3 = &send_request("/pbx/index.pl?mod=Tenant&action=deletetenant&domain_uuid=$hash{data}{domain_uuid}");
is ($hash3{stat}, 'ok', "Tenanat - test Deleted Successfully!");

%hash4 = &database_select_as_hash("select 1, domain_uuid from v_domains where domain_uuid='$hash{data}{domain_uuid}}'", 'uuid');
ok (!$hash4{1}{uuid}, "Tenant Deleted in DB OK!");

