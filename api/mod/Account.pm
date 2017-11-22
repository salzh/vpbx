=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub adduser () {
    local $poststring_add = '
username:zhong
password:123
confirmpassword:123
user_email:zhongxiang721@gmail.com
contact_name_given:zhong
contact_name_family:weixiang
contact_organization:zhong
submit:Create Account
';

    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        username => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        password => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        confirmpassword => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        user_email => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        contact_name_given => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        contact_name_family => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        contact_organization => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	for $k (keys %params) {
        $tmpval   = '';
        if (&getvalue(\$tmpval, $k, $params{$k})) {
            $post_add{$k} = $tmpval;
        } else {
            $response{stat}	= "fail";
            $response{message}	= $k. &_(" not valid");
        }
    }
   
    if ($post_add{password} ne $post_add{confirmpassword}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
    }
    
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash("select
                                    1,user_uuid
                                from
                                    v_users
                                where
                                    username='$post_add{username}' and
                                    domain_uuid='$domain{uuid}'",
                                'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}    = 'fail';
            $response{message} = "$post_add{username} already existed";
        }
    }
    
    if ($response{stat} ne 'fail') {    
        &post_data (
                'domain_uuid' => $domain{uuid},
                'urlpath'     => '/core/users/signup.php',
                'reload'      => 1,
                'data'        => [%post_add]);
        
        %hash = &database_select_as_hash("select
                                            1,user_uuid
                                        from
                                            v_users
                                        where
                                            username='$post_add{username}' and
                                            domain_uuid='$domain{uuid}'",
                                        'uuid');
		#warn $result->content;
        if ($hash{1}{uuid}) {
           $response{stat}	= "ok";
           $response{data}{user_uuid} = $hash{1}{uuid};
        } else {
           $response{stat}		= "fail";
           $response{message}	= "$post_add{username} not saved!";
        }
        
    }
   
   &print_json_response(%response);
}

sub edituser () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    local %params = (
        user_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        username => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        confirmpassword => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        contact_uuid  => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        user_status => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_language => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_time_zone => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        username_old => {type => 'string', maxlen => 50, notnull => 1, default => ''},
    );
	 
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	for $k (keys %params) {
        $tmpval   = '';
        if (&getvalue(\$tmpval, $k, $params{$k})) {
            $post_add{$k} = $tmpval;
        } else {
            $response{stat}	= "fail";
            $response{message}	= $k. &_(" not valid");
        }
    }
    $post_add{id} = $post_add{user_uuid};
    
    if ($post_add{password} ne $post_add{confirmpassword}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
    }
    if ($post_add{username} ne $post_add{username_old}) {
        %hash = &database_select_as_hash("select
                                    1,user_uuid
                                from
                                    v_users
                                where
                                    username='$post_add{username}' and
                                    domain_uuid='$domain{uuid}'",
                                'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}    = 'fail';
            $response{message} = "$post_add{username} already existed";
        }       
    }
    
    if ($response{stat} ne 'fail') {    
        &post_data (
                'domain_uuid' => $domain{uuid},
                'urlpath'     => "/core/users/usersupdate.php?id=$post_add{user_uuid}",
                'reload'      => 1,
                'data'        => [%post_add]);
        
        %hash = &database_select_as_hash("select
                                            1,user_uuid
                                        from
                                            v_users
                                        where
                                            username='$post_add{username}' and
                                            domain_uuid='$domain{uuid}'",
                                        'uuid');
		#warn $result->content;
        if ($hash{1}{uuid}) {
           $response{stat}		      = "ok";
           $response{data}{user_uuid} = $hash{1}{uuid};
        } else {
           $response{stat}		= "fail";
           $response{message}	= "$post_add{username} not saved!";
        }
        
    }
   
   &print_json_response(%response);
}

sub getuserlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    %hash = &database_select_as_hash("select
                                        v_users.user_uuid,v_users.user_uuid,username,user_enabled,group_name
                                    from
                                        v_users left join v_group_users
                                    on
                                        v_users.user_uuid=v_group_users.user_uuid
                                    where
                                        v_users.domain_uuid='$domain{uuid}'",
                                    "user_uuid,username,user_enabled,group_name");
    
    for (sort {$hash{$a}{username} cmp $hash{$b}{username}} keys %hash) {
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response);
}

sub getuser () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    
    $fields = "username,user_enabled,group_name,contact_uuid,user_status";
    %hash = &database_select_as_hash("select
                                        1,v_users.user_uuid,$fields
                                    from
                                        v_users left join v_group_users
                                    on
                                        v_users.user_uuid=v_group_users.user_uuid
                                    where
                                        v_users.domain_uuid='$domain{uuid}' and
                                        v_users.user_uuid='$user_uuid'",
                                    "user_uuid,$fields");
    if (!$hash{1}{user_uuid}) {
        $response{stat}		= "fail";
        $response{message}	= "usr not found";       
    } else {
        $response{data} = $hash{1};
        %settings = &database_select_as_hash(
                        "select
                            user_setting_uuid,user_setting_subcategory,user_setting_value
                        from
                            v_user_settings
                        where
                            user_uuid='$user_uuid' and
                            user_setting_enabled='true'",
                        "category,value");
        for (sort keys %settings) {
            $response{data}{"user_" . $settings{$_}{category}} = $settings{$_}{value};
        }
    }
    
    &print_json_response(%response);
}

sub deleteuser () {
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    local %domain    = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    %hash = &database_select_as_hash(
                "select
                    1,user_uuid
                from
                    v_users
                where
                    user_uuid='$user_uuid'
                    and domain_uuid='$domain{uuid}'",
                'user_uuid');
    
    if (!$hash{1}{user_uuid}) {
        $response{stat}		= "fail";
        $response{message}	= "usr not found";       
    } else {
        &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/core/users/userdelete.php' . "?id=$user_uuid",
            'reload'      => 1,
            'data'        => []);
        $response{stat}   = 'ok';
        
    }
    &print_json_response(%response);    
}

sub deleteusergroup () {
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    local %domain    = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local $group_name = &database_clean_string(substr $form{group_name}, 0, 50);
    if (!$group_name) {
        &print_api_error_end_exit(100, "group_name is null");
    }
    
    &post_data (
        'domain_uuid' => $domain{uuid},
        'urlpath'     => "/core/users/usersupdate.php?id=$user_uuid&domain_uuid=$domain{uuid}&group_name=$group_name&a=delete",
        'reload'      => 1,
        'data'        => []
    );        
    
    &print_json_response(%response);
}

1;