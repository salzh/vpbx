=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub getdialplanlist () {
    #local ($type) = @_;
    local $type = &clean_str($form{type});
    local %dialplan_type = (
        'inbound' => 'c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4',
        'outbound' => '8c914ec3-9fc0-8ab5-4cda-6c9288bdc9a3',
        'queue' => '16589224-c876-aeb3-f59f-523a1c0801f7',
        'time'  => '4b821450-926b-175a-af93-a03c441818b1'
    );
    
    if ($type eq 'inbound' || $type eq 'outbound' || $type eq 'queue' || $type eq 'time') {
        $app_uuid_sql = "app_uuid='$dialplan_type{$type}'";
    } else {
        $app_uuid_sql = "app_uuid NOT IN ('$dialplan_type{inbound}', '$dialplan_type{outbound}')";
    }
    
    
    local %domain  = &get_domain();
	local $fields  = 'dialplan_uuid,app_uuid,dialplan_context,dialplan_name,dialplan_number,dialplan_order,dialplan_enabled,dialplan_description';
	local %hash = &database_select_as_hash(
		"select
		dialplan_uuid,$fields
		from
			v_dialplans
		where
			domain_uuid='$domain{uuid}' and $app_uuid_sql",		
		"$fields");
	
	local %response 	= ();
	$response{stat}		= "ok";
	
	for (sort {$hash{$a}{dialplan_order} <=> $hash{$b}{dialplan_order}}keys %hash) {
		push @{$response{data}{dialplan_list}}, $hash{$_};
	}
	
	&print_json_response(%response);
}


sub getdialplan () {
	local $uuid  = &clean_str(substr($form{dialplan_uuid},0,50),"MINIMAL","-_");
	%response	 = ();

	if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("dialplan_uuid is null!");   
	}
  
	if ($response{stat} ne 'fail') {
		local %domain  = &get_domain();
		local $fields  = 'dialplan_uuid,app_uuid,dialplan_context,dialplan_name,dialplan_number,dialplan_order,dialplan_enabled,dialplan_description';
		local %dialplan = &database_select_as_hash(
			"select
			1,$fields
			from
				v_dialplans
			where
				domain_uuid='$domain{uuid}' and dialplan_uuid='$uuid'",		
		"$fields");
		
		$response{data} = $dialplan{1};
		
		$fields_detail = 'dialplan_detail_uuid,dialplan_detail_tag,dialplan_detail_type,dialplan_detail_data,dialplan_detail_break,dialplan_detail_inline,dialplan_detail_group,dialplan_detail_order';
		
		local %detail = &database_select_as_hash("select
										dialplan_detail_uuid,$fields_detail
									from
										v_dialplan_details
									where
										dialplan_uuid='$uuid'",
									$fields_detail);
		$i = 0;
		for (sort {$detail{$a}{dialplan_detail_order} <=> $detail{$b}{dialplan_detail_order}} keys %detail) {
			push @{$response{data}{dialplan_details_list}}, {
				"dialplan_details[$i][dialplan_detail_uuid]" => $detail{$_}{dialplan_detail_uuid},
				"dialplan_details[$i][dialplan_detail_tag]" => $detail{$_}{dialplan_detail_tag},
				"dialplan_details[$i][dialplan_detail_type]" => $detail{$_}{dialplan_detail_type},
				"dialplan_details[$i][dialplan_detail_data]" => $detail{$_}{dialplan_detail_data},
				"dialplan_details[$i][dialplan_detail_break]" => $detail{$_}{dialplan_detail_break},
				"dialplan_details[$i][dialplan_detail_inline]" => $detail{$_}{dialplan_detail_inline},
				"dialplan_details[$i][dialplan_detail_group]" => $detail{$_}{dialplan_detail_group},
				"dialplan_details[$i][dialplan_detail_order]" => $detail{$_}{dialplan_detail_order}
			};
			$i++;
		}
	}
	
    $response{stat}		= "fail";

	&print_json_response(%response);	
}


sub deletdialplan {
   $uuid    = $form{dialplan_uuid};
   %response=();
   $response{stat}		= "ok";

   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("dialplan_uuid is null!");   
   }
  
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}	= "fail";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }   
   }
   
   if ($response{stat} ne 'fail') {   
      &post_data (
         'domain_uuid' => $domain{uuid},
         'urlpath'     => '/app/dialplan/dialplan_delete.php' . "?id[]=$uuid",
         'reload'      => 1,
         'data'        => []);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
      $response{data}{dialplan_uuid} = $hash{1}{uuid};
   }
   
   &print_json_response(%response);   
}


