=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub adddestination () {
   local $poststring_add = '
destination_type: inbound
destination_prefix: 1
destination_number: 18187298888
destination_caller_id_name: 
destination_caller_id_number: 
destination_context: public
destination_conditions[0][condition_field]: 
destination_conditions[0][condition_expression]: 
destination_actions[0]: transfer:101 XML 222.velantro.net
user_uuid: 
group_uuid: 
destination_cid_name_prefix: 
destination_record: true
destination_hold_music: 
destination_distinctive_ring: 
destination_accountcode: 
domain_uuid: 7ac0f7ec-be4e-4f57-ab8b-f2aff6d83b3a
destination_order: 100
destination_enabled: true
destination_description: 
';

   local %params = (
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => 'inbound'},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      destination_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      'destination_conditions[0][condition_field]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'destination_conditions[0][condition_expression]' => {type => 'int', maxlen => 3, notnull => 0, default => ''},
      'destination_actions[0]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      group_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_record => {type => 'string', maxlen => 50, notnull => 0, default => 'true'},
      destination_hold_music => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_distinctive_ring => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>''},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
	  #domain_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_order => {type => 'bool', maxlen => 10, notnull => 0, default => '10'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}      
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
   
   %response = ();
  
   %domain   = &get_domain();
   $post_add{'destination_actions[0]'} = "transfer: " .$post_add{'destination_actions[0]'} . " XML " . $domain{name};

   $response{stat} = 'ok';
   
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
   $post_add{domain_uuid} = $domain{uuid};
   
   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash(
                    "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_number='$post_add{destination_number}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("this destination already existed!");
         }
   }
   
   if ($response{stat} ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/destinations/destination_edit.php?type=inbound',
            'reload'      => 1,
            'data'        => [%post_add]);
        
         %hash = &database_select_as_hash(
                     "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_type='$post_add{destination_type}' and
                       destination_number='$post_add{destination_number}'",
                    'uuid');
         
         if ($hash{1}{uuid}) {
            $response{stat}		= "ok";
            $response{message}	= "OK";
            $response{data}{destination_uuid} = $hash{1}{uuid};
         } else {
            $response{stat}		= "fail";
            $response{message}	= &_("destination not saved!");
         }        
      }
     
   &print_json_response(%response);
}

sub editdestination () {
      local $poststring_add = '
destination_type: inbound
destination_prefix: 
destination_number: 7472191171
destination_caller_id_name: 
destination_caller_id_number: 
destination_context: public
destination_conditions[0][condition_field]: 
destination_conditions[0][condition_expression]: 
destination_actions[0]: transfer:*99100 XML 222.velantro.net
destination_actions[1]: 
destination_cid_name_prefix: 
destination_record: 
destination_hold_music: 
destination_distinctive_ring: 
destination_accountcode: 
domain_uuid: 7ac0f7ec-be4e-4f57-ab8b-f2aff6d83b3a
destination_order: 100
destination_enabled: true
destination_description: 
db_destination_number: 7472191171
dialplan_uuid: 1c4a4cc4-dd51-45f3-9316-9306f1f9d2a8
destination_uuid: 3cb689d8-f3ac-4c69-875f-e46dabca376f
';

   local %params = (
      destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      dialplan_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => 'inbound'},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      db_destination_number => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      'destination_actions[0]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      'destination_conditions[0][condition_field]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'destination_conditions[0][condition_expression]' => {type => 'int', maxlen => 3, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_record => {type => 'string', maxlen => 50, notnull => 0, default => 'true'},
      destination_hold_music => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_distinctive_ring => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>''},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
	  #domain_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_order => {type => 'bool', maxlen => 10, notnull => 0, default => '10'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}  
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
      
   %response = ();
  
   %domain   = &get_domain();

   $response{stat} = 'ok';
   
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
   
   $post_add{domain_uuid} = $domain{uuid};
   $post_add{db_destination_number} = $post_add{destination_number};
   

   %hash = &database_select_as_hash(
			   "select
				 1,destination_uuid,dialplan_uuid
			  from
				 v_destinations
			  where
				destination_uuid='$post_add{destination_uuid}'",
			  'uuid,dialplan_uuid');
   
   if (!$hash{1}{uuid}) {
	  $response{stat}		= "fail";
	  $response{message}	=  &_("destination not found!");
	
   } else {
	
	  $post_add{dialplan_uuid} = $hash{1}{dialplan_uuid};
      warn "edit destination: " . Dumper(\%post_add);

	  &post_data (
		 'domain_uuid' => $domain{uuid},
		 'urlpath'     => "/app/destinations/destination_edit.php?id=$post_add{destination_uuid}",
		 'reload'      => 1,
		 'data'        => [%post_add]
	  );
   }
     
   &print_json_response(%response);
}

