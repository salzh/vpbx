#!/bin/sh
curl --cookie-jar /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Login&action=Login&domain=newmentor.managedlogix.net&user=admin&password=pbx123--'
#curl --cookie /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Crm&domain=newmentor.managedlogix.net&action=makecall&src=9999&dest=8882115404'


#curl --cookie /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Crm&domain=newmentor.managedlogix.net&action=agentlogout&agentname=102'
curl --cookie /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Crm&domain=newmentor.managedlogix.net&action=makeautocall&src=9991&dest=9992'
#curl --cookie /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Crm&domain=newmentor.managedlogix.net&action=makecall&src=9993&dest=108'
#curl --cookie /tmp/api.txt  -k 'http://67.227.80.11:8080/pbx/index.pl?mod=Crm&domain=newmentor.managedlogix.net&action=getchannelstate&uuid=d691003d-04ec-c194-2da5-ff49eab25c31'

