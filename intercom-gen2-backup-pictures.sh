#!/bin/bash
# Das ist der zweite (erfolgreicher) Proof of Concept um Bilder von einer Loxone intercom2 in anderen Systemen weiter zu verarbeiten.
# Ich verwende das Tool dazu, um ab und zu mal die Bilder von der Intercom wegzusichern
# Achtung wscat ist offensichtlich nicht geegnet im Hintergrund zu laufen, das Script ist daher nicht CRON-fähig
#
# Autor Markus Laube, markus@laube.email
# Version: 2022-01-18 21:22
# Licence: GNU GENERAL PUBLIC LICENSE 3 - https://github.com/markuslaube/loxone/blob/main/LICENSE
#
intercom="172.16.2.190:80"                                       # Die IP und der Port der InterCom Gen.2
wscatwait=20                                                     # Geschätzte Zeit für den Lauf der Funktion make_pictures -> brauchen wir bei -w vom wscat
makewait=2                                                       # Geschätzte Zeit bis die Info von der Intercom im tempfile sind -> brauchen wir beim sleep in der funktion vom wscat
picturedir="/tmp/intercom-bildertest"                            # -> Backup-Destination-Pfad
tempfile="$(mktemp)"                                             # TempFile für Output aus WebSocket


# Wir bauen eine Funktion zum Abholen der Bilder, Hintergrund dazu:
# Während des Downloads muss die aktuelle Web-Socket-Verbindung bestehen bleiben,
# wscat ist aber nicht dafür geeignet selbst im Hintergrund zu laufen also:

function make_pictures () {

        # Sicherheitshalber Verzeichnis anlenegm
        mkdir -p ${picturedir}
        # Verzeichnis betreteb
        cd ${picturedir}
        # Wir warten datauf das die Websocket-Verbindung wirklich die Pfad-Informationen eingesammelt hat, wie lange sagen wir beim Aufruf als Parameter 1
        sleep ${makewait}
        # Jetzt einmal ein bissl grep, awk und sed zusammen mit einem wget
        for image in $(cat ${tempfile} | sed 's#,#\n#g' | grep imagePath | awk -F\" '{print$4}' | sed 's#\\/#/#g' )  ; do wget "http://${intercom}${image}" ; done
        # um die -w Angabe und damit die "Leerlaufzeit" des Scripts zu optimieren, geben wir hier mal die Zeit aus wenn der eigentliche Download fertig ist und später dann wenn das Script beendet ist
        echo "DEBUG: Download beendet: $(date)"
}

# Also ersteinmal die wget Funktion starten und in den Hintergrund schieben
make_pictures &

# und jetzt die wscat Verbindung starten, -w  sorgt dafür das wir x Sekunden nach dem Command-Versand warten, das sollte angepasst werden, bei mir reicht das akutell
wscat -c ${intercom} -s webrtc-signaling --slash -P -w ${wscatwait} -x '{"jsonrpc":"2.0","method":"getLastActivities","id":1,"params":[0,100]}' > ${tempfile}

# Die Verbindung mit wscat ist jetzt eh weg, daher löschen wir jetzt auch das tempfile
rm ${tempfile}

# Nochmal Uhrzeit -> die Differenz in Sekunden kann man dann vom in der Variable wait runter nehmen, bitte Puffer lassen
echo "DEBUG: Script beendet: $(date)"
