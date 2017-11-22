require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
use Data::Dumper;

$domain_name =  'shy.managedlogix.net';
warn $domain_name;

local %params = (
        dialplan_name => 'test1',
        condition_field_1 => 'destination_number',
        condition_expression_1 => '^\*97$',
        action_1 => 'hangup',
        dialplan_context => $domain_name,
        dialplan_order => 998,
        dialplan_description => 'added by api',
);

%hash = &send_request("/pbx/index.pl?action=adddialplan&&domain_name=$domain_name", [%params]);
is ($hash{stat}, 'ok', "dialplan Added: $hash{data}{destination_uuid}: $hash{message}");




%hash5 = &send_request("/pbx/index.pl?action=getdialplanlist" . "&&domain_name=$domain_name");
is($hash5{stat} , 'ok', "Get dialplan List: $hash5{message}!");
print Dumper(\%hash5);


$dialplan_uuid = 'dbdbd9fa-696d-4a49-98db-5357828d8d18';
%hash6 = &send_request("/pbx/index.pl?action=getdialplan&dialplan_uuid=$dialplan_uuid" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get dialplan dialplan_uuid=$dialplan_uuid: $hash6{message}!");
print Dumper(\%hash6);

%params = %{$hash6{data}};
delete $params{dialplan_details_list};
$params{'dialplan_details[0][dialplan_detail_order]'} = '1';
$params{'dialplan_details[0][dialplan_detail_type]'}  =  'destination_number';
$params{'dialplan_details[0][dialplan_detail_inline]'} = '',
$params{'dialplan_details[0][dialplan_detail_tag]'} = 'condition';
$params{'dialplan_details[0][dialplan_detail_uuid]'} = '344a13b4-e28b-4c1e-b9d2-a55e8774eae0';
$params{'dialplan_details[0][dialplan_detail_data]'} = '^\\*99$';


$params{'dialplan_details[1][dialplan_detail_order]'} = '5';
$params{'dialplan_details[1][dialplan_detail_type]'}  =  'transfer';
$params{'dialplan_details[1][dialplan_detail_inline]'} = '',
$params{'dialplan_details[1][dialplan_detail_tag]'} = 'action';
$params{'dialplan_details[1][dialplan_detail_uuid]'} = 'fb429409-82d0-43fb-aebd-b28ca2dfa988';
$params{'dialplan_details[1][dialplan_detail_data]'} = "100 XML $domain_name";

$params{dialplan_description} = "modified";
print Dumper(\%params);

%hash7 = &send_request("/pbx/index.pl?action=editdialplan&dialplan_uuid=$dialplan_uuid" . "&&domain_name=$domain_name", [%params]);
is($hash7{stat}, 'ok', "Edit destination destination_uuid=$hash{data}{destination_uuid}: $hash7{message}!");


%hash6 = &send_request("/pbx/index.pl?action=getdialplan&dialplan_uuid=$dialplan_uuid" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get dialplan dialplan_uuid=$dialplan_uuid: $hash6{message}!");
print Dumper(\%hash6);






