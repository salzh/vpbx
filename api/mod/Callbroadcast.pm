sub addcallbroadcast () {
    local $poststring_add = '
broadcast_name:broadcast2
broadcast_timeout:
broadcast_concurrent_limit:2
broadcast_caller_id_name:
broadcast_caller_id_number:
broadcast_destination_data:
broadcast_phone_numbers:1234
broadcast_avmd:false
broadcast_description:
submit:Save';
   
    local %params = (
        broadcast_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_timeout => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_concurrent_limit => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_caller_id_name => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        broadcast_caller_id_number => {type => 'int', maxlen => 15, notnull => 0, default => '0000000000'},
        broadcast_destination_data => {type => 'destination', maxlen => 255, notnull => 0, default => ''},
        broadcast_phone_numbers => {type => 'string', maxlen => 65535, notnull => 0, default => ''},
        broadcast_avmd => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
        broadcast_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}
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
                     'urlpath'     => '/app/call_broadcast/call_broadcast_edit.php',
                     'reload'      => 1,
                     'data'        => [%post_add]);
          
          %hash = &database_select_as_hash("select 1,call_broadcast_uuid from v_call_broadcasts " .
                                           "where broadcast_name='$post_add{broadcast_name}' and domain_uuid='$domain{uuid}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{error}{code}		= "0";
               $response{error}{message}	= "OK";
               $response{data}{call_broadcast_uuid} = $hash{1}{uuid};
          } else {
               $response{error}{code}		= "1";
               $response{error}{message}	= "$post_add{broadcast_name}\@$domain{name} not saved!";
          }    
    }
    
    &print_json_response(%response);
}

sub editcallbroadcast () {
    local $poststring_add = '
broadcast_name:broadcast2
broadcast_timeout:
broadcast_concurrent_limit:2
broadcast_caller_id_name:
broadcast_caller_id_number:
broadcast_destination_data:
broadcast_phone_numbers:1234
broadcast_avmd:false
broadcast_description:
broadcast_uuid:
submit:Save';
   
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_timeout => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_concurrent_limit => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_caller_id_name => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        broadcast_caller_id_number => {type => 'int', maxlen => 15, notnull => 0, default => '0000000000'},
        broadcast_destination_data => {type => 'destination', maxlen => 255, notnull => 0, default => ''},
        broadcast_phone_numbers => {type => 'string', maxlen => 65535, notnull => 0, default => ''},
        broadcast_avmd => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
        broadcast_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}
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
                     'urlpath'     => '/app/call_broadcast/call_broadcast_edit.php?' . "id=$post_add{call_broadcast_uuid}" ,
                     'reload'      => 0,
                     'data'        => [%post_add]);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{call_broadcast_uuid} = $post_add{call_broadcast_uuid};        
    }
    
    &print_json_response(%response);   
}

sub deletecallbroadcast () {
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''}
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
                     'urlpath'     => '/app/call_broadcast/call_broadcast_delete.php?' . "id=$post_add{call_broadcast_uuid}" ,
                     'reload'      => 0,
                     'data'        => []);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{call_broadcast_uuid} = $post_add{call_broadcast_uuid};        
    }
    
    &print_json_response(%response);   
}

sub sendcallbroadcast () {
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''}
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
                     'urlpath'     => '/app/call_broadcast/call_broadcast_send.php?' . "id=$post_add{call_broadcast_uuid}" ,
                     'reload'      => 0,
                     'data'        => []);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{call_broadcast_uuid} = $post_add{call_broadcast_uuid};        
    }
    
    &print_json_response(%response);   
}


sub stopcallbroadcast () {
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''}
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
                     'urlpath'     => '/app/call_broadcast/call_broadcast_stop.php?' . "id=$post_add{call_broadcast_uuid}" ,
                     'reload'      => 0,
                     'data'        => []);
        
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            $response{data}{call_broadcast_uuid} = $post_add{call_broadcast_uuid};        
    }
    
    &print_json_response(%response);   
}

sub getcallbroadcastlist () {
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_timeout => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_concurrent_limit => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_caller_id_name => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        broadcast_caller_id_number => {type => 'int', maxlen => 15, notnull => 0, default => '0000000000'},
        broadcast_destination_data => {type => 'destination', maxlen => 255, notnull => 0, default => ''},
        broadcast_phone_numbers => {type => 'string', maxlen => 65535, notnull => 0, default => ''},
        broadcast_avmd => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
        broadcast_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}
    );
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    $fields = join ",", keys %params;
    
    %hash = &database_select_as_hash_with_key ("select call_broadcast_uuid,v_call_broadcasts.* from v_call_broadcasts where domain_uuid='$domain{uuid}'",'call_broadcast_uuid', "$fields");
     
     $response{error}{code}		= "0";
     $response{error}{message}	= "OK";
     
     $response{data} = [];
     for (sort {$hash{$a}{broadcast_name} cmp $hash{$b}{broadcast_name}} keys %hash) {
          push @{$response{data}}, $hash{$_};
     }
     
     &print_json_response(%response);
}


sub getcallbroadcast () {
    local %params = (
        call_broadcast_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        broadcast_timeout => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_concurrent_limit => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_caller_id_name => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        broadcast_caller_id_number => {type => 'int', maxlen => 15, notnull => 0, default => '0000000000'},
        broadcast_destination_data => {type => 'destination', maxlen => 255, notnull => 0, default => ''},
        broadcast_phone_numbers => {type => 'string', maxlen => 65535, notnull => 0, default => ''},
        broadcast_avmd => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
        broadcast_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}
    );
    $id = $form{call_broadcast_uuid};
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if (!$response{error}{code}) {
    
        $fields = join ",", keys %params;
        
        %hash = &database_select_as_hash_with_key (
                    "select
                         1,v_call_broadcasts.*
                     from
                         v_call_broadcasts
                     where
                         domain_uuid='$domain{uuid}' and
                         call_broadcast_uuid='$id'",
                    '1', "$fields");
        
        unless($hash{1}{call_broadcast_uuid}){            
              $response{error}{code}	= "1";
              $response{error}{message}	= &_("not found call broadcast");;
        } else {
            $response{error}{code}		= "0";
            $response{error}{message}	= "OK";
            
            for (keys %params) {
                 $response{data}{$_} = defined $hash{1}{$_} ? $hash{1}{$_} : '';
            }
        }
    }
    &print_json_response(%response);

}

return 1;