=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub adddestination () {
   local $poststring_add = '
destination_type:inbound
destination_number:3109990000
destination_context:public
dialplan_details[0][dialplan_detail_type]:
dialplan_details[0][dialplan_detail_order]:10
dialplan_details[0][dialplan_detail_data]:transfer:100 XML shy.velantro.net
fax_uuid:06281b95-0896-4834-9039-cd7317134df3
destination_cid_name_prefix:
destination_accountcode:
destination_enabled:true
destination_description:to be deleted
';

   local %params = (
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      'dialplan_details[0][dialplan_detail_type]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'dialplan_details[0][dialplan_detail_order]' => {type => 'int', maxlen => 3, notnull => 0, default => '10'},
      'dialplan_details[0][dialplan_detail_data]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      fax_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>''},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
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
            'urlpath'     => '/app/destinations/destination_edit.php',
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
destination_type:inbound
destination_number:3109990000
destination_context:public
dialplan_details[0][dialplan_detail_uuid]:69ba135a-0896-4834-9039-cd7317134df3
dialplan_details[0][dialplan_detail_type]:transfer
dialplan_details[0][dialplan_detail_order]:70
dialplan_details[0][dialplan_detail_data]:transfer:100 XML shy.velantro.net
fax_uuid:06281b95-0896-4834-9039-cd7317134df3
destination_cid_name_prefix:
destination_accountcode:
destination_enabled:true
destination_description:to be deleted
';

   local %params = (
      destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      dialplan_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      db_destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      'dialplan_details[0][dialplan_detail_type]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'dialplan_details[0][dialplan_detail_order]' => {type => 'int', maxlen => 3, notnull => 0, default => '10'},
      'dialplan_details[0][dialplan_detail_data]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      fax_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>'false'},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}      
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
   
   for (0..9) {
      last unless $form{"dialplan_details[" . $_ . "][dialplan_detail_data]"};
      $post_add{"dialplan_details[" . $_ . "][dialplan_detail_type]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_type]"});
      
      $post_add{"dialplan_details[" . $_ . "][dialplan_detail_data]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_data]"});
	  $post_add{"dialplan_details[" . $_ . "][dialplan_detail_order]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_order]"});
	  $post_add{"dialplan_details[" . $_ . "][dialplan_detail_uuid]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_uuid]"});
      
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
   
   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash(
                    "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_number='$post_add{destination_number}' and
					   destination_uuid != '$post_add{destination_uuid}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("this destination already existed!");
         }
   }
   
   if ($response{stat} ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => "/app/destinations/destination_edit.php?id=$post_add{destination_uuid}",
            'reload'      => 1,
            'data'        => [%post_add]);
        
		warn "edit destination: " . Dumper(\%post_add);
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

sub deletedestination () {
   $uuid    = $form{destination_uuid};
   %response=();
   $response{stat}		= "ok";

   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("destination_uuid is null!");   
   }
  
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
         'urlpath'     => '/app/destinations/destination_delete.php' . "?id=$uuid",
         'reload'      => 1,
         'data'        => []);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
      $response{data}{destination_uuid} = $hash{1}{uuid};
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



return 1;
