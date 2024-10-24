#!/usr/bin/perl

$uuid = shift || 'null';
$direction = shift || 'incoming';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0" "http://155.mango9.com:8080/pbx/index.pl?mod=C2C&action=senddripcallback&ext=100&dest=8448008008"`;
print $out, "\n";