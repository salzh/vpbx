#!/usr/bin/perl

$uuid = shift || 'null';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMTk4QDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.HrBpW6BjkJqwrv0BLUGFzqQtj9NdS5J1SlCibWHa8V4" "http://222.velantro.net:8080/pbx/index.pl?mod=C2C&action=transfer&uuid=$uuid&dest=8448008008"`;
print $out, "\n";