#!/bin/bash
# Das ist ein (erfolgreicher) Proof of Concept um Bilder von einer Loxone intercom2 in anderen Systemen weiter zu verarbeiten.
# Ich verwende das Tool dazu, um nach einem Klingelsignal mittels Virtuellem Ausgang das letzt Bild zu kopieren und unter einem
# generischen Pfad der Fritz!Box bereitzustellen. In Verbindung mit einem anschließend ausgelösten Text2SIP-Call sehe ich dann
# das letzte Bild auf dem Fritz!Fon ;)
#
# Eigentlich hatte der Hersteller ja eine SIP-Integration versprochen. Mal schauen ob die noch kommt.
#
# Autor Markus Laube, markus@laube.email
#
intercom="172.16.2.190"                                          # Die IP Adresse der InterCom Gen.2
lastpict="/opt/loxberry/webfrontend/html/tmp/lastpicture.jpg"    # -> Ja das sollte noch hinter das Auth landen
                                                                 # In der Fritz steht damit ${loxberry}/tmp/lastpicture.jpg
tempfile="$(mktemp)"                                             # TempFile für Output aus WebSocket
#
mv ${lastpict} ${lastpict}.sic                                   # wenn das mal nötig ist können wir ein step back im Fehlerfall einbauen
#
#
# Wir Initieren ein WebSocket-Upgrade und die Intercom sagt uns den aktuellen Auth-Key :Facepalm:
#
curl --include \
     --no-buffer \
     --header 'Connection: Upgrade' \
     --header 'Pragma: no-cache' \
     --header 'Cache-Control: no-cache' \
     --header 'Upgrade: websocket' \
     --header 'Origin: file://' \
     --header 'Accept-Encoding: gzip, deflate' \
     --header 'Accept-Language: de' \
     --header 'Sec-WebSocket-Version: 13' \
     --header 'Sec-WebSocket-Key: 00KILL0ME0LATER0000000==' \
     --header 'Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits' \
     --header 'Sec-WebSocket-Protocol: webrtc-signaling' \
     http://${intercom}/ --output ${tempfile} 2>/dev/null &
#
# zur Sicherheit einmal ne Sekunde warten, vermutlich reine Paranoia
sleep 1
#
# Das Tempfile jetzt nach dem Auth-Key durchsuchen (erster Wert nach der '['
authkey="$(cat ${tempfile}| iconv -c  | grep '\[' | sed 's/.*\["//g' | sed 's/",".*//g')"
#
# Das Bild abholen, wir sind ja Authentifiziert :D
curl --output ${lastpict} "http://${intercom}/jpg/image.jpg?auth=${authkey}"
#
# Wir brauchen den Pseudo-WebSocket nicht mehr, also machen wir jetzt das was im Key steht (KILL ME LATER) jetzt
kill $(ps auxwwww | grep '[0]0KILL0ME0LATER0000000' | awk '{print$2}')
#
# Das Tempfile kann jetzt weg
rm -f ${tempfile}
