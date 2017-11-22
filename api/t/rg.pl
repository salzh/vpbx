require 'T.pm';
use Data::Dumper;
use Test::More;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%params = (
    ring_group_name => 'test_rg1',
    ring_group_extension => 7001,
    ring_group_strategy => 'sequence',
    ring_group_description => 'to be deleted'
);

$param_string = &build_string(%params);

%hash = &send_request("/pbx/index.pl?mod=Ringgroup&action=addringgroup&&$param_string" . "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "rg Added $hash{message}: $hash{data}{ring_group_uuid}");


%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getringgroup&&ring_group_uuid=$hash{data}{ring_group_uuid}");
#print &Hash2Json(%hash2);
%params = %{$hash2{data}};

print Dumper(\%params);


$params{ring_group_description} = 'modified';
$params{"ring_group_destinations[0][destination_number]"} = 1003;

%hash2 = &send_request("/pbx/index.pl?&action=editringgroup&&ring_group_uuid=$hash{data}{ring_group_uuid}", [\%params]);
%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getringgroup&&ring_group_uuid=$hash{data}{ring_group_uuid}");
#print &Hash2Json(%hash2);
%params = %{$hash2{data}};

print Dumper(\%params);



%hash3 = &send_request("/pbx/index.pl?action=deleteringgroup&&ring_group_uuid=$hash{data}{ring_group_uuid}");
is ($hash3{stat}, 'ok', "ring group deleted: $hash{data}{ring_group_uuid}");
