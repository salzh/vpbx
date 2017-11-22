require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%hash = &send_request('/pbx/index.pl?action=addinboundroute&&dialplan_name=in1&&condition_expression_1=888888&&action_1=transfer:10000 XML $domain_name&&description=it is inboundroute for test, should be deleted' . "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "inboundroute Added $hash{message}");


%hash5 = &send_request("/pbx/index.pl?action=getinboundroutelist" . "&&domain_name=$domain_name" );
is($hash5{stat} , 'ok', "Get inboundroute List: $hash5{message}!");


__END__
%hash6 = &send_request("/pbx/index.pl?action=getinboundroute&inbound_uuid=$hash{data}{inbound_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get inboundroute inbound_uuid=$hash{data}{inbound_uuid} $hash6{error}{message}!");



%hash3 = &send_request("/pbx/index.pl?action=deleteinboundroute&&inbound_uuid=$hash{data}{inbound_uuid}". "&&domain_name=$domain_name" );
is ($hash3{error}{code}, '0', "Deleted inboundroute_id=$hash{data}{inbound_uuid} $hash3{error}{message}!");

=pod

$descr = 'updated';
%hash7 = &send_request("/pbx/index.pl?action=editinboundroute&&dialplan_description=$descr&&dialplan_name=tc3&&condition_wday=1-6&&action_1=transfer:*9910002 XML default.ssnvoip.net&&domain_name=$domain_name&&inbound_uuid=$hash{data}{inbound_uuid}");
ok (!$hash7{error}{code}, "Update inboundroute :$hash7{error}{message}-$hash7{data}{inbound_uuid}");




%hash6 = &send_request("/pbx/index.pl?action=getinboundroute&inbound_uuid=$hash7{data}{inbound_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get inboundroute inbound_uuid=$hash7{data}{inbound_uuid} $hash5{error}{message}!");






