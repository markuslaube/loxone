!#/bin/bash
# Dies ist der dritte (noch nicht endgültig erfolgreicher) Proof of Concept 
# hier versuche ich dem Videostream und idealerweise sogar der Sprachkommunikation der InterCom Gen2 habhaft zu werden
#
# Dies ist nur ein Support-Tool um die manuellen Arbeiten beim Lösungsfinden zu erleichtern.
# 
# Dieses Script erwartet auf $1 ein Mitschnitt des "ANSWERS" der websocket-Aufrufs
# 
# Bsp: ${websocat} --protocol webrtc-signaling ws://${intercom} | tee loxone.log
#      Aus dem dort generierten ANSWER und CANDIDATE von Loxone baut das script aktuell eine ANSWER für aiortc bestehend aus Offer und 
#      die erfoderlichen a=candidate Ausdrücken in eiem Ausdruck
#
#      Diese übergibt man dann per Copy&Paste an den aiortc client 
#      Danach sollte die InterCom UDP Pakete versenden.
#
# Fachliche Diskussionen laufen hierzu unter: 
# https://www.loxforum.com/forum/hardware-zubehör-sensorik/330121-loxone-intercom-gen2-webschnittstelle-um-bild-video-rauszubekommen/page2
#
# Autor Markus Laube, markus@laube.email
# Version: 2022-01-20 20:20
# Licence: GNU GENERAL PUBLIC LICENSE 3 - https://github.com/markuslaube/loxone/blob/main/LICENSE
#
PART1="$(cat $1 | grep answer | awk -F\{ '{print$4}' | awk -F\, '{print$1}' | sed 's#"$##' )"
PART2="$(cat $1 | grep candidate | awk -F\[ '{print$2}' | awk -F\" '{print"a="$2"\\r\\n"}')"

( echo "{${PART1}${PART2}"
echo 'a=end-of-candidates\r\n", "type": "answer"}' ) | tr -d '\n'

echo""
