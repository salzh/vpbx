#!/usr/bin/perl

$uuid = shift || 'null';
$out = `curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.ewogICJzdWIiOiAiMTk5QDIyMi52ZWxhbnRyby5uZXQiLAogICJhdWQiOiAiMjIyLnZlbGFudHJvLm5ldCIsCiAgImV4cCI6IDE2OTQwMjIxMDAKfQo.GM6bMPBYkj8PQ2qIAQ22X6uT8mFBOzGrM0JLESyAGQQ" "http://222.velantro.net:8080/pbx/index.pl?mod=C2C&action=getcallbackstate&callbackuuid=$uuid"`;
print $out, "\n";