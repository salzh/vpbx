=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addgateway () {
   local $poststring_add = '
gateway:gw01
username:test
password:test
from_user:
from_domain:
proxy:127.0.0.1
realm:
expire_seconds:800
register:false
retry_seconds:60
distinct_to:
auth_username:
extension:
register_transport:
register_proxy:
outbound_proxy:
caller_id_in_from:
supress_cng:
sip_cid_type:
codec_prefs:
extension_in_contact:
ping:
channels:
context:public
profile:external
enabled:true
description:
submit:Save
';

   local %params = (
      gateway => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      username => {type => 'string', maxlen => 20, notnull => 0, default => 'noname'},
      password => {type => 'string', maxlen => 20, notnull => 0, default => 'nopassword'},
      from_user => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      from_domain => {type => 'string', maxlen => 255, notnull => 0, default => ''},
      proxy => {type => 'destination', maxlen => 255, notnull => 1, default => ''},
      realm => {type => 'string', maxlen => 255, notnull => 0, default => ''},
      register => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
      retry_seconds => {type => 'int', maxlen => 4, notnull => 0, default => '300'},
      distinct_to => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      auth_username => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      register_transport => {type => 'string', maxlen => 10, notnull => 0, default => 'udp'},
      register_proxy => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      caller_id_in_from => {type => 'string', maxlen => 50, notnull => 0, default => 'true'},
      supress_cng => {type => 'boo1', maxlen => 10, notnull => 0, default => 'true'},
      sip_cid_type => {type => 'string', maxlen => 10, notnull => 0, default => ''},
      extension_in_contact => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      channels => {type => 'int', maxlen => 4, notnull => 0, default => ''},
      context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      profile => {type => 'string', maxlen => 50, notnull => 0, default => 'external'},
      enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
      
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
                       1,gateway_uuid
                    from
                       v_gateways
                    where
                       gateway='$post_add{gateway}' and domain_uuid='$domain{uuid}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("gateway already existed!");
         }
   }
   
   if ($response{stat} ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/gateways/gateway_edit.php',
            'reload'      => 1,
            'data'        => [%post_add]);
        
         %hash = &database_select_as_hash(
                     "select
                        1,gateway_uuid
                     from
                        v_gateways
                     where
                        gateway='$post_add{gateway}' and domain_uuid='$domain{uuid}'",
                     'uuid');
         
         if ($hash{1}{uuid}) {
            $response{stat}		= "ok";
            $response{message}	= "OK";
            $response{data}{gateway_uuid} = $hash{1}{uuid};
         } else {
            $response{stat}		= "fail";
            $response{message}	= &_("gateway not saved!");
         }        
      }
     
   &print_json_response(%response);
}

sub editgateway () {
   local $poststring_add = '
gateway:gw01
username:test
password:test
from_user:
from_domain:
proxy:127.0.0.1
realm:
expire_seconds:800
register:false
retry_seconds:60
distinct_to:
auth_username:
extension:
register_transport:
register_proxy:
outbound_proxy:
caller_id_in_from:
supress_cng:
sip_cid_type:
codec_prefs:
extension_in_contact:
ping:
channels:
context:public
profile:external
enabled:true
description:
gateway_uuid:e6603271-7dc0-46cb-9136-9ff5d13443c3
submit:Save
';


   local %params = (
      gateway_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},      
      gateway => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      username => {type => 'string', maxlen => 20, notnull => 0, default => 'noname'},
      password => {type => 'string', maxlen => 20, notnull => 0, default => 'nopassword'},
      from_user => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      from_domain => {type => 'string', maxlen => 255, notnull => 0, default => ''},
      proxy => {type => 'destination', maxlen => 255, notnull => 1, default => ''},
      realm => {type => 'string', maxlen => 255, notnull => 0, default => ''},
      register => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
      retry_seconds => {type => 'int', maxlen => 4, notnull => 0, default => '300'},
      distinct_to => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      auth_username => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      register_transport => {type => 'string', maxlen => 10, notnull => 0, default => 'udp'},
      register_proxy => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      caller_id_in_from => {type => 'string', maxlen => 50, notnull => 0, default => 'true'},
      supress_cng => {type => 'boo1', maxlen => 10, notnull => 0, default => 'true'},
      sip_cid_type => {type => 'string', maxlen => 10, notnull => 0, default => ''},
      extension_in_contact => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      channels => {type => 'int', maxlen => 4, notnull => 0, default => ''},
      context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      profile => {type => 'string', maxlen => 50, notnull => 0, default => 'external'},
      enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
   );
	
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
    
   %response            = ();
  
   %domain   = &get_domain();
   $response{stat} = 'ok';
   
   if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
 
   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash(
                    "select
                       1,gateway_uuid
                    from
                       v_gateways
                    where
                       gateway='$post_add{gateway}' and domain_uuid='$domain{uuid}'
                       and gateway_uuid!='$post_add{gateway_uuid}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("gateway already existed!");
         }
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
    
    
   if ($response{stat}  ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/gateways/gateway_edit.php' . "?id=$uuid",
            'reload'      => 1,
            'data'        => [%post_add]);
      
         $response{stat}	= "ok";
         $response{message}	= "OK";
         $response{data}{gateway_uuid} = $post_add{gateway_uuid};       
   }
    
   &print_json_response(%response);   
}

