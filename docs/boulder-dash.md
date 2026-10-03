# Boulder-Dash-Vorbilder für TED

IDs 100–104 ergänzen fünf Geräusche aus Boulder Dash (C64). Sie ergänzen
den bereits vorhandenen Diamant-Pickup `boulder-diamond` (ID 51).
Grundlage ist die SID-Analyse
[„Boulder Dash Sounds“ von Martijn Mooij](https://codeincomplete.com/articles/javascript-boulderdash/sounds.pdf)
(Frequenzen, Wellenform, Hüllkurve je Ereignis). Die TED-Fassungen sind
stilisierte Nachbildungen: TED hat Rechteck statt SID-Dreieck, ein anderes
Rauschen und keine Hardware-Hüllkurve. Die Hüllkurven sind deshalb als
Lautstärkestufen in 20-ms-Ticks angenähert.

| ID | Name | Kategorie | SID-Vorlage laut Analyse | Dauer | Loop | TED-Umsetzung |
|---:|---|---|---|---:|:---:|---|
| 100 | `bd-boulder` | OBJEKT | Fels geschoben oder Fall beginnt/endet: Rauschen 143,5 Hz, A 2 ms, D 6 ms, S 15 | 0.08 s | nein | Rauschen 144 Hz, Lautstärke 7→4→1. |
| 101 | `bd-diamond-fall` | OBJEKT | Diamant fällt/landet: Dreieck, Zufallsfrequenz 2091,5–3980 Hz, S 10 | 0.20 s | nein | Drei kurze Pings (3200/2350/3700 Hz) mit festen Tonhöhen statt Zufall. |
| 102 | `bd-crack` | SIGNAL | Rockfords Geburt und Ausgang öffnet sich: Rauschen 736,6 Hz, A 8 ms, D 750 ms | 0.76 s | nein | Rauschen 737 Hz, Lautstärke in acht Stufen von 8 auf 1 über 0,76 s. |
| 103 | `bd-timeout` | SIGNAL | Zeit läuft ab: Dreieck-Ping je Sekunde, 468,2 Hz (9 s) bis 608,7 Hz (0 s), D 1,5 s | 0.60 s | nein | Letzte drei Pings (578/593/609 Hz) auf je 0,2 s verdichtet. |
| 104 | `bd-amoeba` | UMGEBUNG | Amöbe, solange vorhanden: Dreieck, Zufallsfrequenz 124,9–234,1 Hz, A 24 ms | 0.32 s | ja | Acht feste tiefe Töne im Vorlagenbereich als nahtloser Loop. |

Grenzen: Die Zufallsfrequenzen sind als feste, wiederholbare Folgen umgesetzt.
Die Engine variiert nur die Rauschfrequenz, nicht die Tonfrequenz.
`bd-timeout` fasst drei Sekunden des Originals zu 0,6 s zusammen. Im Spiel
würde man stattdessen einmal pro Sekunde einen einzelnen Ping auslösen.
Stimmenpriorität des Originals (Crack vor Amöbe vor Magic Wall) gilt hier
nicht: Die Engine spielt einen Effekt zur Zeit.

## Prüfung

CPU- und VICE-Tests decken alle IDs auf PAL/NTSC mit 16 KB ab, auch die
dreistellige ID-Eingabe. `make record-boulder` erzeugt
`build/boulder-dash-pal.wav` (IDs 100–104) und prüft nicht stummes PCM sowie
natürliche Enden. Hörprüfung und Vergleich mit dem Original stehen aus.
