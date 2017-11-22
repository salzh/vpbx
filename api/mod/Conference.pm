=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addconference () {
	local %params = (
        conference_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_pin_number => {type => 'string', maxlen => 10, notnull => 0, default => ""},
		conference_profile => {type => 'enum:default,wideband,ultrawideband,cdquality',
                               maxlen => 255, notnull => 0, default => "default"},
        conference_flags => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		conference_order => {type => 'string', maxlen => 5, notnull => 0, default => '000'},
		conference_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		conference_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}		
    );
	
	
	%response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	local %post_add = ();
	for $k (keys %params) {
		 $tmpval   = '';
		 if (&getvalue(\$tmpval, $k, $params{$k})) {
			 $post_add{$k} = $tmpval;
		 } else {
			 $response{stat}	= "fail";
			 $response{message}	= $k. &_(" not valid");
		 }
	}
    
	
	if ($response{stat} ne 'fail') {
        &post_data ('domain_uuid' => $domain{uuid},
					'urlpath'     => '/app/conferences/conference_edit.php',
					'reload'	  => 1,
					'data'        => [%post_add]
					);
		
		#$location = $result->header("Location");
		#($uuid) = $location =~ /id=(.+)$/;
        
        %hash = &database_select_as_hash(
                    "select
                        1,conference_uuid,dialplan_uuid
                    from
                        v_conferences
                    where
                        conference_name='$post_add{conference_name}' and
                        conference_extension='$post_add{conference_extension}' and
                        domain_uuid='$domain{uuid}'",
                    'uuid,dialplan_uuid');
        $uuid = $hash{1}{uuid};
		if (!$uuid) {
			$response{stat}		= "fail";
			$response{message}	= "Error";
		} else {
			$response{stat}					    = "ok";
			$response{data}{conference_uuid}	= $uuid;
			$response{data}{dialplan_uuid}  	= $hash{1}{dialplan_uuid};
		}
    }
    
    &print_json_response(%response);    
}

sub editconference () {
    local %params = (
        conference_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_pin_number => {type => 'string', maxlen => 10, notnull => 0, default => ""},
		conference_profile => {type => 'enum:default,wideband,ultrawideband,cdquality',
                               maxlen => 255, notnull => 0, default => "default"},
        conference_flags => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		conference_order => {type => 'string', maxlen => 5, notnull => 0, default => '000'},
		conference_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		conference_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        dialplan_uuid   => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        conference_uuid   => {type => 'string', maxlen => 50, notnull => 1, default => 'false'}        
    );
	
	
	%response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	local %post_add = ();
	for $k (keys %params) {
		 $tmpval   = '';
		 if (&getvalue(\$tmpval, $k, $params{$k})) {
			 $post_add{$k} = $tmpval;
		 } else {
			 $response{stat}	= "fail";
			 $response{message}	= $k. &_(" not valid");
		 }
	}
    
	
	if ($response{stat} ne 'fail') {
        &post_data ('domain_uuid' => $domain{uuid},
					'urlpath'     => "/app/conferences/conference_edit.php?id=$post_add{conference_uuid}",
					'reload'	  => 1,
					'data'        => [%post_add]
					);
		
        #$location = $result->header("Location");
		
		$response{stat}		                = "ok";
        $response{data}{conference_uuid}    = $post_add{conference_uuid};
        $response{data}{dialplan_uuid}      = $post_add{dialplan_uuid};
		    
	}		
    
    &print_json_response(%response);   
}

sub getconferencelist () {
    local %response       = ();   
    local %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local %params = (
        conference_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_pin_number => {type => 'string', maxlen => 10, notnull => 0, default => ""},
		conference_profile => {type => 'enum:default,wideband,ultrawideband,cdquality',
                               maxlen => 255, notnull => 0, default => ""},
        conference_flags => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		conference_order => {type => 'string', maxlen => 5, notnull => 0, default => ''},
		conference_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		conference_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        conference_uuid   => {type => 'string', maxlen => 50, notnull => 1, default => 'false'}        
    );
    
    local $fields = join ',', keys %params;
    local %hash = &database_select_as_hash(
                        "select
                            conference_uuid,$fields
                        from
                            v_conferences
                        where
                            domain_uuid='$domain{uuid}'",
                        $fields);
    for (sort {$hash{$a}{conference_order} <=> $hash{$b}{conference_order}} keys %hash) {
        push @{$response{data}{list}}, $hash{$_};
    }
    $response{stat} = 'ok';
    &print_json_response(%response);
}

sub getconference () {
    local %response       = ();   
    local %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $conference_uuid	= &database_clean_string(substr($form{conference_uuid},0,50));

    local %params = (
        conference_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		conference_pin_number => {type => 'string', maxlen => 10, notnull => 0, default => ""},
		conference_profile => {type => 'enum:default,wideband,ultrawideband,cdquality',
                               maxlen => 255, notnull => 0, default => ""},
        conference_flags => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		conference_order => {type => 'string', maxlen => 5, notnull => 0, default => ''},
		conference_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		conference_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        dialplan_uuid   => {type => 'string', maxlen => 50, notnull => 1, default => 'false'},
        conference_uuid   => {type => 'string', maxlen => 50, notnull => 1, default => 'false'}        
    );
    
    local $fields = join ',', keys %params;
    local %hash = &database_select_as_hash(
                        "select
                            1,$fields
                        from
                            v_conferences
                        where
                            domain_uuid='$domain{uuid}' and
                            conference_uuid='$conference_uuid'",
                        $fields);
    
    
    if ($hash{1}{conference_uuid}) {
        $response{data} = $hash{1};
        $response{stat} = 'ok';
    } else {
        $response{stat} = 'fail';
        $response{message} = "not found by conference_uuid=$conference_uuid";
    }
    
    &print_json_response(%response); 
}

sub deleteconference () {
    $conference_uuid	= &database_clean_string(substr($form{conference_uuid},0,50));
	%response       = ();
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

	%hash = &database_select_as_hash (
				"select
					1,conference_uuid
				from
					v_conferences
				where
					conference_uuid='$conference_uuid' and
					domain_uuid='$domain{uuid}'",
				"uuid");
	
	if (!$hash{1}{uuid}) {
		$response{stat}    = "fail";
		$response{message} = "NOT FOUND";
	} else {
		&post_data ( 'domain_uuid' => $domain{uuid},
					'urlpath'     => "/app/conferences/conference_delete.php?id=$conference_uuid",
					'reload'      => 1,                    
					'data'        => []
				);
		$response{stat}    = "ok";
	}
	
	&print_json_response(%response);
}

return 1;
