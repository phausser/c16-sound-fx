# Mario- und iOS-Vorbilder für TED

IDs 80–89 ergänzen zehn Mario-Vorbilder, IDs 90–99 zehn Vorbilder
weithin bekannter iOS-Spiele. Das ist eine redaktionelle Auswahl,
keine gemessene Popularitätsrangliste. Die Links belegen nur Spiel und
Ereignis, nicht dass die TED-Fassung gleich klingt.

Alle Effekte sind neu gestaltete, kurze Schrittabläufe aus Rechteckton,
Rauschen und gemeinsamer Lautstärke, getrennt für PAL/NTSC berechnet.
Keine Originalsamples und keine Notentranskriptionen: Mario-Tonfolgen
(Münze, Extraleben, Power-up) folgen nur Kontur und Rhythmus des Vorbilds
mit eigenen Tonhöhen. Moderne Mobile-Klänge werden auf ihr Grundmotiv
reduziert, etwa Swoosh, Ding oder Sprungfeder.

| ID | Name | Kategorie | Spiel/Ereignis und Referenz | Dauer | Loop | TED-Klangentwurf |
|---:|---|---|---|---:|:---:|---|
| 80 | `mario-coin` | SAMMELN | [Super Mario Bros.: Münze](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.28 s | nein | Kurzer Vorschlag, dann eine Quarte höher gehaltener, ausklingender Ton. |
| 81 | `mario-jump` | BEWEGUNG | [Super Mario Bros.: Sprung](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.22 s | nein | Schneller, leicht verlangsamender Aufwärtsgleiter. |
| 82 | `mario-1up` | JINGLE | [Super Mario Bros.: Extraleben](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.36 s | nein | Sechs helle Arpeggiotöne mit Oktavsprung, eigene Tonfolge. |
| 83 | `mario-mushroom` | JINGLE | [Super Mario Bros.: Power-up-Pilz](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.60 s | nein | Fünf aufsteigende Dreiklangwellen, jede eine Stufe höher. |
| 84 | `mario-pipe` | JINGLE | [Super Mario Bros.: Rohr/Schrumpfen](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.36 s | nein | Drei fallende Dreiergruppen mit Mikropausen, langsamer Schluss. |
| 85 | `mario-fireball` | SCHUSS | [Super Mario Bros.: Feuerball](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.14 s | nein | Zwei kurze fallende Hüpfer. |
| 86 | `mario-stomp` | KAMPF | [Super Mario Bros.: Gegner zertreten](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.16 s | nein | Ton-/Rauschquetscher, endet mit tiefem Ton. |
| 87 | `mario-brick` | OBJEKT | [Super Mario Bros.: Block zerbricht](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.26 s | nein | Drei zerfallende Rauschbrocken mit Lücken. |
| 88 | `mario-flagpole` | BEWEGUNG | [Super Mario Bros.: Fahnenmast](https://en.wikipedia.org/wiki/Super_Mario_Bros.) | 0.72 s | nein | Langer gleichmäßiger Abwärtsgleiter. |
| 89 | `mario-spin` | BEWEGUNG | [Super Mario World: Wirbelsprung](https://en.wikipedia.org/wiki/Super_Mario_World) | 0.20 s | nein | Flatternder Ton-/Rauschwirbel mit steigender Tendenz. |
| 90 | `angry-launch` | BEWEGUNG | [Angry Birds: Schleuder](https://en.wikipedia.org/wiki/Angry_Birds_(video_game)) | 0.36 s | nein | Tiefes steigendes Spannen, kurze Stille, Abschuss-Swoosh. |
| 91 | `fruit-slice` | KAMPF | [Fruit Ninja: Schnitt](https://en.wikipedia.org/wiki/Fruit_Ninja) | 0.20 s | nein | Heller Rauschswoosh und dumpfer Platscher. |
| 92 | `flappy-point` | SAMMELN | [Flappy Bird: Punkt](https://en.wikipedia.org/wiki/Flappy_Bird) | 0.24 s | nein | Kurzer Vorschlag, heller ausklingender Ding-Ton. |
| 93 | `temple-coin` | SAMMELN | [Temple Run: Münze](https://en.wikipedia.org/wiki/Temple_Run) | 0.18 s | nein | Zwei schnelle schimmernde Arpeggien aus leicht verstimmten Doppeltönen. |
| 94 | `candy-match` | JINGLE | [Candy Crush Saga: Reihe](https://en.wikipedia.org/wiki/Candy_Crush_Saga) | 0.26 s | nein | Drei aufsteigende Quintpaar-Pops und Schlusston. |
| 95 | `subway-jump` | BEWEGUNG | [Subway Surfers: Sprung](https://en.wikipedia.org/wiki/Subway_Surfers) | 0.16 s | nein | Steigender Ton-/Rauschswoosh mit hellem Ausklang. |
| 96 | `cutrope-snip` | OBJEKT | [Cut the Rope: Schnitt und Schlucken](https://en.wikipedia.org/wiki/Cut_the_Rope) | 0.28 s | nein | Scharfer Schnitt, kurze Stille, fallendes Schlucken. |
| 97 | `doodle-spring` | BEWEGUNG | [Doodle Jump: Sprungfeder](https://en.wikipedia.org/wiki/Doodle_Jump) | 0.28 s | nein | Steigender, vibrierender Boing-Gleiter. |
| 98 | `pokemongo-catch` | JINGLE | [Pokemon GO: Fang](https://en.wikipedia.org/wiki/Pok%C3%A9mon_Go) | 0.52 s | nein | Drei Wackelklicks mit Pausen, danach Erfolgsarpeggio. |
| 99 | `jetpack-thrust` | FAHRGERAEUSCH | [Jetpack Joyride: Düsenschub](https://en.wikipedia.org/wiki/Jetpack_Joyride) | 0.16 s | ja | Tiefes pulsierendes Ton-/Rauschdröhnen, gestalteter Loop mit Rauschvariation. |

## Integration

Konstanten wie `SFX_MARIO_COIN` oder `SFX_JETPACK_THRUST` stehen in
`src/sfx_data.asm`. `jetpack-thrust` trägt Loop- und Variationsflag wie
`fire-crackle`; für Dauerschub `lda #1` / `jsr sfx_set_loop`, dann
`lda #SFX_JETPACK_THRUST` / `jsr sfx_play`.

## Prüfung und offene Klangabnahme

CPU-Tests prüfen alle IDs gegen `SPEC.md`: Namen, Quellenmasken,
Dauern, eindeutige Streams, Ende, Stop und Loopübergänge auf PAL/NTSC.
VICE prüft alle Starts und Loops mit 16 KB. `make record-mario`
erzeugt `build/mario-pal.wav` (IDs 80–89), `make record-ios`
`build/ios-pal.wav` (IDs 90–99). Geprüft sind nicht stummes PCM und
natürliche Enden. Hörprüfung, Vergleich mit den Vorbildern und Abstimmung
stehen noch aus.

Aktueller Speicherstand: [status.md](status.md).
