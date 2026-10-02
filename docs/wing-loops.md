# Flügelschlag-Loops für Flappy Bird

Fünf eigene TED-Klangentwürfe in Kategorie BEWEGUNG; keine kopierten
Flappy-Bird-Samples. Die bisherigen IDs 0–69 bleiben unverändert.

| ID | Name | Zyklus | Schläge je Zyklus | Klang |
|---:|---|---:|---:|---|
| 70 | flap-soft | 12 Ticks / 0,24 s | 1 | Leiser weicher Rauschbogen, geeignet als unaufdringlicher Dauerschlag |
| 71 | flap-snappy | 8 Ticks / 0,16 s | 1 | Kurzer kräftiger Luftstoß mit fallendem Tonimpuls |
| 72 | flap-double | 16 Ticks / 0,32 s | 2 | Zwei unterschiedlich starke Luftstöße, danach Ruhe |
| 73 | flap-flutter | 12 Ticks / 0,24 s | 3 | Schnelle dreifache Ton-/Rauschimpulse, flatternder Rhythmus |
| 74 | flap-chirp | 16 Ticks / 0,32 s | 1 + Zwitschern | Weicher Flügelschlag und hoher kurzer Zwitscherbogen |

Alle Varianten haben bewusst gestaltete leise/stumme Ruhephasen.
Am Endmarker fügt die Engine keine zusätzliche Pause ein. Lautstärke
bleibt im Bereich 0–4; Stop wirkt sofort über die öffentliche API.
PAL: 50 logische Ticks/s. NTSC: passende Frequenzdaten und Umsetzung
von 60 Video-Frames auf 50 logische Ticks.

## Im Menü

ID 70–74 eintippen, RETURN/SPACE, dann L für Wiederholung. Alternativ
in der Kategorie BEWEGUNG auswählen und mit RETURN/SPACE starten.
L abschalten: aktueller Durchlauf endet regulär. S/RUN-STOP stoppt sofort
und verwirft Wiederholung. Die vier Seiten haben 24/24/24/3 Einträge.

## Im Spiel

Nach `sfx_init` einmal starten:

```asm
    lda #1
    jsr sfx_set_loop
    lda #SFX_FLAP_SOFT          ; alternativ SNAPPY, DOUBLE, FLUTTER, CHIRP
    jsr sfx_play
```

`sfx_tick` einmal je Video-Frame aufrufen; `sfx_stop` bei Ende des Flugs.
Ein neuer Play ersetzt den laufenden Loop. Bei Flügelschlag pro Tastendruck
kann derselbe Effekt mit ausgeschalteter Wiederholung als einzelner Zyklus
verwendet werden. Auswahl der passendsten Variante bleibt eine Hörentscheidung.

## Prüfung und Vorschau

`make test` prüft Periodizität der Kontrollregister über mehrere Zyklen,
Loop-Abschaltung und Stop für alle fünf Varianten auf PAL/NTSC. Die
VICE-Prüfung startet alle 75 IDs und testet alle 15 gestalteten Loops
mit 16 KB; Seitenwechsel und vierte Katalogseite werden mitgeprüft.

`make record-flaps` erzeugt `build/wing-loops-pal.wav`: IDs 70–74 in
aufsteigender Reihenfolge, jeweils mehrere Zyklen und eine Pause vor der
nächsten Variante. Nichtstummes PCM sowie laufender Loop und Stop werden
technisch geprüft. Die subjektive Klangbeurteilung bleibt offen.
