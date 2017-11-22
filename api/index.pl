#!/usr/bin/perl

=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

BEGIN {
	unshift @INC, './mod';
}



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
	unless ($action eq 'login' || $action eq 'logout' || $action eq 'logincheck') {
		&saldial_http_error_401_if_not_authenticated();
	}
	&$f($form);
} else {
	&print_api_error_end_exit("40","Action:$action Not Define");	
}



