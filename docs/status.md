# Umsetzungsstand und technische Abnahme

Die README ist eine Kurzanleitung. Verbindliche Anforderungen stehen in
`SPEC.md`, KI-Arbeitsregeln in `AGENTS.md`, offene Aufgaben in dieser Datei.

## Aktueller Stand

- Nicht blockierende Engine und alle 105 stabilen Effekt-IDs/Namen implementiert.
- Katalog nach Kategorien, fünf Seiten mit 24/24/24/24/9 Einträgen; keine Status- oder Fußzeile.
- Inverse Titelleiste: `C=16 Sound FX`, `Loop: ON/OFF`, `(H)elp`, Seite rechts.
- Kategorie vor Namen; Namen ab Spalte 20. Kategorien dürfen über Seitenwechsel weiterlaufen.
- Separate Hilfe mit H; RETURN/SPACE kehrt zurück. Sound und Auswahl bleiben erhalten.
- Hintergrund/Rahmen konfigurierbar über `TED_BG_COLOR`, aktuell `$36`; Schrift `$71`.
- KERNAL-Wiederholung gesichert/gesperrt/zurückgegeben; Cursornavigation mit 0,5-s-Vorlauf und 0,1-s-Intervall.
- Menüfreies, animiertes Spielebeispiel mit Jump/Shot/Coin/Engine-Loop vorhanden.

## Prüfungen ausführen

```sh
python3 -m venv /private/tmp/c16-engine-test
/private/tmp/c16-engine-test/bin/python -m pip install -r tests/requirements.txt
make
make example
make test PYTHON=/private/tmp/c16-engine-test/bin/python
make test-vice
make test-example-vice
make record-vice
make record-inspired
```

`make record-vice` zeichnet mit dem konfigurierten Audiotreiber WAVs auf;
das ist noch keine Hörprüfung. PRGs, Symbole, Listings, WAVs, Screenshots,
Monitorbefehle und Logs liegen ausschließlich unter `build/`.

## Abgleich mit SPEC

| Kriterium | Ergebnis und Grenze |
|---|---|
| 1: Build, Start, hörbare Demo | ACME-Build und VICE-Autostart mit 16 KB bestehen; CoreAudio war geöffnet. Menschliche Hörprüfung offen. |
| 2: 105 stabile IDs/Namen | CPU prüft eindeutigen Katalog und alle 105 sortierten Auswahlen; VICE startet alle IDs. |
| 3: Ton/Rauschen/Kombination/Folgen | Daten und Registersteuerung technisch geprüft; subjektive Klangbeurteilung offen. |
| 4: Natürliches Ende | Alle 105 Effekte enden auf PAL/NTSC in CPU und VICE mit ausgeschalteten Quellen; zusätzlich alle 105 explizit gestoppt. |
| 5: Loops | CPU prüft Übergänge und definierte Pause; VICE siebzehn Loops über mehrere Zyklen und Stop. |
| 6: Bedienung während Sound | CPU prüft gehaltene Navigation, Stop, Hilfe und Auswahl; VICE Seitenwechsel während Loops und Q. Tatsächlich gehaltene Host-Tasten manuell noch offen. |
| 7: Video/Speicher | Assemblergrenzen, CPU-Schreibbereiche und Videobits geprüft; Katalog/Hilfe visuell geprüft. Endadresse der Demo `$3F00`, Ziel-RAM bis `$3FFF` (255 Bytes frei). |
| 8: Integration | Menüfreies Beispiel gebaut; VICE PAL/NTSC mit 16 KB: Spielebewegung während Sound, Ereignisse, Ende, Stop und BASIC-Rückkehr bestehen. |
| 9: Emulator/Hören/Hardware | PAL/NTSC-Emulatorprüfungen bestehen. Alle 105 anhören/abstimmen und echte Hardware offen. |
| 10: RAM/Tick-Laufzeit | Demo 12032 Bytes, Engine/Katalog 10203 Bytes, keine Engine-Zero-Page; höchster getesteter Tick 332 CPU-Zyklen. Kein Hardware-Wallclock- oder DMA-Zeitnachweis. |

API, Messgrenzen und Integrationsbeispiel: [engine.md](engine.md).
Effektgestaltung: [effects.md](effects.md). Speicher/KERNAL: [hardware.md](hardware.md).

## Noch erforderliche manuelle Abnahme

1. Gehaltene Host-Tasten in VICE: SPACE/L nur einmal; Cursortasten wiederholen kontrolliert; RUN/STOP und Q funktionieren während Loops.
2. Alle 105 Effekte auf PAL und NTSC anhören; Charakter, Lautstärke, Tonhöhe und Loopübergänge beurteilen und bei Bedarf abstimmen.
3. `make run` und `make run-example` mit echter Audioausgabe von einem frischen Build bedienen.
4. Falls verfügbar: echter C16 mit 16 KB, PAL/NTSC-Geräte bzw. passende Hardwaretests. Ohne Gerät keine Hardwareabnahme.
5. Ursprüngliche System-Speicherreferenz abschließend gegenprüfen (offener Punkt in `docs/hardware.md`).

