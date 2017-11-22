#!/usr/bin/perl
=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


require "/usr/local/pbx/lib/default.include.pl";	# basic things
require "/usr/local/pbx/lib/tools.database.pl";	# database access
require "/usr/local/pbx/lib/tools.memcache.pl";	# pbx-v2 specific

use URI::Escape;
%STARTEXTENSION =  (
	faxserver => 81000,
	timecondition => 82000
);

$FS_CLI = 'fs_cli';

&default_include_init();

&tools_database_init();
&tools_memcache_init();

use CGI;
use CGI::Carp qw(fatalsToBrowser);
$CGI::POST_MAX = 1024 * 1024 * 640; # 640 mb limit to accept upload. a CD :) We still have limit on apache and sometimes (like prompt api) at mysql dbi network packages and maybe mysql blob fields. On client side, we can have limit at jquery upload api
use Carp; $SIG{ __DIE__ } = sub { Carp::confess( @_ ) };
use URI::Escape qw(uri_escape);
use Data::Dumper;

$app{websession_settings_cookie_title}	= "id";
$app{websession_settings_table_name}	= "pbx_websession";
$app{websession_ttl} = 60*60*24*3;
$cgi	= new CGI;

$cgi->autoEscape(0);
%form	= ();
if (lc($ENV{REQUEST_METHOD}) eq 'get') {
	$qs = $ENV{QUERY_STRING};
	for (split /&&|&/, $qs) {
		($key, $val) = split /=/, $_, 2;
		next if not defined $key;
		$form{$key} = uri_unescape($val);
	}
} else {
	foreach $form_name ($cgi->param) {
		@form_values = $cgi->param($form_name);
		$form_values_count = @form_values;
		$form{$form_name} = ($form_values_count>1) ? join(",",@form_values) : $form_values[0];
	}
}
warn Dumper(\%form);

use JSON; # to install, # sudo cpan JSON
$json_engine	= JSON->new->allow_nonref;

%json 			= &Json2Hash($form{POSTDATA});
# hack for post form with query string.
# by default, in post forms, cgi module ignore query string.
# but becuase we use post form with json, we lost query string data
# to solve this situation, we process query string manual in post forms.
# the result is %form with data from post AND query string at same time
# remember this manual decode is dumb, so play safe in your url
if ( ($ENV{REQUEST_METHOD} eq "POST") && ($ENV{QUERY_STRING} ne "") ) {
	foreach $tmp_block (split(/\&/,$ENV{QUERY_STRING})){
		($tmp_name,$tmp_value) = split(/\=/,$tmp_block);
		unless (exists($form{$tmp_name})) {$form{$tmp_name}=$tmp_value}
	}
}

&websession_attach();
&default_ua_init();

%software = &database_select_as_hash("select 1,software_name,software_version from v_software", 'name,version');
warn "$software{1}{name}-$software{1}{version} started!\n";
#translate 'transfer 10000 XML default.xxx.net to
#extension-10000
#transfer *9910000 XML default.xxx.net to voicemail-10000
#...

sub to_simpledst () {
	$fulldst = shift;
	($number, $xml, $domain) = split /\s+/, $fulldst, 3;
	return '' unless $number && $xml && $domain;
	
	if ($fulldst =~ /^\*99(\d+)$/) {
		return "voicemail-$1-$1";
	}
	
	if ($number =~ /^6\d\d\d$/) {
	    %tc = &database_select_as_hash("select 1,dialplan_number,dialplan_name " .
									   "from v_dialplans,v_domains where v_dialplans.domain_uuid=v_domains.domain_uuid and " .
									   "domain_name='$domain' and app_uuid='4b821450-926b-175a-af93-a03c441818b1' and dialplan_number='$number'",
									   'number,name');
		if ($tc{1}{$number}) {
			return "schedule-$tc{1}{$name}-$number";
		}
	}
	
	if ($number =~ /^7\d\d\d$/) {
		%rg = &database_select_as_hash(
		"select 1,ring_group_name,ring_group_extension from v_ring_groups,v_domains " .
		"where v_ring_groups.domain_uuid=v_domains.domain_uuid and ring_group_extension='$number'",
		'name,extension');
		
		if ($rg{1}{extension}) {
			return "ringgroup-$rg{1}{name}-$number";
		}
	}
	
	return "extension-$number-$number";
}

