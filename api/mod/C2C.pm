=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

use POSIX qw(strftime);
$record_format = 'wav';

sub hangup {
	local $uuid = $form{callbackid} || $form{uuid};
    local ($uuid) = &database_clean_string($uuid, 0, 50);
    
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	
    $output = &runswitchcommand('internal', "uuid_kill $uuid");
	$response{error}          =  0;
    $response{message} = $output;
    
	if ($output =~ /ERR/) {
		$response{error}       =  1;
	}
	

	&print_json_response(%response);   	
}



sub sendcallback {	
	local $ext 	= $form{ext};
	local $domain  = $form{domain} || $HOSTNAME;
	$domain		= $cgi->server_name();
	
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	my %jwt_hash = %{$jwt{jwt_hash}};
	
	unless ($jwt_hash{aud} eq $domain && $jwt_hash{sub} eq $ext.'@'.$domain) {
		$response{error} = 1;
		$response{message} = "sub and aud mismatch : $jwt_hash{aud} vs $domain && $jwt_hash{sub} vs " . $ext.'@'.$domain;
		&print_json_response(%response);
		return;		
	}
	
	
	my $auto_answer = $form{autoanswer}  ? "sip_h_Call-Info=<sip:$domain>;answer-after=0,sip_auto_answer=true" : "";
	my $alert_info  = $form{autoanswer}  ? "sip_h_Alert-Info='Ring Answer'" : '';
	my $dest	= $form{dest};
	
	
	my $uuid   = &genuuid();
	#my $result = `fs_cli -x "originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=8188886666,domain_name=$HOSTNAME,origination_uuid=$uuid}loopback/$ext/$HOSTNAME/XML $dest XML $HOSTNAME"`;
	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}
	
	unless($dest =~ /^\d{10}$/ || $dest =~ /^011\d+$/) {
		print j({error => '1', 'message' => "dest=$query{dest} is invalid", 'actionid' => $query{actionid}});
		exit 0;
	}
	
	local $realdest = $dest;
	$fs_cli = 'fs_cli';
	
	$dest =~ s/^1//g;
	$dest =~ s/\D//g;

	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;
	local  $cid = _get_outbound_callerid($domain, $ext) || $dest;
	warn "cid=$cid";
	
	
	my $cmd = "bgapi originate {ringback=/var/www/vpbx/sounds/usring.wav,ignore_early_media=true,absolute_codec_string=PCMA,fromextension=$ext,origination_caller_id_name=$dest,origination_caller_id_number=$dest,effective_caller_id_number=$dest,effective_caller_id_name=$dest,domain_name=$domain,outbound_caller_id_number=$dest,$alert_info,origination_uuid=$uuid,$auto_answer}user/$ext\@$domain &bridge([origination_caller_id_name=$cid,origination_caller_id_number=$cid,effective_caller_id_number=$cid,effective_caller_id_name=$cid,iscallback=$ext,outbound_caller_id_number=$cid,user_record=all,record_session=true,ringback=/var/www/vpbx/sounds/usring.wav,ring_ready=true]loopback/$dest/$domain)";
	$gateway_uuid = $config{gateway_uuid};
	$accountcode = $config{accountcode};
	
	warn "$cmd\n";
	my $result = &runswitchcommand('internal', $cmd);
	
	sleep 1;
	$response{error} = 0;
	$response{message} = 'ok';
	$response{actionid} = $form{actionid};
	$response{callbackid} = $uuid;
	&print_json_response(%response);	
	
}

