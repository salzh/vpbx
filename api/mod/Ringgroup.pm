=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addringgroup () {
     local $poststring_add = '
ring_group_name:rg1
ring_group_extension:1005
ring_group_context:default
ring_group_strategy:simultaneous
ring_group_destinations[0][destination_number]:100
ring_group_destinations[0][destination_delay]:0
ring_group_destinations[0][destination_timeout]:30
ring_group_destinations[0][destination_prompt]:
ring_group_destinations[1][destination_number]:200
ring_group_destinations[1][destination_delay]:0
ring_group_destinations[1][destination_timeout]:30
ring_group_destinations[1][destination_prompt]:
ring_group_destinations[2][destination_number]:
ring_group_destinations[2][destination_delay]:0
ring_group_destinations[2][destination_timeout]:30
ring_group_destinations[2][destination_prompt]:
ring_group_destinations[3][destination_number]:
ring_group_destinations[3][destination_delay]:0
ring_group_destinations[3][destination_timeout]:30
ring_group_destinations[3][destination_prompt]:
ring_group_destinations[4][destination_number]:
ring_group_destinations[4][destination_delay]:0
ring_group_destinations[4][destination_timeout]:30
ring_group_destinations[4][destination_prompt]:
ring_group_timeout_action:transfer:
ring_group_cid_name_prefix:
ring_group_ringback:
user_uuid:
ring_group_skip_active:false
ring_group_enabled:true
ring_group_record:0
ring_group_description:to be delete
     ';
     
     local %post_add = ();
     
     %response  = ();
    
     %domain   = &get_domain();
     
     if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
     }
 
     local %params = (
          ring_group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},      
          ring_group_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
          ring_group_context => {type => 'string', maxlen => 255, notnull => 0, default => "$domain{name}"},
          ring_group_strategy => {type => 'enum:sequence,simultaneous,enterprise,rollover', maxlen => 20,
                                  notnull => 1, default => ''},
          ring_group_timeout_action => {type => 'string', maxlen => 255, notnull => 0, default => ''},
          ring_group_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_ringback => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_skip_active => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
          ring_group_record => {type => 'enum:0,1,2', maxlen => 2, notnull => 0, default => '0'},
          ring_group_enabled => {type => 'bool', maxlen => 2, notnull => 0, default => 'true'},
          ring_group_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
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
     
     if ($response{stat} ne 'fail') {
          for (0..4) {
               last unless $form{"ring_group_destinations[$_][destination_number]"};
               $post_add{"ring_group_destinations[$_][destination_number]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_number]"});
               
               $post_add{"ring_group_destinations[$_][destination_delay]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_delay]"});
                     
               $post_add{"ring_group_destinations[$_][destination_prompt]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_prompt]"});
                     
               $post_add{"ring_group_destinations[$_][destination_timeout]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_timeout]"});
          }
          
          $result = &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/ring_groups/ring_group_edit.php',
                     'data'        => [%post_add]);
          
          $location = $result->header("Location");
          ($uuid) = $location =~ /id=(.+)$/;
          if (!$uuid) {
               $response{stat}		= "fail";
               $response{message}	= "Error";
          } else {         
               $response{stat}	= "ok";
               $response{data}{ring_group_uuid} = $uuid;
          }
     }
     
     &print_json_response(%response);    
}

