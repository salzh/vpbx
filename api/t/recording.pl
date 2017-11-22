require 'T.pm';
use Data::Dumper;
use Test::More;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%hash = &send_request(
                        "/pbx/index.pl?action=addrecording",
                        ['recordingfile' => ['/tmp/ivr-accept_reject.wav']],                        
                        'uploadfile'
                    );
is($hash{stat}, 'ok', "addrecording: $hash{data}{recording_uuid}");

%hash2 = &send_request('/pbx/index.pl?action=getrecordinglist');
is($hash2{stat}, 'ok', "getrecordinglist ok!");
print Dumper(\%hash2);

%hash3 = &send_request("/pbx/index.pl?action=deleterecording&&recording_uuid=$hash{data}{recording_uuid}");
is($hash3{stat}, 'ok', "deleterecording: $hash3{message}!");
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


