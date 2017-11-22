=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

local $poststring_add = '
submit:Save
voicemail_id:8888
voicemail_password:8888
greeting_id:1
voicemail_mail_to:123@abc.com
voicemail_attach_file:true
voicemail_local_after_email:true
voicemail_enabled:true
voicemail_description:
referer_path:/app/voicemails/voicemails.php
referer_query:
';
sub addvoicemail () {
    local %params = (
        voicemail_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        voicemail_password => {type => 'int', maxlen => 10, notnull => 0, default => ''},
        greeting_id => {type => 'int', maxlen => 2, notnull => 0, default => ''},
        voicemail_mail_to => {type => 'email', maxlen => 50, notnull => 0, default => ''},
        voicemail_attach_file => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_local_after_email => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_description => {type => 'string', maxlen => 255, notnull => 0, default =>'false'},
        referer_path => {type => 'string', maxlen => 255, notnull => 0, default => '/app/voicemails/voicemails.php'}
    );
    
    local %post_add = ();
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
            &post_data (
                'domain_uuid' => $domain{uuid},
                'urlpath'     => '//app/voicemails/voicemail_edit.php',
                'reload'      => 1,
                'data'        => [%post_add]);
          
            %hash = &database_select_as_hash("select
                                                1,voicemail_uuid
                                            from
                                                v_voicemails
                                            where
                                                voicemail_id='$post_add{voicemail_id}'
                                                and domain_uuid='$domain{uuid}'",
                                            'uuid');
          if ($hash{1}{uuid}) {
               $response{stat}	= "ok";
               $response{data}{voicemail_uuid} = $hash{1}{uuid};
          } else {
               $response{stat}		= "fail";
               $response{message}	= "$post_add{voicemail_uuid}\@$domain{name} not saved!";
          }    
    }
    
    &print_json_response(%response);
}

sub editvoicemail () {
  local %params = (
        voicemail_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        voicemail_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        voicemail_password => {type => 'int', maxlen => 10, notnull => 0, default => ''},
        greeting_id => {type => 'int', maxlen => 2, notnull => 0, default => ''},
        voicemail_mail_to => {type => 'email', maxlen => 50, notnull => 0, default => ''},
        voicemail_attach_file => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_local_after_email => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_description => {type => 'string', maxlen => 255, notnull => 0, default =>'false'},
        referer_path => {type => 'string', maxlen => 255, notnull => 0, default => '/app/voicemails/voicemails.php'}
    );
    
    local %post_add = ();
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
          &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/voicemails/voicemail_edit.php?' . "id=$post_add{voicemail_uuid}" ,
                    'reload'      => 1,
                    'data'        => [%post_add]);
          
            %hash = &database_select_as_hash("select
                                                1,voicemail_uuid
                                            from
                                                v_voicemails
                                            where
                                                voicemail_id='$post_add{voicemail_id}' and
                                                domain_uuid='$domain{uuid}'",
                                            'uuid');
            if ($hash{1}{uuid}) {
                $response{stat}	= "fail";
                $response{data}{voicemail_uuid} = $hash{1}{uuid};
            } else {
                $response{stat}		= "fail";
                $response{message}	= "$post_add{voicemail_uuid}\@$domain{name} not saved!";
            }    
    }
    
    &print_json_response(%response);   
}

sub deletevoicemail () {
    local %params = (
        voicemail_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''}
    );
    
    local %post_add = ();
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
        &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/voicemails/voicemail_delete.php?' . "id=$post_add{voicemail_uuid}" ,
            'reload'      => 0,
            'data'        => []);
    
        $response{stat}	= "fail";
        $response{data}{voicemail_uuid} = $post_add{voicemail_uuid};        
    }
    
    &print_json_response(%response);   
}

sub getvoicemaillist () {
    local %params = (
        voicemail_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        voicemail_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        voicemail_password => {type => 'int', maxlen => 10, notnull => 0, default => ''},
        greeting_id => {type => 'int', maxlen => 2, notnull => 0, default => ''},
        voicemail_mail_to => {type => 'email', maxlen => 50, notnull => 0, default => ''},
        voicemail_attach_file => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_local_after_email => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_description => {type => 'string', maxlen => 255, notnull => 0, default =>'false'},
        referer_path => {type => 'string', maxlen => 255, notnull => 0, default => '/app/voicemails/voicemails.php'}
    );    
   
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    $fields = join ",", keys %params;
    
    %hash = &database_select_as_hash_with_key (
                "select
                    voicemail_uuid,v_voicemails.*
                from
                    v_voicemails
                where
                    domain_uuid='$domain{uuid}'",
                'voicemail_uuid',
                "$fields");
     
    $response{stat}	= "ok";
    
    $response{data} = [];
    for (sort {$hash{$a}{voicemail_id} cmp $hash{$b}{voicemail_id}} keys %hash) {
         push @{$response{data}{list}}, $hash{$_};
    }
    
    &print_json_response(%response);
}

sub getvoicemail () {
    local %params = (
        voicemail_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        voicemail_id => {type => 'int', maxlen => 10, notnull => 1, default => ''},
        voicemail_password => {type => 'int', maxlen => 10, notnull => 0, default => ''},
        greeting_id => {type => 'int', maxlen => 2, notnull => 0, default => ''},
        voicemail_mail_to => {type => 'email', maxlen => 50, notnull => 0, default => ''},
        voicemail_attach_file => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_local_after_email => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        voicemail_description => {type => 'string', maxlen => 255, notnull => 0, default =>'false'},
        referer_path => {type => 'string', maxlen => 255, notnull => 0, default => '/app/voicemails/voicemails.php'}
    );    
   
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    if ($response{stat} ne 'fail') {
        $voicemail_uuid = &clean_str($form{voicemail_uuid}, "-_");
        
        $fields = join ",", keys %params;
        
        %hash = &database_select_as_hash_with_key (
                        "select
                            1,v_voicemails.*
                        from
                            v_voicemails
                        where
                            domain_uuid='$domain{uuid}' and
                            voicemail_uuid='$voicemail_uuid'",
                        '1', "$fields");
        
        unless($hash{1}{voicemail_uuid}){            
              $response{stat}	= "fail";
              $response{message}= &_("not found voicemail");;
        } else {
            $response{stat}		= "ok";
            
            for (keys %params) {
                 $response{data}{$_} = defined $hash{1}{$_} ? $hash{1}{$_} : '';
            }
        }
    }
    
    &print_json_response(%response);    
}

return 1;

