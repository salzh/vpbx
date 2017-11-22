=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut
use XML::Simple;

sub conferenceactivesummary() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $output = &runswitchcommand('internal', 'conference list');
    for (split /\n/, $output) {
       ($name, $count) =  $_ =~ /Conference (.+)\-$domain_name \((\d+) member/;
       next unless $name;
       $count ||= 0;
       ($display_name=$name) =~ s/\-/ /g;
        
        push @{$response{data}{list}}, {conference_name => $name, conference_display_name => $display_name, count => $count};
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response); 

}

sub conferenceactivedetail() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name   = &database_clean_string(substr $form{conference_name}, 0, 10);
    
    $output = &runswitchcommand('internal', "conference $name-$domain_name xml_list");
    $output =~ s/^.+?</</s;
    $xml = XMLin($output, ForceArray => ['members'], KeyAttr => {members => 'xx'});
   # unlink $tmpfile;
    #warn Dumper($xml);
    for (@{$xml->{conference}{members}}) {
        push @{$response{data}{list}}, {id => $_->{member}{id},
                                        caller_id_name => $_->{member}{caller_id_name},
                                        caller_id_number => $_->{member}{caller_id_number},
                                        is_moderator => $_->{member}{flags}{is_moderator},
                                        joined_time => $_->{member}{joined_time},
                                        can_hear => $_->{member}{flags}{can_hear},
                                        can_speak => $_->{member}{flags}{can_speak},
                                        talking => $_->{member}{flags}{talking},
                                        last_talking => $_->{member}{last_talking},
                                        has_video => $_->{member}{flags}{has_video},
                                        has_floor => $_->{member}{flags}{has_floor},
                                       };
                                        
    }
    $response{stat} = 'ok';
    &print_json_response(%response); 
 
}

sub conferenceinteractivelock() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name   = &database_clean_string(substr $form{conference_name}, 0, 10);
    $type   = &database_clean_string(substr $form{type}, 0, 10);
    
    unless ($type eq 'lock' || $type eq 'unlock') {
        &print_api_error_end_exit(90, "type is not in lock/unlock ");
    }
    $output = &runswitchcommand('internal', "conference $name-$domain_name $type");
    
    $response{stat}    = 'ok';
    $response{message} = $output;
    &print_json_response(%response);   
}

sub conferenceinteractivemuteall() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name   = &database_clean_string(substr $form{conference_name}, 0, 10);
    $type   = &database_clean_string(substr $form{type}, 0, 10);
    
 
    $output = &runswitchcommand('internal', "conference $name-$domain_name mute all");
    
    $response{stat}    = 'ok';
    $response{message} = $output;
    &print_json_response(%response);
}

sub conferenceinteractiveend() {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name   = &database_clean_string(substr $form{conference_name}, 0, 10);
    $type   = &database_clean_string(substr $form{type}, 0, 10);
    

    $output = &runswitchcommand('internal', "conference $name-$domain_name kick all");
    
    $response{stat}    = 'ok';
    $response{message} = $output;
    &print_json_response(%response);      
}

sub conferenceinteractivemutemember () {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name = &database_clean_string(substr $form{conference_name}, 0, 10);
    $id   = &clean_int(substr $form{id}, 0, 10);
    
  
    $output = &runswitchcommand('internal', "conference $name-$domain_name mute $id");
    
    $response{stat}    = 'ok';
    $response{message} = $output;
    &print_json_response(%response);     
}

sub conferenceinteractivekickmember () {
    %response       = ();   
    %domain         = &get_domain();
    $domain_name    = $domain{name};
    if (!$domain{name}) {
        &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $name = &database_clean_string(substr $form{conference_name}, 0, 10);
    $id   = &clean_int(substr $form{id}, 0, 10);
    
  
    $output = &runswitchcommand('internal', "conference $name-$domain_name kick $id");
    
    $response{stat}    = 'ok';
    $response{message} = $output;
    &print_json_response(%response);     
}

return 1;