Die Benutzeränderung hat `TODO.md` entfernt; diese Datei führt den verbleibenden Arbeitsstand.

Keiner dieser offenen Punkte ist als bestanden markiert.

## `make run`-Nachweis mit 105 Effekten

Vom Benutzer am 2026-10-03 ausgeführtes `make run` (Stand `605b16d`)
bestätigt VICE 3.10, `-model c16`, `-ramsize 16`, `-pal`,
`-sounddev coreaudio` und PRG-RAM-Injektion ab `$1001` mit `$2F00` Bytes
Nutzlast, passend zum Build-Ende `$3F00`. Autostart endet mit
`Starting program` und `Done`; CoreAudio öffnet die MacBook-Pro-Lautsprecher
bei 48000 Hz. Ebenso startete `make run-example` mit `$292D` Bytes ab
`$1001`. Die Vorabmeldungen zur Disk-/Tape-/Cartridge-Erkennung und fehlende
Laufwerks-ROMs verhindern den PRG-Start nicht. Dies belegt Start und
geöffnetes Audio, keine menschliche Hörbeurteilung oder vollständige
Bedienabnahme.

Früherer Nachweis vor der Erweiterung auf 70 Effekte: `$198F` Bytes Nutzlast,
gleiche Optionen und gleiches Ergebnis.

## Erweiterung: 20 Spielvorbilder

IDs 0–49 behalten Namen und Abläufe. IDs 50–69 ergänzen stilisierte
Spielvorbilder aus C64, Amiga und neueren Spielen. Drei Katalogseiten mit
24/24/22 Einträgen; neue Klänge in die bestehenden Kategorien einsortiert.
CPU-Tests prüfen alle 80 Auswahlen, PAL/NTSC-Frequenz-/Zeitdaten, Ende,
Stop, Wiederholung und die Tabellenadressierung oberhalb ID 63.
Die neuen Effekte sind gestaltet, aber nicht gegen Originalaufnahmen
akustisch vermessen oder subjektiv als klanggleich abgenommen.
Auswahl, Quellen und Klangideen: [game-inspired.md](game-inspired.md).

WAV-Vorschau der IDs 50–69: `make record-inspired`, Ausgabe `build/game-inspired-pal.wav`. Nichtstummes PCM ist geprüft; Vorbildähnlichkeit und subjektive Hörabnahme bleiben offen.

## Erweiterung: Flügelschlag

IDs 70–79 sind fünf gestaltete Flügelschlag-Loops in BEWEGUNG. Vier Seiten (24/24/24/8); CPU und VICE prüfen alle 80 Effekte und 15 Loops auf PAL/NTSC mit 16 KB. Details: [wing-loops.md](wing-loops.md). `make record-flaps` erzeugt eine Vorschau mit mehrfacher Wiederholung jedes neuen Loops. Subjektive Hörabnahme bleibt offen.

## Lebensverlust

IDs 75–79 ergänzen fünf einmalige Lebensverlust-Sounds unter JINGLE.
Der Katalog umfasst jetzt 80 Effekte, vier Seiten (24/24/24/8) und weiterhin 15 Loops.
Details und drei Flappy-Bird-Beispiele: [life-lost.md](life-lost.md).

## Erweiterung: Mario und iOS

IDs 80–89 ergänzen zehn stilisierte Mario-Vorbilder, IDs 90–99 zehn
Vorbilder bekannter iOS-Spiele. Der Katalog umfasst jetzt 100 Effekte, fünf
Seiten (24/24/24/24/4) und 16 Loops (neu: `jetpack-thrust`). `make test`,
`make test-vice` und `make test-example-vice` bestehen auf PAL/NTSC mit
16 KB. `make record-mario` und `make record-ios` erzeugen Vorschauen; nicht
stummes PCM und natürliche Enden sind geprüft. Das Programm endet bei
`$3EE8`, es bleiben 279 Bytes bis `$3FFF`. Vorbildähnlichkeit und subjektive
Hörabnahme bleiben offen. Details: [mario-ios.md](mario-ios.md).

## Erweiterung: Boulder Dash

IDs 100–104 ergänzen fünf Boulder-Dash-Vorbilder nach der SID-Analyse von
Martijn Mooij. Für Speicher wurde die Hilfeseite auf nullterminierte Zeilen
umgestellt (589 Bytes gespart). Menü zeigt IDs ab 100 dreistellig; die
Direkteingabe nimmt bis zu drei Ziffern an. Katalog: 105 Effekte, fünf Seiten
(24/24/24/24/9), 17 Loops. `make test`, `make test-vice` (alle 105 IDs per
Tastaturpuffer, auch dreistellig) und `make test-example-vice` bestehen auf
PAL/NTSC mit 16 KB; Seite 5 und Hilfe per Bildschirmspeicher geprüft.
`make record-boulder` erzeugt eine Vorschau mit nicht stummem PCM und
natürlichen Enden. Programmende `$3F00`, 255 Bytes frei. Hörabnahme offen.
Details: [boulder-dash.md](boulder-dash.md).
