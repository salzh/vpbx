sub getcontactlist () {
	$domain = &database_clean_string($form{domain});
	
	%hash = &database_select_as_hash("select extension_uuid,extension,effective_caller_id_name from v_extensions,v_domains where  v_extensions.domain_uuid = v_domains.domain_uuid and domain_name='$domain' ",
					 'extension,name');
	$xml 	= '';
	for (sort {$hash{$a}{name} cmp $hash{$b}{name}} keys %hash) {
		$xml .= "
	<DirectoryEntry>
		<Name>$hash{$_}{name}</Name>
		<Telephone>$hash{$_}{extension}</Telephone>
	</DirectoryEntry>
";
	}
	
	$url = "http://$ENV{HTTP_HOST}$ENV{REQUEST_URI}";
	
	($company = $domain) =~ s/\.//g;
	$xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<${company}IPPhoneDirectory clearlight=\"true\">
$xml
	<SoftKeyItem>
	<Name>#</Name>
	<URL><![CDATA[$url]]></URL>
	</SoftKeyItem>
</${company}IPPhoneDirectory>
";

	&cgi_hearder('text/xml');
	print $xml;
	
	exit 0;
}

1;