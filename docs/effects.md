# Effektkatalog – Schritt 3

Der ursprüngliche Katalog (IDs 0–49) besitzt 208 Schritte. Die Erweiterung auf 105 IDs hat insgesamt 580 Schritte; die Vorbild-Effekte sind in `game-inspired.md`, `mario-ios.md` und `boulder-dash.md` beschrieben. Tonfolgen, Frequenzbögen, Rauschhüllkurven, verstimmte Tonpaare und kombinierte Quellen werden als begrenzte Datenstreams gespeichert. Kombinationen teilen eine Lautstärke und verwenden Ton 1 plus Rauschen; Metall-/Motoreffekte nutzen bewusst beide Tonkanäle.

Die folgende Dauer ergibt sich aus den Schrittdaten bei 50 logischen Ticks/s. Ziele zwischen zwei Ticks werden auf den nächsten Tick gerundet (z. B. 0,25 s auf 13 Ticks / 0,26 s). Unter NTSC ist der erste/letzte Frame zusätzlich von der laufenden Akkumulatorphase abhängig. Getrennte 10-Bit-Frequenzwerte berücksichtigen den jeweiligen TED-Takt; die größte rechnerische PAL-/NTSC-Abweichung der nominalen Frequenzen im ursprünglichen Katalog beträgt 1,32 % durch Registerquantisierung.

| ID | Name | Quelle | Ticks | Dauer | Loop |
|---:|---|---|---:|---:|:---:|
| 0 | jingle-win | T | 30 | 0.60 s |  |
| 1 | jingle-lose | T | 30 | 0.60 s |  |
| 2 | level-up | T | 20 | 0.40 s |  |
| 3 | extra-life | T | 25 | 0.50 s |  |
| 4 | checkpoint | T | 13 | 0.26 s |  |
| 5 | coin-pickup | T | 6 | 0.12 s |  |
| 6 | gem-pickup | T | 10 | 0.20 s |  |
| 7 | key-pickup | T | 10 | 0.20 s |  |
| 8 | power-up | T | 25 | 0.50 s |  |
| 9 | power-down | T | 25 | 0.50 s |  |
| 10 | menu-move | T | 2 | 0.04 s |  |
| 11 | menu-select | T | 6 | 0.12 s |  |
| 12 | menu-back | T | 6 | 0.12 s |  |
| 13 | action-denied | T | 10 | 0.20 s |  |
| 14 | pause-toggle | T | 8 | 0.16 s |  |
| 15 | jump | T | 9 | 0.18 s |  |
| 16 | double-jump | T | 13 | 0.26 s |  |
| 17 | landing | R | 5 | 0.10 s |  |
| 18 | bounce | T | 10 | 0.20 s |  |
| 19 | fall | T | 30 | 0.60 s |  |
| 20 | step-stone | R | 4 | 0.08 s |  |
| 21 | step-grass | R | 5 | 0.10 s |  |
| 22 | walk-steps | R | 20 | 0.40 s | ja |
| 23 | swim-stroke | T+R | 20 | 0.40 s | ja |
| 24 | vogelflug | T | 25 | 0.50 s | ja |
| 25 | laser-shot | T | 8 | 0.16 s |  |
| 26 | blaster-shot | T+R | 10 | 0.20 s |  |
| 27 | machine-gun | R | 12 | 0.24 s | ja |
| 28 | explosion-small | R | 15 | 0.30 s |  |
| 29 | explosion-large | T+R | 40 | 0.80 s |  |
| 30 | ricochet | T | 10 | 0.20 s |  |
| 31 | sword-swing | R | 8 | 0.16 s |  |
| 32 | sword-hit | T+R | 10 | 0.20 s |  |
| 33 | player-hit | T+R | 13 | 0.26 s |  |
| 34 | enemy-defeat | T+R | 20 | 0.40 s |  |
| 35 | shield-hit | T | 13 | 0.26 s |  |
| 36 | door-open | T+R | 20 | 0.40 s |  |
| 37 | door-close | R | 10 | 0.20 s |  |
| 38 | switch-click | R | 2 | 0.04 s |  |
| 39 | chest-open | T | 18 | 0.36 s |  |
| 40 | teleport | T+R | 30 | 0.60 s |  |
| 41 | engine-idle | T | 20 | 0.40 s | ja |
| 42 | engine-boost | T+R | 30 | 0.60 s |  |
| 43 | alarm | T | 25 | 0.50 s | ja |
| 44 | timer-tick | T | 3 | 0.06 s |  |
| 45 | countdown-end | T | 15 | 0.30 s |  |
| 46 | water-splash | R | 18 | 0.36 s |  |
| 47 | fire-crackle | R | 30 | 0.60 s | ja |
| 48 | wind-gust | R | 40 | 0.80 s | ja |
| 49 | electric-zap | T+R | 13 | 0.26 s |  |

## Wiederholung und Variation

