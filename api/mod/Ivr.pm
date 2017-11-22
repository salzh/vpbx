=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addivr () {
	local $poststring_add = '
ivr_menu_name:ivr1
ivr_menu_extension:7001
ivr_menu_greet_long:voicemail/vm-play_next_message.wav
ivr_menu_greet_short:voicemail/vm-hello.wav
ivr_menu_options[0][ivr_menu_option_digits]:0
ivr_menu_options[0][ivr_menu_option_param]:menu-exec-app:info
ivr_menu_options[0][ivr_menu_option_order]:000
ivr_menu_options[0][ivr_menu_option_description]:
ivr_menu_timeout:3000
ivr_menu_exit_action:
ivr_menu_direct_dial:false
ivr_menu_ringback:
ivr_menu_cid_prefix:
ivr_menu_invalid_sound:ivr/ivr-that_was_an_invalid_entry.wav
ivr_menu_exit_sound:
ivr_menu_confirm_macro:
ivr_menu_confirm_key:
ivr_menu_tts_engine:flite
ivr_menu_tts_voice:rms
ivr_menu_confirm_attempts:3
ivr_menu_inter_digit_timeout:2000
ivr_menu_max_failures:0
ivr_menu_max_timeouts:0
ivr_menu_digit_len:5
ivr_menu_enabled:true
ivr_menu_description:
';
	
	local %params = (
        ivr_menu_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_greet_long => {type => 'string', maxlen => 255, notnull => 1, default => ""},
		ivr_menu_greet_short => {type => 'string', maxlen => 255, notnull => 0, default => ""},

		ivr_menu_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '3000'},
		ivr_menu_exit_action => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_direct_dial => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		ivr_menu_ringback => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		ivr_menu_invalid_sound => {type => 'string', maxlen => 255, notnull => 0,
								   default => "ivr/ivr-that_was_an_invalid_entry.wav"},
		ivr_menu_exit_sound => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_macro => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_key => {type => 'string', maxlen => 0, notnull => 0, default => "#"},
		ivr_menu_tts_engine => {type => 'string', maxlen => 255, notnull => 0, default => "rms"},
		ivr_menu_confirm_attempts => {type => 'int', maxlen => 3, notnull => 0, default => '3'},
		ivr_menu_inter_digit_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '2000'},
		ivr_menu_max_failures => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_max_timeouts => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_digit_len => {type => 'int', maxlen => 3, notnull => 0, default => '5'},
		ivr_menu_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		ivr_menu_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}		
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
		for (0..99) {
			last unless $form{"ivr_menu_options[$_][ivr_menu_option_param]"};
			$post_add{"ivr_menu_options[$_][ivr_menu_option_digits]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_digits]"});
			$post_add{"ivr_menu_options[$_][ivr_menu_option_param]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_param]"});								
			$post_add{"ivr_menu_options[$_][ivr_menu_option_param]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_order]"});
			$post_add{"ivr_menu_options[$_][ivr_menu_option_order]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_description]"});
		}
		
		$result = &post_data ('domain_uuid' => $domain{uuid},
					'urlpath'     => '/app/ivr_menu/ivr_menu_edit.php',
					'reload'	  => 1,
					'data'        => [%post_add]
					);
		
		$location = $result->header("Location");
		#warn $location;
		($uuid) = $location =~ /id=(.+)$/;
		if (!$uuid) {
			$response{stat}		= "fail";
			$response{message}	= "Error";
		} else {
			$response{stat}					= "ok";
			$response{data}{ivr_menu_uuid}	= $uuid;
		}     
	}
	
    &print_json_response(%response);    
}

