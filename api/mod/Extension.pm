=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addextension () {         
     local $poststring_add = '
extension:2000
number_alias:
range:1
autogen_users:
voicemail_password:1234
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_full_name:
directory_visible:true
directory_exten_visible:true
limit_max:5
limit_destination:
voicemail_enabled:true
voicemail_mail_to:
voicemail_attach_file:true
voicemail_local_after_email:true
toll_allow:
call_timeout:30
call_group:
user_record:
hold_music:
missed_call_app: 
missed_call_data: 
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
sip_force_contact:
sip_force_expires:
nibble_account:
mwi_account:
sip_bypass_media:bypass-media-after-bridge
dial_string:
enabled:true
description:
     ';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }

     $response = ();
    
     %domain   = &get_domain();
     $extension = &clean_int($form{extension});

     if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "$form{domain_name}/$form{domain_uuid} not exists!";
     }
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash("select 1,extension_uuid from v_extensions " .
                                           "where extension='$extension' and domain_uuid='$domain{uuid}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{stat}	             	= "fail";
               $response{message}	            = "$extension already exists!";
               $response{data}{extension_uuid}  = $hash{1}{uuid};
          }
     }
     
     if ($response{stat} ne 'fail') {
          $enabled            = &get_enabled($form{enabled});
          $vm_enabled         = &get_enabled($form{vm_enabled});
          $voicemail_password = &clean_int($form{voicemail_password});
          $vm_mailto          = &database_clean_string(substr($form{vm_mailto}, 0, 50));          
          $user_context       = $domain{name};
          
          
          $post_add{extension} = $extension;
          $post_add{enabled}   = $enabled || 'true';
          $post_add{vm_enabled}= $vm_enabled || 'true';
          $post_add{voicemail_password} = $voicemail_password;
          $post_add{vm_mailto}          = $vm_mailto;
          $post_add{user_context}       = $user_context;
          
          $post_add{accountcode}             = $form{accountcode} || $user_context;
          $post_add{autogen_users}           = &database_clean_string($form{autogen_users});
          $post_add{directory_visible}       = &get_enabled($form{directory_visible}) || 'true';
          $post_add{directory_exten_visible} = &get_enabled($form{directory_exten_visible}) || 'true';
          $post_add{voicemail_attach_file}   = &get_enabled($form{voicemail_attach_file}) || 'true';
          $post_add{voicemail_local_after_email} = &get_enabled($form{voicemail_local_after_email}) || 'true';
          $post_add{call_timeout}                = &clean_int($form{call_timeout}) || 30;
          
          $post_add{effective_caller_id_name}     = &database_clean_string(substr($form{effective_caller_id_name}, 0, 50));
          $post_add{effective_caller_id_number}   = &database_clean_string(substr($form{effective_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_number}    = &database_clean_string(substr($form{outbound_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_name}      = &database_clean_string(substr($form{outbound_caller_id_name}, 0, 50));
          $post_add{directory_full_name}          = &database_clean_string(substr($form{directory_full_name}, 0, 50));
          $post_add{voicemail_password}           = &database_clean_string(substr($form{voicemail_password}, 0, 50));
          $post_add{description}                  = &database_clean_string(substr($form{description}, 0, 50));
          $post_add{domain_uuid}                  = $domain{uuid};
        
          
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/extensions/extension_edit.php',
                     'reload'      => 1,
                     'data'        => [%post_add]);
          
          %hash = &database_select_as_hash("select 1,extension_uuid from v_extensions " .
                                           "where extension='$extension' and domain_uuid='$domain{uuid}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{stat}	= "ok";
               $response{data}{extension_uuid} = $hash{1}{uuid};
          } else {
               $response{stat}		= "fail";
               $response{message}	= "$extension\@$domain{name} not saved!";
          }         
     }
     
     &print_json_response(%response);    
}

sub editextension () {
     local $poststring_add = '
extension:10000
number_alias:admin
password:ML.6!TUH!Q
user_uuid:
voicemail_password:1234
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_first_name:
directory_last_name
directory_visible:true
directory_exten_visible:true
limit_max:5
limit_destination:
device_line_uuid:
line_number:
device_mac_address:
device_template:
voicemail_enabled:true
voicemail_mail_to:
voicemail_attach_file:true
voicemail_local_after_email:true
toll_allow:
call_timeout:30
call_group:
user_record:
hold_music:
missed_call_app: 
missed_call_data: 
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
sip_force_contact:
sip_force_expires:
nibble_account:
mwi_account:
sip_bypass_media:
dial_string:
enabled:true
description:
extension_uuid:bd24e793-2e1e-4352-9a29-8ddbb1880a89
id:bd24e793-2e1e-4352-9a29-8ddbb1880a89
domain_uuid:
delete_type:
delete_uuid:';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }

     $response = ();
    
     %domain   = &get_domain();
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     if (!$domain{name}) {
          $response{stat}	= "fail";
          $response{message}= "domain not exists!";
     }
      
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash(
                              "select
                                   1,extension_uuid
                              from
                                   v_extensions
                              where
                                   extension_uuid='$uuid' and
                                   domain_uuid='$domain{uuid}'",
                              'uuid');
          if (!$hash{1}{uuid}) {
               $response{stat}		= "fail";
               $response{message}	= "extension not exists";
          }
     }
     
     if ($response{stat} ne 'fail') {
          $enabled     = &get_enabled($form{enabled}) || 'true';
          $vm_enabled  = &get_enabled($form{vm_enabled}) || 'true';
          $voicemail_password = &clean_int($form{voicemail_password});
          $vm_mailto   = &database_clean_string(substr($form{vm_mailto}, 0, 50));          
          $user_record   = &database_clean_string(substr($form{user_record}, 0, 50));          
          $user_context = $domain{name};
          
          
          $post_add{enabled}   = $enabled;
          $post_add{vm_enabled}= $vm_enabled;
          $post_add{voicemail_password} = $voicemail_password;
          $post_add{vm_mailto}   = $vm_mailto;
          $post_add{domain_uuid}= $domain{uuid};
          $post_add{user_context}= $user_context;
         
          if ($user_record eq 'all' || $user_record eq 'local' || $user_record eq 'inbound' || $user_record eq 'outbound') {
               $post_add{user_record} = $user_record;
          } else {
               $post_add{user_record} = '';              
          }
          
          $post_add{extension} = &database_clean_string(substr $form{extension}, 0, 20);

          $post_add{password}                = &database_clean_string(substr $form{password}, 0, 15);
          $post_add{accountcode}             = $form{accountcode} || $user_context;
          $post_add{autogen_users}           = &get_enabled($form{autogen_users}) || 'false';
          $post_add{directory_visible}       = &get_enabled($form{directory_visible}) || 'true';
          $post_add{directory_exten_visible} = &get_enabled($form{directory_exten_visible}) || 'true';
          $post_add{voicemail_attach_file}   = &get_enabled($form{voicemail_attach_file}) || 'true';
          $post_add{voicemail_local_after_email} = &get_enabled($form{voicemail_local_after_email}) || 'true';
          $post_add{call_timeout}                = &clean_int($form{call_timeout}) || 30;
          
          $post_add{effective_caller_id_name}    = &database_clean_string(substr($form{effective_caller_id_name}, 0, 50));
          $post_add{effective_caller_id_number}  = &database_clean_string(substr($form{effective_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_number}   = &database_clean_string(substr($form{outbound_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_name}     = &database_clean_string(substr($form{outbound_caller_id_name}, 0, 50));
          $post_add{directory_full_name}         = &database_clean_string(substr($form{directory_full_name}, 0, 50));
          $post_add{voicemail_password}          = &database_clean_string(substr($form{voicemail_password}, 0, 50));
          $post_add{description}                 = &database_clean_string(substr($form{description}, 0, 50));
         
          $post_add{extension_uuid} = $uuid;
          $post_add{id} = $uuid;
          
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/extensions/extension_edit.php?id=$uuid",
                     'reload'      => 1,
                     'data'        => [%post_add]);
          
         
          $response{stat}	= "ok";
     }
     
     &print_json_response(%response);    
}

sub getextension () {
     local $poststring_add = '
extension:10000
number_alias:admin
password:ML.6!TUH!Q
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_first_name:
directory_last_name:
directory_visible:true
directory_exten_visible:true
limit_max:5
limit_destination:
call_timeout:30
call_group:
user_record:
hold_music:
missed_call_app: 
missed_call_data: 
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
sip_force_contact:
sip_force_expires:
nibble_account:
mwi_account:
sip_bypass_media:
dial_string:
enabled:true
description:
extension_uuid:bd24e793-2e1e-4352-9a29-8ddbb1880a89
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }
     
     $fields = join ",", keys %post_add;
     $response = ();
    
     %domain= &get_domain();
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "domain not exists!";
     }
     
     $uuid   = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     #warn "select 1,$fields from v_extensions where extension_uuid='$uuid' and domain_uuid='$domain{uuid}'";
     %hash = &database_select_as_hash ("select
                                             1,$fields
                                        from
                                             v_extensions
                                        where
                                             extension_uuid='$uuid' and
                                             domain_uuid='$domain{uuid}'",
                                        "$fields");
    
     
     if(!$hash{1}{extension_uuid}){
           
          $response{stat}	= "fail";
          $response{message}= &_("not found extension");;
     } else {          
          $response{stat}     = "ok";
          %vm = &database_select_as_hash(
               "select
                    1,voicemail_enabled,voicemail_mail_to,voicemail_attach_file,voicemail_local_after_email,voicemail_password
               from
                    v_voicemails
               where
                   domain_uuid='$domain{uuid}' and
                   voicemail_id='$hash{1}{extension}'",
                   "voicemail_enabled,voicemail_mail_to,voicemail_attach_file,voicemail_local_after_email,voicemail_password");
          for (keys %post_add) {
               $response{data}{$_} = defined $hash{1}{$_} ? $hash{1}{$_} : '';
          }
          $response{data}{voicemail_enabled} = $vm{1}{voicemail_enabled};
          $response{data}{voicemail_mail_to} = $vm{1}{voicemail_mail_to};
          $response{data}{voicemail_attach_file} = $vm{1}{voicemail_attach_file};
          $response{data}{voicemail_local_after_email} = $vm{1}{voicemail_local_after_email};
          $response{data}{voicemail_password} = $vm{1}{voicemail_password};
     }
     
     &print_json_response(%response);
}

sub getextensionlist () {
     local $poststring_add = '
extension_uuid:
extension:10000
password:ML.6!TUH!Q
user_context:pbx.fusionpbx.cn
enabled:true
description:
call_group:
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     $fields = join ",", keys %post_add;

     $response = ();
    
     %domain   = &get_domain();
     
     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "domain not exists!";
     }
     
     %hash = &database_select_as_hash_with_key (
                                             "select
                                                  extension_uuid,v_extensions.*
                                             from
                                                  v_extensions where domain_uuid='$domain{uuid}'",
                                             'extension_uuid',
                                             "$fields");
     
     $response{stat}	= "ok";
     $response{message}	= "OK";
     
     $response{data}{list} = [];
     for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
          push @{$response{data}{list}}, $hash{$_};
     }
     
     &print_json_response(%response);
}

