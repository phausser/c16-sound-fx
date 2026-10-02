# Projektregeln

## Ziel und Dokumentation

Dieses Projekt entwickelt mit ACME eine C16-Demo mit 50 TED-Soundeffekten und einer separat nutzbaren Spiele-Soundengine. Verbindliche Anforderungen stehen in `SPEC.md`, der Arbeitsplan in `TOOD.md` (Schreibweise beibehalten). Die `README.md` beschreibt den tatsächlichen Stand; geplante Funktionen ausdrücklich als geplant kennzeichnen.

## Umsetzung

- Zielgerät: unveränderter C16 mit 16 KB RAM; PAL als Referenz, NTSC gemäß Spezifikation.
- ACME-Syntax und 6502/8501-kompatible Befehle verwenden.
- Soundengine und Menü getrennt halten. Wiedergabe darf nicht blockieren.
- Stabile Effekt-IDs 0–49 und genau 50 eindeutige Namen erhalten.
- Fremde TED-Registerbits erhalten, insbesondere die Videobits in `$FF12`.
- Speicherlayout einschließlich Bildschirm, Stack und KERNAL-Arbeitsbereichen prüfen; keine 64-KB-Maschine voraussetzen.
- `make` baut; `make run` baut bei Bedarf und startet VICE (`xplus4`) als C16 mit 16 KB RAM, PAL, Sound und PRG-Autostart. Toolpfade über `ACME` und `VICE` überschreibbar halten.
- Generierte Dateien in `build/` ablegen und nicht versionieren.

## Prüfung

Nach Codeänderungen den ACME-Build und passende Prüfungen ausführen. Änderungen an Wiedergabe oder Menü in VICE mit 16 KB RAM prüfen. Hörprüfungen, Hardwaretests und Laufzeitmessungen nur als bestanden dokumentieren, wenn sie tatsächlich durchgeführt wurden. Aufgaben in `TOOD.md` erst nach erfülltem Ergebnis abhaken.

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