sub editringgroup () {
     local $poststring_add = '    
ring_group_name:rg1
ring_group_extension:1005
ring_group_context:default
ring_group_strategy:simultaneous
ring_group_destinations[0][ring_group_destination_uuid]:4404c55d-fd27-437b-a003-c9ac4d8aa946
ring_group_destinations[0][destination_number]:100
ring_group_destinations[0][destination_delay]:0
ring_group_destinations[0][destination_timeout]:30
ring_group_destinations[0][destination_prompt]:
ring_group_destinations[1][ring_group_destination_uuid]:8f730594-0c0d-43bb-9183-2b29a5985f56
ring_group_destinations[1][destination_number]:200
ring_group_destinations[1][destination_delay]:0
ring_group_destinations[1][destination_timeout]:30
ring_group_destinations[1][destination_prompt]:
ring_group_destinations[2][destination_number]:300
ring_group_destinations[2][destination_delay]:0
ring_group_destinations[2][destination_timeout]:30
ring_group_destinations[2][destination_prompt]:
ring_group_timeout_action:transfer:
ring_group_cid_name_prefix:
ring_group_ringback:
user_uuid:
ring_group_skip_active:false
ring_group_enabled:true
ring_group_record:0
ring_group_description:to be delete
dialplan_uuid:228cf8b0-abc5-461e-a5f3-90dfdb640f15
ring_group_uuid:c91100a5-ff16-4787-b6a2-55f77c13571d
';

     local %post_add = ();

     %response  = ();

     %domain   = &get_domain();
     
     if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
     }
 
     local %params = (
          ring_group_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},      
          ring_group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},      
          ring_group_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
          ring_group_context => {type => 'string', maxlen => 255, notnull => 0, default => "$domain{name}"},
          ring_group_strategy => {type => 'enum:sequence,simultaneous,enterprise,rollover', maxlen => 20,
                                  notnull => 1, default => ''},
          ring_group_timeout_action => {type => 'string', maxlen => 255, notnull => 0, default => ''},
          ring_group_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_ringback => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_skip_active => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
          ring_group_record => {type => 'enum:0,1,2', maxlen => 2, notnull => 0, default => '0'},
          ring_group_enabled => {type => 'bool', maxlen => 2, notnull => 0, default => 'true'},          
          ring_group_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
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
     
     local $uuid  = &clean_str(substr($form{ring_group_uuid},0,50),"MINIMAL","-_" ) ||
          &print_api_error_end_exit(80, 'ring_group_uuid is null');
          
     $fields= join ",", keys %post_add;
     
     %hash  = &database_select_as_hash(
                    "select
                         1,ring_group_uuid
                    from
                         v_ring_groups
                    where
                         ring_group_uuid='$uuid'",
                    'ring_group_uuid');
     
     
     if (!$hash{1}{ring_group_uuid}) {
          $response{stat} = "fail";
          $response{message} = "ring_group_uuid=$uuid not found!";
     }
     
     if ($response{stat} ne 'fail') {
          for (0..20) {
               last unless $form{"ring_group_destinations[$_][destination_number]"};
               $post_add{"ring_group_destinations[$_][destination_number]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_number]"});
               
               $post_add{"ring_group_destinations[$_][destination_delay]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_delay]"});
                     
               $post_add{"ring_group_destinations[$_][destination_prompt]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_prompt]"});
                     
               $post_add{"ring_group_destinations[$_][destination_timeout]"} =
                     &database_clean_string($form{"ring_group_destinations[$_][destination_timeout]"});
          }
          &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => "/app/ring_groups/ring_group_edit.php?id=$uuid",
                    'reload'      => 1,                    
                    'data'        => [%post_add]);
          
        
          $response{stat}	= "ok";
     }
     
     &print_json_response(%response);
}


sub deleteringgroupdestination () {
     $ring_group_uuid = &database_clean_string(substr($form{ring_group_uuid},0,50)) ||
                    &print_api_error_end_exit("ring_group_uuid is null");
     $ring_group_destination_uuid = &database_clean_string(substr($form{ring_group_destination_uuid},0,50)) ||
                    &print_api_error_end_exit("ring_group_destination_uuid is null");
   
     %domain    = &get_domain();     
     %response  = ();
     
     if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
     }
     if ($response{stat} ne 'fail') {
          %post_add = (
             ring_group_uuid =>   $ring_group_uuid,
             ring_group_destination_uuid => $ring_group_destination_uuid,
             'a'    => 'delete'
          );
          
          %hash = &database_select_as_hash(
                         "select
                              1,ring_group_destination_uuid
                         from
                              v_ring_group_destinations
                         where
                              ring_group_uuid='$ring_group_uuid' and
                              ring_group_destination_uuid='$ring_group_destination_uuid'",
                         'uuid');
          if (!$hash{1}{uuid}) {
               $response{stat}    = "fail";
               $response{message} = "not found!";
          } else {
               
               &post_data (
                 'domain_uuid' => $domain{uuid},
                 'urlpath'     => "/app/ring_groups/ring_group_destination_delete.php?id=$ring_group_destination_uuid&ring_group_uuid=$ring_group_uuid",
                 'data'        => [%post_add]
               );
               $response{stat}    = "ok";
          }
     }
     
     &print_json_response(%response);
}