sub deleteextension () {
     local $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     warn $uuid;
     %domain   = &get_domain();
     
     $response = ();

     &post_data (
                    'domain_uuid' => $domain{uuid},
                    'reload'      => 1,
                    'urlpath' => '/app/extensions/extension_delete.php?id=' . $uuid,
                    'data' => []
                );
     %hash     = &database_select_as_hash(
                                             "select
                                                  1, extension_uuid
                                             from
                                                  v_extensions
                                             where
                                                  extension_uuid='$uuid'",
                                             'uuid'
                                        );
     if ($hash{1}{uuid}) {
          $response{stat}    = 'fail';
          $response{message} = 'Error';
     } else {
          $response{stat} = 'ok';
     }
     $response{data}{extension_uuid} = $uuid;
     
     &print_json_response(%response); 
}

sub getgswaveqr () {
     local $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     warn $uuid;
     %domain   = &get_domain();
     
     $response = ();

     $res = &post_data (
                    'domain_uuid' => $domain{uuid},
                    'reload'      => 0,
                    'urlpath' => '/app/gswave/index.php?id=' . $uuid,
                    'data' => []
                );
	 $html = $res->content;
 
	 open(W, "> /tmp/qr.html") or die "fail to open qr.html";
	 print W $html;
	 close W;
	 ($qrimg_src) = $html =~ m{<img src="(data:image/jpeg;base64,.+?)"}i;
     $response{stat} = 'ok';
   
     $response{data} = $qrimg_src;
     
     &print_json_response(%response); 
}