sub to_fulldst () {
	$simpledst = shift;
	
	($type, $name, $number) = split /\-/, $simpledst, 3;
	
	%domain = &get_domain();
	if ($type eq 'voicemail') {
		return "*99$number XML $domain{name}";
	}
	
	return "$number XML $domain{name}";
}

sub send_esl () {
	($cmd) = @_;
	$output = `$FS_CLI -rx "$cmd"`;
	
	return $output;
}

sub get_enabled () {
	$v = shift;
	if (lc($v) eq 'true') {
		return 'true';
	}
	
	if (lc($v) eq 'false') {
		return 'false';
	}
	
	return 'true';
}

sub getvalue () {
	local ($var_ref, $key, $hash) = @_;
	unless ($form{$key}) {
		if ($hash->{notnull}) {
			return;
		}
		$$var_ref= $hash->{'default'};
	} else {
		$tmpval = substr ($form{$key}, 0, $hash->{maxlen} || 65535);
		$type   = $hash->{type};
		
		if ($type eq 'int') {
			if ($tmpval =~ /\D/) {
				return;
			}
			
			$$var_ref = &clean_int($tmpval);
		}
		
		if ($type eq 'string') {
			#$$var_ref = &database_clean_string($tmpval);
			$$var_ref = $tmpval;
		}
		
		if ($type eq 'bool') {
			$$var_ref = &get_enabled($tmpval);
		}
		
		if ($type eq 'destination') {
			$$var_ref = &database_clean_string($tmpval);
		}
		
		if ($type =~ /^enum:(.+)$/) {
			if (index(",$type,", $tmpval) != -1) {
				$$var_ref = $tmpval;
			} else {
				return;
			}
		}
		
		if ($type eq 'regexp') {
			$$var_ref = $form{$key};
		}
	}
	
	return 1;	
}

sub get_xml_value () {
	($key, $xml) = @_;
	return unless $key;
	($val) = $xml =~ m{<$key>(.*?)</$key>}s;
	return defined $val ? $val : '';
}

sub genuuid () {
	@char = (0..9,'a'..'f');
	$size = int @char;
	$uuid = '';
	for (1..8) {
		$s = int rand $size;
		$uuid .= $char[$s];
	}
	$uuid .= '-';
	for (1..4) {
		$s = int rand $size;
		$uuid .= $char[$s];
	}
	$uuid .= '-';
	for (1..4) {
		$s = int rand $size;
		$uuid .= $char[$s];
	}
	$uuid .= '-';
	for (1..4) {
		$s = int rand $size;
		$uuid .= $char[$s];
	}
	$uuid .= '-';
	
	for (1..12) {
		$s = int rand $size;
		$uuid .= $char[$s];
	}
	
	return $uuid;	
}

1;











# ==============================================
# hi-level functions
# ==============================================
sub print_json_response(){
	local(%data) = @_;
	&cgi_hearder_jason();
	if ($form{callback} ne "") { print "$form{callback} (";}
	print &Hash2Json(%data);
	if ($form{callback} ne "") { print ");";}
}

sub print_html_response(){
	local(%data) = @_;
	&cgi_hearder_html();
	if ($form{callback} ne "") { print "$form{callback} (";}
	print &Hash2Json(%data);
	if ($form{callback} ne "") { print ");";}
}
# ==============================================
# json/response libs
# ==============================================
sub Json2Hash(){
	local($json_plain) = @_;
	local(%json_data);
	my %json_data = ();
	if ($json_plain ne "") {
		my $json_data_reference	= $json_engine->decode($json_plain);
		%json_data			= %{$json_data_reference};
	}
	return %json_data;
}
sub Hash2Json(){
	local(%jason_data) = @_;
	# hack: error.code need be a numeric if value is 0
	#if ( exists($jason_data{error}) ){
	#	if ($jason_data{error}{code} == "0"){
	#		$jason_data{error}{code} = 0;
	#	}
	#}
	my $json_data_reference = \%jason_data;
	my $json_data_text		= $json_engine->encode($json_data_reference);
	return $json_data_text;
}
# ==============================================


