# C16 Sound FX

Dieses Projekt entwickelt eine ACME-Assembler-Demo mit 50 benannten Soundeffekten für den Commodore 16. Eine Auswahlliste macht kurze Tonfolgen, Rauscheffekte, kombinierte Geräusche und wiederholbare Effekte direkt spielbar. Die Soundengine ist unabhängig vom Menü nutzbar.

Der C16 erzeugt seinen Sound mit dem TED: zwei Rechteck-Tonkanäle und ein Rauschgenerator, der die Frequenzsteuerung mit dem zweiten Tonkanal teilt. Ziel ist ein unveränderter C16 mit 16 KB RAM, zunächst PAL; NTSC ist ebenfalls vorgesehen.

## Aktueller Stand

Build, nicht blockierende Soundengine und alle 50 Effektdaten sind implementiert. Die Katalogdemo startet jeden Effekt über seine stabile ID 00–49. Acht Effekte haben gestaltete Loops; `fire-crackle` verwendet reproduzierbare Knistervariation. Das Auswahlmenü zeigt drei nach Kategorien sortierte Seiten mit 24/24/2 Einträgen, Auswahlmarkierung und Loopstatus. Vor jedem Namen steht die Kategorie in Klammern. Die inverse Kopfzeile zeigt `C=16 Sound FX`, `Loop: ON/OFF`, `(H)elp` und rechts die Seite. H öffnet eine separate Hilfeseite. Hintergrund und Rahmen sind schwarz, die Schrift weiß. Cursortasten navigieren; RETURN/SPACE startet die Auswahl. Aktionskeys lösen einmal je Tastendruck aus; gehaltene Cursortasten wiederholen nach 0,5 Sekunden alle 0,1 Sekunden. CPU-Tests und VICE-Prüfungen auf PAL/NTSC mit 16 KB RAM bestehen; die Startanzeige ist visuell geprüft. Klangabstimmung und Hardwareprüfung bleiben offen.

Die Demo belegt 6543 Bytes; die Engine samt vollständigem Katalog 4269 Bytes, ohne Zero Page. Der höchste getestete Tick benötigt 332 CPU-Zyklen. API und Messgrenzen: [docs/engine.md](docs/engine.md). Katalog und Prüfungen: [docs/effects.md](docs/effects.md). Hardwaregrundlage: [docs/hardware.md](docs/hardware.md).

- [SPEC.md](SPEC.md): Anforderungen, vollständiger Katalog der 50 Effekte, API und Abnahme.
- [TOOD.md](TOOD.md): Umsetzungsschritte und Prüfungen.
- [AGENTS.md](AGENTS.md): verbindliche Regeln für die Entwicklung und Commit-Nachrichten.

## Voraussetzungen und Start

Benötigt werden ACME, Make und VICE mit dem TED-Emulator `xplus4`. ACME und `xplus4` wurden auf dem Entwicklungsrechner unter `/opt/homebrew/bin` gefunden.

Build und Emulatorstart:

```sh
make
make run
```

`make` erzeugt `build/c16-sound-fx.prg`. `make run` baut bei Bedarf und startet das Programm automatisch in VICE mit C16-Modell, 16 KB RAM, PAL und aktiviertem Sound.

Andere Toolpfade sind über Make-Variablen auswählbar:

```sh
make run ACME=/pfad/zu/acme VICE=/pfad/zu/xplus4
```

## Katalogdemo bedienen

| Taste | Aktion |
|---|---|
| Cursor hoch/runter, links/rechts | Auswahl, Seite wechseln |
| RETURN oder SPACE | Auswahl starten/neustarten |
| 00–49, dann RETURN oder SPACE | Effekt per ID starten/neustarten |
| H | Hilfe öffnen/schließen; RETURN/SPACE kehrt zum Katalog zurück |
| L | Wiederholung umschalten |
| S | Wiedergabe und Wiederholung stoppen |
| Q | Ressourcen freigeben und nach BASIC zurückkehren |
| P / N | PAL / NTSC wählen; muss zum Emulator passen, stoppt Wiedergabe |

Die Demo startet mit ID 00, PAL und Wiederholung aus. Beispielsweise startet `24` und RETURN den Effekt `vogelflug`. Ein oder zwei Ziffern werden angenommen; eine dritte Ziffer beginnt eine neue Eingabe. Ungültige IDs 50–99 lassen die Wiedergabe unverändert. Für NTSC: `make run VICE_STANDARD=ntsc`, anschließend N drücken. Ein anderer Audiotreiber ist über `VICE_SOUND_DEVICE` wählbar. Die Demo deaktiviert die KERNAL-Tastenwiederholung und stellt deren vorherigen Wert bei Q wieder her.

## Automatisierte Prüfung

Für die CPU-Tests wird py65 benötigt; der VICE-Test benötigt nur Python und xplus4:

```sh
python3 -m venv /private/tmp/c16-engine-test
/private/tmp/c16-engine-test/bin/python -m pip install -r tests/requirements.txt
make test PYTHON=/private/tmp/c16-engine-test/bin/python
make test-vice
make record-vice
```

`make test-vice` verwendet den Dummy-Audiotreiber; es prüft alle 50 Starts und natürlichen Enden, acht Loops mit Stop, ID-Eingabe, Bildschirmdaten und die Rückkehr nach BASIC. `make record-vice` führt denselben Test mit CoreAudio und WAV-Aufnahme ohne Warp durch; die Klangbeurteilung erfolgt separat.

## Auswahlmenü bedienen

| Taste | Aktion |
|---|---|
| Cursor hoch/runter | Effekt auswählen |
| Cursor links/rechts | Seite wechseln |
| RETURN oder SPACE | Effekt starten oder neu starten |
| L | Wiederholung ein/aus |
| S oder RUN/STOP | Wiedergabe und Wiederholung stoppen |
| Q | Zurück zu BASIC |

Die Liste umfasst drei Seiten mit 24, 24 und 2 Einträgen. Kategorien stehen zusammenhängend hintereinander und dürfen über einen Seitenwechsel weiterlaufen. Die Sortierung verändert weder die angezeigten noch die API-IDs. Gruppen: JINGLE, SAMMELN, MENU, SIGNAL, BEWEGUNG, FAHRGERAEUSCH, UMGEBUNG, OBJEKT, SCHUSS, EXPLOSION, KAMPF. Die Hilfeseite hält Auswahl und Wiedergabe aufrecht; L, S/RUN-STOP und Q bleiben verfügbar. Navigation bleibt während der Wiedergabe möglich. Ein neuer Start ersetzt den laufenden Effekt.

## Entwicklung und Commits

Alle Commits verwenden **Conventional Commits**:

```text
type(scope): kurze beschreibung
```

Der Scope ist optional. Beispiele: `feat(engine): nicht blockierende wiedergabe ergaenzen`, `fix(menu): seitengrenzen korrigieren` oder `docs: effektkatalog dokumentieren`. Typen und Regeln sind in [AGENTS.md](AGENTS.md) festgelegt.

Generierte Dateien gehören nach `build/` und werden über `.gitignore` ausgeschlossen. Build-Ergebnisse, Emulatorprüfungen und später gemessene Speicher- und Laufzeitwerte werden bei der Umsetzung dokumentiert.

Unter der Titelleiste sind alle 24 Zeilen für Effekte reserviert; es gibt keine Status- oder Fußzeile. Direkte ID-Eingabe bleibt verfügbar, ohne eine separate Eingabeanzeige.
