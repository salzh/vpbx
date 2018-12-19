=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub getdestinations () {
	#*99(\d+) voicemail
	#6xxx timecondition
	#7xxx ringgroup
	# 2~7 digits normal extensions
	# > 8 digits external numbers
    #we need define external number user input
    
    %domain   = &get_domain();
    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
	if (!$response{error}{code}) {	
		@dests    = ();
		
		#Call Center
		@subcc = ();
		%cc = &database_select_as_hash ("select call_center_queue_uuid,queue_name,queue_extension from v_call_center_queues where domain_uuid='$domain{uuid}'", 'name,extension');
												
		for (sort {$cc{$a}{name} <=> $cc{$b}{name}} keys %cc) {
			push @subcc, {displayname => $cc{$_}{name}, value => "transfer:$cc{$_}{extension} XML $domain{name}"};
		}
		
		push @dests, {'Call Center' => \@subcc};
		
		#Call Flow
		@subcf = ();
		%cf = &database_select_as_hash ("select call_flow_uuid,call_flow_name,call_flow_extension from v_call_flows where domain_uuid='$domain{uuid}'", 'name,extension');
												
		for (sort {$cf{$a}{name} <=> $cf{$b}{name}} keys %cf) {
			push @subcf, {displayname => $cf{$_}{name}, value => "transfer:$cf{$_}{extension} XML $domain{name}"};
		}
		
		push @dests, {'Call Flow' => \@subcf};
		
		#Call Group
		@subcg = ();
=pod	
		%cf = &database_select_as_hash ("select call_flow_uuid,call_flow_name,call_flow_extension from v_call_flows where domain_uuid='$domain{uuid}'", 'name,extension');
												
		for (sort {$cf{$a}{name} <=> $cf{$b}{name}} keys %cf) {
			push @subdests, {displayname => $cf{$_}{name}, value => "transfer:$cf{$_}{extension} XML $domain{name}"};
		}
=cut    
		push @dests, {'Call Group' => \@subcg};
		
		#extensions
		@subextensions   = ();
		warn "select extension_uuid,extension from v_extensions where domain_uuid='$domain{uuid}'";
		%extensions = &database_select_as_hash ("select extension_uuid,extension from v_extensions where domain_uuid='$domain{uuid}'", 'extension');
												
		for (sort {$extensions{$a}{extension} <=> $extensions{$b}{extension}} keys %extensions) {
			push @subextensions, {displayname => $extensions{$_}{extension}, value => "transfer:$extensions{$_}{extension} XML $domain{name}"};
		}
		
		push @dests, {Extensions => \@subextensions};
		
		#Fax
		@subfax = ();
		%fax = &database_select_as_hash ("select fax_uuid,fax_extension from v_fax where domain_uuid='$domain{uuid}'", 'extension');
												
		for (sort {$fax{$a}{extension} <=> $fax{$b}{extension}} keys %fax) {
			push @subfax, {displayname => $fax{$_}{extension}, value => "transfer:$fax{$_}{extension} XML $domain{name}"};
		}
		
		push @subfax, {'Call Flow' => \@subdests};
		
		#FIFO
		@subfifo = ();
=pod	
		%cf = &database_select_as_hash ("select call_flow_uuid,call_flow_name,call_flow_extension from v_call_flows where domain_uuid='$domain{uuid}'", 'name,extension');
												
		for (sort {$cf{$a}{name} <=> $cf{$b}{name}} keys %cf) {
			push @subdests, {displayname => $cf{$_}{name}, value => "transfer:$cf{$_}{extension} XML $domain{name}"};
		}
=cut    
		push @dests, {'FIFO' => \@subfifo};
		
		#Gateway
		@subgateway = ();	
		%gateway = &database_select_as_hash("select gateway_uuid,gateway from v_gateways  where domain_uuid='$domain{uuid}'", 'gateway');
		
		for (sort {$gateway{$a}{gateway} <=> $gateway{$b}{gateway}} keys %gateway) {
			push @subgateway, {displayname => $voicemails{$_}{gateway}, value => "bridge:sofia/gateway/$_/xxxxx"};
		}
		push @dests, {Gateway => \@subgateway};
	
		#IVR Menu
		@subivr = ();	
		%ivr = &database_select_as_hash("select ivr_menu_uuid,ivr_menu_name,ivr_menu_extension from v_ivr_menus  where domain_uuid='$domain{uuid}'", 'name,extension');
		
		for (sort {$ivr{$a}{name} <=> $ivr{$b}{name}} keys %ivr) {
			push @subivr, {displayname => $ivr{$_}{name}, value => "transfer:$ivr{$_}{extension} XML $domain{name}"};
		}
		push @dests, {'IVR Menu' => \@subivr};
	
		#Languages
		%languages = (nl => 'Dutch',
					  en => 'English',
					  fr => 'French',
					  it => 'Italian',
					  de => 'German',
					  'pt-pt' => 'Portuguese-Portugal',
					  'pt-br' => 'Portuguese-Brazil',
					  es => 'Spanish',
					  cn => 'Chinese');
		@sublan = ();	
		
		for (sort {$languages{$a} <=> $languages{$a}} keys %languages) {
			push @sublan, {displayname => $languages{$_}, value => "set:default_language=$_"};
		}
		push @dests, {Languages => \@sublan};
	
		#Recordings
		@subrec = ();	
		%recordings = &database_select_as_hash("select recording_uuid,recording_filename from v_recordings  where domain_uuid='$domain{uuid}'", 'filename');
		
		for (sort {$recordings{$a}{filename} <=> $recordings{$b}{filename}} keys %recordings) {
			push @subrec, {displayname => $recordings{$_}{filename}, value => "playback:/usr/local/freeswitch/recordings/$domain{name}/$recordings{$_}{filename}"};
		}
		push @dests, {Recordings => \@subrec};
	
		#Ring Groups
		@subrg = ();	
		%rg = &database_select_as_hash("select ring_group_uuid,ring_group_name,ring_group_extension from v_ring_groups  where domain_uuid='$domain{uuid}'", 'name,extension');
		
		for (sort {$rg{$a}{name} <=> $rg{$b}{name}} keys %rg) {
			push @subrg, {displayname => $rg{$_}{name}, value => "transfer:$rg{$_}{extension} XML $domain{name}"};
		}
		push @dests, {'Ring Groups' => \@subrg};
	
		#timeconditions
		@subtc = ();
		%tc = &database_select_as_hash("select dialplan_uuid,dialplan_name,dialplan_number from v_dialplans where domain_uuid='$domain{uuid}' and app_uuid='4b821450-926b-175a-af93-a03c441818b1'", 'name,number');
		for (sort {$tc{$a}{name} cmp $extensions{$b}{name}} keys %tc) {
			push @subtc, {displayname => $tc{$_}{name}, value => "transfer:$tc{$_}{number} XML $domain{name}"};
		}
		push @dests, {'Time Conditions' => \@subtc};
	   
	   
		#voicemails
		@subvm = ();	
		%voicemails = &database_select_as_hash("select voicemail_uuid,voicemail_id from v_voicemails  where domain_uuid='$domain{uuid}'", 'vid');
		
		for (sort {$voicemails{$a}{vid} <=> $voicemails{$b}{vid}} keys %voicemails) {
			push @subvm, {displayname => $voicemails{$_}{vid}, value => "transfer:*99$voicemails{$_}{vid} XML $domain{name}"};
		}
		push @dests, {Voicemails => \@subvm};
	
		%other =('check voicemail' => "transfer:*98 XML $domain{name}",
				'company directory'	=> "transfer:*411 XML $domain{name}",
				'record'			=> "transfer:*732 XML $domain{name}",
				'answer'			=> "answer",
				'hangup'			=> "hangup",
				'info'				=> 'info',
				'bridge'			=> 'bridge:',
				'db'				=> 'db:',
				'export'			=> 'export:',
				'global_set'		=> 'global_set:',
				'group'				=> 'group:',
				'javascript'		=> 'javascript:',
				'lua'				=> 'lua:',
				'perl'				=> 'perl:',
				'reject'			=> 'reject',
				'set'				=> 'set:',
				'sleep'				=> 'sleep:',
				'transfer'			=> 'transfer:',
				'other'				=> ''
		);
		@subdests = ();	
		
		for (sort keys %other) {
			push @subdests, {displayname => $_, value => "$other{$_}"};
		}
		push @dests, {Other => \@subdests};
	
		
		$response{error}{code} = 0;
		$response{error}{message} = 'OK';
		$response{data}    = \@dests;
	}
    &print_json_response(%response);      
}

