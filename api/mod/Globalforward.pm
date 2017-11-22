=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub setforward() {
    local %post_add = ();
     
    %response  = ();
   
    %domain   = &get_domain();
    
    if (!$domain{name}) {
      $response{stat}		= "fail";
      $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }

    local %params = (
        forwardstr => {type => 'string', maxlen => 255, notnull => 1, default => ''}     
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
        &post_data (
                    'domain_uuid' => $domain{uuid},
                    'urlpath'     => "/app/dialplan/forward.php?action=updatedest&forwardstr=$post_add{forwardstr}",
                    'data'        => []);
        $response{stat}	= "ok";
    }
    
    &print_json_response(%response);
}

sub getfowardlist () {
    local %response  = ();
    %domain   = &get_domain();

    if (!$domain{name}) {
      $response{stat}		= "fail";
      $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {

        %hash = &database_select_as_hash(
                    "select
                        dialplan_uuid,dialplan_name,dialplan_number,dest
                    from
                        v_dialplans left join v_global_forward
                    on
                        v_dialplans.dialplan_number=v_global_forward.did
                    where
                        domain_uuid='$domain{uuid}' and
                        length(dialplan_number) > 0 and
                        app_uuid='c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4'",
                    "dialplan_name,dialplan_number,dest"
                    );
        
        $response{stat} = 'ok';
        for (sort {$hash{$a}{dialplan_name} cmp $hash{$b}{dialplan_name}} keys %hash) {
            push @{$response{data}{list}}, $hash{$_};
        }
    } 
    &print_json_response(%response);
}

return 1;