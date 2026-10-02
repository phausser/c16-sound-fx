# Leben verloren

Fünf einmalige TED-Sounds für den Verlust eines Spielerlebens. IDs bleiben stabil.

| ID | Name | Dauer | Charakter |
| --- | --- | --- | --- |
| 75 | life-fall | 0,28 s | Kurzer Absturz mit Rauschen |
| 76 | life-thud | 0,28 s | Dumpfer Treffer mit ausklingendem Ton |
| 77 | life-sigh | 0,44 s | Enttäuschter, absinkender Seufzer |
| 78 | life-sad | 0,52 s | Traurige absteigende Tonfolge |
| 79 | life-wobble | 0,48 s | Verstimmter, absinkender Wobbelton |

Für Flappy Bird sind 77–79 die drei Enttäuschungsvarianten. Einmal mit
`lda #0` / `jsr sfx_set_loop`, danach z. B. `lda #SFX_LIFE_SAD` /
`jsr sfx_play` starten. Weiterhin genau einmal je Video-Frame `sfx_tick`
aufrufen. [Integration und Lautstärke](engine.md#einen-effekt-einbauen-und-leiser-abstimmen).

`make record-life` nimmt alle fünf auf. Für die drei Flappy-Bird-Beispiele:
`python3 tests/record_inspired.py xplus4 coreaudio --first 77 --last 79`.
Die Vorschau liegt in `build/life-lost-pal.wav`. Aufnahme und automatische
Endprüfung ersetzen keine subjektive Hörabnahme.
