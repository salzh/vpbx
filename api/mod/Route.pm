=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addinboundroute () {
	local $poststring_add = '
dialplan_name:3402459922
condition_field_1:destination_number
condition_expression_1:/^(3402459922)$/
condition_field_2:
condition_expression_2:
action_1:transfer:7002 XML default.domain.net
action_2:
limit:
public_order:100
dialplan_enabled:true
dialplan_description:
';

	local %post_add = ();
	for (split /\n/, $poststring_add) {
		 ($key, $val) = split ':', $_, 2;
		 next if !$key;
		 $post_add{$key} = $val;
	}
	
	local %params = (
        dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        condition_field_1 => {type => 'string', maxlen => 20, notnull => 0, default => 'destination_number'},
        condition_expression_1 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        condition_field_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        condition_expression_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        action_1 => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        action_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        limit => {type => 'int', maxlen => 4, notnull => 0, default =>''},
        public_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		
    );
	 
	%response       = ();   
    %domain         = &get_domain();

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
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/dialplan_inbound/dialplan_inbound_add.php?action=advanced',
			'reload'      => 1,
			'data'        => [%post_add]);
		#warn $result->header("Location");
		$location = $result->header("Location");
		($uuid) = $location =~ /app_uuid=(.+)$/;
		if (!$uuid) {
			$response{stat}		= "fail";
            $response{message}	= $k. &_(" not valid");
		} else {
			$response{stat}		= "ok";
		}       
	}
	
	&print_json_response(%response);
}

#note: gateway is the gatewayuuid+gatewayname
sub addoutboundroute () {
	local $poststring_add = '
gateway:4e6a5f2e-5e15-48cb-b4b7-9c6d2d6754bc:default
gateway_2:4e6a5f2e-5e15-48cb-b4b7-9c6d2d6754bc:default
gateway_3:
dialplan_expression:^\d{10}$
dialplan_expression_select:^(\d{7})$
prefix_number:1
limit:200
accountcode:
dialplan_order:100
dialplan_enabled:true
dialplan_description:
submit:Save';

	
	local %params = (
        gateway => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        gateway2 => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        gateway3 => {type => 'string', maxlen => 50, notnull => 0, default => ''},
       
        dialplan_expression => {type => 'regexp', maxlen => 255, notnull => 1, default => ''},
        dialplan_expression_select => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        prefix_number => {type => 'string', maxlen => 20, notnull => 0, default => ''},
    
        limit => {type => 'int', maxlen => 4, notnull => 0, default =>''},
		accountcode => {type => 'string', maxlen => 50, notnull => 0, default => ''},

        public_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}		
    );

	
	local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if ($response{error}{code} ne 'fail') {
       for $k (keys %params) {
            local $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{stat}		= "fail";
                $response{message}	= $k. &_(" not valid");
            }
       }
    }
	
	if ($response{stat} ne 'fail') {
		warn $post_add{dialplan_expression};

		#for (split /\n/, $form{dialplan_expression}) {
			#$post_add{dialplan_expression} = substr $_, 0, 50;
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => "/app/dialplan_outbound/dialplan_outbound_add.php",
			'data'        => [%post_add]
		);
		
		$location = $result->header("Location");
		($uuid) = $location =~ /app_uuid=(.+)$/;
		
		if (!$uuid){
			$response{stat}		= "fail";
			$response{message}	= $post_add{dialplan_expression}. &_(" not inserted into  db");
		} else {			
			$response{stat}	= "ok";
		}			       
		#}
	}
    &print_json_response(%response);
}


sub getinboundroutelist () {
	$form{type} = 'inbound';
    &getdialplanlist();
}

sub getoutboundroutelist () {
	$form{type} = 'outbound';
	&getdialplanlist();
}


return 1;

