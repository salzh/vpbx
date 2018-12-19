=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

use POSIX qw(strftime);
$record_format = 'wav';
sub addincomingbycallerid () {
	local %params = (
        dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        condition_field_1 => {type => 'string', maxlen => 20, notnull => 0, default => 'caller_id_number'},
        condition_expression_1 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        condition_field_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        condition_expression_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        action_1 => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        action_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        limit => {type => 'int', maxlen => 4, notnull => 0, default =>''},
        public_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},	
    );
	 
	%response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if ($response{stat} ne 'fail') {
       for $k (keys %params) {
            $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{stat}		= "fail";
                $response{message}	= $k. &_(" not valid");
            }
       }
    }	
	
	if (!$response{stat} ne 'fail') {
        $post_add{dialplan_description} = "caller_id_number-$post_add{condition_expression_1}";
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/dialplan_inbound/dialplan_inbound_add.php?action=advanced',
			'reload'      => 1,
			'data'        => [%post_add]);
		#warn $result->header("Location");
		$location = $result->header("Location");
		($uuid) = $location =~ /app_uuid=(.+)$/;
		if (!$uuid) {
			$response{stat}		= "fail";
            $response{message}	= $k. &_(" not valid");
		} else {
            
            %hash = &database_select_as_hash(
                            "select
                                1,dialplan_uuid
                            where
                                dialplan_description='$post_add{dialplan_description}' and
                                app_uuid='c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4'",
                            "dialplan_uuid");
            
			$response{stat}		            = "ok";
            $response{data}{dialplan_uuid} = $hash{1}{dialplan_uuid};
		}       
	}
	
	&print_json_response(%response);   
}

sub hangup {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    
    $output = &runswitchcommand('internal', "uuid_kill $uuid"
								);
    
    $response{stat}          = 'ok';
    $response{message} = $output;
	&print_json_response(%response);   	
}

sub blindtransfer {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local ($dest) = &database_clean_string($form{dest});
    local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';
    
	%calls = parse_calls();
    if ($direction eq 'inbound') {		
		for  (keys %calls) {
		   $uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}
	} else {
		$uuid_xtt = $calls{$uuid}{b_uuid};	
	}
		
	if (!$uuid_xtt) {
		$response{stat}    = 'fail';
		$response{message} = '$uuid is not in any bridged call';
	} else {
	    %domain         = &get_domain();
    	$domain_name    = $domain{name};
	    $output = &runswitchcommand('internal', "uuid_transfer $uuid_xtt $dest XML $domain_name");
	    $response{stat}    = 'ok';
	    $response{message} = $output;
    }
    
   	&print_json_response(%response);
}

sub startattendedtransfer () {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local ($dest) = &database_clean_string($form{dest});
    local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';

    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';
    %calls = &parse_calls();

	if ($direction eq 'inbound') {
		for  (keys %calls) {
		   $uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}		
	} else  {
		$uuid_xtt = $calls{$uuid}{b_uuid};
    	#($uuid_xtt, $uuid) = ($uuid, $uuid_xtt);
    }
		
	if (!$uuid_xtt) {
		warn "$uuid not in any calls!";
		&print_api_error_end_exit(160, "$uuid not in any $direction calls");
	}
		
    #check if api-park dialplan is created
    %hash = &database_select_as_hash("select
                                        1,dialplan_uuid,dialplan_number
                                    from
                                        v_dialplans
                                    where
                                        dialplan_context='default' and
                                        dialplan_name='api-park'",
                                    'dialplan_uuid,dialplan_number');
    if (!$hash{1}{dialplan_uuid}) {
        &print_api_error_end_exit(160, "dialplan of api-park not defined");        
    }
    
	$park_number = $hash{1}{dialplan_number};

	if (!$dest) {		
        &print_api_error_end_exit(130, "dest is null");
	}
	
	$accountcode = $form{accountcode};
	if ($accountcode) {
		#$accountcode_str = "sip_h_X-accountcode=$accountcode";
		&runswitchcommand('internal', "uuid_setvar $uuid sip_h_X-accountcode $accountcode");
	}
	

	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}
	
	$realdest = $dest;
	
	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;
	
    $cid = &database_clean_string(substr $form{callerid}, 0, 50);

	@uri = &outbound_route_to_bridge($realdest, $domain{uuid});
	if ($uri[0]) {
		$src_uri = $uri[0];
	} else {
		$src_uri = "user/$realdest\@$domain{name}";
	}
	
	warn $src_uri;
	$output = &runswitchcommand('internal', "uuid_setvar $uuid src_uri $src_uri");
	
    
    $output = &runswitchcommand('internal', "uuid_setvar $uuid uuid_xtt $uuid_xtt");
    $output = &runswitchcommand('internal', "uuid_dual_transfer $uuid  xtt/XML/default $park_number/XML/default");
    
    $response{stat}          = 'ok';
    $response{message} = $output;
    
    
   	&print_json_response(%response); 
}

