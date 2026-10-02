# Umsetzungsstand und technische Abnahme

Die README ist eine Kurzanleitung. Verbindliche Anforderungen stehen in
`SPEC.md`, KI-Arbeitsregeln in `AGENTS.md`, offene Aufgaben in dieser Datei.

## Aktueller Stand

- Nicht blockierende Engine und alle 80 stabilen Effekt-IDs/Namen implementiert.
- Katalog nach Kategorien, vier Seiten mit 24/24/24/8 Einträgen; keine Status- oder Fußzeile.
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
| 2: 80 stabile IDs/Namen | CPU prüft eindeutigen Katalog und alle 80 sortierten Auswahlen; VICE startet alle IDs. |
| 3: Ton/Rauschen/Kombination/Folgen | Daten und Registersteuerung technisch geprüft; subjektive Klangbeurteilung offen. |
| 4: Natürliches Ende | Alle 80 Effekte enden auf PAL/NTSC in CPU und VICE mit ausgeschalteten Quellen; zusätzlich alle 80 explizit gestoppt. |
| 5: Loops | CPU prüft Übergänge und definierte Pause; VICE fünfzehn Loops über mehrere Zyklen und Stop. |
| 6: Bedienung während Sound | CPU prüft gehaltene Navigation, Stop, Hilfe und Auswahl; VICE Seitenwechsel während Loops und Q. Tatsächlich gehaltene Host-Tasten manuell noch offen. |
| 7: Video/Speicher | Assemblergrenzen, CPU-Schreibbereiche und Videobits geprüft; Katalog/Hilfe visuell geprüft. Endadresse der Demo `$3557`, Ziel-RAM bis `$3FFF`. |
| 8: Integration | Menüfreies Beispiel gebaut; VICE PAL/NTSC mit 16 KB: Spielebewegung während Sound, Ereignisse, Ende, Stop und BASIC-Rückkehr bestehen. |
| 9: Emulator/Hören/Hardware | PAL/NTSC-Emulatorprüfungen bestehen. Alle 80 anhören/abstimmen und echte Hardware offen. |
| 10: RAM/Tick-Laufzeit | Demo 9559 Bytes, Engine/Katalog 7174 Bytes, keine Engine-Zero-Page; höchster getesteter Tick 332 CPU-Zyklen. Kein Hardware-Wallclock- oder DMA-Zeitnachweis. |

API, Messgrenzen und Integrationsbeispiel: [engine.md](engine.md).
Effektgestaltung: [effects.md](effects.md). Speicher/KERNAL: [hardware.md](hardware.md).

## Noch erforderliche manuelle Abnahme

1. Gehaltene Host-Tasten in VICE: SPACE/L nur einmal; Cursortasten wiederholen kontrolliert; RUN/STOP und Q funktionieren während Loops.
2. Alle 80 Effekte auf PAL und NTSC anhören; Charakter, Lautstärke, Tonhöhe und Loopübergänge beurteilen und bei Bedarf abstimmen.
3. `make run` und `make run-example` mit echter Audioausgabe von einem frischen Build bedienen.
4. Falls verfügbar: echter C16 mit 16 KB, PAL/NTSC-Geräte bzw. passende Hardwaretests. Ohne Gerät keine Hardwareabnahme.
5. Ursprüngliche System-Speicherreferenz abschließend gegenprüfen (offener Punkt in `docs/hardware.md`).

Die Benutzeränderung hat `TODO.md` entfernt; diese Datei führt den verbleibenden Arbeitsstand.

Keiner dieser offenen Punkte ist als bestanden markiert.

## `make run`-Nachweis vor der Erweiterung auf 70 Effekte

Vom Benutzer ausgeführtes `make run` bestätigt VICE 3.10, `-model c16`,
`-ramsize 16`, `-pal`, `-sounddev coreaudio` und PRG-RAM-Injektion ab
`$1001` mit `$198F` Bytes Nutzlast. Autostart endet mit `Starting program`
und `Done`; CoreAudio öffnet die MacBook-Pro-Lautsprecher bei 48000 Hz.
Die Vorabmeldungen zur Disk-/Tape-/Cartridge-Erkennung verhindern den
anschließenden PRG-Start nicht. Dies belegt Start und geöffnetes Audio,
keine menschliche Hörbeurteilung oder vollständige Bedienabnahme.

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
