require '../include.pl';
require 'T.pm';
use Test::More;
plan tests => 8;
use Data::Dumper;

$domain_name =  'newmentor.managedlogix.net';
warn $domain_name;

%hash = &send_request('/pbx/index.pl?action=addextension&extension=3000&description=it is extension for test, should be deleted'. "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "extension Added: $hash{data}{extension_uuid}: $hash{message}");


%hash5 = &send_request("/pbx/index.pl?action=getextensionlist" . "&&domain_name=$domain_name");
is($hash5{stat} , 'ok', "Get extensionlist List: $hash5{message}!");

%hash6 = &send_request("/pbx/index.pl?action=getextension&extension_uuid=$hash{data}{extension_uuid}" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get extension extension_uuid=$hash{data}{extension_uuid}: $hash6{message}!");
#print Dumper(\%hash6);

%params = %{$hash6{data}};
$params{user_record} = 'all';
$params{password} = 'abc123';
%hash7 = &send_request("/pbx/index.pl?action=editextension&extension_uuid=$hash{data}{extension_uuid}" . "&&domain_name=$domain_name", [%params]);
is($hash7{stat}, 'ok', "Get extension extension_uuid=$hash{data}{extension_uuid}: $hash7{message}!");

%hash6 = &send_request("/pbx/index.pl?action=getextension&extension_uuid=$hash{data}{extension_uuid}" . "&&domain_name=$domain_name");
is($hash6{stat}, 'ok', "Get extension extension_uuid=$hash{data}{extension_uuid}: $hash6{message}!");
print Dumper(\%hash6);

%hash3 = &send_request("/pbx/index.pl?action=deleteextension&extension_uuid=$hash{data}{extension_uuid}");
is ($hash3{stat}, 'ok', "Delete Extension extension_uuid=$hash{data}{extension_uuid}: $hash3{message} !");



