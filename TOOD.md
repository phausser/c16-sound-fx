# C16 Sound FX – Aufgabenplan

Dateiname `TOOD.md` wie angefordert. Anforderungen und Effekt-IDs stehen in `SPEC.md`.

## 1. Hardwaregrundlage und Werkzeugkette

- [x] TED-Registerbits, Ton-/Rauschkopplung, Lautstärke und PAL-/NTSC-Frequenzberechnung anhand der Originalquellen prüfen.
- [ ] C16-Speicherlayout, Bildschirmbereiche, BASIC-Start und sichere KERNAL-Tastaturnutzung festlegen.
- [x] Installierte Programme finden: ACME und VICE (`xplus4`) liegen in `/opt/homebrew/bin`.
- [x] VICE-Startoptionen für C16, 16 KB RAM, PAL, Sound und PRG-Autostart anhand der installierten Version prüfen.
- [x] Quellstruktur und Makefile anlegen; minimales startbares PRG bauen.
- [ ] `make run` implementieren: bei Bedarf bauen und anschließend in VICE mit hörbarer Audioausgabe automatisch starten; `ACME` und `VICE` als überschreibbare Make-Variablen vorsehen.
- [x] Speichergrenzen und Überschneidungen als Build-Checks absichern.

Implementierung von `make run` vorhanden; VICE bestätigt Autostart und geöffnetes CoreAudio-Gerät. Q-Rückkehr ist inzwischen per Monitor geprüft; die Kataloganzeige ist inzwischen visuell geprüft; Hörprüfung bleibt offen. Details: [docs/hardware.md](docs/hardware.md).

## 2. Wiederverwendbare Soundengine

- [x] API einschließlich Init-Parameter für PAL/NTSC, Registerzerstörung und Zero-Page-Nutzung festlegen.
- [x] Sichere TED-Registerzugriffe implementieren, besonders fremde Bits in `$FF12` erhalten.
- [x] Schrittformat, Endmarker und Loop-Einstieg definieren.
- [x] `sfx_init`, `sfx_play`, `sfx_tick`, `sfx_stop`, `sfx_set_loop` und `sfx_shutdown` implementieren.
- [x] PAL-Takt und NTSC-Zeitumsetzung sowie passende Frequenzwerte implementieren.
- [x] Ungültige IDs, Neustart, natürliches Ende und Stop verifizieren.
- [ ] Erst je einen Ton-, Rausch-, Kombinations- und Tonfolgen-Prototyp hörbar prüfen.
- [x] Maximale Tick-Laufzeit und Engine-RAM messen; bei Bedarf Datenformat vereinfachen.

Engine und vollständiger Katalog implementiert; CPU-Tests und VICE-Monitortests auf PAL/NTSC bestehen. Höchster getesteter Tick: 332 CPU-Zyklen. Hörprüfung offen. API, RAM und Grenzen: [docs/engine.md](docs/engine.md).

## 3. 50 Effekte gestalten

- [x] IDs 0–9: Erfolg, Niederlage und Sammelaktionen.
- [x] IDs 10–14: Menü und Rückmeldungen.
- [x] IDs 15–24: Bewegung, Schritte, Schwimmen und Vogelflug.
- [x] IDs 25–35: Waffen, Explosionen und Treffer.
- [x] IDs 36–40: Objekte und Teleport.
- [x] IDs 41–49: Motor, Alarm, Timer und Umgebung.
- [ ] Jeden Effekt anhören und auf verständlichen Charakter, Kürze und passende Lautstärke abstimmen.
- [x] Gemeinsame Lautstärke bei kombinierten Quellen berücksichtigen.
- [x] Alle markierten Loops über mehrere Zyklen technisch prüfen und Übergänge gestalten.
- [x] Wiederholung von Einzeleffekten mit definierter Pause prüfen.
- [x] Tabelle auf genau 50 eindeutige Namen und stabile IDs prüfen.

Alle 50 Abläufe sind technisch auf PAL/NTSC mit 16 KB RAM geprüft. Die subjektive Hörprüfung und Klangabstimmung bleiben offen. Einzelne Pausen innerhalb der Schritt-/Schuss-/Flug-/Knisterzyklen sind beabsichtigt; kein zusätzlicher stummer Tick am Endmarker. Details: [docs/effects.md](docs/effects.md).

## 4. Auswahldemo

- [ ] 40×25-Anzeige mit Seiten zu 20/20/10 Einträgen aufbauen.
- [ ] Auswahlmarkierung, Status, Wiederholung und Tastenhilfe darstellen.
- [ ] Navigation und kontrollierte Tastenwiederholung implementieren.
- [ ] RETURN/SPACE, L, S/RUN-STOP und Q implementieren.
- [ ] Frame-Takt anbinden, ohne Soundengine mit Menü oder KERNAL zu koppeln.
- [ ] Seitenwechsel und Auswahl während laufender Effekte prüfen.
- [ ] Sauberen Exit nach BASIC samt Ressourcenfreigabe prüfen.

## 5. Abnahme und Übergabe

- [ ] ACME-Build und Speichergrenzen auf dem vollständigen Programm prüfen.
- [ ] `make run` vom frischen Build bis zur bedienbaren und hörbaren Demo in VICE prüfen.
- [ ] Alle 50 Effekte im 16-KB-Emulator starten, natürlich enden lassen und stoppen.
- [ ] Schnelle Startwechsel, ungültige API-IDs, Stop im Loop und Loop-Abschaltung prüfen.
- [ ] Registerbits für die Anzeige vor/nach Soundzugriffen vergleichen.
- [ ] PAL und NTSC auf Dauer und Tonhöhe prüfen; offene Unterschiede dokumentieren.
- [ ] Wenn Hardware verfügbar ist: Hör- und Bedienprüfung auf echtem C16 durchführen.
- [ ] Menüfreies Integrationsbeispiel erstellen und bauen.
- [ ] README mit Build, Start, Bedienung, API, Speicherbedarf und gemessener Tick-Laufzeit schreiben.
- [ ] PRG bereitstellen; Ergebnisse und verbleibende Einschränkungen gegen die SPEC-Abnahmekriterien festhalten.