sub setextensionforward () {
     local $poststring_add = '
forward_all_enabled: false
forward_all_destination: 
forward_busy_enabled: false
forward_busy_destination: 
forward_no_answer_enabled: false
forward_no_answer_destination: 
forward_user_not_registered_enabled: false
forward_user_not_registered_destination: 
follow_me_enabled: true
destinations[0][uuid]: a6b6e113-56ec-4809-969b-87a95405e240
destinations[0][destination]: 18882115404
destinations[0][delay]: 0
destinations[0][timeout]: 30
destinations[0][prompt]: 
destinations[1][uuid]: 3ac2bbd7-a53a-4d4f-b4cf-2ca376f56299
destinations[1][destination]: 2124441005
destinations[1][delay]: 0
destinations[1][timeout]: 30
destinations[1][prompt]: 
destinations[2][uuid]: 11adda93-8b35-4156-86cc-24cea6f70276
destinations[2][destination]: 
destinations[2][delay]: 0
destinations[2][timeout]: 30
destinations[2][prompt]: 
destinations[3][uuid]: 4e31a051-809a-48f8-812d-5f219d91756d
destinations[3][destination]: 
destinations[3][delay]: 0
destinations[3][timeout]: 30
destinations[3][prompt]: 
destinations[4][uuid]: ec65f3ab-50ae-4a91-937d-892acce35ba9
destinations[4][destination]: 
destinations[4][delay]: 0
destinations[4][timeout]: 30
destinations[4][prompt]: 
follow_me_ignore_busy: true
dnd_enabled: false
';

     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     

     local %params = (
          forward_all_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          forward_all_destination => {type => 'string', maxlen => 20, notnull => 0, default => ''},
		  
		  forward_busy_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          forward_busy_destination => {type => 'string', maxlen => 20, notnull => 0, default => ''},
		  
		  forward_no_answer_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          forward_no_answer_destination => {type => 'string', maxlen => 20, notnull => 0, default => ''},
		  
		  forward_user_not_registered_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},		  
          forward_user_not_registered_destination => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		  
		  follow_me_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},

          'destinations[0][uuid]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[0][data]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[0][delay]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[0][timeout]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[0][prompt]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
		  
		  'destinations[1][uuid]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[1][data]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[1][delay]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[1][timeout]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[1][prompt]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
		  
		  'destinations[2][uuid]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[2][data]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[2][delay]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[2][timeout]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[2][prompt]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
		  
		  'destinations[3][uuid]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[3][data]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[3][delay]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[3][timeout]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[3][prompt]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
		  
		  'destinations[4][uuid]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[4][data]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[4][delay]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[4][timeout]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
          'destinations[4][prompt]' => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        
	 
          dnd_enabled => {type => 'boll', maxlen => 10, notnull => 0, default => 'false'},     
          follow_me_ignore_busy => {type => 'boll', maxlen => 10, notnull => 0, default => 'false'}        
    );
	 
	%response       = ();   
    %domain         = &get_domain();

     if (!$domain{name}) {
         $response{stat}	= "fail";
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
	 
	 for(0..4) {
		  if ($form{'destinations[' . $_ . '][uuid]'}) {
			   $post_add{'destinations[' . $_ . '][uuid]'} = &genuuid();
		  }
		  
		  $post_add{'destinations[' . $_ . '][destination]'} = $form{'destination_data_' . $_};
		  $post_add{'destinations[' . $_ . '][delay]'} = $form{'destination_delay_' . $_};
		  $post_add{'destinations[' . $_ . '][timeout]'} = $form{'destination_timeout_' . $_};
		  $post_add{'destinations[' . $_ . '][prompt]'} = $form{'destination_prompt_' . $_};
		  
		  delete $form{'destination_data_' . $_}, $form{'destination_delay_' . $_}, $form{'destination_timeout_' . $_},$form{'destination_prompt_' . $_};

	 }
     
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");

     %response  = ();
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash(
                         "select
                              1,extension_uuid
                         from
                              v_extensions
                         where
                              extension_uuid='$uuid' and
                              domain_uuid='$domain{uuid}'",
                         'uuid');
          if (!$hash{1}{uuid}) {
               $response{stat}		= "fail";
               $response{message}	= "extension not exists";
          }
     }
     
     if ($response{stat} ne 'fail') {
          for (keys %post_add) {
               $post_add{$_} ||= $form{$_};
          }

          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/calls/call_edit.php?id=$uuid",
                     'reload'      => 1,
                     'data'        => [%post_add]);          
         
          $response{stat}	    = "ok";
          $response{message}	= "OK";
     }
     &print_json_response(%response); 

}