sub getcallbackstate {
	my $uuid = $form{uuid} || $form{callbackid};

	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	my %jwt_hash = %{$jwt{jwt_hash}};
	
	my %uuid = ();
	#my $channels = `fs_cli -x "show channels"`;
	my $channels = &runswitchcommand('internal', "show channels");
	my $uuid_found = 0;
	$i = 0;
	$callstate_index = 24;
	for $channel (split /\n/, $channels) {
		if ($i++ == 0) {
			$j = 0;
			for $field_name (split ',', $channel) {
				if ($field_name eq 'callstate') {
					$callstate_index = $j;
					last;
				}
				$j++;
				
			}
			next;
		}
		
		#warn $callstate_index;
		#@f = split ',', $_;
		$f = _records($channel);
		$uuid{$$f[0]} = $$f[$callstate_index];
		if ($$f[0] eq $uuid) {
			$uuid_found = 1;
			$state = $$f[$callstate_index];
			last;
		}
	}
	
	
	warn "$uuid:$state!";
	if ($state eq 'EARLY') {
		$state = 'EXTRING';
	} elsif ($state eq 'RING_WAIT') {
		$state = 'DESTRING';
	} elsif ($state eq 'ACTIVE') {
		$state = 'DESTANSWERED';
	} elsif ($state eq 'HELD') {
		$state = 'HELD';
	} else {
		$state = 'EXTWAIT';
	}
	#	$state = 'HANGUP';
	
	
	warn "$uuid state: $state";
	$response{error} = 0;
	$response{message} = 'ok';
	$response{'actionid'} = $form{actionid};
	$response{state} = $state;
	$response{mute} = 0;
	$response{recording} = 0;
	
	&print_json_response(%response);
}



sub transfer {
	my $uuid = $form{uuid} || $form{callbackid};
	my $dest = $form{dest};
	my $domain		= $cgi->server_name();

	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	my %jwt_hash = %{$jwt{jwt_hash}};
	
	
	if (!$dest) {
		$response{error} = 1;
		$response{message} = 'transfer: failed - dest is null';
		$response{actionid} = $form{actionid};
		
		&print_json_response(%response);
		return;
	}
	
	
	my $leg = '';
	if ($form{direction} eq 'incoming') {
		my $channels =  &runswitchcommand('internal', "show channels");
		my $uuid_found = 0;
		for (split /\n/, $channels) {
			my ($id, $dir) = split ',', $_;
			if ($id eq $uuid) {
				$uuid_found = 1;
				if ($dir eq 'outbound') {
					$leg = '-bleg';
				}
				last;
			}
		}
	} else {
		$leg = '-bleg';
	}
	
	$res =  &runswitchcommand('internal', "uuid_transfer $uuid  $leg $dest XML $domain");
	$response{error} = 0;
	$response{message} = 'transfer: ok';
	$response{actionid} = $form{actionid};
	
	&print_json_response(%response);
}


sub uploadvoicemaildrop {
	my $name = uri_unescape(clean_str($form{name}, 'SQLSAFE'));
	my $format = clean_str($form{format}, 'SQLSAFE') || 'mp3';
	my $ext =  clean_str($form{ext}, 'SQLSAFE') || '';
	my $uuid = &genuuid();
	my $domain		= $cgi->server_name();
	
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	my $basedir = "/var/lib/freewitch/voicemaildrop";
	if (!-d $basedir) {
		system("mkdir -p $basedir");
	}
	
	my $path = "$basedir/$uuid.$format";
	my $ok = $cgi->upload('voicemaildropfile',  $path);
	my $msg = 'ok';
	my $error = 0;
	if (!$ok) {
        $msg =  $cgi->cgi_error();
		$error = 1;
    }
	
	&database_do("insert into v_voicemaildrop (voicemaildrop_uuid, voicemaildrop_name, voicemaildrop_path, domain_name, ext) values ('$uuid', '$name', '$path', '$domain', '$ext')");
	$response{error} = $error;
	$response{message} =  $msg;
	$response{actionid} = $form{actionid};
	&print_json_response(%response);
}

sub listvoicemaildrop {
	my $domain		= $cgi->server_name();
	my $ext =  clean_str($form{ext}, 'SQLSAFE') || '';

	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	%data = &database_select_as_hash("select voicemaildrop_uuid,voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext from v_voicemaildrop where domain_name='$domain' and ext='$ext'",
									 "voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext");

	my $list = [];
	my $found = 0;
	for $k (keys %data) {
		($type) = $data{$k}{voicemaildrop_path} =~ /\.(\w+)$/;
		$filepath = "voicemaildrop/" . $data{$k}{voicemaildrop_uuid} . ".$type";
		push @$list, {id =>$data{$k}{voicemaildrop_uuid}, name => $data{$k}{voicemaildrop_name}, filepath => $filepath};
		$found = 1;
	}
	
	if ($found) {
		$response{error} = 0;
		$response{message} =  $msg;
		$response{actionid} = $form{actionid};
		$response{list} = $list;
		&print_json_response(%response);
	} else {
		$response{error} = 1;
		$response{message} =  'not found';
		$response{actionid} = $form{actionid};
		$response{ip} = $cgi->server_name();
		&print_json_response(%response);
	}
}

