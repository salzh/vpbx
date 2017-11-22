require 'T.pm';
use Data::Dumper;
use Test::More;
plan tests => 8;
$domain_name = 'shy.managedlogix.net';

%params = (
    ivr_menu_name => 'test_ivr1',
    ivr_menu_extension => 8001,
    ivr_menu_greet_long => 'ivr/accept-accept_reject.wav',
    ivr_menu_description => 'to be deleted'
);

$param_string = &build_string(%params);

%hash = &send_request("/pbx/index.pl?mod=Ivr&action=addivr&&$param_string" . "&&domain_name=$domain_name");
is ($hash{stat}, 'ok', "ivr Added $hash{message}: $hash{data}{ivr_menu_uuid}");

%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getivr&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}");
is ($hash2{data}{ivr_menu_greet_long}, 'ivr/accept-accept_reject.wav', "get ivr: $hash{message}");
#print &Hash2Json(%hash2);
%params = %{$hash2{data}};

$i = 0;
for $o (@{$hash2{data}{options_list}}) {
   %params = (%params, %$o);
   $i++;
}

delete $params{options_list};

$params{"ivr_menu_options[$i][ivr_menu_option_digits]"} = 1;
$params{"ivr_menu_options[$i][ivr_menu_option_param]"}  = "menu-exec-app:info";
$params{"ivr_menu_options[$i][ivr_menu_option_order]"}  = "000";
$params{"ivr_menu_options[$i][ivr_menu_option_description]"}  = "info";

$i++;

$params{"ivr_menu_options[$i][ivr_menu_option_digits]"} = 1;
$params{"ivr_menu_options[$i][ivr_menu_option_param]"}  = "menu-exec-app:hangup";
$params{"ivr_menu_options[$i][ivr_menu_option_order]"}  = "001";
$params{"ivr_menu_options[$i][ivr_menu_option_description]"}  = "hangup";
#$params{"ivr_menu_options[$i][ivr_menu_option_uuid]"}  = $_;
#print Dumper(\%params);
$param_string = &build_string(%params);

%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=editivr&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}", [\%params]);
is ($hash{stat}, 'ok', "Ivr Edit $hash{message}: $hash2{message}");

%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getivr&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}");
is ($hash2{data}{options_list}[$i]{"ivr_menu_options[$i][ivr_menu_option_param]"}, 'hangup', "get ivr after edit: $hash{message}");

$ivr_menu_option_uuid = $hash2{data}{options_list}[$i]{"ivr_menu_options[$i][ivr_menu_option_uuid]"};
#deleteivroption
%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=deleteivroption&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}&&ivr_menu_option_uuid=$ivr_menu_option_uuid");
is ($hash{stat}, 'ok', "Ivr Delete Option $hash2{message}");

%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getivr&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}");
isnt ($hash2{data}{options_list}[$i]{"ivr_menu_options[$i][ivr_menu_option_param]"}, 'hangup', "get ivr after deleteoption: $hash{message}");

%hash2 = &send_request("/pbx/index.pl?mod=Ivr&action=getivrlist");
ok ($hash2{data}{ivr_list},  "getivrlist: $hash{message}");
#print Dumper(\%hash2);


%hash3 = &send_request("/pbx/index.pl?mod=Ivr&action=deleteivr&&ivr_menu_uuid=$hash{data}{ivr_menu_uuid}");
is ($hash3{stat}, 'ok', "ivr deleted: $hash{data}{ivr_menu_uuid}");
