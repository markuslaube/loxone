#!/bin/bash
# Das ist ein Proof of Conecpt um Bilder von einer Loxone intercom2 in anderen Systemen weiter zu verarbeiten.
#
# Autor Markus Laube, markus@laube.email
#
intercom="172.16.2.190"
#
# Das Script ist Mac-Optimiert, bitte insbesondere bei diversen Parametern (ps aux u. a.) beachten
#
#
# Proof Of Concept! Wir arbeiten mit Temp daten

rm /tmp/testfile.output
rm /tmp/lastpicture.jpg

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
     http://${intercom}/ --output /tmp/testfile.output 2>/dev/null &

sleep 1
authkey="$(cat /tmp/testfile.output| iconv -c  | grep '\[' | sed 's/.*\["//g' | sed 's/",".*//g')"
curl --output /tmp/lastpicture.jpg "http://${intercom}/jpg/image.jpg?auth=${authkey}"
kill $(ps auxwwww | grep '[0]0KILL0ME0LATER0000000' | awk '{print$2}')
