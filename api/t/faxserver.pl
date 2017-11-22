require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
$domain_name = 'pbx.fusionpbx.cn';

%hash = &send_request('/api/index.pl?action=addfaxserver&&fax_name=fax&&fax_description=it is faxserver for test, should be deleted' . "&&domain_name=$domain_name");
is ($hash{error}{code}, '0', "faxserver Added $hash{error}{message}: $hash{data}{fax_uuid}");

%hash5 = &send_request("/api/index.pl?action=getfaxserverlist" . "&&domain_name=$domain_name" );
ok(!$hash5{error}{code} , "Get faxserver List: $hash5{error}{message}!");

%hash6 = &send_request("/api/index.pl?action=getfaxserver&fax_uuid=$hash{data}{fax_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get faxserver fax_uuid=$hash{data}{fax_uuid} $hash6{error}{message}!");



%hash3 = &send_request("/api/index.pl?action=deletefaxserver&&fax_uuid=$hash{data}{fax_uuid}". "&&domain_name=$domain_name" );



is ($hash3{error}{code}, '0', "Deleted faxserver_id=$hash{data}{fax_uuid} $hash3{error}{message}!");

=pod
$descr = 'updated';
%hash7 = &send_request("/api/index.pl?action=editfaxserver&&dialplan_description=$descr&&dialplan_name=tc3&&condition_wday=1-6&&action_1=transfer:*9910002 XML default.ssnvoip.net&&domain_name=$domain_name&&faxserver_uuid=$hash{data}{faxserver_uuid}");
ok (!$hash7{error}{code}, "Update faxserver :$hash7{error}{message}-$hash7{data}{faxserver_uuid}");




%hash6 = &send_request("/api/index.pl?action=getfaxserver&faxserver_uuid=$hash7{data}{faxserver_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get faxserver faxserver_uuid=$hash7{data}{faxserver_uuid} $hash5{error}{message}!");






