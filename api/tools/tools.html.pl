($mod, $action) = @ARGV;
require "../include.pl";
use LWP::Simple;
if ($action eq 'addoutboundroute') {
    for (qw/gateway dialplan_expression dialplan_description/) {
        $other_fields .="           $_: <input type=text name=$_ /><br>\n"
    }
}

if ($action eq 'editdialplan') {
	$json='{"detail_list":[{"dialplan_details[0][dialplan_detail_group]":null,"dialplan_details[0][dialplan_detail_break]":null,"dialplan_details[0][dialplan_detail_order]":"10","dialplan_details[0][dialplan_detail_type]":"context","dialplan_details[0][dialplan_detail_inline]":null,"dialplan_details[0][dialplan_detail_tag]":"condition","dialplan_details[0][dialplan_detail_uuid]":"47b46b6e-6b66-4393-9c59-90cb86c69cd9","dialplan_details[0][dialplan_detail_data]":"public"},{"dialplan_details[1][dialplan_detail_inline]":null,"dialplan_details[1][dialplan_detail_uuid]":"77c36512-75e2-406d-a294-d6f2ae44ac86","dialplan_details[1][dialplan_detail_break]":null,"dialplan_details[1][dialplan_detail_type]":"destination_number","dialplan_details[1][dialplan_detail_data]":"3109990000","dialplan_details[1][dialplan_detail_tag]":"condition","dialplan_details[1][dialplan_detail_group]":null,"dialplan_details[1][dialplan_detail_order]":"20"},{"dialplan_details[2][dialplan_detail_order]":"30","dialplan_details[2][dialplan_detail_group]":null,"dialplan_details[2][dialplan_detail_break]":null,"dialplan_details[2][dialplan_detail_type]":"set","dialplan_details[2][dialplan_detail_data]":"accountcode=false","dialplan_details[2][dialplan_detail_uuid]":"1128cb67-303a-4c75-bd2a-9fa5fdae0c19","dialplan_details[2][dialplan_detail_tag]":"action","dialplan_details[2][dialplan_detail_inline]":null},{"dialplan_details[3][dialplan_detail_group]":null,"dialplan_details[3][dialplan_detail_break]":null,"dialplan_details[3][dialplan_detail_tag]":"action","dialplan_details[3][dialplan_detail_uuid]":"ba17cefd-00ed-4e0b-b238-5a3c58431483","dialplan_details[3][dialplan_detail_inline]":null,"dialplan_details[3][dialplan_detail_data]":"100 XML shy.managedlogix.net","dialplan_details[3][dialplan_detail_order]":"41","dialplan_details[3][dialplan_detail_type]":"transfer"}],"dialplan_name":"3109990000","dialplan_enabled":"true","dialplan_uuid":"08feacc0-a4c1-498e-8ed2-7b91bb9d54a5","dialplan_context":"public","app_uuid":"c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4","dialplan_number":"3109990000","dialplan_description":"to be deleted","dialplan_order":"81"}';
	%hash = &Json2Hash($json);
	print Dumper(\%hash);
	for (keys %hash) {
		next if $_ eq 'detail_list';
		$other_fields .="           $_: <input type=text name=$_  value='$hash{$_}' size=50/><br>\n";
	}
	
	for $list (@{$hash{detail_list}}) {
		for (keys %$list) {
			$other_fields .="           $_: <input type=text name=$_  value='$$list{$_}' size=50/><br>\n";
		}
	}
}

if ($action eq 'adddialplan'){
	for (qw/dialplan_name condition_field1 condition_expression_1 action_1/) {
        $other_fields .="           $_: <input type=text name=$_ /><br>\n"
    }
}
$TT =<<HTML;
    <html>
        <header><title>route test</title></header>
        <body>
            <form method=post action='/pbx/index.pl'>
                <input type=hidden name=mod value=$mod />
                <input type=hidden name=action value=$action />
    $other_fields
                <input type=submit value=submit />
            </form>
        </body>
    </html>
HTML
    
open FH, "> ../html/$action.html";
print FH $TT;
close FH;


