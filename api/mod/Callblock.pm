=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addcallblock () {
    local $poststring_add = '
call_block_number:2345678901
call_block_name:zhong
call_block_action:Voicemail default 1000
call_block_enabled:true
submit:Save
';
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if ($response{stat} ne 'fail') {
        for (split /\n/, $poststring_add) {
            ($key, $val) = split ':', $_, 2;
            next if !$key;
            $post_add{$key} = $form{$key};
            $post_add{$key} = $val unless defined $post_add{$key};
        }
    }
    
    if ($response{stat} ne 'fail') {   
        if ($post_add{call_block_number} =~ /\D/) {
            $response{stat}		= "fail";
            $response{message}	= &_("number format error:") .  $post_add{call_block_numer};
        }
    }
    
    if ($response{stat} ne 'fail') { 
        %hash = &database_select_as_hash("select 1,call_block_uuid from v_call_block " .
                                      "where call_block_number='$post_add{call_block_number}' " .
                                      "and domain_uuid='$domain{uuid}'", 'uuid');
        
        if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= $post_add{call_block_number} . &_(" already exists");            
        }
    }
    
    if ($response{stat} ne 'fail') {   
        $post_add{call_block_action} = substr($post_add{call_block_action}, 0, 50);
        if (!$post_add{call_block_action}) {
            $response{stat}		= "fail";
            $response{message}	= &_("Action not defined: ") .  $post_add{call_block_numer};
        }
    }  
    
    if ($response{stat} ne 'fail') {
        $post_add{call_block_name}   = &database_clean_string(substr $post_add{call_block_name}, 0, 50);
        $post_add{call_block_enabled}= &get_enabled($post_add{call_block_enabled}) || 'true';    
    }
    
    if ($response{stat} ne 'fail') {     
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/call_block/call_block_edit.php',
                    'reload'      => 1,
                    'data'        => [%post_add]);
         
        %hash = &database_select_as_hash("select 1,call_block_uuid from v_call_block " .
                                         "where call_block_number='$post_add{call_block_number}' and domain_uuid='$domain{uuid}'", 'uuid');
        if ($hash{1}{uuid}) {
             $response{stat}	= "ok";
             $response{data}{call_block_uuid} = $hash{1}{uuid};
        } else {
             $response{stat}		= "fail";
             $response{message}	= "number not saved!";
        }
    }
    
    &print_json_response(%response);    

}

sub editcallblock () {
 local $poststring_add = '
call_block_number:2345678901
call_block_name:zhong
call_block_action:Voicemail default 1000
call_block_enabled:true
call_block_uuid:
submit:Save
';
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if ($response{stat} ne 'fail') {
        for (split /\n/, $poststring_add) {
            ($key, $val) = split ':', $_, 2;
            next if !$key;
            $post_add{$key} = $form{$key};
            $post_add{$key} = $val unless defined $post_add{$key};
        }
    }
    
    if ($response{stat ne 'fail'}) {   
        if ($post_add{call_block_number} =~ /\D/) {
            $response{stat}		= "fail";
            $response{message}	= &_("number format error:") .  $post_add{call_block_numer};
        }
    }
     
    if ($response{stat} ne 'fail') {   
        $post_add{call_block_action} = $post_add{call_block_action};
        if (!$post_add{call_block_action}) {
            $response{stat}		= "fail";
            $response{message}	= &_("Action not defined: ") .  $post_add{call_block_numer};
        }
    }  
    
    if ($response{stat} ne 'fail') {     
        $post_add{call_block_name}   = &database_clean_string(substr $post_add{call_block_name}, 0, 50);
        $post_add{call_block_enabled}= &get_enabled($post_add{call_block_enabled}) || 'true';    
    }
    
    if ($response{stat} ne 'fail') {     
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/call_block/call_block_edit.php' . "?id=$form{call_block_uuid}",
                    'reload'      => 1,
                    'data'        => [%post_add]);
      
        $response{stat}		= "ok";
        $response{data}{call_block_uuid} = $form{call_block_uuid};
            
    }
    
    &print_json_response(%response);        
}

sub deletecallblock () {
    $id = $form{call_block_uuid};
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "ok";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {     
         &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/call_block/call_block_delete.php' . "?id=$id",
                    'reload'      => 1,
                    'data'        => []);
      
        $response{stat}		= "fail";
        $response{message}	= "OK";
    }
    
    &print_json_response(%response);
}

sub getcallblocklist () {
    %domain   = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash("select
                                            call_block_uuid,
                                            call_block_name,
                                            call_block_number,
                                            call_block_count,
                                            call_block_action,
                                            date_added,
                                            call_block_enabled
                                        from
                                            v_call_block
                                        where
                                            domain_uuid='$domain{uuid}'",
                                        "name,number,count,action,date,enabled");
        $list = [];
        for (sort {$hash{$b}{date} cmp $hash{$a}{date}} keys %hash) {
            push @$list, {call_block_uuid => $_,
                          call_block_name => $hash{$_}{name},
                          call_block_number => $hash{$_}{number},
                          call_block_count => $hash{$_}{count},
                          call_block_action => $hash{$_}{action},
                          call_block_enabled  => $hash{$_}{enabled},
                          call_block_date     => $hash{$_}{date}
                          }
        }
        
        $response{stat}			= "ok";
        $response{data}{list}	= $list;
    }
    &print_json_response(%response);
                                    
}

sub getcallblock () {
    %domain   = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "1";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    $uuid = $form{call_block_uuid};
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash("select 1,
                                            call_block_uuid,
                                            call_block_name,
                                            call_block_number,
                                            call_block_count,
                                            call_block_action,
                                            date_added,
                                            call_block_enabled
                                        from
                                            v_call_block
                                        where
                                            domain_uuid='$domain{uuid}' and call_block_uuid='$uuid'",
                                        "uuid,name,number,count,action,date,enabled");
        $response{stat}		= "ok";
        $response{data}{call_block_uuid}= $uuid;
        $response{data}{call_block_name}= $hash{1}{name};
        $response{data}{call_block_number}= $hash{1}{number};
        $response{data}{call_block_count} = $hash{1}{count};
        $response{data}{call_block_action}= $hash{1}{action};
        $response{data}{call_block_date}   = $hash{1}{date};
        $response{data}{call_block_enabled}= $hash{1}{enabled};

    }
    &print_json_response(%response);
}


return 1;
