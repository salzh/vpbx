require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
use Data::Dumper;

$domain_name =  'shy.managedlogix.net';
warn $domain_name;

local %params = (
      destination_type => 'inbound',
      destination_number => '3419504333',
      'dialplan_details[0][dialplan_detail_data]' => "transfer:1000 XML $domain_name",
      destination_description => '3419504333'
);

%hash = &send_request("/pbx/index.pl?action=adddestination&&domain_name=$domain_name", [%params]);
is ($hash{stat}, 'ok', "destination Added: $hash{data}{destination_uuid}: $hash{message}");




%hash5 = &send_request("/pbx/index.pl?action=getdestinationlist" . "&&domain_name=$domain_name");
is($hash5{stat} , 'ok', "Get destination List: $hash5{message}!");

%hash6 = &send_request("/pbx/index.pl?action=getdestination&destination_uuid=$hash{data}{destination_uuid}" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get destination destination_uuid=$hash{data}{destination_uuid}: $hash6{message}!");
print Dumper(\%hash6);

%params = %{$hash6{data}};
$params{'dialplan_details[0][dialplan_detail_data]'} = "transfer:100 XML $domain_name";

$params{destination_description} = "modified";
print Dumper(\%params);

%hash7 = &send_request("/pbx/index.pl?action=editdestination&destination_uuid=$hash{data}{destination_uuid}" . "&&domain_name=$domain_name", [%params]);
is($hash7{stat}, 'ok', "Edit destination destination_uuid=$hash{data}{destination_uuid}: $hash7{message}!");


%hash6 = &send_request("/pbx/index.pl?action=getdestination&destination_uuid=$hash{data}{destination_uuid}" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get destination destination_uuid=$hash{data}{destination_uuid}: $hash6{message}!");
print Dumper(\%hash6);


%hash3 = &send_request("/pbx/index.pl?action=deletedestination&destination_uuid=$hash{data}{destination_uuid}");
is ($hash3{stat}, 'ok', "Delete destination destination_uuid=$hash{data}{destination_uuid}: $hash3{message} !");



