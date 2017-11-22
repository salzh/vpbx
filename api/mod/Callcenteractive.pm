=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub callcenteractivedetail() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name   = &database_clean_string(substr $form{callcenter_name}, 0, 10);
    %hash = &database_select_as_hash(
                "select
                    1,call_center_queue_uuid
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    queue_name='$name'",
                'uuid'
    );
    
    if (!$hash{1}) {
        &print_api_error_end_exit(90, "$name\@$domain{name} not found"); 
    }
    
    $output = &runswitchcommand('internal', "callcenter_config queue list agents $name\@$domain_name");
    
    $fields_name = "name|system|uuid|type|contact|status|state|max_no_answer|wrap_up_time|" .
                   "reject_delay_time|busy_delay_time|no_answer_delay_time|last_bridge_start|" .
                   "last_bridge_end|last_offered_call|last_status_change|no_answer_count|" .
                   "calls_answered|talk_time|ready_time";
    @fields_name = split /\|/, $fields_name;
    
    $j = 0;
    for $line (split /\n/, $output) {
        next unless $line;
        @fields = split /\|/, $line;
        next if $fields[0] eq 'name' || $fields[0] eq '+OK';
        
        $i = 0;
        for (@fields_name) {
            $response{data}{agent_list}[$j]{$_} = $fields[$i];
            $i++;
        }
        
        $j++;
    }
    
    $output = &runswitchcommand('internal', "callcenter_config queue list members $name\@$domain_name");
    $fields_name = "queue|system|uuid|session_uuid|cid_number|cid_name|system_epoch|joined_epoch|" .
                   "rejoined_epoch|bridge_epoch|abandoned_epoch|base_score|skill_score|serving_agent|" .
                   "serving_system|state|score";
    @fields_name = split /\|/, $fields_name;
    
    $j = 0;         
    for $line (split /\n/, $output) {
        next unless $line;
        @fields = split  /\|/, $line;
        next if $fields[0] eq 'queue' || $fields[0] eq '+OK';
        
        $i = 0;
        for (@fields_name) {
            $response{data}{member_list}[$j]{$_} = $fields[$i++];
        }
        
        $j++;
        
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response); 
 
}


return 1;