#------------------------
# generic cgi library
#------------------------
sub cookie_save($$) {
	local($name,$value,$flags)=@_;
	$flags = ($flags eq "") ? "" : "$flags;";
	print "Set-Cookie: ";
	print $name."=".$value."; path=/; $flags  \n";
	#print $name."=".$value."; path=/; $flags expires=Sun, 26-Jun-2011 00:00:00 GMT; \n";
	#print $name."=".$value."; path=/; $flags expires=Sun, 26-Jun-2011 00:00:00 GMT; domain=$ENV{SERVER_NAME};\n";
	#print ($name,"=",$value,"; path=/; \n");
}
sub cookie_read{
	local(@rawCookies) = split (/; /,$ENV{'HTTP_COOKIE'});
	local(%r);
	foreach(@rawCookies){
		($key, $val) = split (/=/,$_);
		$r{$key} = $val;
	}
	return %r;
}
sub cgi_hearder_html() {
	local($status)=@_;
	$status = &clean_int($status);
	$status = ($status eq "") ? 200 : $status;
	print "Content-type: text/html\n";
	print "Cache-Control: no-cache, must-revalidate\n";
	print "Pragma: no-cache\n";
	print "status: $status\n";
	print "\n";
}
sub cgi_hearder_jason() {
	local($status)=@_;
	#$status = &clean_int($status);
	$status = &clean_int($form{status});
	$status = ($status eq "") ? 200 : $status;
	print "Content-type: application/json\n";
	print "Cache-Control: no-cache, must-revalidate\n";
	print "Pragma: no-cache\n";
	print "status: $status\n";
	#print "status: 500\n";
	print "\n";
}

sub cgi_hearder() {
	local($type)=@_;
	#$status = &clean_int($status);
	$type ||= 'text/text';
	print "Content-type: $type\n";	
	print "Pragma: no-cache\n";
	print "status: 200\n";
	#print "status: 500\n";
	print "\n";
}

