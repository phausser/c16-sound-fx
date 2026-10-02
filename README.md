# C16 Sound FX

Geplant ist eine ACME-Assembler-Demo mit 50 benannten Soundeffekten für den Commodore 16. Eine Auswahlliste macht kurze Tonfolgen, Rauscheffekte, kombinierte Geräusche und wiederholbare Effekte direkt spielbar. Die Soundengine soll sich unabhängig vom Menü in Spiele einbauen lassen.

Der C16 erzeugt seinen Sound mit dem TED: zwei Rechteck-Tonkanäle und ein Rauschgenerator, der die Frequenzsteuerung mit dem zweiten Tonkanal teilt. Ziel ist ein unveränderter C16 mit 16 KB RAM, zunächst PAL; NTSC ist ebenfalls vorgesehen.

## Aktueller Stand

Build und nicht blockierende Soundengine sind implementiert. Die Demo spielt vier Prototypen: `jingle-win`, `landing`, `blaster-shot` und `alarm`. Die übrigen 46 IDs sind vorläufig stumm; vollständiger Katalog und Auswahlmenü folgen. ACME-Build und automatisierte Engine- sowie VICE-Prüfungen auf PAL/NTSC mit 16 KB RAM bestehen. Hörprüfung und visuelle Grafikprüfung sind offen.

Die Prototypdemo belegt 1412 Bytes; die Engine mit Tabellen und Prototypdaten 1071 Bytes, ohne Zero Page. Der höchste getestete Tick benötigt 292 CPU-Zyklen. API, Einbindung und Messgrenzen: [docs/engine.md](docs/engine.md). Hardwaregrundlage: [docs/hardware.md](docs/hardware.md).

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

## Prototypdemo bedienen

| Taste | Aktion |
|---|---|
| 1–4 | Win, Landing, Blaster oder Alarm starten/neustarten |
| L | Wiederholung umschalten |
| S | Wiedergabe und Wiederholung stoppen |
| Q | Ressourcen freigeben und nach BASIC zurückkehren |
| P / N | PAL / NTSC wählen; muss zum Emulator passen, stoppt Wiedergabe |

Die Demo startet mit PAL und Wiederholung aus. Für NTSC: `make run VICE_STANDARD=ntsc`, anschließend N drücken. Ein anderer Audiotreiber ist über `VICE_SOUND_DEVICE` wählbar. Aktionsentprellung folgt mit dem Menü.

## Automatisierte Prüfung

Für die CPU-Tests wird py65 benötigt; der VICE-Test benötigt nur Python und xplus4:

```sh
python3 -m venv /private/tmp/c16-engine-test
/private/tmp/c16-engine-test/bin/python -m pip install -r tests/requirements.txt
make test PYTHON=/private/tmp/c16-engine-test/bin/python
make test-vice
```

`make test-vice` verwendet den Dummy-Audiotreiber; es prüft Bildschirmtext, Prototypstarts und -ende sowie die Rückkehr nach BASIC, ohne Hörprüfung.

## Geplante Bedienung

| Taste | Aktion |
|---|---|
| Cursor hoch/runter | Effekt auswählen |
| Cursor links/rechts | Seite wechseln |
| RETURN oder SPACE | Effekt starten oder neu starten |
| L | Wiederholung ein/aus |
| S oder RUN/STOP | Wiedergabe und Wiederholung stoppen |
| Q | Zurück zu BASIC |

Die Liste umfasst drei Seiten mit 20, 20 und 10 Einträgen. Navigation bleibt während der Wiedergabe möglich. Ein neuer Start ersetzt den laufenden Effekt.

## Entwicklung und Commits

Alle Commits verwenden **Conventional Commits**:

```text
type(scope): kurze beschreibung
```

Der Scope ist optional. Beispiele: `feat(engine): nicht blockierende wiedergabe ergaenzen`, `fix(menu): seitengrenzen korrigieren` oder `docs: effektkatalog dokumentieren`. Typen und Regeln sind in [AGENTS.md](AGENTS.md) festgelegt.

Generierte Dateien gehören nach `build/` und werden über `.gitignore` ausgeschlossen. Build-Ergebnisse, Emulatorprüfungen und später gemessene Speicher- und Laufzeitwerte werden bei der Umsetzung dokumentiert.
