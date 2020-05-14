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
directory_full_name:
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
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
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
          $response{message}= "$domain not exists!";
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
               $response{message}	= "$extension not exists!";
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
directory_full_name:
directory_visible:true
directory_exten_visible:true
limit_max:5
limit_destination:
call_timeout:30
call_group:
user_record:
hold_music:
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
          $response{message}	= "$domain not exists!";
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
          $response{message}	= "$domain not exists!";
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



sub setextensionforward () {
     local $poststring_add = '
forward_all_enabled:false
forward_all_destination:
follow_me_enabled:false
destination_data_1:8284665566
destination_delay_1:0
destination_timeout_1:15
destination_data_2:8384665566
destination_delay_2:5
destination_timeout_2:15
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
call_prompt:true
dnd_enabled:false
submit:Save
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
          follow_me_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          
          destination_data_1 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_1 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_1 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          destination_data_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_2 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_2 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
         
          destination_data_3 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_3 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_3 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
                  
          destination_data_4 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_4 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_4 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          destination_data_5 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_5 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_5 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          cid_name_prefix => {type => 'string', maxlen => 255, notnull => 0, default => ''},
          call_prompt => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
          dnd_enabled => {type => 'boll', maxlen => 10, notnull => 0, default => 'false'}        
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
               $response{message}	= "$extension not exists!";
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



return 1;

