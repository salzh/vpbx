sub addhotdesking () {
    local $poststring_add = '
extension_uuid:630909a9-7cf3-4e7c-b878-b8feb4ce2d7d
unique_id:2223344
';
   
    local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        unique_id => {type => 'int', maxlen => 10, notnull => 1, default => ''}
    );
    
    local %post_add = ();
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
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/hot_desking/extension_edit.php',
                     'reload'      => 1,
                     'data'        => [%post_add]);
          
          %hash = &database_select_as_hash("select
                                                1,extension_uuid
                                            from
                                                v_extensions 
                                            where
                                                extension_uuid='$post_add{extension_uuid}' and
                                                unique_id='$post_add{unique_id}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{error}{code}		= "0";
               $response{error}{message}	= "OK";
               $response{data}{extension_uuid} = $hash{1}{uuid};
          } else {
               $response{error}{code}		= "1";
               $response{error}{message}	= &_("hotdesk not saved");
          }    
    }
    
    &print_json_response(%response);
}

sub edithotdesking () {
    local $poststring_add = '
unique_id:432542
vm_password:1234
dial_string:{presence_id=12344@pbx.fusionpbx.cn,instant_ringback=true,domain_uuid=879b9f9b-e69d-4181-9d81-f6775341cc7d,sip_invite_domain=pbx.fusionpbx.cn,domain_name=pbx.fusionpbx.cn,domain=pbx.fusionpbx.cn,accountcode=pbx.fusionpbx.cn}loopback/12344
extension_uuid:46efce5d-6c47-468a-9b0c-d53443f3b8da;
';  
    local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        unique_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        vm_password => {type => 'int', maxlen => 6, notnull => 1, default => ''},
        dial_string => {type => 'string', maxlen => 255, notnull => 0, default => ''}        
    );
    
    
    local %post_add = ();
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
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/hot_desking/extension_edit.php?id=' . $post_add{extension_uuid} ,
                     'reload'      => 1,
                     'data'        => [%post_add]);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{extension_uuid} = $post_add{extension_uuid};        
    }
    
    &print_json_response(%response);   
}

sub deletehotdesking () {
#http://pbx.fusionpbx.cn/app/hot_desking/extension_delete.php?id=46efce5d-6c47-468a-9b0c-d53443f3b8da
    local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''}
    );
    
    local %post_add = ();
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
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/hot_desking/extension_delete.php?id=' . $post_add{extension_uuid} ,
                     'reload'      => 0,
                     'data'        => []);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{extension_uuid} = $post_add{extension_uuid};        
    }
    
    &print_json_response(%response);   
}


sub gethotdeskinglist () {
    local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        unique_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        vm_password => {type => 'int', maxlen => 6, notnull => 1, default => ''},
        dial_string => {type => 'string', maxlen => 255, notnull => 1, default => ''}        
    );
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {    
        %hash = &database_select_as_hash ("select extension_uuid,unique_id,extension
                                          from v_extensions
                                          where domain_uuid='$domain{uuid}' and unique_id is not null",
                                          'unique_id,extension');
         
         $response{error}{code}		= "0";
         $response{error}{message}	= "OK";
         
         $response{data} = [];
         for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
              push @{$response{data}}, {extension_uuid => $_, unique_id => $hash{$_}{unique_id},
                                        extension => $hash{$_}{extension}};
         }
    }
    &print_json_response(%response);
}


sub gethotdesking () {
    local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        unique_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        vm_password => {type => 'int', maxlen => 6, notnull => 1, default => ''},
        dial_string => {type => 'string', maxlen => 255, notnull => 1, default => ''}        
    );
    
    $extension_uuid = &clean_str(substr($form{extension_uuid},0,50), 'MINIMAL', '-_');
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if (!$response{error}{code}) {
        
        %hash = &database_select_as_hash ("select
                                            1,extension_uuid,dial_string,unique_id,extension
                                        from
                                            v_extensions
                                        where
                                            extension_uuid='$extension_uuid'",
                                            "extension_uuid,dial_string,unique_id,extension");
        
        unless($hash{1}{extension_uuid}){            
              $response{error}{code}	= "1";
              $response{error}{message}	= &_("not found hotdesk");
        } else {
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            %vm = &database_select_as_hash("select 1, voicemail_password from v_voicemails where
                                           domain_uuid='$domain{uuid}' and voicemail_id='$hash{1}{extension}'", 'password');
            $hash{1}{v}=$vm{1}{vm_assword};
            $response{data} = $hash{1};
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
        }
    }
    
    &print_json_response(%response);
}

return 1;