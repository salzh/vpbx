=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut
use POSIX qw(strftime);
use MIME::Base64;

sub getcdr () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
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
    
    %queues = &database_select_as_hash(
                            "select
                                queue_name,queue_extension,call_center_queue_uuid
                            from
                                v_call_center_queues
                            where
                                domain_uuid='$domain{uuid}'",
                            "queue_extension,call_center_queue_uuid");
    
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
    
    $start_index   = $post_add{page} * $post_add{limit};
    $start_index ||= 0;
    
    $limit         = $post_add{limit};
    $limit       ||= 100;
    
    $condition   ||= '1=1';
    warn $condition;
    
    %hash = &database_select_as_hash(
                            "select
                                1,count(*)
                            from
                                v_xml_cdr
                            where
                                $condition",
                            "total");
    $response{data}{total} = $hash{1}{total} ? $hash{1}{total} : 0;
    
    $fields = 'uuid,uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
    if ($response{stat} ne 'fail') {
    	
        %hash = &database_select_as_hash(
                            "select
                                uuid,$fields
                            from
                                v_xml_cdr
                            where
                                $condition
                            limit $limit offset $start_index",
                            "$fields");
        
       
        for (sort {$hash{$b}{start_stamp} cmp $hash{$a}{start_stamp}} keys %hash) {
        		local $start_epoch = $hash{$_}{start_epoch};
        		local $uuid				 = $_;
                
        		local $recording_filename = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.wav";
                if (!-e $recording_filename) {
                    $recording_filename  = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.mp3";
                }
                
                warn $recording_filename;
                $recording_url = '';
                if (-e $recording_filename) {
                    $recording_url = "http://$domain{name}/app/recordings/recordings2.php?filename=" . encode_base64($recording_filename, '');
                    $hash{$_}{recording_url} = $recording_url;
                }
            local $queue_name = $hash{$_}{cc_queue};
            if ($queue_name) {
                local ($n) = split '@', $queue_name;
                local $e = $queues{$n}{queue_extension};
                local $d = $queues{$n}{call_center_queue_uuid};
                
                $hash{$_}{cc_queue} = $n;
                $hash{$_}{queue_extension} = $e;
                $hash{$_}{queue_uuid} = $d;
            } else {
                $hash{$_}{cc_queue} = '';
                $hash{$_}{queue_extension} = '';
                $hash{$_}{queue_uuid} = '';                
            }
            
            if ($hash{$_}{direction} eq 'inbound' or $hash{$_}{direction} eq 'local') {
                if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
                    $call_result = 'answered';
                } elsif($hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid}) {
                    $call_result = 'voicemail';
                } elsif(!$hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid} && $hash{$_}{sip_hangup_disposition} ne 'send_refuse') {
                    $call_result = 'cancelled';
                } else {
                    $call_result = 'failed';
                }
                    
            } elsif ($hash{$_}{direction} eq 'outbound') {
                if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
                    $call_result = 'answered';
                } elsif(!$hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
                    $call_result = 'cancelled';
                } else {
                     $call_result = 'failed';
                }
            }
            
            $hash{$_}{call_result} = $call_result;
            
            push @{$response{data}{list}}, $hash{$_};
        }
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response);
}

sub getcdrmissed () {
    $form{missed} = 1;
    &getcdr();
}

sub getcdrstatistics () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    %hash = &database_select_as_hash("select 1,extract(epoch from now())", 'epoch');
    $current_epoch = int $hash{1}{epoch};
    $epoch_before1day = $current_epoch - 24*3600;
    $epoch_before30day= $current_epoch - 24*3600*30;
    $fields = 'uuid,start_stamp,start_epoch,billsec';
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash(
                            "select
                                uuid,$fields
                            from
                                v_xml_cdr
                            where
                                start_epoch >= '$epoch_before1day'",                            
                            "$fields");
        
        for (1..24) {
            $response{data}{hours}{$_}{volume} = 0;
            $response{data}{hours}{$_}{minutes} = 0;
            $response{data}{hours}{$_}{callsperminute} = 0;
            $response{data}{hours}{$_}{missed} = 0;
            $response{data}{hours}{$_}{asr} = 0;
            $response{data}{hours}{$_}{aloc} = 0;            
        }
        
        for (sort {$hash{$b}{start_epoch} <=> $hash{$a}{start_epoch}} keys %hash) {
            $i = int (($current_epoch - $hash{$_}{start_epoch}) / 3600) + 1;
            
            warn "$i: $hash{$_}{start_stamp}";
            
            $response{data}{hours}{$i}{volume}++;
            $response{data}{hours}{$i}{seconds} += $hash{$_}{billsec};
            $response{data}{hours}{$i}{missed}++ if $hash{$_}{billsec} <= 0;
            
            $response{data}{hours}{$i}{minutes} = sprintf("%.02f", $response{data}{hours}{$i}{seconds} / 60);
            $response{data}{hours}{$i}{callsperminute} = sprintf("%.02f", $response{data}{hours}{$i}{volume} / 60);
            
            if ($response{data}{hours}{$i}{volume} > 0) {
                $response{data}{hours}{$i}{asr} = int (($response{data}{hours}{$i}{volume}-$response{data}{hours}{$i}{missed}) /
                                        $response{data}{hours}{$i}{volume}) * 100;
            }
            
            $response{data}{hours}{$i}{aloc} = sprintf ("%.02f", $response{data}{hours}{$i}{minutes} /
                                                 $response{data}{hours}{$i}{volume});
            
        }
        
        %hash = &database_select_as_hash(
                        "select
                            uuid,$fields
                        from
                            v_xml_cdr
                        where
                            start_epoch >= '$epoch_before30day'",                            
                        "$fields");
        
        for (1,7,30) {
            $response{data}{days}{$_}{volume} = 0;
            $response{data}{days}{$_}{minutes} = 0;
            $response{data}{days}{$_}{callsperminute} = 0;
            $response{data}{days}{$_}{missed} = 0;
            $response{data}{days}{$_}{asr} = 0;
            $response{data}{days}{$_}{aloc} = 0;            
        }
        
        for (sort {$hash{$b}{start_epoch} <=> $hash{$a}{start_epoch}} keys %hash) {
            $i = int($current_epoch - $hash{$_}{start_epoch}) / 3600 /24 + 1;
            $i = 7  if $i > 1 && $i <=7;
            $i = 30 if $i > 7 && $i <=30;
            
            warn "$i: $hash{$_}{start_stamp}";

            $response{data}{days}{$i}{volume}++;
            $response{data}{days}{$i}{seconds} += $hash{$_}{billsec};
            $response{data}{days}{$i}{missed}++ if $hash{$_}{billsec} <= 0;
            
            $response{data}{days}{$i}{minutes} = sprintf("%.02f", $response{data}{days}{$i}{seconds} / 60);
            $response{data}{days}{$i}{callsperminute} = sprintf("%.02f", $response{data}{days}{$i}{volume} / 60);
            if ($response{data}{days}{$i}{volume} > 0) {
                $response{data}{days}{$i}{asr} = int (($response{data}{days}{$i}{volume}-$response{data}{days}{$i}{missed}) /
                                            $response{data}{days}{$i}{volume}) * 100;
                $response{data}{days}{$i}{aloc} = sprintf ("%.02f", $response{data}{days}{$i}{minutes} /
                                                           $response{data}{days}{$i}{volume});

            }
            
            
        }
        
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response);  
}

return 1;