sub deletevoicemaildrop {
	my $id = clean_str($form{id}, 'SQLSAFE');
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	%data = &database_select_as_hash("select voicemaildrop_uuid,voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext from v_voicemaildrop wherevoicemaildrop_uuid='$id'",
									 "voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext");
	

	if ($data{$id}{voicemaildrop_uuid}) {
		&database_do("delete from v_voicemaildrop where voicemaildrop_uuid='$id' ");
		$path = $data{$id}{voicemaildrop_path};
		unlink $path;
		$response{error} = 0;
		$response{message} =  $msg;
		$response{actionid} = $form{actionid};

	} else {
		$response{error} = 1;
		$response{message} =  'not found';
		$response{actionid} = $form{actionid};
	}
	&print_json_response(%response);

}

sub getvoicemaildrop {
	my $id = clean_str($form{id}, 'SQLSAFE');
	warn $id;
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	%data = &database_select_as_hash("select voicemaildrop_uuid,voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext from v_voicemaildrop wherevoicemaildrop_uuid='$id'",
									 "voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext");
	

	if ($data{$id}{voicemaildrop_uuid}) {
		$path = $data{$id}{voicemaildrop_path};
		($type) = $path =~ /\.(\w+)$/;
		$filepath = "voicemaildrop/$id.$type";
		$response{error} = 0;
		$response{message} =  'ok';
		$response{filepath} = $filepath;
		$response{name} => $data{$id}{voicemaildrop_name};
		$response{actionid} = $form{actionid};

	} else {
		$response{error} = 1;
		$response{message} =  'not found';
		$response{actionid} = $form{actionid};
	}
	&print_json_response(%response);
}

sub updatevoicemaildrop {
	my $id = clean_str($form{id}, 'SQLSAFE');
	my $name = uri_unescape(clean_str($form{name}, 'SQLSAFE'));
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	&database_do("update  v_voicemaildrop set voicemaildrop_name='$name' where voicemaildrop_uuid='$id' ");
	$response{error} = 0;
	$response{message} =  'ok';
	$response{actionid} = $form{actionid};
	&print_json_response(%response);
}

sub sendvoicemaildrop {
	my $id = clean_str($form{id}, 'SQLSAFE');
	my $callback_uuid = clean_str($form{callback_uuid}, 'SQLSAFE');
	
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	%data = &database_select_as_hash("select voicemaildrop_uuid,voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext from v_voicemaildrop wherevoicemaildrop_uuid='$id'",
									 "voicemaildrop_uuid,voicemaildrop_name,voicemaildrop_path domain_name,ext");
	

	if ($data{$id}{voicemaildrop_uuid}) {
		$path = $data{$id}{voicemaildrop_path};
		($type) = $path =~ /\.(\w+)$/;
		
		$path = $row->{voicemaildrop_path};
		$found = 1;
	}
	
	if ($found) {
		my $channels = `fs_cli -x "show calls"`;
		my $cnt      = 0;
		for my $line (split /\n/, $channels) {
			my @f = split ',', $line;
			if ($f[0] eq $callback_uuid ) { #presence_id && initial_ip_addr
				
				$call_found = 1;
				$b_uuid_index = &_call_field2index('b_uuid');
				$remote_uuid = $f[$b_uuid_index];
			}		
		}
		
		if (!$call_found || !$remote_uuid) {
			$response{error} = 1;
			$response{message} =   "$callback_uuid not found in any call";
			$response{actionid} = $form{actionid};
			&print_json_response(%response);
			return;
		} else {
		
			my $result = `fs_cli -x "uuid_setvar $remote_uuid  voicemaildrop_file $path"`;
			$result = `fs_cli -x "uuid_transfer $remote_uuid play_voicemaildrop XML default"`;
			$response{error} = 0;
			$response{message} =  'ok';
			$response{actionid} = $form{actionid};
			&print_json_response(%response);
			return;
		}
	} else {
		$response{error} = 1;
		$response{message} =   "'not found";
		$response{actionid} = $form{actionid};
		&print_json_response(%response);
		return;
	}
}

