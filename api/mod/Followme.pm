=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub editfollowme () {
   local $poststring_add = '
forward_all_enabled:false
forward_all_destination:
follow_me_enabled:true
destination_data_1:17474779511
destination_delay_1:0
destination_timeout_1:30
destination_data_2:
destination_delay_2:0
destination_timeout_2:30
destination_data_3:
destination_delay_3:0
destination_timeout_3:30
destination_data_4:
destination_delay_4:0
destination_timeout_4:30
destination_data_5:
destination_delay_5:0
destination_timeout_5:30
cid_name_prefix:
cid_number_prefix:
call_prompt:true
dnd_enabled:false
submit:Save
';
 local %params = (
        extension_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        forward_all_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        forward_all_destination => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        follow_me_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        
        destination_data_1 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        destination_delay_1 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        destination_timeout_1 => {type => 'int', maxlen => 3, notnull => 0, default => '30'},
        
        destination_data_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        destination_delay_2 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        destination_timeout_2 => {type => 'int', maxlen => 3, notnull => 0, default => '30'},
        
        destination_data_3 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        destination_delay_3 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        destination_timeout_3 => {type => 'int', maxlen => 3, notnull => 0, default => '30'},
        
        destination_data_4 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        destination_delay_4 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        destination_timeout_4 => {type => 'int', maxlen => 3, notnull => 0, default => '30'},
        
        destination_data_5 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        destination_delay_5 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        destination_timeout_5 => {type => 'int', maxlen => 3, notnull => 0, default => '30'},
        
        cid_name_prefix => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        cid_number_prefix => {type => 'string', maxlen => 20, notnull => 0, default => ''},

        call_prompt => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        dnd_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},

    );
	local %post_add = ();
	for (split /\n/, $poststring_add) {
		 ($key, $val) = split ':', $_, 2;
		 next if !$key;
		 $post_add{$key} = $val;
	}
    
    $response            = ();
   
    %domain   = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "ok";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {
       for $k (keys %params) {
            $tmpval   = '';
            if (&getvalue(\$tmpval, $k, $params{$k})) {
                $post_add{$k} = $tmpval;
            } else {
                $response{stat}	    = "ok";
                $response{message}  = $k. &_(" not valid");
            }
       }
    }
    
    if ($response{stat} ne 'fail') {
        &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/calls/call_edit.php?id=' . "$post_add{extension_uuid}",
            'reload'      => 1,
            'data'        => [%post_add]);
      
        $response{stat}		= "ok";
        $response{data}{extension_uuid} = $post_add{extension_uuid};
       
    }
     
    &print_json_response(%response);   
}

sub getfollowme () {
   $extension_uuid = &clean_str(substr($form{extension_uuid}, 0, 50), "-_");
   if (!$extension_uuid) {
      $response{stat}		= "ok";
      $response{message}	=  &_(" extension_uuid is null");
   }
   
   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash("select
                                          1, extension_uuid,v_extensions.follow_me_uuid,forward_all_enabled,forward_all_destination,
                                          cid_name_prefix,cid_number_prefix,call_prompt,follow_me_enabled
                                       from
                                          v_extensions left join v_follow_me
                                       on
                                          v_extensions.follow_me_uuid=v_follow_me.follow_me_uuid
                                       where
                                          extension_uuid='$extension_uuid'",
                                       "extension_uuid,follow_me_uuid,forward_all_enabled,forward_all_destination," .
                                       "cid_name_prefix,cid_number_prefix,call_prompt,follow_me_enabled");
      if ($hash{1}{extension_uuid}) {
         $response{stat} = "ok";
         $response{data} = $hash{1};
         
         %dests = &database_select_as_hash("select
                                             follow_me_destination_uuid,
                                             follow_me_destination,
                                             follow_me_delay,
                                             follow_me_timeout,
                                             follow_me_order
                                          from
                                             v_follow_me_destinations
                                          where
                                             follow_me_uuid='$hash{1}{follow_me_uuid}'",
                                          "dest,delay,timeout,order");
         for (sort {$dests{$a}{order} <=> $dests{$b}{order}} keys %dests) {
            $response{data}{'destination_data_' . $dests{$_}{order}} = $dests{$_}{dest};
            $response{data}{'destination_delay_' . $dests{$_}{order}} = $dests{$_}{delay};
            $response{data}{'destination_timeout_' . $dests{$_}{order}} = $dests{$_}{timeout};            
         }

      } else {
         $response{stat}	= "fail";
         $response{message}	= &_("not found followme in db") . " extension_uuid=$extension_uuid" ;
      }       
   }
   
   &print_json_response(%response);
}

sub getfollowmelist () {
   
   %domain   = &get_domain();

   if (!$domain{name}) {
       $response{stat}		= "ok";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
   
   if ($response{stat} ne 'fail') {
      $response{stat}    = "ok";
      
      %hash = &database_select_as_hash("select extension_uuid,extension from v_extensions where domain_uuid='$domain{uuid}'", "extension");
      for (sort {$hash{$a}{extension} <=> $hash{$b}{extension}} keys %hash) {
         push @{$response{data}{list}}, {extension_uuid => $_, extension => $hash{$_}{extension}};
      }     
   }
   
   
   &print_json_response(%response);
}

return 1;
