sub addclick2call () {
    local $poststring_add = '
src_cid_name:callback
src_cid_number:8888886666
dest_cid_name:fusionpbx-cn
dest_cid_number:8888886666
src:10000
dest:8186664488
auto_answer:true
rec:true
ringback:us-ring
';
    
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    if (!$domain{name}) {
        $response{error}{code}		= "1";
        $response{error}{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    
    if (!$response{error}{code}) {
        for (split /\n/, $poststring_add) {
            ($key, $val) = split ':', $_, 2;
            next if !$key;
            $post_add{$key} = $form{$key};
            $post_add{$key} = $val unless defined $post_add{$key};
        }
    }
    
    
    if (!$response{error}{code}) {     
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => '/app/click_to_call/click_to_call.php',
                    'reload'      => 1,
                    'data'        => [%post_add]);
       
        $response{error}{code}		= "0";
        $response{error}{message}	= "OK";       
    }
    
    &print_json_response(%response);
}

return 1;