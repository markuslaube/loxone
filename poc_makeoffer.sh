!#/bin/bash
# Dies ist der dritte (noch nicht endgültig erfolgreicher) Proof of Concept 
# hier versuche ich dem Videostream und idealerweise sogar der Sprachkommunikation der InterCom Gen2 habhaft zu werden
#
# Dies ist nur ein Support-Tool um die manuellen Arbeiten beim Lösungsfinden zu erleichtern.
# 
# Dieses Script erwartet auf $1 ein Mitschnitt des "OFFERS" der AIORTC _Aufrufs
# 
# Bsp: python3 cli.py --record-to bilder/dump.mp4 offer | tee aio.log
#      Aus dem dort generierten OFFER von aiortc baut das script aktuell ein jsonrpc 2.0 für Loxone bestehend aus Offer und 
#      die erfoderlichen addIceCandidate Jsonrpc Ausdrücke
#
#      Diese übergibt man dann per Copy&Paste an den webocket der Loxone (siehe weiteres Script)
#
# Autor Markus Laube, markus@laube.email
# Version: 2022-01-20 20:20
# Licence: GNU GENERAL PUBLIC LICENSE 3 - https://github.com/markuslaube/loxone/blob/main/LICENSE
#
#
echo ""
echo ""
echo -n '{"jsonrpc":"2.0","method":"call","id":2,"params":['
echo -n "$(grep offer $1)"
echo ',"new",false]}'
echo ""
count=10
ufrag="$(grep offer $1 | sed 's#\\n#\\n\n#g' | grep ufrag | awk -F: '{print$2}' | sed 's/\\r\\n//g')"
grep offer $1 | sed 's#\\n#\\n\n#g' | grep candidate | grep -v 'a=end-of-candidates' | sed 's/^a=//g' | sed 's/\\r\\n/ /g' | while read line ; do
        let count=count+1
        echo -n '{"jsonrpc":"2.0","method":"addIceCandidate","id":'
        echo -n ${count}
        echo -n ',"params":["'
        echo -n $line
        echo -n ' generation 0 ufrag '
        echo -n $ufrag
        echo ' network-id 5 network-cost 50",0]}'
done
