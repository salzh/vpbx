=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

$music_dir = '/usr/local/freeswitch/sounds/music';
sub addmusiconhold () {
    %domain = &get_domain();
    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if ($response{stat} ne 'fail') {
        $rawname	= $cgi->param('recordingfile');
	
        if ($rawname) {
            ($filename) = $rawname    =~ /([^\\\/]+)$/;
            $filename   = &clean_str($filename, "-_.")
        } else {
             $response{stat}	= "fail";
             $response{message}	= &_("no file uploaded");
        }
        
        if ($response{stat} ne 'fail') {            #code
            $rate = $form{upload_sampling_rate} || 8000;
            $rate = "$rate";
            $category = $form{upload_category} || '';
            $category_new = $form{upload_category_new};
            
            $dir = "";
            if ($category_new) {
                $dir = "$music_dir/$domain{name}/$rate/$category_new";
                mkdir $dir;
            } else {
                if ($category) {
                    $dir = "$music_dir/$domain{name}/$category/$rate";
                } else {
                    $dir = "$music_dir/$rate";
                }
                
            }
            
			warn $dir;
            if (!-e $dir) {
				use File::Path qw(make_path);
                make_path $dir;
            }
            
			%upload = &upload_file('recordingfile', $dir, 10*1024*1024, 'wav,mp3', 'keepname');
            
           
            $response{stat}			  = "ok";
            $response{data}{filename} = $upload{name};
        }
    }
    
    &print_html_response(%response);
}



sub deletemusiconhold () {
    %domain = &get_domain();
    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    if ($response{stat} ne 'fail') {
        $rate     = $form{sampling_rate} || 8000;
        $category = $form{category};
        
        $filename = &clean_str(substr($form{filename}, 0, 50), "-_.");
		if ($filename =~ /\\\//) {
			&print_api_error_end_exit(180, "there is invalid character in the filename");	
		}
		
        $file = '';
        if ($category && $category ne 'default') {
            $file = "$music_dir/$domain{name}/$category/$rate/$filename";
        } else {
            $file = "$music_dir/$rate/$filename";
        }
        warn "delete moh: $file";
        
        unlink $file;
        $response{stat}	= "ok";
       
    }
    &print_json_response(%response);
}

sub getmusiconholdlist () {
    %domain = &get_domain();
    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    if ($response{stat} ne 'fail') {
        $response{stat}	= "ok";
        
        $response{data}{musiconhold_list} = [];
        
        while (<$music_dir/*/*>) {
            ($rate, $filename) = $_ =~ /(\d+)\/([^\\\/]+)$/;
            @s = stat($_);
            next if !$filename;

            $size = $s[7];
            $date = &time2str($s[10]);
            push @{$response{data}{musiconhold_list}},
				{
					filename => $filename, recording_size => $size,
					url => "/pbx/index.pl?action=downloadfile&&type=music&&sampling_rate=$rate&&filename=$filename",
					sampling_rate => $rate, category => 'default',
					uploaded_time => $date
				};
        }
        
       
        while (<$music_dir/$domain{name}/*/*/*>) {
            ($category, $rate, $filename) = $_ =~ /([^\\\/]+)\/(\d+)\/([^\\\/]+)$/;
            @s = stat($_);
            $size = $s[7];
			next if !$filename;
            $date = &time2str($s[10]);
            push @{$response{data}{musiconhold_list}},
				{
					filename => $filename, recording_size => $size,
					url => "/pbx/index.pl?action=downloadfile&&type=music&&rate=$rate&&category=$category&&name=$filename",
					sampling_rate => $rate, category => $category, uploaded_time => $date
				};
        }
    }
    &print_json_response(%response);   
}


return 1;

