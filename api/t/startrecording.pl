#!/usr/bin/perl

$uuid = shift || 'null';
$direction = shift || 'incoming';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0" "http://222.velantro.net:8080/pbx/index.pl?mod=C2C&action=startrecording&uuid=$uuid"`;
print $out, "\n";