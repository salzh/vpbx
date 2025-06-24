#!/usr/bin/perl

$uuid = shift || 'null';
$direction = shift || 'incoming';
$auth = 'eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0" "http://155.mango9.com:8080/pbx/index.pl?mod=C2C&action=hangup&src=100&callerid=7474779513&dests=8882115404"`;
print $out, "\n";