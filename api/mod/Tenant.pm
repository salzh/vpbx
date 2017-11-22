=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addtenant () {
    $name  = &database_clean_string(substr($form{domain_name},0,255));
    $name  = "\L$name";
    
    $descr = &database_clean_string(substr($form{domain_description},0,255));
    $domain_name = $name . ($app{base_domain} ? ".$app{base_domain}" : '');
    
    %response = ();
	
    %hash  = &database_select_as_hash("select
										1, domain_uuid
									from
										v_domains
									where
										domain_name='$domain_name'",
									'uuid');
    if ($hash{1}{uuid}) {
        $response{stat}				 = "fail";
        $response{message}			 = "$name already exists!";
        $response{data}{domain_uuid} = $hash{1}{uuid};
        
    	&print_json_response(%response);        
    }
    
    if ($response{stat} ne 'fail') {
        &post_data ( 'domain'    => '',
			'urlpath'   => '/core/domain_settings/domain_edit.php',
			'reload'	=> 1,
			'data'   =>  [
				'domain_name' => $domain_name,
				'domain_description' => $descr,
				'submit' => 'Save'
			]
        );
        
        %hash  = &database_select_as_hash("select
											1, domain_uuid
										from
											v_domains
										where
											domain_name='$domain_name'",
										'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}					= "ok";
            $response{data}{domain_uuid}    = $hash{1}{uuid};
        } else {
            $response{stat}			= "fail";
            $response{message}		= "$name not saved, pls contact administrator";
        }
        
        &print_json_response(%response); 
    }   
    
}

sub edittenant () {
	$name  = &database_clean_string(substr($form{domain_name},0,255));
    $name  = "\L$name";
    
    $descr = &database_clean_string(substr($form{domain_description},0,255));
    $domain_name = $name . ($app{base_domain} ? ".$app{base_domain}" : '');
    $uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");

    %response = ();
	
    if ($response{stat} ne 'fail') {
        &post_data ( 'domain'    => '',
			'urlpath'   => "/core/domain_settings/domain_edit.php?id=$uuid",
			'reload'	=> 1,
			'data'   =>  [
				'domain_name' => $domain_name,
				'domain_description' => $descr,
				'domain_uuid'	=> $uuid,
				'submit' => 'Save'
			]
        );
		
		$response{stat}				 = "ok";
		$response{data}{domain_uuid} = $uuid;
    
        
        &print_json_response(%response); 
    }   	
}

sub deletetenant () {
	$uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");
	&post_data ( 'domain'   => '',
				'urlpath'   => "/core/domain_settings/domain_delete.php?id=$uuid",
				'reload'	=> 1,
				'data'   =>  []
				);
	
	$response{stat}	= "ok";
    
    &print_json_response(%response); 
   
}

sub gettenantlist () {
	#$uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");

	%hash  = &database_select_as_hash("select
										domain_uuid,domain_name,domain_description
									from
										v_domains",
									'name,descr');
	
	$list  = [];
	for (sort {$hash{$a}{name} cmp $hash{$b}{name}} keys %hash) {
		push @$list, {domain_uuid => $_, domain_name => $hash{$_}{name},domain_description => $hash{$_}{descr}};
	}
	
    $response{stat}			= "ok";
	$response{data}{tenant_list}	= $list;
	
	&print_json_response(%response);

}

sub gettenant () {	
    $uuid  = &database_clean_string(substr $form{domain_uuid},0,50);
	
	%hash  = &database_select_as_hash("select
										1,domain_uuid,domain_name,domain_description
									from
										v_domains
									where
										domain_uuid='$uuid'",
									'uuid,name,descr');
	
	
	if ($hash{1}{uuid}) {
		$response{stat}					= "ok";
		$response{data}{domain_uuid}    = $hash{1}{uuid};
		$response{data}{domain_name}    = $hash{1}{name};
		$response{data}{domain_description}    = $hash{1}{descr};
	} else {
		$response{stat}			= "fail";
		$response{message}		= "tenant not found by uuid=$uuid";
	}
	
	&print_json_response(%response);
}

sub switchtenant () {
	%domain           = &get_domain();

	if (!$domain{name}) {
		$response{stat}		= "fail";
		$response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
	}
   
	&change_domain($domain{uuid});
	$response{stat}			= "ok";
	$response{message}		= "ok";
	&print_json_response(%response);
}

return 1;