sub deletegateway () {
   $uuid    = $form{gateway_uuid};
   %response=();
   $response{stat}		= "ok";

   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("gateway_uuid is null!");   
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
         'urlpath'     => '/app/gateways/gateway_delete.php' . "?id=$uuid",
         'reload'      => 1,
         'data'        => []);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
      $response{data}{gateway_uuid} = $hash{1}{uuid};
   }
   
   &print_json_response(%response);   

}

sub getgatewaylist () {
   @fields = qw/gateway_uuid	gateway	username	password
               distinct_to	auth_username	realm	from_user	from_domain	proxy
               register_proxy	outbound_proxy	expire_seconds	register	register_transport
               retry_seconds	extension	ping	caller_id_in_from	supress_cng	sip_cid_type
               codec_prefs	channels	extension_in_contact	context	profile	enabled	description/;
   
   
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
                        v_gateways
                     where
                        domain_uuid='$domain{uuid}'",
                     $field_string
                     
                  );
         
         $list = [];
         for (sort {$hash{$a}{gateway} cmp $hash{$b}{gateway}} keys %hash) {
            $xml = &send_esl("sofia xmlstatus gateway $hash{$_}{gateway_uuid}");
            $val = &get_xml_value('state', $xml);
            $hash{$_}{state} = $val;
            push @$list, $hash{$_};
         }
         
         $response{stat}		= "ok";
         $response{message}		= "OK";
         $response{data}{list}	= $list;
   }
   
   &print_json_response(%response);
}

sub getgateway () {
   @fields = qw/gateway_uuid	gateway	username	password
               distinct_to	auth_username	realm	from_user	from_domain	proxy
               register_proxy	outbound_proxy	expire_seconds	register	register_transport
               retry_seconds	extension	ping	caller_id_in_from	supress_cng	sip_cid_type
               codec_prefs	channels	extension_in_contact	context	profile	enabled	description/;
   
   
   %response = ();
  
   %domain   = &get_domain();

   if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
   
   if ($response{stat} ne 'fail') {
      $field_string = join ",", @fields;
      
      $uuid  = &clean_str(substr($form{gateway_uuid},0,50),"MINIMAL","-_");
      

      %hash = &database_select_as_hash("select
                                          1,$field_string
                                       from
                                          v_gateways
                                       where
                                          domain_uuid='$domain{uuid}' AND
                                          gateway_uuid='$uuid'",
                                       $field_string);
      
      if ($hash{1}{gateway_uuid}) {
         for (@fields) {
             $response{data}{$_} = $hash{1}{$_};
         }
         
         $response{stat}		= "ok";
         $response{message}		= "OK";
      } else {
          $response{stat}		= "fail";
          $response{message}	= &_("gateway not found");
      }
   }
   &print_json_response(%response);
}

sub startgateway () {
   local $uuid  = &clean_str(substr($form{gateway_uuid},0,50),"MINIMAL","-_");
   $a  = &clean_str(substr($form{a},0,50),"MINIMAL","-_");
   %domain   = &get_domain();

   if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
   
   if ($response{stat} ne 'fail') {

      %hash = &database_select_as_hash("select
                                             1,gateway_uuid
                                          from
                                             v_gateways
                                          where
                                             domain_uuid='$domain{uuid}' AND
                                             gateway_uuid='$uuid'",
                                          'uuid');
      
      if (!$hash{1}{uuid}) {
         $response{stat}	= "fail";
         $response{message}	= &_("gateway not exists");
      }
      
      if ($response{stat} ne 'fail') {
            &post_data('domain_uuid' => $domain{uuid},
               'urlpath'     => '/app/gateways/gateways.php' . "?gateway=$uuid&a=$a&profile=external",
               'reload'      => 1,
               'data'        => []);
       
         $response{stat}   = "ok";
         $response{message}= "OK";
         $response{data}{gateway_uuid} = $hash{1}{uuid};
      }

   }
   
   &print_json_response(%response);
}

return 1;
