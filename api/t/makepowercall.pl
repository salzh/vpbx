#!/usr/bin/perl
use Crypt::JWT qw(encode_jwt decode_jwt);
use Data::Dumper;
$exp = time+3600*24;
$domain = '155.mango9.com';
$data =<<D;
{
  "sub": "100\@$domain",
  "aud": "$domain",
  "exp": $exp
}
D

$key = 'fkkE5ferD1XLed';
my $auth = encode_jwt(payload=>$data, alg=>'HS256', key=>$key);
warn $auth;

print $auth, "\n";
my $data1 = decode_jwt(token=>$auth, key=>$key);
print Data::Dumper::Dumper($data1);

#$auth = 'eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0';
$out = `curl -H "Authorization: Bearer $auth" "http://$domain:8080/pbx/index.pl?mod=C2C&action=makepowercall&src=100&callerid=7474779513&dests=2124441005,8882115404,8189625505"`;
print $out, "\n";