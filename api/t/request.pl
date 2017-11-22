use HTTP::Request::Common;
use LWP::UserAgent;
use Data::Dumper;
$global_useragent  = LWP::UserAgent->new('agent' => "Salzh PBX");
use HTTP::Cookies;

$file = '/tmp/cookie-123.txt';
	
	warn "set cookie to $file";
	$jar = HTTP::Cookies->new(
		file => "$file",
		#autosave => 1,
        igonre_discard => 1
	);

	$global_useragent->cookie_jar({file => $file, autosave => 1});
$check_url = "http://shy.velantro.net/core/user_settings/user_dashboard.php";
#$check_url = "http://baidu.com";
warn $check_url;
$res = $global_useragent->request(GET $check_url);
print $res->header('Set-Cookie');
#print Dumper($res)
print join',', $res->header_field_names;
$jar->save();
print `cat "$file"`;