sub test {
	$response{stat} = 'ok';
    
    &print_json_response(%response);    
}

sub runswitchcommand () {
	$internal = shift;
	local $cmd;
	if ($internal) {
		$cmd = shift;
	} else {
		$cmd = &database_clean_string(substr $form{cmd}, 0, 255);
	}
	
	local %result = &post_data ('domain_uuid' => '',
					'urlpath'     => "/app/exec/exec_switch_command.php?switch_cmd=$cmd",
					'reload'	  => 0,
					'data'        => []
					);
	$output = $result->content;

	warn $cmd;
	if ($internal) {
		return $output;
	} else {
		$response{data} = $output;
		$response{stat} = 'ok';
		&print_json_response(%response);
	}
}

sub parse_channels () {
	local $header_csv = 'uuid,direction,created,created_epoch,name,state,cid_name,cid_num,ip_addr,dest,application,application_data,dialplan,context,read_codec,read_rate,read_bit_rate,write_codec,write_rate,write_bit_rate,secure,hostname,presence_id,presence_data,accountcode,callstate,callee_name,callee_num,callee_direction,call_uuid,sent_callee_name,sent_callee_num,initial_cid_name,initial_cid_num,initial_ip_addr,initial_dest,initial_dialplan,initial_context';
	
	@header_array = split /,/, $header_csv;
	
	%channels = ();
	$output = &runswitchcommand('internal', 'show channels');
	for (split /\n/, $output) {
		next if /^\s*$/;
		@v = split /,/, $_;
		
		for (0..$#header_array) {
		#	warn $header_array[$_] , ' ==> ' . $v[$_], "\n";
			$channels{$v[0]}{$header_array[$_]} = $v[$_];
		}
	}
	
	return %channels;	
}

