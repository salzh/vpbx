=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addcallcenter() {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 0, default => ''}
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
       %result = &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/call_center/call_center_queue_edit.php',
                     'data'        => [%post_add]);
          
          $location = $result->header("Location");
          ($uuid) = $location =~ /id=(.+)$/;
          if (!$uuid) {
               $response{stat}		= "fail";
               $response{message}	= "Error";
          } else {         
               $response{stat}                         = "ok";
               $response{data}{call_center_queue_uuid} = $uuid;
          }
    }
    
    
    &print_json_response(%response);    
}

sub editcallcenter () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        call_center_queue_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},        
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        
        agent_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_level => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        tier_position => {type => 'int', maxlen => 3, notnull => 0, default => '1'},
        
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
        $post_add{id} = $post_add{call_center_queue_uuid};
        if ($form{call_center_tier_uuid}) {
            $post_add{delete_type} = 'tier';
            $post_add{delete_uuid} = $form{call_center_tier_uuid}
        }
        
        %hash = &database_select_as_hash(
                "select
                    1,call_center_queue_uuid
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_queue_uuid='$post_add{call_center_queue_uuid}'",
                'uuid'
        );
    
        if ($hash{1}) {
            $post_add{id} = $post_add{call_center_queue_uuid};
            %result = &post_data (
                        'domain_uuid' => $domain{uuid},
                        'urlpath'     => "/app/call_center/call_center_queue_edit.php?id=$post_add{call_center_queue_uuid}",
                        'data'        => [%post_add]);
              
                $location = $result->header("Location");
                ($uuid) = $location =~ /id=(.+)$/;
                if (!$uuid) {
                    $response{stat}		= "fail";
                    $response{message}	= "Error";
                } else {         
                    $response{stat}                         = "ok";
                    $response{data}{call_center_queue_uuid} = $uuid;
                }
        } else {
            $response{stat}		= "fail";
            $response{message}	= "Call CENTER QUEUE NOT FOUND";
        }
    }
    
    &print_json_response(%response);    
}

sub getcallcenterlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $fields = 'call_center_queue_uuid,queue_name,queue_extension,queue_strategy,queue_tier_rules_apply,queue_description';
    %hash = &database_select_as_hash(
                "select
                    call_center_queue_uuid,$fields
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}'",
                $fields
    );
    
    for (sort {$hash{$a}{queue_name} cmp $hash{$b}{queue_name}} keys %hash) {
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    
    &print_json_response(%response);
}

sub getcallcenter () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_queue_uuid = &database_clean_string(substr $form{call_center_queue_uuid}, 0, 50);
    
     local %params = (
        call_center_queue_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},        
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 1, default => ''},
        
        agent_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_level => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        tier_postion => {type => 'int', maxlen => 3, notnull => 0, default => '1'},
        
        delete_type => {type => 'string', maxlen => 50, notnull => 0, default => 'tier'}
    );
    $fields = 'call_center_queue_uuid,queue_name,queue_extension,queue_strategy,queue_tier_rules_apply,queue_description,' .
              'queue_moh_sound,queue_record_template,queue_time_base_score,queue_max_wait_time,' .
              'queue_max_wait_time_with_no_agent,queue_max_wait_time_with_no_agent_time_reached,' .
              'queue_timeout_action,queue_tier_rules_apply,queue_tier_rule_wait_second,queue_tier_rule_wait_multiply_level,' .
              'queue_tier_rule_no_agent_no_wait,queue_discard_abandoned_after,queue_abandoned_resume_allowed,' .
              'queue_cid_prefix,queue_announce_sound,queue_announce_frequency';
              
              
    %hash = &database_select_as_hash(
                "select
                    1,$fields
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_queue_uuid='$call_center_queue_uuid'",
                $fields
    );
    
    if ($hash{1}) {
        $response{stat} = 'ok';
        $response{data} = $hash{1};
        
        %tier = &database_select_as_hash(
            "select
                1,call_center_tier_uuid,call_center_tier_uuid,agent_name,tier_level,tier_position
            from
                v_call_center_tiers
            where
                domain_uuid='$domain{uuid}' and
                queue_name='$hash{1}{queue_name}'",
            "call_center_tier_uuid,agent_name,tier_level,tier_position"
        );
        
        for (sort {$tier{$a}{tier_position} <=> $tier{$b}{tier_position}} keys %tier) {
            push @{$response{data}{tier_list}}, $tier{$_};
        }
        
    } else {
        $response{stat}    = 'fail';
        $response{message} = "not found call_center";
    }
    
    &print_json_response(%response);   
}

sub deletecallcenter () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_queue_uuid = &database_clean_string(substr $form{call_center_queue_uuid}, 0, 50);
    
    %hash = &database_select_as_hash(
                "select
                    1,call_center_queue_uuid
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_queue_uuid='$call_center_queue_uuid'",
                'uuid'
    );
    
    if ($hash{1}{uuid}) {
        $response{stat} = 'ok';
        &post_data (
             'domain_uuid' => $domain{uuid},
             'urlpath'     => '/app/call_center/call_center_queue_delete.php' . "?id=$call_center_queue_uuid",
             'reload'      => 1,
             'data'        => []);    
    } else {
        $response{stat}    = 'fail';
        $response{message} = "not found call_center"
    }
    
    &print_json_response(%response);
}

sub deletecallcenteragent () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $delete_uuid = &database_clean_string(substr $form{call_center_tier_uuid}, 0, 50);
    %tier = &database_select_as_hash(
        "select
            1,call_center_tier_uuid
        from
            v_call_center_tiers
        where
            call_center_tier_uuid='$delete_uuid'",
        "uuid");
    
    if (!$tier{1}{uuid}) {
        $response{stat}    = 'fail';
        $response{message} = "not found this tier";
        &print_json_response(%response);

    } else {
        &editcallcenter();
    }        
}

return 1;