sub deletedestination () {
   local $uuid    = $form{destination_uuid};
   %response=();
   $response{stat}		= "ok";

   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("destination_uuid is null!");   
   }
  
   local %post_add = ();
   $post_add['destinations[0][uuid]'] = $uuid;
   $post_add['destinations[0][checked]'] = 'true';
   $post_add['type'] = 'inbound';
   $post_add['action'] = 'delete';
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}		= "1";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }   
   }
   
   if ($response{stat} ne 'fail') {   
      &post_data (
         'domain_uuid' => $domain{uuid},
         'urlpath'     => '/app/destinations/destinations.php',
         'reload'      => 1,
         'data'        => [%post_add]);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
      $response{data}{destination_uuid} = $uuid;
   }
   
   &print_json_response(%response);   

}

sub getdestinationlist () {
   
   local %params = (
      destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}      
   );
   
   @fields = keys %params;
   
   $response = ();
   $response{stat}   = "ok";
  
   %domain           = &get_domain();

   if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
   
   if ($response{stat} ne 'fail') {
         
         $field_string = join ",", @fields;
         %hash = &database_select_as_hash_with_auto_key(
                     "select
                        $field_string
                     from
                        v_destinations
                     where
                        domain_uuid='$domain{uuid}'",
                     $field_string
                     
                  );
         
         $list = [];
         for (sort {$hash{$a}{destination} cmp $hash{$b}{destination}} keys %hash) {
            push @$list, $hash{$_};
         }
         
         $response{stat}		= "ok";
         $response{message}		= "OK";
         $response{data}{destination_list}	= $list;
   }
   
   &print_json_response(%response);
}

sub getdestination () {
   local $uuid = &database_clean_string(substr $form{destination_uuid}, 0, 50);
   $response = ();
   $response{stat}   = "ok";
  
   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("destination_uuid is null!");   
   }
   
   if ($response{stat} ne 'fail') {
   
      local %params = (
         destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
         destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
         destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
         destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
         destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
         destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
         dialplan_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''}      
      );
      
      @fields = keys %params;
      
     
      %domain           = &get_domain();
   
      
      if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }
      
      if ($response{stat} ne 'fail') {
            
            $field_string = join ",", @fields;
            %hash = &database_select_as_hash(
                        "select
                           1,$field_string
                        from
                           v_destinations
                        where
                           domain_uuid='$domain{uuid}' AND
                           destination_uuid='$uuid'",
                        $field_string
                        
            );

            if ($hash{1}{destination_uuid}) {
               $response{stat}		= "ok";
               $response{message}	= "OK";
               $response{data} = $hash{1};
			   $response{data}{db_destination_number} = $hash{1}{destination_number};

               if ($hash{1}{dialplan_uuid}) {
                  %d = &database_select_as_hash(
                        "select
                           dialplan_detail_uuid, dialplan_detail_type,dialplan_detail_data,dialplan_detail_order
                        from
                           v_dialplan_details
                        where
                           dialplan_uuid='$hash{1}{dialplan_uuid}'",
                        "type,data,order");
                  $i = 0;
                  for (sort {$d{$a}{order} <=> $d{$b}{order}} keys %d) {
					 $response{data}{'destination_actions[' . $i . ']'} = $d{$_}{data};
                     $response{data}{"dialplan_details[" . $i . "][dialplan_detail_type]"} = $d{$_}{type};
                     $response{data}{"dialplan_details[" . $i . "][dialplan_detail_data]"} = $d{$_}{data};
                     $response{data}{"dialplan_details[" . $i . "][dialplan_detail_order]"} = $d{$_}{order};
                     $response{data}{"dialplan_details[" . $i . "][dialplan_detail_uuid]"} = $_;
                  }
               }
            } else {
               $response{stat}		= "fail";
               $response{message}	= &_('not found');
            }
      }
   }   
   &print_json_response(%response);
}

sub getdestinationdropdownlist() {
 
  
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}		= "1";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }   
   }
   
   if ($response{stat} ne 'fail') {   
      $result = &post_data (
         'domain_uuid' => $domain{uuid},
         'urlpath'     => '/app/destinations/destination_json.php',
         'reload'      => 0,
         'data'        => []);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
	  $content = $result->content;
	  $content =~ s{<script>.+?</script>}{}gs;
      $response{data}{html} = $content;
   }
   
   &print_json_response(%response);   
}

return 1;