sub cgi_redirect {
  local($url) = @_;
  print "Content-type: text/html\n";
  print "Cache-Control: no-cache, must-revalidate\n";
  print "Pragma: no-cache\n";
  print "status: 302\n";
  # we should use 303 http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
  print "location: $url\n";
  print "\n";
  #print "<meta http-equiv='refresh' content='0;URL=$url'>";
  #print "<script>window.location='$url'</script>";
  print "\n";
}
sub cgi_url_encode {
    defined(local $_ = shift) or return "";
    s/([" %&+<=>"])/sprintf '%%%.2X' => ord $1/eg;
    $_
}
sub cgi_url_decode {
  local($trab)=@_;
  $trab=~ tr/+/ /;
  $trab=~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  return $trab;
}
sub cgi_mime_get_from_file(){
	#
	# get mime type. need mimetype, lame sox to find exactly
	#
	local($file) = @_;
	local($tmp,$tmp1,$tmp2);
	local($cmd,$ans);
	#
	# get first by mimetype
	$tmp= `/usr/bin/mimetype -b -M "$file" 2>/dev/null `;
	chomp($tmp);
	#
	# lest get deep check for application/octet-stream
	if ($tmp eq "application/octet-stream") {
		$tmp1="";
		#
		# check mp3
		if ($tmp1 eq "") {
			$tmp2 = `/usr/bin/mpg123 -t -n 10 "$file" 2>&1`;
			if (index($tmp2,"MPEG 1.0 layer III") ne -1) { $tmp1 = "audio/mpeg"} 
			if (index($tmp2,"MPEG 2.0 layer III") ne -1) { $tmp1 = "audio/mpeg"} 
		}
		#
		# check simple (trust extension)
		if ($tmp1 eq "") {
			$tmp1= `/usr/bin/mimetype -b "$file" 2>/dev/null `;
			chomp($tmp1);
		}
		#
		# return then 
		$tmp = ($tmp1 eq "") ? "application/octet-stream" : $tmp1;
	}
	#
	return $tmp;
}
sub cgi_check_ip_flood(){
	if ($ENV{REMOTE_ADDR} eq "127.0.0.1") {return}
	local ($section) = @_;
	local ($ip) = $ENV{REMOTE_ADDR};
	local ($buf,$out,$tmp,$tmp1,$tmp2,%hash,$counter_1,$counter_2,$timestamp);
	$counter_1	= 0;
	$counter_2	= 0;
    %hash = &database_select_as_hash("SELECT 1,1,counter_1,counter_2,unix_timestamp(timestamp) FROM system_ip_flood where ip='$ip'","flag,counter_1,counter_2,timestamp");
	if ($hash{1}{flag} eq 1) {
		$counter_1	= ($hash{1}{counter_1}	ne "") ? $hash{1}{counter_1}: 0;
		$counter_2	= ($hash{1}{counter_2}	ne "") ? $hash{1}{counter_2}: 0;
		$timestamp	= ($hash{1}{timestamp}	ne "") ? $hash{1}{timestamp}: time;
		if ( (time-$timestamp)<(60) 	) {$counter_1++;} else {$counter_1 = 0;}
		if ( (time-$timestamp)<(60*10) 	) {$counter_2++;} else {$counter_2 = 0;}
		&database_do("
			update system_ip_flood set
			counter_1 = '$counter_1',
			counter_2 = '$counter_2',
			timestamp  = now()
			where ip='$ip'
		");
	} else {
		&database_do("
			insert into system_ip_flood
			(ip,     timestamp,  counter_1,   counter_2   ) values
			('$ip',  now(),      '1',         '1'         )
		");
		$counter_1	= 1;
		$counter_2	= 1;
	}
	if ( ($counter_1 > 10) || ($counter_2 > 60) ) {
		print "Content-type: text/html\n";
		print "Cache-Control: no-cache, must-revalidate\n";
  		print "status:503\n";
		print "\n";
		print qq[
		<body bgcolor=#ffffff color=#000000 >
		<font face=verdana,arial size=2>
		<div 						style="padding:50px;">
		<div class=alert_box 		style="width:600px;padding:0px;margin:0px;border:1px solid #f8d322;background-color:#fff18e;">
		<div class=alert_box_inside	style="padding:0px;border:0px;margin-top:4px;margin-left:7px;margin-right:5px;margin-bottom:7px;padding-left:22px;padding-top:0px;background-image:url(/design/icons/forbidden.png);background-repeat:no-repeat;background-position:0 3;">
		<font size=3><b>Warning</b>:</font><br>
		You triggered website surge protection by doing too many requests in a short time.<br>
		Please make a short break, slow down and try again.<br>
		</div>
		</div>
		</div>
		];
		exit;
	}
}
sub cgi_security_is_flood(){
	#
	# read and clean key context
	local($key) = @_;
	local ($buf,$out,$tmp,$tmp1,$tmp2,%hash,$counter_1,$counter_2,$timestamp);
	$key = &trim(substr(&clean_str($key,"MINIMAL","_-. "),0,128));
	#
	# if key context is empty or localhost, we have no flood
	if ($key eq "127.0.0.1") {return false}
	if ($key eq "") {return false}
	#
	# get/update counters for this key context
	$counter_1	= 0;
	$counter_2	= 0;
    %hash = &database_select_as_hash("SELECT 1,1,counter_1,counter_2,unix_timestamp(timestamp) FROM system_security_flood where key='$key'","flag,counter_1,counter_2,timestamp");
	if ($hash{1}{flag} eq 1) {
		$counter_1	= ($hash{1}{counter_1}	ne "") ? $hash{1}{counter_1}: 0;
		$counter_2	= ($hash{1}{counter_2}	ne "") ? $hash{1}{counter_2}: 0;
		$timestamp	= ($hash{1}{timestamp}	ne "") ? $hash{1}{timestamp}: time;
		if ( (time-$timestamp)<(60) 	) {$counter_1++;} else {$counter_1 = 0;}
		if ( (time-$timestamp)<(60*10) 	) {$counter_2++;} else {$counter_2 = 0;}
		&database_do("
			update system_security_flood set
			counter_1 = '$counter_1',
			counter_2 = '$counter_2',
			timestamp  = now()
			where key='$key'
		");
	} else {
		&database_do("
			insert into system_security_flood 
			(key,     timestamp,  counter_1,   counter_2   ) values
			('$key',  now(),      '1',         '1'         )
		");
		$counter_1	= 1;
		$counter_2	= 1;
	}
	#
	# if one of counters is too big, we have a flood
	if ( ($counter_1 > 10) || ($counter_2 > 60) ) {
		return true;
	} else {
		return false;
	}
}





#------------------------
# websession_* helpers
#------------------------
# remember websession maybe refer to noc users and maybe client users base. Depends on cgi configuration
# we recomend use this helpers just to websession control. 
# Use client_* to direct access to client data. we dont have noc_* to direct access to noc account
#
sub websession_session_init()	{
	local(%cookie,$cookie_u,$cookie_k,$tmp_gap);
	#
	# check if this web session is ok.
	#
	# read cookies (k is uid session, u is login_id just to make things easy for api)
	%cookie	= &cookie_read();
	$cookie_k = &clean_int(substr($cookie{$app{session_cookie_k_name}},0,100));
	$cookie_u = &clean_int(substr($cookie{$app{session_cookie_u_name}},0,100));
	$app{session_cookie_u}	= "";
	$app{session_cookie_k}	= "";
	#
	# no cookie, return  0
	if ($cookie_k eq "") {return 0}
	if ($cookie_u eq "") {return 0}
	#
	# if no session, return -31 (some one try to create arbritary session cookie or old old session cookie)
	if (&websession_session_get($cookie_k,"active") ne 1) {return -31}
	#
	# if active ip and session ip mismatch, return -32 (maybe user move to new ip or some one try to spoof session cookie)
	if (&websession_session_get($cookie_k,"ip") ne $ENV{REMOTE_ADDR}) {return -32}
	#
	# if cookie_u mismatch from session, return -33 (a bad spoofed cookie set)
	if (&websession_session_get($cookie_k,"login_id") ne $cookie_u) {return -32}
	#
	# if user dows not exists, logout and return -2
	if (&websession_user_exists($cookie_u) ne 1) { &websession_session_detach($key); return -2 }
	#
	# if timeout, return -1
	if ($app{session_logout_on_timeout} eq 1) {
		$tmp_sec = &websession_session_get($cookie_k,"time_last_access");
		$tmp_sec = ($tmp_sec > 100) ? $tmp_sec : time ;
		$tmp_gap = time - $tmp_sec;
		if ($tmp_gap > $app{session_timeout_seconds}) {
			&websession_session_detach($cookie_k);
			return -1
		}
	}
	#
	# all ok, just touch session:time_last_access
	&websession_session_set($cookie_k,"time_last_access",time);
	$app{session_cookie_u}		= $cookie_u;
	$app{session_cookie_k}		= $cookie_k;
	$app{session_active_user_id}= $cookie_u;
	return 1;
}
sub websession_session_attach()	{
	local($login_id) = @_;
	local($key,%acc,$sql);
	#
	# check if user_id exists
	$sql = "select 1,1,$app{users_col_id} from $app{users_table} where $app{users_col_id} = '$login_id' ";
	%acc = &database_select_as_hash($sql,"flag,id");
	unless ($acc{1}{flag} eq 1) {return 0}
	unless ($acc{1}{id} eq $login_id) {return 0}
	#
	# create uid, create session with uid, add uid at cookie
	if ($cookie{$app{session_cookie_k_name}} ne "") {&websession_session_delete($cookie{$app{session_cookie_k_name}})}
	$key = substr("0000".int(1000*rand()),-4,4) . time . substr("0000".int(1000*rand()),-4,4);
	&websession_session_set($key,"active"			,"1");
	&websession_session_set($key,"login_id"		,$acc{1}{id});
	&websession_session_set($key,"ip"				,$ENV{REMOTE_ADDR});
	&websession_session_set($key,"time_login"		,time);
	&websession_session_set($key,"time_last_access",time);
	#
	# rotate login and last login date
	&websession_user_set($login_id,"time_login_last",&websession_user_get($login_id,"time_login") );
	&websession_user_set($login_id,"time_login",time);
	#
	# set cookie (k is uid session, u is login_id just to make things easy for api)
	&cookie_save($app{session_cookie_k_name},$key);
	&cookie_save($app{session_cookie_u_name},$acc{1}{id});
	#
	# save things and return
	$app{session_cookie_u}	= $acc{1}{id};
	$app{session_cookie_k}	= $key;
	return 1;
}
sub websession_session_detach()	{
	local($key);
	local(%cookie,$key);
	if ($key eq "") {
		%cookie	= &cookie_read();
		$key = $cookie{$app{session_cookie_k_name}};
	}
	$key = &clean_int(substr($key,0,100));
	if ($key eq "") {return}
	$app{session_status} = 0;
	&cookie_save($app{session_cookie_k_name},"");
	&cookie_save($app{session_cookie_u_name},"");
	&websession_session_delete($key);
}
sub websession_session_detach_all_from_login_id()	{
	local($login_id) = @_;
	local($sql,@sessions,$session);
	#
	# clean
	$login_id = &clean_int($login_id);
	#
	# get all websessions ids
	$sql		= "SELECT distinct target FROM $app{session_table} where name='login_id' and value='%s'";
	$sql		= &database_clean_sql($sql,$login_id ); 
	@sessions	= &database_select_as_array($sql);
	#
	# delete all this sessions
	foreach $session (@sessions) {
		$sql		= "delete from $app{session_table} where target='%s'";
		$sql		= &database_clean_sql($sql,$session); 
		&database_do($sql);
	}
}
sub websession_session_get()	{
	local($key,$name) = @_;
	if ($key  eq "") {return ""}
	if ($name eq "") {return ""}
	return &data_get($app{session_table},$key,$name);
}
sub websession_session_set()	{
	local($key,$name,$value) = @_;
	if ($key  eq "") {return ""}
	if ($name eq "") {return ""}
	return &data_set($app{session_table},$key,$name,$value);
}
sub websession_session_delete()	{
	local($key) = @_;
	if ($key  eq "") {return ""}
	foreach (&data_get_names($app{session_table},$key)) {
		##$dbg .= "SESSION_DELETE : delete name ($_) <br>";
		&data_delete($app{session_table},$key,$_);
	}
}
sub websession_activesession_set()	{
	local($name,$value) = @_;
	if ($app{session_status} ne 1)	{return ""}
	if ($app{session_cookie_k} eq "")	{return ""}
	return  &websession_session_set($app{session_cookie_k},$name,$value);
}
sub websession_activesession_get()	{
	local($name) = @_;
	if ($app{session_status} ne 1)		{return ""}
	if ($app{session_cookie_k} eq "")	{return ""}
	return  &websession_session_get($app{session_cookie_k},$name);
}
sub websession_activesession_delete()	{
	local($name) = @_;
	if ($app{session_status} ne 1)		{return ""}
	if ($app{session_cookie_k} eq "")	{return ""}
	return &data_delete($app{session_table},$app{session_cookie_k},$name);
}
sub websession_activeuser_get()	{
	local($name) = @_;
	if ($app{session_status} ne 1)	{return ""}
	if ($app{session_cookie_u} eq "")	{return ""}
	return  &websession_user_get($app{session_cookie_u},$name);
}
sub websession_activeuser_set()	{
	local($name,$value) = @_;
	if ($app{session_status} ne 1)		{return ""}
	if ($app{session_cookie_u} eq "")	{return ""}
	return  &websession_user_set($app{session_cookie_u},$name,$value);
}
sub websession_user_exists()	{
	local($old_acc) = @_;
	local($acc);
	$acc = &clean_int(substr($old_acc,0,250));
	if ($acc eq "") {return 0};
	if ($acc ne $old_acc) {return 0};
	if ( &database_do("select 1 from $app{users_table} where $app{users_col_id} = '$acc'") eq 1) {
		return 1;
	} else {
		return 0;
	}
}
sub websession_user_get()	{
	local($acc,$name) = @_;
	local(%tmp,$acc_id);
	$name	= &clean_str(substr($name,0,250),	"._-","MINIMAL");
	if ($name eq "") {return ""}
	if (&websession_user_exists($acc) ne 1) {return 0}
	return &data_get($app{users_data_table},$acc,$name);
}
sub websession_user_set()	{
	local($acc,$name,$value) = @_;
	local(%tmp,$acc_id);
	$name	= &clean_str(substr($name,0,250),	"._-","MINIMAL");
	if ($name eq "") {return ""}
	if (&websession_user_exists($acc) ne 1) {return 0}
	$value	= substr($value,0,250);
	return &data_set($app{users_data_table},$acc,$name,$value);
}
sub websession_user_password_encode(){
	local($password,$extra_salt) = @_;
	# encoded password need use global system_encode_user_password
	return &system_encode_user_password($password,$extra_salt);
}
sub websession_user_permission_get(){
	local($acc,$name) = @_;
	local(%tmp,$status);
	$name = substr(&trim(&clean_str("$name","TEXT")),0,255);
	if ($name eq "") {return ""}
	if ($acc eq "") {return ""}
	%tmp = &database_select_as_hash("select 1,1,$app{users_col_status} from $app{users_table} where $app{users_col_id} = '$acc' " , "flag,status");
	if ($tmp{1}{flag} ne 1) {return ""}
	if ($tmp{1}{status} eq "") {return ""}
	return &data_get($app{users_status_permission_table},$tmp{1}{status},$name);
}
sub websession_activeuser_permission_get()	{
	local($name) = @_;
	if ($app{session_status} ne 1)	{return ""}
	if ($app{session_cookie_u} eq "")	{return ""}
	return  &websession_user_permission_get($app{session_cookie_u},$name);
}
sub websession_clickchain_set(){
	local ($prefix) = @_;
	local ($buf,$out,$tmp,$tmp1,$tmp2,%hash);
	$out = substr($prefix,0,2).time;
	$tmp = &websession_activesession_get("clickchain");
	&websession_activesession_set("clickchain",substr("$out,$tmp",0,200));
	return $out;
}
sub websession_clickchain_check(){
	local ($prefix,$id) = @_;
	local ($buf,$out,$tmp,$tmp1,$tmp2,%hash,$in);
	$in = substr($prefix,0,2).&clean_int($id);
	if ($in eq "") {return 0}
	$buf = &websession_activesession_get("clickchain");
	$tmp = ",$buf,";
	$tmp1 = ",$in,";$tmp2 = ",";	$tmp =~ s/$tmp1/$tmp2/eg;
	$tmp1 = ",,";	$tmp2 = ",";	$tmp =~ s/$tmp1/$tmp2/eg;
	$tmp1 = ",,";	$tmp2 = ",";	$tmp =~ s/$tmp1/$tmp2/eg;
	&websession_activesession_set("clickchain",substr($tmp,0,200));
	if (index(",$buf,",",$in,") ne -1) {return 1}
	return 0;
}




# ==============================================
# websession_* helpers
# ==============================================
sub websession_attach()	{
	local(%cookie,$session_id,$gap,$wsts,$wsip);
	#
	# read cookies
	if ($app{websession_settings_cookie_title} eq "") {return 0}
	%cookie	= &cookie_read();
	$websession_id = &clean_str(substr($cookie{$app{websession_settings_cookie_title}},0,100));
	$app{websession_id}	= "";
	#
	# no cookie, return  0
	if ($websession_id eq "") {return 0}
	#
	# load
	$wsts = &websession_tools_data_get($websession_id,"ts");
	$wsip = &websession_tools_data_get($websession_id,"ip");
	$app{user_id} = &websession_tools_data_get($websession_id,"user_id");
	$app{pbx_host} = &websession_tools_data_get($websession_id,"pbx_host");
	$app{pbx_cookie} = &websession_tools_data_get($websession_id,"pbx_cookie");
	$app{pbx_host} =~ s/[\t\r\n]//g;
	warn $app{pbx_host};
	&websession_tools_data_set($websession_id,"ts",time);
	warn $websession_id;
	$app{websession_id} = $websession_id;
	#
	# if no session session (ts is our flag)
	if ($wsts eq "") {return 0}
	#
	# if ip is wrong, reject
	if ($wsip ne $ENV{REMOTE_ADDR}) {return 0}
	#
	# check if session exists. ts field is our flag
	$wsts += 0;
	if ($wsts eq 0) { return 0 }
	#
	# check session ttl
	if (exists($app{websession_logout_ttl})) {
		$wsts = ($wsts eq 0) ? time :$ts;
		$gap = time - $ts;
		if ($gap > $app{websession_logout_ttl}) {
			&websession_destroy($websession_id);
			return 0
		}
	}
	#
	# all ok, just touch session

	return 1;
}
sub websession_create()	{
	local(%hash,$sql,@chars,$tmp,$websession_id);
	#
	# destroy previos (if exists)
	&websession_destroy();
	#
	# check basic
	if ($app{websession_settings_table_name} eq "") {return ""}
	#
	# create id
	$websession_id = time;
	my @chars=('A'..'Z','a'..'z','0'..'9');
	foreach (1..32) {$websession_id .= $chars[rand @chars];}
	$websession_id = substr($websession_id,0,32);
	#
	# create session
	$sql = "delete from $app{websession_settings_table_name} where uid='%s' ";
	$sql = &database_escape_sql($sql,$websession_id);
	&database_do($sql);
	&websession_tools_data_set($websession_id,"ts",time);
	&websession_tools_data_set($websession_id,"ip",$ENV{REMOTE_ADDR});
	$app{websession_id} = $websession_id;
	&cookie_save($app{websession_settings_cookie_title},$websession_id);
	#
	# set session
	return $websession_id;
}
sub websession_destroy(){
	local(%hash,$sql,@chars,$tmp,$websession_id);
	#
	# destroy 1
	if ($app{websession_id} ne "") {
		$sql = "delete from $app{websession_settings_table_name} where uid='%s' ";
		$sql = &database_escape_sql($sql,$app{websession_id});
		&database_do($sql);
	}
	#
	# destroy 2
	%cookie	= &cookie_read();
	$websession_id = &clean_str(substr($cookie{$app{websession_settings_cookie_title}},0,100));
	if ( ($websession_id ne "") && ($websession_id ne $app{websession_id}) ) {
		$sql = "delete from $app{websession_settings_table_name} where uid='%s' ";
		$sql = &database_escape_sql($sql,$websession_id);
		&database_do($sql);
	}
	#
	# destroy 3
	$app{websession_id} = "";
	&cookie_save($app{websession_settings_cookie_title},"");
	
	unlink "/tmp/cookie-$app{user_id}.txt";
}

sub websession_is_active()	{
	if ($app{websession_id} eq "") {return 0}
	if (&websession_tools_data_get($app{websession_id},"ts") eq "") { return 0 }
	
	if (!&do_pbx_login_check()) {return 0};
	return 1;
}
sub websession_get()	{
	local($name) = @_;
	if ($app{websession_id} eq "") {return ""}
	return &websession_tools_data_get($app{websession_id},$name);
}
sub websession_set()	{
	local($name,$value) = @_;
	if ($app{websession_id} eq "") {return ""}
	return &websession_tools_data_set($app{websession_id},$name,$value);
}
sub websession_tools_data_get()	{
	local($websession_id,$name) = @_;
	local(%hash,$sql,@chars,$tmp,$value);
	local($memcache_uid,$memcache_raw,$memcache_ttl);
	#
	# check id
	$websession_id = substr(&clean_str($websession_id,"URL"),0,32);
	if ($websession_id eq "") {return ""}
	#
	# check name
	$name = substr(&clean_str($name,"TEXT"),0,32);
	if ($name eq "") {return ""}
	#
	# memcache
	#$memcache_ttl = 60*5;
	#$memcache_uid = "wsdata|$websession_id|$name";
	#$memcache_raw = $memcache->get($memcache_uid);
	#if (defined($memcache_raw)){return $memcache_raw;}
	#
	# read data
	$sql = "select 1,1,value from $app{websession_settings_table_name} where uid='%s' and name='%s' ";
	$sql = &database_escape_sql($sql,$websession_id,$name);
	%hash = &database_select_as_hash($sql,"flag,value");
	$value = ($hash{1}{flag} eq 1) ? $hash{1}{value} : "";
	#
	# return
	return $value
}
sub websession_tools_data_set()	{
	local($websession_id,$name,$value) = @_;
	local(%hash,$sql,@chars,$tmp);
	local($memcache_uid,$memcache_raw,$memcache_ttl);
	#
	# check id
	$websession_id = substr(&clean_str($websession_id,"URL"),0,32);
	if ($websession_id eq "") {return 0}
	#
	# check name
	$name = substr(&clean_str($name,"TEXT"),0,32);
	if ($name eq "") {return 0}
	#
	# check name
	$value = &database_clean_string($value); #substr(&clean_str($value,"TEXT"),0,32);
	#
	# memcache
	#$memcache_ttl = 60*5;
	#$memcache_uid = "wsdata|$websession_id|$name";
	#$memcache->set($memcache_uid,$value,$memcache_ttl); 
	#
	# save data
	$sql = "delete from $app{websession_settings_table_name} where uid='%s' and name='%s' ";
	$sql = &database_escape_sql($sql,$websession_id,$name);
	&database_do($sql);
	$sql = "insert into $app{websession_settings_table_name} (uid,name,value) values ('%s','%s','%s') ";
	$sql = &database_escape_sql($sql,$websession_id,$name,$value);
	&database_do($sql);
	#
	# return
	return 1
}

sub saldial_http_error_401_if_not_authenticated(){
	#
	# todo: check permission from time to time.... We canot trust this user forever. Things change :)
	# a good idea is check saldial_user_is_broadcast and other enable/disable flags
	unless (&websession_is_active()) {
		print "Content-type: text/html\n";
		print "Cache-Control: no-cache, must-revalidate\n";
		print "Pragma: no-cache\n";
		print "status: 401\n";
		print "\n";
		print "Unauthorized\n";
		exit;
	}	
}

sub print_api_error_end_exit(){
	local($code,$message) = @_;
	local %response = ();
	$response{stat}		= "fail";
	$response{code}		= ($code) ? $code : 1;
	$response{message}	= ($message) ? $message : "Error code $response{code}";
	&print_json_response(%response);
	exit;
}
sub print_api_ok_end_exit(){
	local($message) = @_;
	local %response = ();
	$response{stat}		= "ok";
	$response{code}		= "0";
	$response{message}	= ($message) ? $message : "ok";
	&print_json_response(%response);
	exit;
}

sub get_cgi_info () {
	local ($arg) = shift;
	local $v	 = '';
	if ($arg eq 'server_name') {
		$v = $cgi->server_name()
	}
	
	return $v;
}