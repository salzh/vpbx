require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
$domain_name = 'pbx.fusionpbx.cn';

%hash = &send_request('/api/index.pl?action=addcallblock&&call_block_number=1234&&call_block_action=reject' . "&&domain_name=$domain_name");

is ($hash{error}{code}, '0', "callblock Added $hash{error}{message}: $hash{data}{call_block_uuid}");

$descr = 'updated';
%hash7 = &send_request("/api/index.pl?action=editcallblock&&call_block_number=5678&&call_block_action=reject&&call_block_uuid=$hash{data}{call_block_uuid}". "&&domain_name=$domain_name");

ok (!$hash7{error}{code}, "Update callblock :$hash7{error}{message}-$hash7{data}{call_block_uuid}");
=pod
%hash5 = &send_request("/api/index.pl?action=getcallblocklist" . "&&domain_name=$domain_name" );
ok(!$hash5{error}{code} , "Get callblock List: $hash5{error}{message}!");

%hash6 = &send_request("/api/index.pl?action=getcallblock&call_block_uuid=$hash{data}{call_block_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get callblock call_block_uuid=$hash{data}{call_block_uuid} $hash6{error}{message}!");



%hash3 = &send_request("/api/index.pl?action=deletecallblock&&call_block_uuid=$hash{data}{call_block_uuid}". "&&domain_name=$domain_name" );



is ($hash3{error}{code}, '0', "Deleted callblock_id=$hash{data}{call_block_uuid} $hash3{error}{message}!");

=pod





%hash6 = &send_request("/api/index.pl?action=getcallblock&callblock_uuid=$hash7{data}{callblock_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get callblock callblock_uuid=$hash7{data}{callblock_uuid} $hash5{error}{message}!");