sub deleteringgroup () {
     $ring_group_uuid = &database_clean_string(substr($form{ring_group_uuid},0,50)) ||
                       &print_api_error_end_exit(80, "ring_group_uuid is null");
     
     %domain    = &get_domain();
     if (!$domain{name}) {
          &print_api_error_end_exit(80, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
                                   
     }
     
     %hash = &database_select_as_hash(
                    "select
                         1, ring_group_uuid
                    from
                         v_ring_groups
                    where
                         ring_group_uuid='$ring_group_uuid'  AND
                         domain_uuid='$domain{uuid}'",
                    'ring_group_uuid');
     
     if (!$hash{1}{ring_group_uuid}) {
          &print_api_error_end_exit("ring_group_uuid=$ring_group_uuid/$form{name}not found!");
     }
     &post_data (
          'domain_uuid' => $domain{uuid},
          'urlpath'     => "/app/ring_groups/ring_group_delete.php?id=$ring_group_uuid",
          'reload'      => 1,
          'data'        => []
          );
   
     $response{stat}    = "ok";
          
     &print_json_response(%response);
}

sub getringgroup () {
     local $ring_group_uuid = &database_clean_string(substr($form{ring_group_uuid},0,50)) ||
                    &print_api_error_end_exit(80, "ring_group_uuid is null");


     local %params = (
          ring_group_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
          ring_group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},      
          ring_group_extension => {type => 'string', maxlen => 50, notnull => 1, default => ''},
          ring_group_context => {type => 'string', maxlen => 255, notnull => 1, default => "$domain{name}"},
          ring_group_strategy => {type => 'enum:sequence,simultaneous,enterprise,roller', maxlen => 20,
                                  notnull => 1, default => ''},
          ring_group_timeout_app => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_timeout_data => {type => 'string', maxlen => 255, notnull => 0, default => ''},
          ring_group_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_ringback => {type => 'string', maxlen => 50, notnull => 0, default => ''},
          ring_group_skip_active => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
          ring_group_record => {type => 'enum:0,1,2', maxlen => 2, notnull => 0, default => '0'},
          ring_group_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
     );
 
     %domain    = &get_domain();
     if (!$domain{name}) {
          &print_api_error_end_exit(80, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
                                   
     }
     %response  = ();     
     
     $fields = join ",", keys %params;
     
     %hash = &database_select_as_hash(
                    "select
                         1, $fields
                    from
                         v_ring_groups
                    where
                         ring_group_uuid='$ring_group_uuid'",
                    $fields);
     
     if (!$hash{1}{ring_group_uuid}) {
          $response{stat} = "fail";
          $response{message} = "ring_group_uuid=$ring_group_uuid not found!";
     } else {
          $response{data}  = $hash{1};
          
          #$response{data}{ring_group_timeout_action} = &database_clean_string($hash{1}{ring_group_timeout_action});
          @destinations = ();
          
          %dest = &database_select_as_hash(
                         "select
                              ring_group_destination_uuid,destination_number,destination_delay,
                              destination_timeout,destination_prompt
                         from
                              v_ring_group_destinations
                         where
                              ring_group_uuid='$ring_group_uuid'",
                         "destination_number,destination_delay,destination_timeout,destination_prompt");
          
          $i = 0;
          for (sort {$dest{$a}{destination_number} cmp $dest{$b}{destination_number}} keys %dest) {
               push @destinations, {
                    "ring_group_destinations[$i][ring_group_destination_uuid]" => $_,
                    "ring_group_destinations[$i][destination_number]"          => $dest{$_}{destination_number},
                    "ring_group_destinations[$i][destination_delay]"           => $dest{$_}{destination_delay},
                    "ring_group_destinations[$i][destination_timeout]"         => $dest{$_}{destination_timeout},
                    "ring_group_destinations[$i][destination_prompt]"          => $dest{$_}{destination_prompt}               
               };
               $i++;
          }
          
          $response{stat}        = "ok";
          $response{data}{destination_list}  = \@destinations;
     }
     
     &print_json_response(%response);
}

sub getringgrouplist () {
     %domain    = &get_domain();     
     %response  = ();
     
     %hash = &database_select_as_hash(
                    "select
                         ring_group_uuid,ring_group_name
                    from
                         v_ring_groups
                    where
                         domain_uuid='$domain{uuid}'",
                    "ring_group_name");
     
     $response{stat} = "ok";
     
     @ringgroups = ();
     for (keys %hash) {
          push @ringgroups, {ring_group_uuid => $_, ring_group_name => $hash{$_}{ring_group_name}}
     }
     
     $response{data}{ringroup_list} = \@ringgroups;
     
     &print_json_response(%response);
}

return 1;

