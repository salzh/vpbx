require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

local %params = (
        gateway => "68db1dc1-ad3e-409d-b998-3337aac82478:main1",
       
        dialplan_expression => '^1234$',
       
		accountcode => 64735557,

        dialplan_enabled => 'true',
		
        dialplan_description => '1234'		
    );
%hash = &send_request("/pbx/index.pl?action=addoutboundroute&&domain_name=$domain_name", [%params]);
is ($hash{stat}, 'ok', "outboundroute Added $hash{message}");


%hash5 = &send_request("/pbx/index.pl?action=getoutboundroutelist" . "&&domain_name=$domain_name" );
is($hash5{stat} , 'ok', "Get outboundroute List: $hash5{message}!");
print Dumper(\%hash5);

__END__
%hash6 = &send_request("/pbx/index.pl?action=getoutboundroute&inbound_uuid=$hash{data}{inbound_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get outboundroute inbound_uuid=$hash{data}{inbound_uuid} $hash6{error}{message}!");



%hash3 = &send_request("/pbx/index.pl?action=deleteoutboundroute&&inbound_uuid=$hash{data}{inbound_uuid}". "&&domain_name=$domain_name" );
is ($hash3{error}{code}, '0', "Deleted outboundroute_id=$hash{data}{inbound_uuid} $hash3{error}{message}!");

=pod

$descr = 'updated';
%hash7 = &send_request("/pbx/index.pl?action=editoutboundroute&&dialplan_description=$descr&&dialplan_name=tc3&&condition_wday=1-6&&action_1=transfer:*9910002 XML default.ssnvoip.net&&domain_name=$domain_name&&inbound_uuid=$hash{data}{inbound_uuid}");
ok (!$hash7{error}{code}, "Update outboundroute :$hash7{error}{message}-$hash7{data}{inbound_uuid}");




%hash6 = &send_request("/pbx/index.pl?action=getoutboundroute&inbound_uuid=$hash7{data}{inbound_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get outboundroute inbound_uuid=$hash7{data}{inbound_uuid} $hash5{error}{message}!");