#uuid,direction,created,created_epoch,name,state,cid_name,cid_num,ip_addr,dest,presence_id,presence_data,callstate,callee_name,callee_num,callee_direction,call_uuid,hostname,sent_callee_name,sent_callee_num,b_uuid,b_direction,b_created,b_created_epoch,b_name,b_state,b_cid_name,b_cid_num,b_ip_addr,b_dest,b_presence_id,b_presence_data,b_callstate,b_callee_name,b_callee_num,b_callee_direction,b_sent_callee_name,b_sent_callee_num,call_created_epoch

sub parse_calls () {
	local $header_csv = 'uuid,direction,created,created_epoch,name,state,cid_name,cid_num,ip_addr,dest,presence_id,presence_data,accountcode,callstate,callee_name,callee_num,callee_direction,call_uuid,hostname,sent_callee_name,sent_callee_num,b_uuid,b_direction,b_created,b_created_epoch,b_name,b_state,b_cid_name,b_cid_num,b_ip_addr,b_dest,b_presence_id,b_presence_data,b_callstate,b_callee_name,b_callee_num,b_callee_direction,b_sent_callee_name,b_sent_callee_num,call_created_epoch';
	
	@header_array = split /,/, $header_csv;
	
	%calls = ();
	$output = &runswitchcommand('internal', 'show calls');
	for (split /\n/, $output) {
		next if /^\s*$/;
		@v = split /,/, $_;
		
		for (0..$#header_array) {
			$calls{$v[0]}{$header_array[$_]} = $v[$_];
		}
	}
	
	return %calls;	
}

sub downloadfile () {
	%domain   = &get_domain();
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	$type = $form{type};
	if ($type eq 'fax') {
		$name = $form{name};
		$box  = $form{box};
		$extension = $form{extension};
		$postfix = $form{postfix};
		
		$dir = "/usr/local/freeswitch/storage/fax/$domain{name}/$extension";
		
		if ($postfix eq 'tif') {
			$content_type = "image/tiff";
		} elsif ($postfix eq 'pdf') {
			$content_type = "application/pdf";
		}
		
		$filename = "$name.$postfix";
		$file = "$dir/$box/$name.$postfix";
		if (!-e $file) {
			&print_api_error_end_exit(100, "$name.$postfix not found");
		}
		
	} elsif ($type eq 'recording') {
		$name = $form{name};
		
		$dir = "/usr/local/freeswitch/recordings/$domain{name}";
		
		if ($postfix eq 'wav') {
			$content_type = "audio/x-wav";
		} elsif ($postfix eq 'mp3') {
			$content_type = "audio/mpeg";
		}
		
		$filename = "$name";
		$file = "$dir/$name";
		if (!-e $file) {
			&print_api_error_end_exit(100, "$name not found");
		}
		
	} elsif ($type eq 'music') {
		$name = $form{name};
		
		$category = $form{category};
		$rate     = $form{rate} || 8000;
		
		if (!$category || $category eq 'default') {
			$dir = "/usr/local/freeswitch/sounds/music/$rate";
		} else {
			$dir = "/usr/local/freeswitch/sounds/music/$domain{name}/$category/$rate";
		}
		
		if ($postfix eq 'wav') {
			$content_type = "audio/x-wav";
		} elsif ($postfix eq 'mp3') {
			$content_type = "audio/mpeg";
		}
		
		$filename = "$name";
		$file = "$dir/$name";
		warn $file;
		if (!-e $file) {
			&print_api_error_end_exit(100, "$name not found");
		}
		
	} else {
		&print_api_error_end_exit(100, "$type file not defined");
	}
	
	print "Content-disposition: attachment; filename=$filename\n";
	print "Content-type: $content_type\n";
	print "Cache-Control: no-cache, must-revalidate\n";
	print "Pragma: no-cache\n";
	print "status: 200\n";
	print "\n";
	
	binmode STDOUT;
	$size = -s $file;
	open FH, $file or &print_api_error_end_exit(100, "fail to open $file for reading");
	sysread FH, $buffer, $size;
	print $buffer;	
}

