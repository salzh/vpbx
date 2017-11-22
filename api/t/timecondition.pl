require 'T.pm';
use Test::More;
use Data::Dumper;

plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%hash = &send_request("/pbx/index.pl?action=addtimecondition&&dialplan_description=it is schedule for test, should be deleted&&dialplan_number=6001&&dialplan_name=tc3&&condition_wday=1-5&&action_1=transfer:100 XML $domain_name" . "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "TimeConditon Added $hash{message}");

%hash5 = &send_request("/pbx/index.pl?action=gettimeconditionlist" . "&&domain_name=$domain_name" );
is($hash5{stat} , 'ok', "Get timecondition List: $hash5{message}!");

print Dumper(\%hash5);

%hash5 = &send_request("/pbx/index.pl?action=getdialplan&&dialplan_uuid='d021c420-7180-4329-985f-aae5c2b8a740'" . "&&domain_name=$domain_name" );
is($hash5{stat} , 'ok', "Get timecondition: $hash5{message}!");

print Dumper(\%hash5);
=pod
$descr = 'updated';
%hash7 = &send_request("/api/index.pl?action=editschedule&&dialplan_description=$descr&&dialplan_name=tc3&&condition_wday=1-6&&action_1=transfer:*9910002 XML default.ssnvoip.net&&domain_name=$domain_name&&schedule_uuid=$hash{data}{schedule_uuid}");
ok (!$hash7{error}{code}, "Update timecondition :$hash7{error}{message}-$hash7{data}{schedule_uuid}");


%hash5 = &send_request("/api/index.pl?action=getschedulelist" . "&&domain_name=$domain_name" );
ok(!$hash5{error}{code} , "Get timecondition List: $hash5{error}{message}!");

%hash6 = &send_request("/api/index.pl?action=getschedule&schedule_uuid=$hash7{data}{schedule_uuid}". "&&domain_name=$domain_name" );
ok(!$hash6{error}{code}, "Get timecondition schedule_uuid=$hash7{data}{schedule_uuid} $hash5{error}{message}!");



%hash3 = &send_request("/api/index.pl?action=deleteschedule&&schedule_uuid=$hash7{data}{schedule_uuid}". "&&domain_name=$domain_name" );
is ($hash3{error}{code}, '0', "Deleted schedule_id=$hash7{data}{schedule_uuid} $hash3{error}{message}!");