sub getextensionforward () {
	 local $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     warn $uuid;
     %domain   = &get_domain();
     if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "domain not exists!";
		  &print_json_response(%response); return;
		  
     }
     $response = ();
	 
	 $fields = 'extension,do_not_disturb,forward_all_destination,forward_all_enabled,forward_busy_destination,forward_busy_enabled,forward_no_answer_destination,forward_no_answer_enabled,forward_user_not_registered_destination,forward_user_not_registered_enabled,follow_me_uuid'
	 %hash = &database_select_as_hash("select 1,$fields from v_extensions  where domain_uuid = '$domain{uuid}'  and extension_uuid = '$uuid'",
									  $fields);
	 
	 
	 
	 if (!$hash{1}{extension}) {
		  $response{stat} = 'fail';
		  $response{error} = '1';
		  $response{message} = "not found by extension_uuid=$uuid";
		  &print_json_response(%response); return;

	 }
	 
	 $response{data} = $hash{1};	 
	 if ($hash{1}{follow_me_uuid}) {
		  $follow_me_uuid = $hash{1}{follow_me_uuid};
		  %data = &database_select_as_hash("select follow_me_destination_uuid,follow_me_destination,follow_me_delay,follow_me_prompt,follow_me_timeout,follow_me_order from v_follow_me where  follow_me_uuid = '$follow_me_uuid'", "follow_me_destination,follow_me_delay,follow_me_prompt,follow_me_timeout,follow_me_order");
		  
		  for $id (keys %data) {
			   $order = $data{$uuid}{follow_me_order};
			   $response{data}{'destinations[' . $order . '][destination]'} = $data{$id}{follow_me_destination};
			   $response{data}{'destinations[' . $order . '][uuid]'} = $data{$id}{follow_me_destination_uuid};
			   $response{data}{'destinations[' . $order . '][delay]'} = $data{$id}{follow_me_delay};
			   $response{data}{'destinations[' . $order . '][prompt]'} = $data{$id}{follow_me_prompt};
			   $response{data}{'destinations[' . $order . '][timeout]'} = $data{$id}{follow_me_timeout};
		  }
		  
		  for $order (0..4) {
			   if ($response{data}{'destinations[' . $order . '][uuid]'}) {
					$response{data}{'destinations[' . $order . '][uuid]'} = &genuuid();
					$response{data}{'destinations[' . $order . '][destination]'} = '';
					$response{data}{'destinations[' . $order . '][delay]'} = 0;
					$response{data}{'destinations[' . $order . '][prompt]'} = '';
					$response{data}{'destinations[' . $order . '][timeout]'} = 30;
			   }
		  }
	 }
	 
	 
}

sub getregistration () {
	 $extension = &clean_str(substr($form{extension},0,50),"MINIMAL","-_");

     $response = ();
    
     %domain   = &get_domain();
     
     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "domain not exists!";
		  &print_json_response(%response);
		  return;
     }
     
     $output = &runswitchcommand('internal', "show registrations");

	 $output =~ s/\r//g;
	 
	 @list = ();
	 for $row (split /\n/, $output) {
		  #warn $row;
		  @arr = split ',', $row;
		  if ($arr[1] eq $domain{name}) {
			   warn $arr[1];
			    push @list, {ext=>$arr[0],'network_ip' => $arr[5], 'network_port' => $arr[6]};
		  }		  
	 }
     $response{stat}	= "ok";
     $response{message}	= "OK";
     
     $response{data}{list} = \@list;
     
     &print_json_response(%response);
}

return 1;

