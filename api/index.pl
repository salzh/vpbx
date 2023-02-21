#!/usr/bin/perl

=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

BEGIN {
	unshift @INC, './mod', '/var/www/vpbx/api';
}

use Crypt::JWT qw(encode_jwt decode_jwt);


require "include.pl";

while (<./mod/*.pm>) {
	#warn "load $_\n";
	require $_;
}

$action   = &clean_str(substr($form{action},0,255),"MINIMAL","_");
$action   = "\L$action";
$action ||= "test";

$module   = &clean_str(substr($form{mod},0,255),"MINIMAL","_");
$module ||= 'Misc';


my $f = "main" . "::$action";
warn $f;
if (defined &$f) {
	unless ($action eq 'login' || $action eq 'logout' || $action eq 'logincheck' || $module eq 'C2C') {
		&saldial_http_error_401_if_not_authenticated();
	}
	if ($module eq 'C2C') {
		($jwt_token) = $cgi->http('HTTP_AUTHORIZATION') =~ /Bearer (.+)$/;
		if (!$jwt_token) {
			$response{error} = 1;
			$response{message} = 'jwt key not found!';
			&print_json_response(%response);
			return;		
		}
		
		
		eval{$tmp=decode_jwt(token=>$jwt_token, key => $app{jwt_key});%jwt_hash = %$tmp};
		unless ($jwt_hash{sub} && $jwt_hash{aud}) {
			$response{error} = 1;
			$response{message} = "jwt_token=$jwt_token decode error: $@: $!";
			&print_json_response(%response);
			return;		
		}
	}
	
	&$f($form);
} else {
	&print_api_error_end_exit("40","Action:$action Not Define");	
}



