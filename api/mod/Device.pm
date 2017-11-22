local $poststring_add = '
device_mac_address:00:26:b6:7d:2f:5d
device_label:00:26:b6:7d:2f:5d
device_template:yealink/t28p
device_lines[0][line_number]:1
device_lines[0][server_address]:pbx.fusionpbx.cn
device_lines[0][outbound_proxy]:
device_lines[0][display_name]:10000
device_lines[0][user_id]:
device_lines[0][auth_id]:10000
device_lines[0][password]:123--
device_lines[0][sip_port]:
device_lines[0][sip_transport]:tcp
device_lines[0][register_expires]:
device_keys[0][device_key_category]:
device_keys[0][device_key_id]:
device_keys[0][device_key_type]:
device_keys[0][device_key_line]:
device_keys[0][device_key_value]:
device_keys[0][device_key_extension]:
device_keys[0][device_key_label]:
device_settings[0][device_setting_subcategory]:
device_settings[0][device_setting_value]:
device_settings[0][device_setting_enabled]:
device_settings[0][device_setting_description]:
device_vendor:
device_model:
device_firmware_version:
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
device_provision_enable:true
device_description:
';

sub adddevice () {
    local %params= (
        device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
       
        device_vendor => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_provision_enable => {type => 'bool', maxlen => 50, notnull => 1, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 1, default => ''},
    );
    
    for (0..11) {
        if (defined $form{'device_lines[' . $_ . '][line_number]'}) {
            $params{'device_lines[' . $_ . '][line_number]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
            $params{'device_lines[' . $_ . '][server_address]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_lines[' . $_ . '][outbound_proxy]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][display_name]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][password]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][sip_port]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][sip_transport]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][register_expires]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
        } else {
            last;
        }
    }
    
    for (0.99) {
        if (defined $form{'device_keys[' . $_ .'][device_key_id]'}) {
           
            $params{'device_keys[' . $_ . '][device_key_category]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
             $params{'device_keys[' . $_ . '][device_key_id]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_type]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_line]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_extension]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_label]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            
        } else {
            last;
        }
    }
    
    for (0.99) {
        if (defined $form{'device_settings[' . $_ .'][device_setting_subcategory]'}) {           
            $params{'device_settings[' . $_ . '][device_setting_subcategory]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_enabled]'} = {type => 'bool', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_description]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
             
        } else {
            last;
        }
    }
    %post_add       = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {
       for $k (keys %params) {
            $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{error}{code}		= "1";
                $response{error}{message}	= $k. &_(" not valid");
            }
       }
    }
    
	if (!$response{error}{code}) {
        $post_add{domain_uuid} = $domain{uuid};
        $result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/devices/device_edit.php',
			'reload'      => 1,
			'data'        => [%post_add]);
		#warn $result->header("Location");
		$location = $result->header("Location");
		($uuid) = $location =~ /id=(.+)$/;
		if (!$uuid) {
			$response{error}{code}		= "1";
			$response{error}{message}	= "Error";
		} else {
            $response{error}{code}		= "0";
			$response{error}{message}	= "ok";
            $response{data}{device_uuid} = $uuid;
        }
    }
    
   	&print_json_response(%response);
}

sub editdevice () {
    local %params= (
        device_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
       
        device_vendor => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_provision_enable => {type => 'bool', maxlen => 50, notnull => 1, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 1, default => ''},
    );
    
    for (0..11) {
        if (defined $form{'device_lines[' . $_ . '][line_number]'}) {
            $param{'device_lines[' . $_ . '][device_line_uuid]'} = {type => 'string', maxlen => 200, notnull => 1, default => ''};
   
            $params{'device_lines[' . $_ . '][line_number]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
            $params{'device_lines[' . $_ . '][server_address]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_lines[' . $_ . '][outbound_proxy]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][display_name]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][password]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][sip_port]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][sip_transport]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $param{'device_lines[' . $_ . '][register_expires]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
        } else {
            last;
        }
    }
    
    for (0.99) {
        if (defined $form{'device_keys[' . $_ .'][device_key_id]'}) {
            $params{'device_keys[' . $_ . '][device_key_uuid]'} = {type => 'string', maxlen => 200, notnull => 1, default => ''};
           
            $params{'device_keys[' . $_ . '][device_key_category]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
             $params{'device_keys[' . $_ . '][device_key_id]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_type]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_line]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_extension]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_keys[' . $_ . '][device_key_label]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            
        } else {
            last;
        }
    }
    
    for (0.99) {
        if (defined $form{'device_settings[' . $_ .'][device_setting_subcategory]'}) {           
            $params{'device_settings[' . $_ . '][device_setting_uuid]'} = {type => 'string', maxlen => 200, notnull => 1, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_subcategory]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_enabled]'} = {type => 'bool', maxlen => 200, notnull => 0, default => ''};
            $params{'device_settings[' . $_ . '][device_setting_description]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
             
        } else {
            last;
        }
    }
    %post_add       = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {
       for $k (keys %params) {
            $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{error}{code}		= "1";
                $response{error}{message}	= $k. &_(" not valid");
            }
       }
    }
    
	if (!$response{error}{code}) {
        $post_add{domain_uuid} = $domain{uuid};
        $result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/devices/device_edit.php?id=' . $post_add{device_uuid},
			'reload'      => 1,
			'data'        => [%post_add]);
		#warn $result->header("Location");
		
        $response{error}{code}		= "0";
        $response{error}{message}	= "ok";
        $response{data}{device_uuid} = $uuid;        
    }
    
  	&print_json_response(%response);
}

sub getdevicelist () {
    local %params = (
        device_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
       
        device_vendor => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_provision_enable => {type => 'bool', maxlen => 50, notnull => 1, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 1, default => ''},
    );
    
    %domain = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {
        $fields = join ",", keys %params;
    
        %hash = &database_select_as_hash_with_key ("
                    select
                        device_uuid,v_devices.*
                    from
                        v_devices
                    where
                        domain_uuid='$domain{uuid}'",
                    'device_uuid',
                    "$fields");
       
        $response{error}{code}		= "0";
        $response{error}{message}	= "OK";
        
        for (keys %hash) {
            push @{$response{data}}, $hash{$_};
        }
    }   
      
  	&print_json_response(%response);      
}

sub getdevice() {    
    local %params= (
        device_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
       
        device_vendor => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_provision_enable => {type => 'bool', maxlen => 50, notnull => 1, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 1, default => ''},
    );
    
    $uuid   =  &clean_str($form{device_uuid}, "-_");
    %domain = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {
        $fields = join ",", keys %params;
    
        %hash = &database_select_as_hash_with_key ("
                    select
                        1,device_uuid,v_devices.*
                    from
                        v_devices
                    where
                        domain_uuid='$domain{uuid}' and device_uuid='$uuid'",
                    '1',
                    $fields);
        
        if (!$hash{1}{device_uuid}) {
            $response{error}{code}		= "1";
            $response{error}{message}	= &_("not found device");
        } else {
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            
            $response{data} = $hash{1};
            
            %line = &database_select_as_hash ("
                                            select
                                                device_line_uuid,line_number,server_address,
                                                outbound_proxy,display_name,user_id,auth_id,
                                                password,sip_port,sip_transport,register_expires
                                            from
                                                v_device_lines
                                            where
                                                device_uuid='$uuid'",
                                                
                                            "line_number,server_address," .
                                            "outbound_proxy,display_name,user_id,auth_id" .
                                            "password,sip_port,sip_transport,register_expires");
            
            $i = 0;
            for (sort {$line{$a}{line_number} <=> $line{$b}{line_number}} keys %line) {
                $response{data}{'device_lines[' . $i. '][line_number]'} = $line{$_}{line_number};
                $response{data}{'device_lines[' . $i. '][device_line_uuid]'} =$_;
                $response{data}{'device_lines[' . $i. '][server_address]'} = $line{$_}{server_address};
                $response{data}{'device_lines[' . $i. '][outbound_proxy]'} = $line{$_}{outbound_proxy};
                $response{data}{'device_lines[' . $i. '][display_name]'} = $line{$_}{display_name};
                $response{data}{'device_lines[' . $i. '][user_id]'} = $line{$_}{user_id};
                $response{data}{'device_lines[' . $i. '][auth_id]'} = $line{$_}{auth_id};
                $response{data}{'device_lines[' . $i. '][password]'} = $line{$_}{password};
                $response{data}{'device_lines[' . $i. '][sip_port]'} = $line{$_}{sip_port};
                $response{data}{'device_lines[' . $i. '][sip_transport]'} = $line{$_}{sip_transport};
                $response{data}{'device_lines[' . $i. '][register_expires]'} = $line{$_}{register_expires};
                
                $i++;                
            }
            
            
 
            %key = &database_select_as_hash ("
                    select
                        device_key_uuid,device_key_id,device_key_category,
                        device_key_type,device_key_line,
                        device_key_value,device_key_extension,device_key_label
                    from
                        v_device_keys
                    where
                        device_uuid='$uuid'",
                        
                    "device_key_id,device_key_category,device_key_type," .
                    "device_key_line,device_key_value,device_key_extension,device_key_label");
            
            $i = 0;
            for (sort {$key{$a}{device_key_id} <=> $key{$b}{device_key_id}} keys %line) {
                $response{data}{'device_keys[' . $i. '][device_key_id]'}   = $key{$_}{device_key_id};
                $response{data}{'device_keys[' . $i. '][device_key_uuid]'} = $_;
                $response{data}{'device_keys[' . $i. '][device_key_category]'} = $key{$_}{device_key_category};
                $response{data}{'device_keys[' . $i. '][device_key_type]'} = $key{$_}{device_key_type};
                $response{data}{'device_keys[' . $i. '][device_key_line]'} = $key{$_}{device_key_line};
                $response{data}{'device_keys[' . $i. '][device_key_value]'} = $key{$_}{device_key_value};
                $response{data}{'device_keys[' . $i. '][device_key_extension]'} = $key{$_}{device_key_extension};
                $response{data}{'device_keys[' . $i. '][device_key_label]'} = $key{$_}{device_key_label};

                
                $i++;                
            }
            
            
            %settings = &database_select_as_hash ("
                    select
                        device_setting_uuid,device_setting_category,device_setting_subcategory,
                        device_setting_name,device_setting_value,
                        device_setting_enabled,device_setting_description
                    from
                        v_device_settings
                    where
                        device_uuid='$uuid'",
                        
                    "device_setting_category,device_setting_subcategory",
                    "device_setting_name,device_setting_value," .
                    "device_setting_enabled,device_setting_description");
            
            $i = 0;
            for (sort {$settings{$a}{device_setting_name} <=> $settings{$b}{device_setting_name}} keys %line) {
                $response{data}{'device_settings[' . $i. '][device_setting_category]'}   = $settings{$_}{device_setting_category};
                $response{data}{'device_settings[' . $i. '][device_setting_uuid]'}   =$_;
                $response{data}{'device_settings[' . $i. '][device_setting_category]'}   = $settings{$_}{device_setting_category};
                $response{data}{'device_settings[' . $i. '][device_setting_subcategory]'}   = $settings{$_}{device_setting_subcategory};
                $response{data}{'device_settings[' . $i. '][device_setting_name]'}   = $settings{$_}{device_setting_name};
                $response{data}{'device_settings[' . $i. '][device_setting_value]'}   = $settings{$_}{device_setting_value};
                $response{data}{'device_settings[' . $i. '][device_setting_enabled]'}   = $settings{$_}{device_setting_enabled};
                $response{data}{'device_settings[' . $i. '][device_setting_description]'}   = $settings{$_}{device_setting_description};
                
                $i++;                
            }            
            
        }
    }
    
    &print_json_response(%response);          
}

