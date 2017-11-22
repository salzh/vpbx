=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addagent () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        agent_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_status => {type => 'string', maxlen => 50, notnull => 0, default => 'Available'},
        agent_contact => {type => 'string', maxlen => 250, notnull => 1, default => ''},        
        agent_type => {type => 'string', maxlen => 20, notnull => 0, default => 'callback'},
        agent_call_timeout => {type => 'int', maxlen => 5, notnull => 0, default =>'10'},
        agent_no_answer_delay_tme => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_max_no_answer => {type => 'int', maxlen => 5, notnull => 0, default => '0'},
        agent_wrap_up_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_reject_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_busy_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        agent_logout => {type => 'string', maxlen => 250, notnull => 0, default => ''}
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
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
        %hash = &database_select_as_hash(
                "select
                    1,call_center_agent_uuid
                from
                    v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    agent_name='$post_add{agent_name}'",
                'uuid'
        );
        
        if ($hash{1}{uuid}) {
             &print_api_error_end_exit(120, "$post_add{agent_name} already added!");
        }
        
        &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/call_center/call_center_agent_edit.php',
                     'data'        => [%post_add]);
          
        %hash = &database_select_as_hash(
              "select
                  1,call_center_agent_uuid
              from
                  v_call_center_agents
              where
                  domain_uuid='$domain{uuid}' and
                  agent_name='$post_add{agent_name}'",
              'uuid'
        );
        
        if ($hash{1}{uuid}) {
            $response{stat}                         = 'ok';
            $response{data}{call_center_agent_uuid} = $hash{1}{uuid};
        } else {
            $response{stat}    = 'fail';
            $response{message} = 'not saved'
        }
    }
    
    
    &print_json_response(%response);       
}

sub editagent() {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        call_center_agent_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_status => {type => 'string', maxlen => 50, notnull => 0, default => 'Available'},
        agent_contact => {type => 'string', maxlen => 250, notnull => 1, default => ''},        
        agent_type => {type => 'string', maxlen => 20, notnull => 0, default => 'callback'},
        agent_call_timeout => {type => 'int', maxlen => 5, notnull => 0, default =>'10'},
        agent_no_answer_delay_tme => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_max_no_answer => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_wrap_up_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_reject_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_busy_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        agent_logout => {type => 'string', maxlen => 250, notnull => 0, default => ''}
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
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
        %hash = &database_select_as_hash(
                "select
                    1,call_center_agent_uuid
                from
                    v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    agent_name='$post_add{agent_name}' and
                    call_center_agent_uuid <> '$post_add{call_center_agent_uuid}'",
                'uuid'
        );
        
        if ($hash{1}{uuid}) {
             &print_api_error_end_exit(120, "$post_add{agent_name} already added!");
        }
        
        &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/call_center/call_center_agent_edit.php?id=$post_add{call_center_agent_uuid}",
                     'data'        => [%post_add]);
          
        %hash = &database_select_as_hash(
              "select
                  1,call_center_agent_uuid
              from
                  v_call_center_agents
              where
                  domain_uuid='$domain{uuid}' and
                  agent_name='$post_add{agent_name}'",
              'uuid'
        );
        
        if ($hash{1}{uuid}) {
            $response{stat}                         = 'ok';
            $response{data}{call_center_agent_uuid} = $hash{1}{uuid};
        } else {
            $response{stat}    = 'fail';
            $response{message} = 'not saved'
        }
    }
    
    
    &print_json_response(%response);    
}

sub getagentlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $fields = 'call_center_agent_uuid,agent_name,agent_type,agent_call_timeout,agent_contact,agent_status,agent_max_no_answer';
    %hash = &database_select_as_hash(
                "select
                    call_center_agent_uuid,$fields
                from
                     v_call_center_agents
                where
                    domain_uuid='$domain{uuid}'",
                $fields
    );
    
    $output = &runswitchcommand('internal', 'callcenter_config agent list');
    %agent_status = ();
    for (split /\n/, $output) {
    	@cols = split /\|/;
    	$agent_status{$cols[0]} = $cols[5];
    	warn $cols[0], ' ==> ', $cols[5], "\n";
    }
    for (sort {$hash{$a}{agent_name} cmp $hash{$b}{agent_name}} keys %hash) {
    		$hash{$_}{agent_status} = $agent_status{$hash{$_}{agent_name} . '@' . $domain{name}};
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    
    &print_json_response(%response);    
}

sub getagent() {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_agent_uuid = &database_clean_string(substr $form{call_center_agent_uuid}, 0, 50);
    $fields = 'call_center_agent_uuid,agent_name,agent_type,agent_call_timeout,agent_contact,agent_status,agent_max_no_answer,' .
              'agent_logout,agent_wrap_up_time,agent_reject_delay_time,agent_busy_delay_time,agent_no_answer_delay_time';
    %hash = &database_select_as_hash(
                "select
                    1,$fields
                from
                     v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_agent_uuid='$call_center_agent_uuid'",
                $fields
    );
    
    if ($hash{1}) {    
        $response{stat} = 'ok';
        $response{data} = $hash{1};
    } else {
        $response{stat}    = 'fail';
        $response{message} = "Agent not found";
    }
    
    &print_json_response(%response);     
}

sub deleteagent () {
    $call_center_agent_uuid = &database_clean_string(substr $form{call_center_agent_uuid}, 0, 50);
    
    %hash = &database_select_as_hash(
                "select
                    1,call_center_agent_uuid
                from
                    v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_agent_uuid='$call_center_agent_uuid'",
                'uuid'
    );
    
    if ($hash{1}) {
        $response{stat} = 'ok';
        &post_data (
             'domain_uuid' => $domain{uuid},
             'urlpath'     => '/app/call_center/call_center_agent_delete.php' . "?id=$call_center_agent_uuid",
             'reload'      => 1,
             'data'        => []);    
    } else {
        $response{stat}    = 'fail';
        $response{message} = "not found agent"
    }
    
    &print_json_response(%response);
}


return 1;