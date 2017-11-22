#{instant_ringback=true,ignore_early_media=true,sip_invite_domain=ssn.domain.net,origination_caller_id_name=Emer__#${caller_id_name},origination_caller_id_number=${caller_id_number}}[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14153363197,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152255467,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/19255491757,[outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,group_confirm_key=exec,group_confirm_file=lua confirm.lua,leg_delay_start=0,leg_timeout=0]loopback/14152158122
sub sendcall () {
	$destinations = $form{destinations};
	$alarmid	  = $form{alarmid};
	
	$ds = '';
	for (split ',', $destinations) {
		next unless $_;

		$ds ='[origination_caller_id_name=Emer__alarm,origination_caller_id_number=14159629911,outbound_caller_id_number=14159629911,presence_id=8888@ssn.domain.net,leg_delay_start=0,leg_timeout=0,domain_name=ssn.domain.net]loopback/' . $_ . '/ssn.domain.net/XML';

		`fs_cli -rx "bgapi originate $ds  playalarm$alarmid XML ssn.domain.net"`;
	}

	$response  = ();
	$response{error}{code}	   = 0;
	$response{error}{message} = 'OK';
	&print_json_response(%response);
}

1;
