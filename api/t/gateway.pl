require 'T.pm';
use Test::More;
use Data::Dumper;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%hash = &send_request('/pbx/index.pl?mod=Gateway&action=addgateway&&gateway=g1&&username=none&&password=none&&proxy=127.0.0.1&&description=it is gateway for test, should be deleted' . "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "gateway Added $hash{message}: $hash{data}{gateway_uuid}");

%hash2 = &send_request("/pbx/index.pl?mod=Misc&&action=runswitchcommand&&cmd=sofia status gateway $hash{data}{gateway_uuid}");
unlike ($hash2{data}, qr/invalid/, "gateway test is ok");



%hash6 = &send_request("/pbx/index.pl?mod=Gateway&action=getgateway&gateway_uuid=$hash{data}{gateway_uuid}". "&&domain_name=$domain_name" );
is ($hash6{stat}, 'ok', "Get gateway gateway_uuid=$hash{data}{gateway_uuid} $hash6{message}!");


%hash2 = &send_request("/pbx/index.pl?mod=Gateway&&action=startgateway&a=stop&&gateway_uuid=$hash{data}{gateway_uuid}");
%hash2 = &send_request("/pbx/index.pl?mod=Gateway&&action=startgateway&a=start&&gateway_uuid=$hash{data}{gateway_uuid}");

$descr = 'updated';
%hash7 = &send_request("/pbx/index.pl?mod=Gateway&action=editgateway&&gateway=g1&&username=none&&password=none&&proxy=127.0.0.2&&description=$descr&&gateway_uuid=$hash{data}{gateway_uuid}");
is ($hash7{stat}, 'ok', "Update gateway :$hash7{message}-$hash{data}{gateway_uuid}");

%hash2 = &send_request("/pbx/index.pl?mod=Gateway&&action=startgateway&a=stop&&gateway_uuid=$hash{data}{gateway_uuid}");
%hash2 = &send_request("/pbx/index.pl?mod=Gateway&&action=startgateway&a=start&&gateway_uuid=$hash{data}{gateway_uuid}");

%hash2 = &send_request("/pbx/index.pl?mod=Misc&&action=runswitchcommand&&cmd=sofia status gateway $hash{data}{gateway_uuid}");
warn $hash2{data};


%hash2 = &send_request("/pbx/index.pl?action=getgatewaylist");
print Dumper(\%hash2);
%hash3 = &send_request("/pbx/index.pl?mod=Gateway&action=deletegateway&&gateway_uuid=$hash{data}{gateway_uuid}". "&&domain_name=$domain_name" );
is ($hash3{stat}, 'ok', "Deleted gateway_id=$hash{data}{gateway_uuid} $hash3{message}!");









