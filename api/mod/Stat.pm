#{instant_ringback=true,ignore_early_media=true,sip_invite_domain=ssn.domain.net,origination_caller_id_name=Emer__#${caller_id_name},origination_caller_id_number=${caller_id_number}}[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14153363197,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152255467,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/19255491757,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152158122
sub getstat () {
	%domain         = &get_domain();
	if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
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


	$response  = ();
	$response{error}{code}	   = 0;
	$response{error}{message} = 'OK';
	$response{data} = \%data;
	&print_json_response(%response);
}

1;
