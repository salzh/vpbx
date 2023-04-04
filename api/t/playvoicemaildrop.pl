#!/usr/bin/perl

$uuid = shift || 'null';
$direction = shift || 'incoming';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMzAxQDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.Nt9ccxmvwhmth2R_sXMyP0g1rbaW-59y8JjIzUNHdt0" "http://222.velantro.net:8080/pbx/index.pl?mod=C2C&action=sendvoicemaildrop&callbackid=$uuid&id=7e8e7771-82af-b7cd-c694-564fb9f04125"`;
print $out, "\n";