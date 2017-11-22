use HTTP::Request::Common;
use LWP::UserAgent;
use HTTP::Cookies;
require "/usr/local/pbx/lib/tools.database.pl";	# database access

use JSON; # to install, # sudo cpan JSON
$json_engine	= JSON->new->allow_nonref;


&default_include_init();
&default_ua_init();
&tools_database_init();

sub default_include_init(){
	open(IN,"/etc/pbx-v2.cfg"); while (<IN>) { chomp($_); ($tmp1,$tmp2) = split(/\=/,$_,2); $app{&trim("\L$tmp1")}=$tmp2; } close(IN);
	$app{app_root}			= $app{app_root} || "/usr/local/pbx-v2/";
	##$app{host_name}			= $app{host_name} || "dev-desktop";# we need remove all calls to this variable. we need use server_id instead
	$app{server_id}			= $app{server_id} || "1";
	$app{database_dsn}		= $app{database_dsn} || "dbi:mysql:fusionpbx:localhost";
	$app{database_user}		= $app{database_user} || "root";
	$app{database_password}	= $app{database_password} || "root";
	$host_name				= $app{host_name};
	$app{pbx_host}		= $app{pbx_host}     || '';
	$app{pbx_hostname}	= $app{pbx_hostname} || '';
	$app{base_domain}	= $app{base_domain}	 || '';
	$app{log_level}		= $app{log_level} 	 || 4;
	$app{log_file}		= '/tmp/pbx.log';
	open LOG, ">> $app{log_file}";

}

sub default_ua_init() {
	$global_useragent  = LWP::UserAgent->new('agent' => "Salzh PBX");
    $time = time;
	$file = '/tmp/cookie-' . $time . '.txt';
	
	warn "set cookie to $file";
	$jar = HTTP::Cookies->new(
		file => "$file",
		autosave => 1,
	);
    
    $global_useragent->cookie_jar($jar);
	#$global_headers{Cookie} = $app{pbx_cookie};
    
    %login = &do_login();
    if ($login{stat} ne 'ok') {
        die "fail to login pbx api";
    }
	return 1;
}

sub send_request () {
    local ($path, $data, $is_upload_file) = @_;

    #warn $path;
    $result = &post_data('urlpath' => $path, data => defined $data ? $data : [], is_upload_file => $is_upload_file);
    return &Json2Hash($result->content);    
}


sub do_login() {
    local $path = "/pbx/index.pl?mod=Login&action=login&user=$app{test_user}&&password=$app{test_password}&domain=$app{test_domain}";
    $result  = &post_data('urlpath' => $path);
    return &Json2Hash($result->content);
}


sub post_data () {
	local %data = @_;
	if ($data{domain_uuid} ||  $data{domain_name} ) {
		$s = &change_domain($data{domain_uuid}, $data{domain_name});
		if (!$s) {
			&log_debug(4, "Error: fail to change to $data{domain}|$data{domain_uuid}!\n");
			return;
		}
	}
	$url = "http://$app{pbx_host}" . $data{urlpath};
	#warn $url;
	#warn @{$data{data}};
	if (@{$data{data}}) {
		if ($data{is_upload_file}) {
			$result = $global_useragent -> request(
				POST $url,
				%global_headers,
				Content_Type => 'form-data',
				Content => $data{data}
			);
		} else {
			$result = $global_useragent -> request(
				POST $url,
				%global_headers,
				Content => $data{data}
			);
		}
	} else {
		$result = $global_useragent -> request(
			GET $url,
			%global_headers
		);
	}
	
	if ($data{reload}) {
		$global_useragent -> request(
			POST $url,
			%global_headers,
			Content => []
		);	
	}
	
	return $result;
}

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

sub trim {
     my @out = @_;
     for (@out) {
         s/^\s+//;
         s/\s+$//;
     }
     return wantarray ? @out : $out[0];
}

sub build_string() {
    local %params = @_;
    $string = '';
    for (keys %params) {
        $string .= '&' if $string;
        $string .= "$_=$params{$_}";
    }
    
    return $string;
}
return 1;
