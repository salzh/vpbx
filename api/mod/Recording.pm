=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


$recording_dir = '/usr/local/freeswitch/recordings';
sub addrecording () {
    %domain = &get_domain();
    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {
        $rawname	= $cgi->param('recordingfile');
	
        if ($rawname) {
            ($filename) = $rawname    =~ /([^\\\/]+)$/;
        } else {
            $response{stat}		= "fail";
            $response{message}	= &_("no file uploaded");           
        }
        
        if ($response{stat} ne 'fail') {
            $dir = $recording_dir . "/$domain{name}";
            if (! -e $dir) {
                mkdir $dir;
            }
            
			%upload = &upload_file('recordingfile', $dir, 10*1024*1024, 'wav,mp3', 'keepname');
			if ($upload{error} == 1) {
				&print_api_error_end_exit(180, "file upload error: $upload{message}");
			}
			
            $filename = "$upload{name}.$upload{format}";
			
            $uuid = &genuuid();
            &database_do("insert into
                            v_recordings
                            (recording_uuid,domain_uuid,recording_filename,recording_name,recording_description)
                          values
                            ('$uuid','$domain{uuid}','$filename','$filename','$filename')"
                        );
            
			warn "recording_uuid: $uuid";
            $response{stat}		= "ok";
            $response{message}	= "OK";
            $response{data}{recording_uuid} = $uuid;
        }
    }
    &print_json_response(%response);
}

sub deleterecording () {
    $uuid   = $form{recording_uuid};
    %domain = &get_domain();
    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash("select
                                            1,recording_filename
                                          from
                                            v_recordings
                                          where
                                            domain_uuid='$domain{uuid}' and recording_uuid='$uuid'",
                                        "filename");
        if (!$hash{1}{filename}) {
            $response{stat}		= "fail";
            $response{message}	= &_("recording filename not found"); 
        } else {
            warn "delete $recording_dir/$domain{name}/$hash{1}{filename}";
            
            unlink "$recording_dir/$domain{name}/$hash{1}{filename}";
            &database_do("delete from v_recordings where recording_uuid='$uuid'");
            
            $response{stat}		= "ok";
            $response{message}	= "ok";
        }
    }
    &print_json_response(%response);
}

sub getrecordinglist () {
    %domain         = &get_domain();
    local %response = ();
    
    if (!$domain{name}) {
        $response{stat}		= "ok";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    if ($response{stat} ne 'fail') {
        $response{stat}		= "ok";
        $response{message}	= "OK";
        
        $response{data}{recording_list} = [];
        %hash = &database_select_as_hash("select
                                        recording_uuid,recording_filename
                                      from
                                        v_recordings
                                      where
                                        domain_uuid='$domain{uuid}'",
                                    "filename");
        for (keys %hash) {
            $size = -s "$recording_dir/$domain{name}/$hash{$_}{filename}";
            push @{$response{data}{recording_list}},
				{
					recording_uuid => $_,
					recording_filename => $hash{$_}{filename},
					recording_size => $size,
					url => "/pbx/index.pl?action=downloadfile&&type=recording&&name=$hash{$_}{filename}"
				};
        }
    }
    &print_json_response(%response);   
}

return 1;

