   require 'include.pl';
    local %params = (
        broadcast_name => {type => 'string', maxlen => 50, notnull => 1, default => '\d'},
        broadcast_timeout => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_concurrent_limit => {type => 'int', maxlen => 4, notnull => 0, default => ''},
        broadcast_caller_id_name => {type => 'string', maxlen => 20, notnull => 0, default => ''},
        broadcast_caller_id_number => {type => 'int', maxlen => 15, notnull => 0, default => '0000000000'},
        broadcast_destination_data => {type => 'destination', maxlen => 255, notnull => 0, default => ''},
        broadcast_phone_numbers => {type => 'string', maxlen => 65535, notnull => 0, default => ''},
        broadcast_avmd => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
        broadcast_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}
    );
    
    #$h = $params{broadcast_name};
    
    print $h->{type};
    
    $json =  &Hash2Json(%params);
    
    
    %hash = &Json2Hash($json);
    
    print $hash{broadcast_name}{default}, "\n";
    