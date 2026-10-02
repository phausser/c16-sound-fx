# Projektregeln

## Ziel und Dokumentation

Dieses Projekt entwickelt mit ACME eine C16-Demo mit 80 TED-Soundeffekten und einer separat nutzbaren Spiele-Soundengine. Verbindliche Anforderungen stehen in `SPEC.md`, der Arbeitsplan in `docs/status.md`. Die `README.md` bleibt eine Kurzanleitung für Build, Start und Bedienung. Technischer Stand, Prüfergebnisse und offene Einschränkungen gehören nach `docs/`, insbesondere `docs/status.md` und `docs/engine.md`. Geplante Funktionen ausdrücklich als geplant kennzeichnen.

## Umsetzung

- Zielgerät: unveränderter C16 mit 16 KB RAM; PAL als Referenz, NTSC gemäß Spezifikation.
- ACME-Syntax und 6502/8501-kompatible Befehle verwenden.
- Soundengine und Menü getrennt halten. Wiedergabe darf nicht blockieren.
- Bestehende Effekt-IDs 0–49 unverändert erhalten; zusätzliche Vorbild-Effekte 50–69 und Flügelschlag-Loops 70–79. Genau 80 eindeutige Namen.
- Spielvorbilder sind stilisierte TED-Nachbildungen; keine Originalsamples, Sprachnachbildung nur als Tonkontur. Quellen und Grenzen in `docs/game-inspired.md` festhalten, keine gemessene Popularitätsrangliste behaupten.
- Tabellenadressierung für IDs ab 64 mitprüfen; Vier-Byte-Einträge benötigen einen 9-Bit-Index.
- Fremde TED-Registerbits erhalten, insbesondere die Videobits in `$FF12`.
- Speicherlayout einschließlich Bildschirm, Stack und KERNAL-Arbeitsbereichen prüfen; keine 64-KB-Maschine voraussetzen.
- `make` baut; `make run` baut bei Bedarf und startet VICE (`xplus4`) als C16 mit 16 KB RAM, PAL, Sound und PRG-Autostart. Toolpfade über `ACME` und `VICE` überschreibbar halten.
- Generierte Dateien in `build/` ablegen und nicht versionieren.

## Verbindlicher Menüstand

- Vier Katalogseiten mit 24/24/24/8 Einträgen; alle 24 Zeilen unter der Kopfzeile für die Liste nutzen, keine Status- oder Fußzeile.
- Inverse Titelleiste: `C=16 Sound FX`, `Loop: ON/OFF` vor `(H)elp`, rechts `1/4` bis `4/4`.
- Kategorie in Klammern vor dem Namen; Namen beginnen in Spalte 20 (nullbasiert). Kategorien zusammenhängend sortieren, Fortsetzung über Seitengrenzen zulässig.
- Reihenfolge nur im Menü ändern; Effekt-IDs und API bleiben 0–79. Jede ID genau einmal anzeigen.
- H öffnet/schließt die separate Hilfe; RETURN/SPACE kehrt zurück. Auswahl und laufenden Sound erhalten.
- Hintergrund und Rahmen verwenden `TED_BG_COLOR` aus `src/ted.inc` (aktuell `$36`), Schrift `TED_WHITE` (`$71`). Benutzeränderungen an der Farbe erhalten.
- Direkte numerische ID-Eingabe bleibt verfügbar, ohne separate Eingabeanzeige.
- KERNAL-Wiederholung während der Demo sperren und beim Exit zurückgeben. Navigation: 0,5 s Vorlauf, dann 0,1 s Intervall auf PAL und NTSC.
- Seitenzahl, Grenzen und Tabellen aus `SFX_COUNT`/`SFX_PAGE_COUNT` ableiten; maximal 24 Einträge je Seite. Flügelschlag-Loops enthalten gestaltete Ruhephasen, keine zusätzliche Endmarker-Pause.
- Menüfreies Beispiel in `examples/game_integration.asm`; mit `make example` bauen und `make test-example-vice` prüfen.

## Prüfung

Nach Codeänderungen den ACME-Build und passende Prüfungen ausführen. Änderungen an Wiedergabe oder Menü in VICE mit 16 KB RAM prüfen. Hörprüfungen, Hardwaretests und Laufzeitmessungen nur als bestanden dokumentieren, wenn sie tatsächlich durchgeführt wurden. Aufgaben in `docs/status.md` erst nach erfülltem Ergebnis abhaken.

## Git-Commits

Alle Commits müssen Conventional Commits verwenden:

```text
type(scope): kurze beschreibung
```

Der Scope ist optional. Zulässige Typen: `feat`, `fix`, `docs`, `build`, `test`, `refactor`, `perf`, `chore`, `ci`, `style`, `revert`. Geeignete Scopes sind beispielsweise `engine`, `effects`, `menu`, `vice` und `docs`. Beschreibung konkret und knapp halten, ohne abschließenden Punkt. Zusammengehörige Änderungen gemeinsam committen; unabhängige Änderungen trennen. Breaking Changes mit `!` vor dem Doppelpunkt und einem erklärenden `BREAKING CHANGE:`-Footer kennzeichnen.

Beispiele:

```text
docs: projektplanung und entwicklungsregeln dokumentieren
build(vice): make run fuer die c16-demo ergaenzen
feat(effects): vogelflug als wiederholbaren effekt hinzufuegen
fix(engine): videobits beim frequenzwechsel erhalten
```

Keine fremden Änderungen überschreiben oder ohne Auftrag zurücksetzen.