sub upload_file () {
    ($fieldname, $destdir, $max_size, $allow_type, $keepname) = @_;
    
    $rawname    = $cgi->param($fieldname);
    $destdir  ||= '.';
    if (!$rawname) {
        return (error => 1, message => 'no file uploaded');
    } else {
        local ($filename, $format) = $rawname    =~ /([^\\\/]+)\.(\w+)$/;
        if ($allow_type && index(",$allow_type,", $format) == -1) {
            return(error => 1, message => "$rawname - file format not support!");
        }

        $temp_file = (time . '-' .  int (rand 9999) ) . ".$format";
        $filehandle = $cgi->upload($fieldname);
        open(LOCAL, "> /tmp/$temp_file");
        $size = 0;
        while($bytesread=read($filehandle,$buffer,1024)) {
            print LOCAL $buffer;
            $size += $bytesread;
            
            if ($max_size && $size > $max_size) {
                unlink $temp_file;
                return (error => 1, message => "filesize is too big");
            }
        }
        
        close(LOCAL);
		
		if (!$keepname) {
			move("/tmp/$temp_file", $destdir);
		} else {
			move("/tmp/$temp_file", "$destdir/$filename.$format");
		}
		return (error => 0, file => "$destdir/$temp_file", name => $filename, format => $format);
    }
}

sub outbound_route_to_bridge () {
	local ($destination_number, $domain_uuid) = @_;

	$sql = "select
				dialplan_uuid,dialplan_uuid,dialplan_continue,dialplan_order
			from
				v_dialplans
			where
				(domain_uuid = '$domain_uuid' or domain_uuid is null) and
				app_uuid = '8c914ec3-9fc0-8ab5-4cda-6c9288bdc9a3' and
				dialplan_enabled = 'true'";
				
	warn $sql;
	
	%hash = &database_select_as_hash($sql, "dialplan_uuid,dialplan_continue,dialplan_order");
	$exit_2 = 0;
	for $duuid (sort {$hash{$a}{dialplan_order} <=> $hash{$b}{dialplan_order}} keys %hash) {
		$dialplan_uuid = $hash{$duuid}{'dialplan_uuid'};

		$dialplan_continue = $hash{$duuid}{'dialplan_continue'};
		
		last if $exit_2;
		$sql = "select
					dialplan_detail_uuid,dialplan_detail_uuid,dialplan_detail_tag,dialplan_detail_type,dialplan_detail_data,dialplan_detail_order
				from
					v_dialplan_details
				where
					(domain_uuid = '$domain_uuid' or domain_uuid is null) and
					dialplan_uuid = '$dialplan_uuid'";
		warn $sql;	
		%detail = &database_select_as_hash($sql, "dialplan_detail_uuid,dialplan_detail_tag,dialplan_detail_type,dialplan_detail_data,dialplan_detail_order");
		$regex_match = 0;
		for $D (sort {$detail{$a}{dialplan_detail_order} <=> $detail{$b}{dialplan_detail_order}} keys %detail) {
			if ($detail{$D}{'dialplan_detail_tag'} eq "condition") {
				if ($detail{$D}{'dialplan_detail_type'} eq "destination_number") {
					$dialplan_detail_data = $detail{$D}{'dialplan_detail_data'};
					warn $dialplan_detail_data;
					$count = $destination_number =~ m/$dialplan_detail_data/;
					warn $count;
					if (!$count) {
						$regex_match = 0;
					}
					else {
						$regex_match = 1;
						$regex_match_1 = $1;
						$regex_match_2 = $2;
						$regex_match_3 = $3;
						$regex_match_4 = $4;
						$regex_match_5 = $5;
					}
				}
			}
		}
		
		if ($regex_match) {
			for $d (sort {$detail{$a}{dialplan_detail_order} <=> $detail{$b}{dialplan_detail_order}} keys %detail) {
				$dialplan_detail_data = $detail{$d}{'dialplan_detail_data'};
				if ($detail{$d}{'dialplan_detail_tag'} eq "action" && $detail{$d}{'dialplan_detail_type'} eq "bridge" && $dialplan_detail_data ne "\${enum_auto_route}") {
					$dialplan_detail_data =~ s/\$1/$regex_match_1/g;
					$dialplan_detail_data =~ s/\$2/$regex_match_2/g;
					$dialplan_detail_data =~ s/\$3/$regex_match_3/g;
					$dialplan_detail_data =~ s/\$4/$regex_match_4/g;
					$dialplan_detail_data =~ s/\$5/$regex_match_5/g;
				
					warn "$detail{$d}{'dialplan_detail_type'},$dialplan_detail_data";
					push @bridge_array, $dialplan_detail_data;
					if ($dialplan_continue eq "false") {
						$exit_2 = 1;
						last;
					}
				}
			}
		}
		
	}
	return @bridge_array;
}
return 1;