sub editdialplan () {
	   local $poststring_add = '
dialplan_name:3109990000
dialplan_number:3109990000
dialplan_context:public
dialplan_continue:false
dialplan_order:081
domain_uuid:ebaf56f4-6bd6-42cb-91e5-7bd426ac6399
dialplan_enabled:true
dialplan_description:to be deleted
dialplan_details[0][dialplan_detail_uuid]:47b46b6e-6b66-4393-9c59-90cb86c69cd9
dialplan_details[0][dialplan_detail_tag]:condition
dialplan_details[0][dialplan_detail_type]:context
dialplan_details[0][dialplan_detail_data]:public
dialplan_details[0][dialplan_detail_break]:
dialplan_details[0][dialplan_detail_inline]:
dialplan_details[0][dialplan_detail_group]:
dialplan_details[0][dialplan_detail_order]:10';
   
   local %params = (
	app_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
	dialplan_name => {type => 'string', maxlen => 20, notnull => 1, default => ''},	
	dialplan_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
	dialplan_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
	dialplan_continue => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
	dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
    dialplan_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},	
	dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}      
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
   
  
   
	%domain  		= &get_domain();
	$response{stat}	= 'ok';
	
	local $uuid = $form{dialplan_uuid};
	%response=();
	$response{stat}		= "ok";

	if (!$uuid) {
	   &print_api_error_end_exit(60, "dialplan_uuid is null");
	}
	
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
			 $response{stat}	= "fail";
			 $response{message}	= $k. &_(" not valid");
		  }
	   }
	}
   
    for (1..20) {
		last unless $form{"dialplan_details[$_][dialplan_detail_data]"};
		$post_add{"dialplan_details[$_][dialplan_detail_type]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_type]"});
		
		$post_add{"dialplan_details[$_][dialplan_detail_data]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_data]"});
			  
		$post_add{"dialplan_details[$_][dialplan_detail_uuid]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_uuid]"});
			  
		$post_add{"dialplan_details[$_][dialplan_detail_tag]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_tag]"});
			  
		$post_add{"dialplan_details[$_][dialplan_detail_break]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_break]"});
		
		$post_add{"dialplan_details[$_][dialplan_detail_inline]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_inline]"});
			  
		$post_add{"dialplan_details[$_][dialplan_detail_group]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_group]"});
			  
		$post_add{"dialplan_details[$_][dialplan_detail_order]"} =
			  &database_clean_string($form{"dialplan_details[$_][dialplan_detail_order]"});  
	}
	 
	if (!$response{stat} ne 'fail') {
		$post_add{domain_uuid}	 = $domain{uuid};
		$post_add{dialplan_uuid} = $uuid;
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => "/app/dialplan/dialplan_edit.php?id=$uuid&app_uuid=$post_add{app_uuid}",
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

sub adddialplan () {
	local $poststring_add = '
dialplan_name:3402459922
condition_field_1:destination_number
condition_expression_1:/^(3402459922)$/
condition_field_2:
condition_expression_2:
action_1:transfer:7002 XML default.domain.net
action_2:
dialplan_context:
dialplan_order:100
dialplan_enabled:true
dialplan_description:
';

	local %post_add = ();
	for (split /\n/, $poststring_add) {
		 ($key, $val) = split ':', $_, 2;
		 next if !$key;
		 $post_add{$key} = $val;
	}
	
	%response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
	local %params = (
        dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        condition_field_1 => {type => 'string', maxlen => 20, notnull => 0, default => 'destination_number'},
        condition_expression_1 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        condition_field_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        condition_expression_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        action_1 => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        action_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        dialplan_context => {type => 'string', maxlen => 255, notnull => 0, default => "$domain{name}"},
        dialplan_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		
    );
	 

    
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
	
	if (!$response{stat} ne 'fail') {
		$post_add{dialplan_context} ||= $domain{name};
		
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/dialplan/dialplan_add.php',
			'reload'      => 1,
			'data'        => [%post_add]);
		#warn $result->header("Location");
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

return 1;