sub cancelattendedtransfer() {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local  $direction = 'inbound'; #$form{direction} eq 'inbound' ? 'inbound': 'outbound';
		 
    if ($direction eq 'outbound') {
    	$uuid = &get_bchannel_uuid($uuid);
    }
    
    $uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");
    $output   = &runswitchcommand('internal', "uuid_bridge $uuid $uuid_xtt");

    $response{stat}          = 'ok';
    $response{message} = $output;    
    
   	&print_json_response(%response); 
}

sub confirmattendedtransfer() {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local  $direction = 'inbound';  #$form{direction} eq 'inbound' ? 'inbound': 'outbound';
		 
    if ($direction eq 'outbound') {
    	$uuid = &get_bchannel_uuid($uuid);
    }
    
    $uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");

    %calls = &parse_calls();
    if (!$calls{$uuid}{b_uuid}) {
		warn "$uuid not in any calls!";
        &print_api_error_end_exit(160, "$uuid not in any calls");
    }
    
    $output   = &runswitchcommand('internal', "uuid_bridge $calls{$uuid}{b_uuid} $uuid_xtt");
    warn "uuid_bridge $calls{$uuid}{b_uuid} $uuid_xtt!!";
   
    $response{message} = $output;    
   	&print_json_response(%response);
}

sub getchannelstate () {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    
    %channels = &parse_channels();
    
    $state   = $channels{$uuid}{callstate};
    
    $response{stat}        = 'ok';
    $response{data}{state} = $state;
    
    
   	&print_json_response(%response);   
}

sub getlivechannels () {
	%domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	$show_all	= $form{show_all};
	%channels 	= &parse_channels();
	
	for (sort {$channel{$b}{created_epoch} <=> $channel{$a}{created_epoch}} keys %channels) {
		if (!$show_all) {
			next unless $channels{$_}{context} eq $domain_name;
		}
		
		push @{$response{data}{channel_list}}, $channels{$_};
	}

	$response{stat} = 'ok';
	
   	&print_json_response(%response);	
}

sub makecall {	
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	if (!$ext) {		
        &print_api_error_end_exit(130, "src is null");
	}
    %domain      = &get_domain();
    $domain_name = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }	
	
	$auto_answer = $form{autoanswer}  ? "sip_h_Call-Info=<sip:$domain_name>;answer-after=0,sip_auto_answer=true" : "";
	$alert_info  = $form{autoanswer}  ? "sip_h_Alert-Info='Ring Answer'" : '';
	$dest	= $form{dest};
	if (!$form{dest}) {		
        &print_api_error_end_exit(130, "dest is null");
	}
	
	$accountcode = $form{accountcode};
	if ($accountcode) {
		$accountcode_str = "sip_h_X-accountcode=$accountcode";
	}
	
	$uuid   = &genuuid();
    if (!$uuid) {
        &print_api_error_end_exit(130, "uuid tool not defined");       
    }
	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}
	
	$realdest = $dest;
	
	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;
	
  $cid = &database_clean_string(substr $form{callerid}, 0, 50);
  $code = &_get_area_code($dest);
	$dcid = &_get_dynamic_callerid($ext, $domain{uuid}, $code);
	
	$cid = $dcid if $dcid;
	
	warn "dynamic_callerid: $ext $cid - $dcid!\n";
	@uri = &outbound_route_to_bridge($ext, $domain{uuid});
	if ($uri[0]) {
		$src_uri = $uri[0];
	} else {
		$src_uri = "user/$ext\@$domain{name}";
	}
	
	warn $src_uri;
	$year = strftime('%Y', localtime);
	$mon  = strftime('%b', localtime);
	$day  = strftime('%d', localtime);
	
	%hash = &database_select_as_hash("select 1,user_record from v_extensions where user_context='$domain_name' and extension='$ext'", 'record');
	if ($hash{1}{record} eq 'all' or $hash{1}{record} eq 'outbound') {
		$record = "api_on_answer='uuid_record $uuid start /usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid.$record_format'";
	}
	$output = &runswitchcommand('internal', "bgapi originate {ringback=local_stream://default,ignore_early_media=true,fromextension=$ext,origination_caller_id_name=$cid,origination_caller_id_number=$cid,effective_caller_id_number=$cid,effective_caller_id_name=$cid,domain_name=$domain_name,outbound_caller_id_number=$cid,$alert_info,origination_uuid=$uuid,$accountcode_str,$auto_answer,record_session=true,$record}$src_uri  $realdest XML $domain_name");
 
    $response{stat}          = 'ok';
    $response{data}{uuid}    = $uuid;   
    $response{message} = $output;   
   	
    &print_json_response(%response);
}


