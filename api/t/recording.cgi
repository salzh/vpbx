#!/opt/lampp/bin/perl

require "include.cgi";
use File::Copy;

$my_url = "recording.cgi";
#$action = $form{action};


$filename = $form{filename};

#http://10.205.20.38/spool/monitor/20140829-101031-1409278231.239052.wav
&set_database_dsn("dbi:mysql:cccentercdrdb:127.0.0.1:3306");
($y, $mon, $d, $h, $min, $s)   = $filename =~ /(\d{4})(\d{2})(\d{2})\-(\d{2})(\d{2})(\d{2})/;
$sql  = "select 1,src,dst from cdr  where calldate='$y-$mon-$d $h:$min:$s' limit 1";
warn $sql;

%hash = &database_select_as_hash($sql, "src,dst");

if (length($hash{1}{src}) > 4) {
    $dir = 'in';
} else {
    $dir = 'out';
}

$newfile = "$dir-$hash{1}{src}-$hash{1}{dst}-$y$mon$d$h$min$s.wav";
warn $newfile;

#copy("/var/spool/cccenter/monitor/$filename",
#     "/var/spool/cccenter/monitor/$newfile");
$url = "/spool/monitor/$filename";

print "Content-disposition: attachment; filename=$newfile\n";
print "Content-type: audio/x-wav\n";
print "Cache-Control: no-cache, must-revalidate\n";
print "Pragma: no-cache\n";
print "status: 200\n";
print "location: $url\n";
print "\n";
print "<meta http-equiv='refresh' content='0;URL=$url'>";
#print "<script>window.location='$url'</script>";
print "\n";

