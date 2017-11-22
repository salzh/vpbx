=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addfaxserver  () {
    local $poststring_add = '
fax_name:fax
fax_extension:4001
fax_destination_number:8124326644
fax_email:admin@fusionpbx.cn
fax_caller_id_name:faxserver
fax_caller_id_number:8184886666
fax_forward_number:8184886668
fax_description:
submit:Save
';
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        fax_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        fax_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        fax_destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_email => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_forward_number => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        fax_description => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
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
    

    
    if ($response{stat} ne 'fail') {     
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/fax/fax_edit.php',
                    'reload'      => 1,
                    'data'        => [%post_add]);
       
       
        
        %hash = &database_select_as_hash("select
                                            1, fax_uuid
                                          from
                                            v_fax
                                          where
                                            fax_extension='$post_add{fax_extension}' and
											fax_name='$post_add{fax_name}' and
                                            domain_uuid='$domain{uuid}'",
                                         "uuid");
        if ($hash{1}{uuid}) {
            $response{stat}				= "ok";
            $response{data}{fax_uuid}   = $hash{1}{uuid};
        } else {
            $response{stat}		= "fail";
            $response{message}	= &_("fail to add fax server");
        }
    
    }
    
    &print_json_response(%response);
}

sub editfaxserver  () {
     local $poststring_add = '
fax_name:fax
fax_extension:4001
fax_destination_number:8124326644
fax_email:admin@fusionpbx.cn
fax_caller_id_name:faxserver
fax_caller_id_number:8184886666
fax_forward_number:8184886668
fax_description:
submit:Save
';
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        fax_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        fax_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        fax_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        dialplan_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        fax_destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_email => {type => 'string', maxlen => 50, notnull => 255, default => ''},
        fax_caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        fax_forward_number => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        fax_description => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
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
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => "/app/fax/fax_edit.php?id=post_add{fax_uuid}",
                    'reload'      => 1,
                    'data'        => [%post_add]);    
       
        $response{stat}		= "ok";
        $response{message}	= "OK";
        
        $response{data}{fax_uuid}   = $post_add{fax_uuid};   
    }
    
    &print_json_response(%response);
}

sub deletefaxserver () {
    $id = &database_clean_string($form{fax_uuid});
    %response = ();   
    %domain   = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
	&post_data (
		'domain_uuid' => $domain{uuid},
		'urlpath'     => '/app/fax/fax_delete.php' . "?id=$id",
		'reload'      => 1,
		'data'        => []);
  
   
	$response{stat}		= "ok";
    
    &print_json_response(%response);
}

sub getfaxserverlist () {
    %response = ();   
    %domain   = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
	%hash = &database_select_as_hash(
				"select
				   fax_uuid,
				   fax_uuid,
				   fax_extension,
				   fax_destination_number,
				   fax_name,
				   fax_email,
				   fax_pin_number,
				   fax_caller_id_name,
				   fax_caller_id_number,
				   fax_forward_number,
				   dialplan_uuid,
				   fax_description
			   from
				   v_fax
			   where
				   domain_uuid='$domain{uuid}'",
			   "fax_uuid,extension,destination,name,email,pin,cid_name,cid_number,forward_number,dialplan_uuid,descr");
	$list = [];
	for (sort {$hash{$b}{extension} cmp $hash{$a}{extension}} keys %hash) {
		push @$list, {
						fax_uuid      => $_,
						fax_name => $hash{$_}{name},
						fax_extension => $hash{$_}{extension},
						fax_destination_number => $hash{$_}{destination},
						fax_name        => $hash{$_}{name},
						fax_email       => $hash{$_}{email},
						fax_pin_number  => $hash{$_}{pin},
						fax_caller_id_name  => $hash{$_}{cid_name},
						fax_caller_id_number=> $hash{$_}{cid_number},
						fax_forward_number  => $hash{$_}{forward_number},
						dialplan_uuid		=> $hash{$_}{dialplan_uuid},
						fax_description     => $hash{$_}{descr}
					  };
	}
	
	$response{stat}		  = "ok";
	$response{data}{list} = $list;
    
    &print_json_response(%response);
}

sub getfaxserver () {
    $uuid = &database_clean_string($form{fax_uuid});
    
    %response = ();   
    %domain   = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
	%hash = &database_select_as_hash(
				"select
				   1,
				   fax_uuid,
				   fax_extension,
				   fax_destination_number,
				   fax_name,
				   fax_email,
				   fax_pin_number,
				   fax_caller_id_name,
				   fax_caller_id_number,
				   fax_forward_number,
				   dialplan_uuid,
				   fax_description
			   from
				   v_fax
			   where
				   domain_uuid='$domain{uuid}' and fax_uuid='$uuid'",
			   "fax_uuid,fax_extension,fax_destination_number,fax_name,fax_email,fax_pin_number,fax_caller_id_name,fax_caller_id_number,fax_forward_number,dialplan_uuid,fax_description");
  
	if ($hash{1}{fax_uuid}) {
		$response{stat}	= "ok";
		$response{data} = $hash{1};
	} else {
		$response{stat}		= "fail";
		$response{message}	= &_("fax server not found");
	}
    
    
    &print_json_response(%response);
}

sub sendfax () {
    $uuid = &database_clean_string($form{fax_uuid});
    
    %response = ();   
    %domain   = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
		
}

sub getfaxlist () {
    $uuid = &database_clean_string($form{fax_uuid});
    
    %response = ();   
    %domain   = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
	%hash = &database_select_as_hash(
				"select
				   1,
				   fax_extension
			   from
				   v_fax
			   where
				   domain_uuid='$domain{uuid}' and fax_uuid='$uuid'",
			   "extension");
	$dir = "/usr/local/freeswitch/storage/fax/$domain{name}/$hash{1}{extension}";
	@boxes = ('inbox', 'sent');
	for $box (@boxes) {
		while(<$dir/$box/*.tif>) {
			($name) = $_ =~ /\/(.+)\.tif$/;
			@s = stat $_;
			%f = ();
			$f{modify_time} = $s[9];
			$f{size}		= -s $_;
			$f{tif_url}		= "index.pl?mod=MIS&&action=downloadfile&&type=fax&&box=inbox&&name=$name&&postfix=tif";
			$f{pdf_url}		= "index.pl?action=downloadfile&&type=fax&&box=inbox&&name=$name&&postfix=pdf";
			
			push @{$response{data}{$box}}, $f;
		}
	}
	
	$response{stat} = 'ok';
	
	&print_json_response(%response);
}


return 1;