sub makeautocall {
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
    
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	
	$auto_answer = $form{autoanswer}  ? "sip_h_Call-Info=<sip:$domain_name>;answer-after=0,sip_auto_answer=true" : "";
	$alert_info  = $form{autoanswer}  ? "sip_h_Alert-Info='Ring Answer'" : '';
	$dest	= $form{dest};
	if (!$form{dest}) {		
        &print_api_error_end_exit(130, "dest is null");
	}
	$accountcode = $form{accountcode};
	if ($accountcode) {
		$accountcode_str = "sip_h_X-accountcode=$accountcode";
	}
	
	$uuid   = &genuuid();
    if (!$uuid) {
        &print_api_error_end_exit(130, "uuid tool not defined");       
    }
	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}
	
	$realdest = $dest;
	
	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;
	
  $cid = &database_clean_string(substr $form{callerid}, 0, 50);
  $code = &_get_area_code($dest);
	$dcid = &_get_dynamic_callerid($ext, $domain{uuid}, $code);
	$cid = $dcid if $dcid;
	
	$is_widget_in_conference = 0;
	$conf_list = &runswitchcommand('internal', "conference $ext list");
	for (split /\n/, $conf_list) {
		if (index($_, "loopback/$ext-a") != -1) {
			$is_widget_in_conference = 1;
			last;
		}
	}
	$result = &runswitchcommand('internal', "conference $ext kick non_moderator");
	
	if (!$is_widget_in_conference) {
		$result =  &runswitchcommand('internal', "originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=$cid,domain_name=$domain_name,ignore_early_media=true,origination_uuid=$uuid,flags=endconf|moderator}loopback/$ext/$domain_name/XML conference$ext XML default");
		sleep 2;
		
		$call_list = &runswitchcommand('internal', "show calls");
		$is_ext_answered = 0;
		for (split /\n/, $call_list) {
			if (index($_, "$uuid,") == 0) {
				$is_ext_answered = 1;
				last;
			}
		}
	
		if (!$is_ext_answered) {
            &print_api_error_end_exit(140, "ext not answered");
		}
	}
	
	
	$uuid = &genuuid();
	$result = &runswitchcommand('internal', "bgapi originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=$cid,domain_name=$domain_name,origination_uuid=$uuid,autocallback_fromextension=$ext,is_lead=1}loopback/$dest/$domain_name/XML conference$ext XML default");
	
    $response{stat}       = 'ok';
    $response{data}{uuid} = $uuid;
    &print_json_response(%response);
}

sub get_incoming_event {
	local $ext = $form{ext};
	%domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	
	$ext = "$ext\@$domain";
	
	use Cache::Memcached;
	local $memcache = "";
    $memcache = new Cache::Memcached {'servers' => ['127.0.0.1:11211'],};
	
	$memcache->delete($ext);

	local $starttime = time;
	local $| = 1;
	
	print $cgi->header(-type  =>  'text/event-stream', '-cache-control' => 'NO-CACHE',);

CHECK:
	
	if (time - $starttime > 3600) {
		$memcache->delete($ext);
		exit 0; #force max connection time to 1h
	}
	
	local $status = $memcache->get($ext);
	local $current_state = '';
	
	local $channels = &runswitchcommand('internal', 'show channels');
	local $cnt      = 0;
	for  $line (split /\n/, $channels) {
		my @f = split ',', $line;
		if ($f[22] eq $ext && $f[33] ) { #presence_id && initial_ip_addr
			
			$current_state = $f[24];
			if ($status ne $current_state) {		
				print "data:", &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => $f[0],
					 caller => "$f[6] <$f[7]>", start_time => $f[2], current_state => $f[24]), "\n\n";
				$memcache->set($ext, $current_state);
			}
		}		
	}
	
	if (!$current_state) {
		if (!$status) {
			
			print "data:" , &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => '',
					 caller => "", start_time => '', current_state => 'nocall'), "\n\n";
			$memcache->set($ext, 'nocall');
		} elsif ($status ne 'nocall') {
			print "data:", &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => '',
					 caller => "", start_time => '', current_state => 'hangup'), "\n\n";
			$memcache->set($ext, '');
		}
	}
	
	sleep 1;
	goto CHECK;
}

sub hold () {
    local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
    local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';
		 
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

sub agentlogin () {
    $name   = &database_clean_string(substr $form{agentname}, 0, 50);
    $status = shift || 'Available';
    %domain      = &get_domain();
    $domain_name = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    warn "callcenter_config agent set status $name\@$domain_name '$status'";
    $output = &runswitchcommand(1, "callcenter_config agent set status $name\@$domain_name '$status'");
    
    $response{stat}          = 'ok';
    $response{message} = $output;
    &print_json_response(%response);
}

sub agentlogout () {
    &agentlogin('Logged Out');
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
			
			$recording_file = "/usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid.$record_format";
			for $i (0..20) {
				$tmp_recording_file = "/usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid" . ($i ? "_$i":"") . ".$record_format";
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

sub get_bchannel_uuid() {
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
return 1;