sub editivr () {
	local $poststring_add = '
ivr_menu_name:ivr1
ivr_menu_extension:7001
ivr_menu_greet_long:voicemail/vm-play_next_message.wav
ivr_menu_greet_short:voicemail/vm-hello.wav
ivr_menu_options[0][ivr_menu_option_digits]:
ivr_menu_options[0][ivr_menu_option_param]:
ivr_menu_options[0][ivr_menu_option_order]:000
ivr_menu_options[0][ivr_menu_option_description]:
ivr_menu_timeout:3000
ivr_menu_exit_action:answer
ivr_menu_direct_dial:false
ivr_menu_ringback:
ivr_menu_cid_prefix:
ivr_menu_invalid_sound:ivr/ivr-that_was_an_invalid_entry.wav
ivr_menu_exit_sound:
ivr_menu_confirm_macro:
ivr_menu_confirm_key:
ivr_menu_tts_engine:flite
ivr_menu_tts_voice:rms
ivr_menu_confirm_attempts:3
ivr_menu_inter_digit_timeout:2000
ivr_menu_max_failures:0
ivr_menu_max_timeouts:0
ivr_menu_digit_len:5
ivr_menu_enabled:true
ivr_menu_description:
ivr_menu_uuid:f973900c-dbba-46b0-98fd-4fef24e8d866
';
	
	%response       = ();


    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local %params = (
		ivr_menu_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        ivr_menu_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_greet_long => {type => 'string', maxlen => 255, notnull => 1, default => ""},
		ivr_menu_greet_short => {type => 'string', maxlen => 255, notnull => 0, default => ""},

		ivr_menu_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '3000'},
		ivr_menu_exit_action => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_direct_dial => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		ivr_menu_ringback => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		ivr_menu_invalid_sound => {type => 'string', maxlen => 255, notnull => 0, 
								   default => "ivr/ivr-that_was_an_invalid_entry.wav"},
		ivr_menu_exit_sound => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_macro => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_key => {type => 'string', maxlen => 0, notnull => 0, default => "#"},
		ivr_menu_tts_engine => {type => 'string', maxlen => 255, notnull => 0, default => "rms"},
		ivr_menu_confirm_attempts => {type => 'int', maxlen => 3, notnull => 0, default => '3'},
		ivr_menu_inter_digit_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '2000'},
		ivr_menu_max_failures => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_max_timeouts => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_digit_len => {type => 'int', maxlen => 3, notnull => 0, default => '5'},
		ivr_menu_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		ivr_menu_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},	
    );
	
	local %post_add = ();
	for $k (keys %params) {
		 $tmpval   = '';
		 if (&getvalue(\$tmpval, $k, $params{$k})) {
			 $post_add{$k} = $tmpval;
		 } else {
			 $response{stat}		= "fail";
			 $response{message}	= $k. &_(" not valid");
		 }
	}
    
	
	if ($response{stat} ne 'fail') {		
	
		for (0..99) {
			last unless $form{"ivr_menu_options[$_][ivr_menu_option_param]"};
			$post_add{"ivr_menu_options[$_][ivr_menu_option_digits]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_digits]"});
			$post_add{"ivr_menu_options[$_][ivr_menu_option_param]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_param]"});								
			$post_add{"ivr_menu_options[$_][ivr_menu_option_order]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_order]"});
			$post_add{"ivr_menu_options[$_][ivr_menu_option_description]"}
					= &database_clean_string($form{"ivr_menu_options[$_][ivr_menu_option_description]"});
		}
		
		%result = &post_data ('domain_uuid' => $domain{uuid},
					'urlpath'     => "/app/ivr_menu/ivr_menu_edit.php?id=$post_add{ivr_menu_uuid}",
					'reload'	  => 1,
					'data'        => [%post_add]
					);
		
		$location = $result->header("Location");
		($uuid) = $location =~ /id=(.+)$/;
		if (!$uuid) {
			$response{stat}		= "fail";
			$response{message}	= "Error";
		} else {
			$response{stat}					= "ok";
			$response{data}{ivr_menu_uuid}	= $uuid;
		}     
	}
	
	&print_json_response(%response);    

}

sub deleteivroption () {
	$ivr_menu_uuid	  	  = &clean_str(substr($form{ivr_menu_uuid},0,50),"MINIMAL","-_");
	$ivr_menu_option_uuid = &clean_str(substr($form{ivr_menu_option_uuid},0,50),"MINIMAL","-_");
	
		
	%response       = ();
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
	
	
	%hash = &database_select_as_hash (
				"select
					1,ivr_menu_option_uuid
				from
					v_ivr_menu_options
				where
					ivr_menu_option_uuid='$ivr_menu_option_uuid' and
					ivr_menu_uuid='$ivr_menu_uuid'",
				"uuid");
	if (!$hash{1}{uuid}) {
		$response{stat}    = "fail";
		$response{message} = "NOT FOUND";
	} else {
		&post_data ( 'domain_uuid' => $domain{uuid},
						'urlpath'     => "/app/ivr_menu/ivr_menu_option_delete.php?id=$ivr_menu_option_uuid&ivr_menu_uuid=$ivr_menu_uuid",
						'reload'      => 1,                    
						'data'        => []
						);
		$response{stat}    = "ok";
	}
	
	&print_json_response(%response);
}

sub getivrlist () {
	
	%response       = ();
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

	%hash = &database_select_as_hash(
				"select
					ivr_menu_uuid,ivr_menu_uuid,ivr_menu_name,ivr_menu_extension,ivr_menu_direct_dial,ivr_menu_enabled,ivr_menu_description
				from
					v_ivr_menus
				where
					domain_uuid='$domain{uuid}'",
				'ivr_menu_uuid,ivr_menu_name,ivr_menu_extension,ivr_menu_direct_dial,ivr_menu_enabled,ivr_menu_description');
	@menus = ();
	
	for (sort {$hash{$a}{name} cmp $hash{$b}{name}} keys %hash) {
		push @menus, $hash{$_};
	}
	
	$response{stat}    = "ok";
	$response{data}{ivr_list} = \@menus;
	
	
	&print_json_response(%response);
}

