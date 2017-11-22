require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
$domain_name = 'pbx.fusionpbx.cn';

%hash = &send_request('/api/index.pl?action=addhotdesking&&extension_uuid=630909a9-7cf3-4e7c-b878-b8feb4ce2d7d&&unique_id=1234343' . "&&domain_name=$domain_name");

is ($hash{error}{code}, '0', "hotdesking Added $hash{error}{message}: $hash{data}{extension_uuid}");

$descr = 'updated';
%hash7 = &send_request("/api/index.pl?action=edithotdesking&&extension_uuid=630909a9-7cf3-4e7c-b878-b8feb4ce2d7d&&unique_id=1234343&&vm_password=5678" . "&&domain_name=$domain_name");


ok (!$hash7{error}{code}, "Update hotdesking :$hash7{error}{message}-$hash7{data}{extension_uuid}");
=pod
%hash5 = &send_request("/api/index.pl?action=gethotdeskinglist" . "&&domain_name=$domain_name" );
ok(!$hash5{error}{code} , "Get hotdesking List: $hash5{error}{message}!");

%hash6 = &send_request("/api/index.pl?action=gethotdesking&hotdesking_uuid=$hash{data}{hotdesking_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get hotdesking hotdesking_uuid=$hash{data}{hotdesking_uuid} $hash6{error}{message}!");



%hash3 = &send_request("/api/index.pl?action=deletehotdesking&&hotdesking_uuid=$hash{data}{hotdesking_uuid}". "&&domain_name=$domain_name" );



is ($hash3{error}{code}, '0', "Deleted hotdesking_id=$hash{data}{hotdesking_uuid} $hash3{error}{message}!");

=pod





%hash6 = &send_request("/api/index.pl?action=gethotdesking&hotdesking_uuid=$hash7{data}{hotdesking_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get hotdesking hotdesking_uuid=$hash7{data}{hotdesking_uuid} $hash5{error}{message}!");






