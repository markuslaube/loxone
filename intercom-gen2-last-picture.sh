#!/bin/bash
# Das ist ein (erfolgreicher) Proof of Concept um Bilder von einer Loxone intercom2 in anderen Systemen weiter zu verarbeiten.
# Ich verwende das Tool dazu, um nach einem Klingelsignal mittels Virtuellem Ausgang das letzt Bild zu kopieren und unter einem
# generischen Pfad der Fritz!Box bereitzustellen. In Verbindung mit einem anschließend ausgelösten Text2SIP-Call sehe ich dann
# das letzte Bild auf dem Fritz!Fon ;)
#
# Ursprünglich habe ich das ganze mit curl / websocat implementiert, jetzt hat sich herausgestellt das ein mjpeg stream verfügbar ist.
#
# Eigentlich hatte der Hersteller ja eine SIP-Integration versprochen. Mal schauen ob die noch kommt.
#
# Autor Markus Laube, markus@laube.email
# Version: 2022-10-11 22:46 
# Licence: GNU GENERAL PUBLIC LICENSE 3 - https://github.com/markuslaube/loxone/blob/main/LICENSE
#
# echo "DEBUG: Script startet: $(date)"

intercom="172.16.2.190:80"                                       # Die IP und der Port der InterCom Gen.2
username="****"							 # User mit rechten auf Klingel
password="****"							 # Password des Users

lastpict="/opt/loxberry/webfrontend/html/tmp/lastpicture.jpg"    # -> Ja das sollte noch hinter das Auth landen
                                                                 # In der Fritz steht damit ${loxberry}/tmp/lastpicture.jpg
tempfile="$(mktemp)"                                             # TempFile für Output aus WebSocket
rm -f ${tempfile}						 # Tempfile brauch eh Endung (.jpg) und darf eh nicht existieren

base64auth="$(echo -n "${username}:${password}" | base64 )"

ffmpeg -loglevel error -headers "Authorization: Basic ${base64auth}" -i "http://${intercom}/mjpg/video.mjpg" -frames:v 1 ${tempfile}.jpg
mv ${tempfile}.jpg ${lastpict}