sub getivr () {
	local %params = (
		ivr_menu_uuid => {type => 'string', maxlen => 50, notnull => 1, default => 'false'},
        ivr_menu_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		ivr_menu_greet_long => {type => 'string', maxlen => 255, notnull => 1, default => ""},
		ivr_menu_greet_short => {type => 'string', maxlen => 255, notnull => 0, default => ""},

		ivr_menu_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '3000'},
		ivr_menu_exit_app => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_exit_data => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_direct_dial => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		ivr_menu_ringback => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		ivr_menu_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default =>'false'},
		ivr_menu_invalid_sound => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_exit_sound => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_invalid_sound => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_macro => {type => 'string', maxlen => 255, notnull => 0, default => ""},
		ivr_menu_confirm_key => {type => 'string', maxlen => 1, notnull => 0, default => "#"},
		ivr_menu_tts_engine => {type => 'string', maxlen => 255, notnull => 0, default => "rms"},
		ivr_menu_confirm_attempts => {type => 'int', maxlen => 3, notnull => 0, default => '3'},
		ivr_menu_inter_digit_timeout => {type => 'int', maxlen => 5, notnull => 0, default => '2000'},
		ivr_menu_max_failures => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_max_timeouts => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		ivr_menu_digit_len => {type => 'int', maxlen => 3, notnull => 0, default => '5'},
		ivr_menu_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		ivr_menu_description => {type => 'string', maxlen => 255, notnull => 0, default => 'false'}	
    );
	
	%response       = ();
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

	
	$fields    = join ',', keys %params;
	$ivr_menu_uuid	= &database_clean_string(substr($form{ivr_menu_uuid},0,50));
	
	
	%hash = &database_select_as_hash(
					"select
						1, $fields
					from
						v_ivr_menus
					where
						ivr_menu_uuid='$ivr_menu_uuid'",
					$fields);
	if (!$hash{1}{ivr_menu_uuid}) {
		$response{stat}    = "fail";
		$response{message} = "NOT FOUND";
	} else {
		
		@options = ();
		%o = &database_select_as_hash(
					"select
						ivr_menu_option_uuid,ivr_menu_option_digits,ivr_menu_option_param,ivr_menu_option_order,ivr_menu_option_description
					from
						v_ivr_menu_options where ivr_menu_uuid='$ivr_menu_uuid'",
					'ivr_menu_option_digits,ivr_menu_option_param,ivr_menu_option_order,ivr_menu_option_description');
		
		$i = 0;
		
		for (sort {$o{$a}{ivr_menu_option_order} <=> $o{$b}{ivr_menu_option_order}} keys %o) {
			push @options, {"ivr_menu_options[$i][ivr_menu_option_digits]" => $o{$_}{ivr_menu_option_digits},
							"ivr_menu_options[$i][ivr_menu_option_param]"  => $o{$_}{ivr_menu_option_param},
							"ivr_menu_options[$i][ivr_menu_option_order]"  => $o{$_}{ivr_menu_option_order},
							"ivr_menu_options[$i][ivr_menu_option_description]"  => $o{$_}{ivr_menu_option_description},
							"ivr_menu_options[$i][ivr_menu_option_uuid]"  => $_
						   };
			$i++;
							
		}
		
		$hash{1}{options_list}  = \@options;
		$response{stat}   	 = "ok";
		$response{data}		 = $hash{1};
	}
	
	&print_json_response(%response);
}

sub deleteivr() {
	$ivr_menu_uuid	= &database_clean_string(substr($form{ivr_menu_uuid},0,50));
	%response       = ();
    %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

	%hash = &database_select_as_hash (
				"select
					1,ivr_menu_uuid
				from
					v_ivr_menus
				where
					ivr_menu_uuid='$ivr_menu_uuid' and
					domain_uuid='$domain{uuid}'",
				"uuid");
	
	if (!$hash{1}{uuid}) {
		$response{stat}    = "fail";
		$response{message} = "NOT FOUND";
	} else {
		&post_data ( 'domain_uuid' => $domain{uuid},
					'urlpath'     => "/app/ivr_menu/ivr_menu_delete.php?id=$ivr_menu_uuid",
					'reload'      => 1,                    
					'data'        => []
				);
		$response{stat}    = "ok";
		$response{message} = "OK";
	}
	
	&print_json_response(%response);
}

return 1;
