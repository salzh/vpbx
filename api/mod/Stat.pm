#{instant_ringback=true,ignore_early_media=true,sip_invite_domain=ssn.domain.net,origination_caller_id_name=Emer__#${caller_id_name},origination_caller_id_number=${caller_id_number}}[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14153363197,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152255467,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/19255491757,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152158122
sub getstat () {
	%domain         = &get_domain();
	if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    %domain         = &get_domain();

	@v = localtime(time-7*3600*24);
	$last7days = sprintf("%04d-%02d-%02d 00:00:00", 1900+$v[5],$v[4]+1,$v[3]);
	

    $start_stamp = 
    local %params = (
        uuid => {type => 'string', maxlen => 36, notnull => 0, default => ''},
        direction => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
        start_stamp => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        end_stamp => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        page => {type => 'int', maxlen => 50, notnull => 0, default => 0},
        limit => {type => 'int', maxlen => 50, notnull => 0, default => 100},
        missed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        cc_queue => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        cc_result => {type => 'string', maxlen => 50, notnull => 0, default => ''}
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	for $k (keys %params) {
        $tmpval   = '';
        if (&getvalue(\$tmpval, $k, $params{$k})) {
            $post_add{$k} = $tmpval;
        } else {
            $response{stat}	    = "fail";
            $response{message}	= $k. &_(" not valid");
        }
    }
    
	if (!$post_add{start_stamp}) {
		$post_add{start_stamp} = $last7days;
	}
	
   
    $condition = "domain_uuid='$domain{uuid}'";
    for (keys %post_add) {
        next if  !$_ || $post_add{$_} eq '' || $_ eq 'page' || $_ eq 'limit';
        $condition .= ' AND ' if $condition;
        if ($_ eq 'start_stamp') {
            $condition .= "start_stamp >= '$post_add{start_stamp}'";
        } elsif ($_ eq 'end_stamp') {
            $condition .= "end_stamp <= '$post_add{end_stamp}'";
        } elsif ($_ eq 'missed' ) {
            if ($post_add{missed} eq 'true') {
                $condition .= "billsec=0"
            } else {
            	 $condition .= " 1=1 ";
            }
        } elsif ($_ eq 'call_result' ) {
            if ($post_add{call_result} eq 'answered') {
            	 $condition .= "(answer_stamp is not null and bridge_uuid is not null)";
            } elsif ($post_add{call_result} eq 'voicemail') {
            	 $condition .= "(answer_stamp is not null and bridge_uuid is null)";
            } elsif ($post_add{call_result} eq 'missed' || $post_add{call_result} eq 'cancelled') {
            	 $condition .= " (answer_stamp is not null and bridge_uuid is null) ";
            } elsif ($post_add{call_result} eq 'failed') {
            	 $condition .= "(answer_stamp is null and bridge_uuid is null and billsec = 0 and sip_hangup_disposition = 'send_refuse')";
            } 
        } else {
            if ($_ eq 'cc_queue' ) {
                if (lc($post_add{$_}) eq 'null' or lc($post_add{$_}) eq 'not null') {
                    $condition .= "$_ IS $post_add{$_}"; next;
                } elsif (index($post_add{$_}, '@') == -1) {
                    $post_add{$_} .= '@' . $domain{name};
                    $condition .= "$_='$post_add{$_}'";
                }                
            } else {                       
                $condition .= "$_='$post_add{$_}'";
            }           
        }
    }
    
	%data = ();
	$data{live_calls} = 0;
	$data{max_concurrent} = 0;
	$data{recording_storage} = 0;
	$data{answered_precent} = 0;
	$data{all_calls} = 0;
	$data{outbound_calls} = 0;
	$data{inbound_calls} = 0;
	$data{tollfree_calls} = 0;
	$data{avg_outbound_duration} = 0;
	$data{avg_inbound_duration} = 0;
	$data{total_inbound_duration} = 0;
	$data{total_outbound_duration} = 0;

	$fields = 'xml_cdr_uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	
	$sql =  "select xml_cdr_uuid,$fields from v_xml_cdr where $condition";
	%hash = &database_select_as_hash($sql, "$fields");
	warn "sql: $sql";


	$response  = ();
	$response{error}{code}	   = 0;
	$response{error}{message} = 'OK';
	for $uuid (keys %hash) {
		$data{all_calls} += 1;
		$len_callerid_number = length($hash{$uuid}{caller_id_number});
		$len_destination_number = length($hash{$uuid}{destination_number});
		if ($len_callerid_number < 7 && $len_destination_number > 7) {
			$data{outbound_calls} += 1;
			$data{total_outbound_duration} += $hash{$uuid}{billsec};
		} elsif ($len_callerid_number > 7) {
			$data{inbound_calls} += 1;
			$data{total_inbound_duration} += $hash{$uuid}{billsec};
		}
		
		($pre3) = $hash{$uuid}{caller_id_number} =~ /^1?(\d{3})\d{5,}$/;
		if ($pre eq '800' || $pre3 eq '811' || $pre3 eq '822' || $pre3 eq '833' || $pre3 eq '844' || $pre3 eq '855' || $pre3 eq '866' || $pre3 eq '877' || $pre3 eq '888' || $pre3 eq '899') {
			$data{tollfree_calls} += 1;
		}	
	}
	
	$data{avg_outbound_duration} = $data{outbound_calls} > 0 ? $data{total_outbound_duration} / $data{outbound_calls} : 0;
	$data{avg_inbound_duration} = $data{inbound_calls} > 0 ? $data{total_inbound_duration} / $data{inbound_calls} : 0;
	
	$channels = &runswitchcommand('internal', "show channels");
	
	$header_found = 0;
	for $channel (split /\n/, $channels) {
		if (!$header_found) {
			$j = 0;
			for $field_name (split ',', $channel) {
				if ($field_name eq 'callstate') {
					$callstate_index = $j;
					$header_found = 1;
					last;
				}
				$j++;
				
			}
			next;
		} else {
			$data{live_calls} += 1;	
		}
	}
	
	$out = &runswitchcommand('internal', "status");
	($v) = $out =~ /peak (\d+),/s;
	$data{max_concurrent} = $v;
	$response{data} = \%data;
	&print_json_response(%response);
}

1;