Loop-IDs sind 22, 23, 24, 27, 41, 43, 47 und 48. Leise bzw. stille Schritte innerhalb von Schrittfolge, Flügelschlag, Schussfolge und Knisterzyklus gehören zur Gestaltung. Die Engine fügt am Zyklusende keine zusätzliche Pause ein. Alle anderen Effekte wiederholen mit zehn Ticks / 200 ms Pause. Ein neuer Start ersetzt sofort den bisherigen Ablauf.

`fire-crackle` kombiniert unregelmäßige Impulsabstände und Lautstärken mit einem eigenen 8-Bit-Zufallszustand. Neustart ist reproduzierbar; die Rauschfrequenzvariation entwickelt sich über die Loopzyklen weiter. Fremde Speicherstellen werden dafür nicht gelesen.

## Prüfung

- `make test`: alle 50 Namen und IDs gegen die SPEC, 50 eindeutige Streams je Videostandard, Quellenmasken, Lautstärkegrenzen, positive Schrittdauern, gültige Wiederholungseinstiege, selbständiges Ende, Wiederholung und Stop. Alle acht Loops werden über mehrere Zyklen auf beabsichtigte Kontrollwerte und ohne zusätzliche Pause geprüft; die Knistervariation auf Neustart-Reproduzierbarkeit und unterschiedliche Folgezyklen.
- `make test-vice`: alle 50 Starts über Zifferneingabe und RETURN auf einem 16-KB-C16, jeweils PAL/NTSC, natürliches Ende, acht Loops über mindestens drei Zyklen mit Stop, Bildschirmdaten, Videobits und Q-Rückkehr nach BASIC. Screenshots und Logs liegen in `build/`.
- Die korrigierte PAL-Startanzeige wurde visuell anhand `build/catalog-screen.png` geprüft. ACME `!pet` benötigt für normale Großbuchstaben kleingeschriebene Quellstrings; die bisherige Schreibweise erzeugte Grafikzeichen.

Die klangliche Beurteilung und Lautstärkeabstimmung aller 50 Effekte sowie echte Hardware bleiben offen. Technisch unterschiedliche Streams garantieren keine subjektiv unterschiedlichen Klangcharaktere. Die aktuelle Gestaltung ist die erste Version für die Hörprüfung.
## Hörproben vorbereiten

`make record-vice` wiederholt die PAL-/NTSC-Tests ohne Warp mit CoreAudio und erzeugt `build/vice-pal.wav` sowie `build/vice-ntsc.wav`. Die Aufnahmen enthalten zunächst IDs 00–49 in Reihenfolge, danach die acht Loopprüfungen mit Stop. Der Audiotreiber ist über `VICE_SOUND_DEVICE` überschreibbar. Gültige PCM-Dateiköpfe und vorhandene Audiosamples werden geprüft; dies ersetzt keine subjektive Hörprüfung.

Die aktuelle VICE-Version lässt beim Monitor-Exit Platzhalter für die WAV-Längen zurück. Das Testskript finalisiert die Dateiköpfe anhand der tatsächlich aufgenommenen PCM-Samples, ohne Samples zu ändern. WAV-Dateien und Screenshots sind erzeugte Artefakte unter `build/` und werden nicht versioniert.

## Erweiterung auf 70 Effekte

Die ursprünglichen 50 Effekte bleiben unter ihren IDs unverändert.
20 neue Vorbild-Effekte belegen IDs 50–69; Auswahl, Quellen, Klangkonturen
und offene Hörabnahme stehen in [game-inspired.md](game-inspired.md).
Turrican-Strahl und Lotus-Motor ergänzen zwei gestaltete Loops;
insgesamt sind zehn Effekte ausdrücklich loopbar.

## Fünf Flügelschlag-Loops

IDs 70–74 ergänzen fünf zyklische Flügelschlag-Varianten in BEWEGUNG. Alle sind explizit loopbar; zusammen mit dem bisherigen Katalog jetzt 80 Effekte und 15 gestaltete Loops. Beschreibung und Integration: [wing-loops.md](wing-loops.md).

## Lebensverlust

IDs 75–79 ergänzen fünf einmalige Lebensverlust-Sounds unter JINGLE.
Der Katalog umfasst jetzt 80 Effekte, vier Seiten (24/24/24/8) und weiterhin 15 Loops.
Details und drei Flappy-Bird-Beispiele: [life-lost.md](life-lost.md).

## Mario und iOS

IDs 80–99 ergänzen zehn Mario- und zehn iOS-Spielvorbilder, einsortiert in bestehende Kategorien. Der Katalog umfasst jetzt 100 Effekte, fünf Seiten (24/24/24/24/4) und 16 Loops (neu: `jetpack-thrust`). Details: [mario-ios.md](mario-ios.md).

## Boulder Dash

IDs 100–104 ergänzen fünf Boulder-Dash-Vorbilder (C64) nach einer SID-Analyse. Der Katalog umfasst jetzt 105 Effekte, fünf Seiten (24/24/24/24/9) und 17 Loops (neu: `bd-amoeba`). Details: [boulder-dash.md](boulder-dash.md).