sub hold () {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';
		 
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
    %calls = parse_calls();
    if ($direction eq 'inbound') {		
		for  (keys %calls) {
		   $uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}
	} else {
		$uuid_xtt = $calls{$uuid}{b_uuid};	
	}
	
	if (!$uuid_xtt) {
		warn "$uuid not in any calls!";
		&print_api_error_end_exit(160, "$uuid not in any $direction calls");
	}
	
    $output = &runswitchcommand("internal", "uuid_hold toggle $uuid_xtt");
    
    $response{stat}          = 'ok';
    $response{message} = $output;
    &print_json_response(%response);
}

sub unhold() {
    &hold();
}




sub stoprecording() {
	&_dorecording(0);
}

sub startrecording() {
	&_dorecording(1);
}
sub _dorecording() {
	local $mode = shift;
	local $ext = $form{ext} || $form{extension};
	my %jwt = &get_jwt();
	if ($jwt{error}) {
		&print_json_response(%jwt);
		return;
	}
	
	%domain    = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	
	$ext = "$ext\@$domain";
	%raw_calls = &parse_calls();
	for (keys %raw_calls) {
		if ($raw_calls{$_}{presence_id} eq $ext) {
			$found = 1;
			$direction = 'outbound';
		
		}
		
		if ($raw_calls{$_}{b_presence_id} eq $ext) {
			$found = 1;
			$direction = 'inbound';			
		}
		
		
		if ($found) {
			$uuid = $_;
			$time = $raw_calls{$_}{created_epoch};
			
			last;
		}
		
	}
	
	if (!$found) {
		 $response{stat}    = 'fail';
    	 $response{message} = '$ext is not in any bridged call';
	} else {
		if (!$mode) {
			$output = &runswitchcommand('internal', "uuid_record $main_uuid stop all");
		} else {
			
			$year = strftime('%Y', localtime);
			$mon  = strftime('%b', localtime);
			$day  = strftime('%d', localtime);
			
			$recording_file = "/var/lib/freewitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid.$record_format";
			for $i (0..20) {
				$tmp_recording_file = "/var/lib/freewitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid" . ($i ? "_$i":"") . ".$record_format";
				if (!-e $tmp_recording_file) {
					$recording_file = $tmp_recording_file;
					last;
				}			
			}
			
			$output = &runswitchcommand('internal', "uuid_record $uuid start $recording_file");
		}	
		$response{stat}    = 'ok';
		$response{message} = $output;
	}
	
	&print_json_response(%response);

}



sub getuuid() {
    #try best to get call uuid by different condition
}

sub get_bchannel() {
	local $uuid = shift || return;
	%raw_calls = &parse_calls();
	for (keys %raw_calls) {
		if ($_ eq $uuid) {
			return $raw_calls{$_}{b_uuid};
			last;
		}
	}
	
	return;
}

sub _get_dynamic_callerid() {
	local ($ext, $domain_uuid, $code) = @_;
	local $sql = "SELECT 1,dynamic_callerid FROM v_extensions where extension = '$ext' and domain_uuid = '$domain_uuid' limit 1";
	local %data = &database_select_as_hash($sql, "dynamic_callerid");
	
	return unless $data{1}{dynamic_callerid} and $data{1}{dynamic_callerid} eq 'true';
	
	$sql = "SELECT 1, destination_number FROM v_destinations where destination_number like '$code%' and domain_uuid = '$domain_uuid' and destination_enabled='true' limit 1";
	warn $sql;
	%data = &database_select_as_hash($sql, "destination_number");
	return $data{1}{destination_number};
}

sub _get_area_code() {
	local ($number) = @_;
	$number =~ s/^\+?1?//g;
	return substr($number, 0, 3);
}

sub _get_outbound_callerid {
	my $domain = shift;
	my $ext	= shift;
	
	my $sql = "select 1, outbound_caller_id_number from v_extensions where user_context='$domain' and extension='$ext'";
	local %data = &database_select_as_hash($sql, "outbound_caller_id_number");
	return $data{1}{outbound_caller_id_number};
}

sub _records {
	my $line   = shift || return;
	my $limit  = shift;
	my $token  = "saaaazh_";
	my $i      = 0;
	my @temp   = ();
	my @fields = ();
	$line =~ s/\[(.*?)\]/$temp[$i]=$1;$token.$i++/gxe;
	for my $f (split ',', $line) {
			if ($f =~ /$token(\d+)/) {
					$f = $temp[$1];
			}
			push @fields, $f;
	}

	return \@fields;
}
return 1;
