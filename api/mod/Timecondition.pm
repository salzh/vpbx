=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addtimecondition () {    
    local $poststring_add = '
dialplan_name:tc
dialplan_number:6001
template2:Office Hours Mon-Fri 8am-5pm
condition_mday:
condition_wday:2-6
condition_minute_of_day:480-1020
condition_mon:
condition_mweek:
condition_yday:
condition_hour:
condition_minute:
condition_week:
condition_year:
action_1:transfer:*9910002 XML default.domain.net
anti_action_1:transfer:7001 XML default.domain.net
dialplan_order:300
dialplan_enabled:true
dialplan_description:
submit:Save
';

    local %post_add = ();
    for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
    }
    $response  = ();
   
    %domain   = &get_domain();
    local %params = (
        dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        dialplan_number => {type => 'string', maxlen => 20, notnull => 1, default => 'destination_number'},
        condition_mday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_wday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_minute_of_day => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_mon => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_mweek => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        condition_yday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_hour => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_minute => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_week => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_year => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        action_1 => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        anti_action_1 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        dialplan_order => {type => 'int', maxlen => 4, notnull => 0, default => '300'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		
    );
	 

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if ($response{stat} ne 'fail') {
       for $k (keys %params) {
            $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{stat}		= "fail";
                $response{message}	= $k. &_(" not valid");
            }
        }
    }
    
    
    if ($response{stat} ne 'fail') {
        &post_data (
           'domain_uuid' => $domain{uuid},
           'urlpath'     => '/app/time_conditions/time_condition_add.php',
           'reload'      => 1,
           'data'        => [%post_add]);
          
		#$location = $result->header("Location");
        %result = &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => "/app/dialplan/dialplans.php?app_uuid=4b821450-926b-175a-af93-a03c441818b1",
            'data'        => []
        );
		
		$location = $result->header("Location");
		($uuid) = $location =~ /app_uuid=(.+)$/;
		if (!1) {
			$response{stat}		= "fail";
            $response{message}	= $k. &_(" not valid");
		} else {
			$response{stat}		= "ok";
		}       
	}
    &print_json_response(%response);
}


sub gettimeconditionlist () {
	$form{type} = 'time';
    &getdialplanlist();
}

return 1;

