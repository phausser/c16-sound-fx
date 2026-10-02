# Hardwaregrundlage und Schritt 1

## Vorgehen

1. TED-Register und Frequenzformel anhand des MOS-Datenblatts prüfen.
2. System- und Bildschirm-RAM freihalten, BASIC-SYS-Stub anlegen.
3. ACME-Build mit Speicherprüfungen und VICE-Start einrichten.
4. Build und Emulatorstart prüfen; Anzeige, Tastatur und Audio gesondert bewerten.

## TED

Quelle: [MOS TED 7360R0 Preliminary Data Sheet](https://www.pagetable.com/docs/ted/TED%207360R0%20Preliminary%20Data%20Sheet.pdf), PDF-Seiten 8–9 und 15–16.

`$FF0E/$FF12[1:0]` steuern Ton 1, `$FF0F/$FF10[1:0]` Ton 2 bzw. Rauschen. `$FF11` enthält Lautstärke (Bits 0–3, nutzbar 0–8), Ton 1 (Bit 4), Ton 2 (Bit 5), Rauschen (Bit 6) und Reload/Test (Bit 7). Bei gleichzeitig gesetzten Bits 5 und 6 hat Ton 2 Vorrang. Kombinationen verwenden daher Ton 1 plus Rauschen. `$FF12[7:2]` bleiben bei jeder Frequenzänderung aus dem aktuellen Registerwert erhalten.

Für den 10-Bit-Wert N gilt `f = K / (1024 - N)`: K = 110840,45 Hz (PAL), 111860,781 Hz (NTSC). Umrechnung: `N = 1024 - round(K / f)`, auf 0–1023 begrenzen. Die doppelte CPU-Geschwindigkeit außerhalb der Anzeige ändert diese Formel nicht. Schritt 2 berechnet getrennte Frequenzdaten und setzt 60 NTSC-Frame-Aufrufe auf 50 logische Ticks um.

## Speicher und KERNAL

Reserviert bleiben `$0000–$07FF` einschließlich Zero Page, Hardwarestack `$0100–$01FF` und Systemarbeitsbereichen. Standard-Textanzeige: Attribute `$0800–$0BFF`, Zeichen `$0C00–$0FFF` (je 1000 genutzte Bytes plus Reserve). PRG ab `$1001`, exklusives Ende höchstens `$4000`. Die Demo benutzt keine eigene Zero Page und schaltet ROMs und KERNAL-IRQ nicht ab. GETIN `$FFE4` liest den IRQ-befüllten Tastaturpuffer ohne auf eine Taste zu warten; CHROUT `$FFD2` leert die Anzeige; danach schreibt das Menü direkt in den Bildschirm-RAM. Die Demo setzt `$0540` auf `$40` (KERNAL-Wiederholung aus). Navigation wiederholt selbst mit 25/30 Frames Vorlauf und 5/6 Frames Intervall. Gesichert wird der vorherige Wert; Q stellt ihn wieder her.

Die abschließende Gegenprüfung der Systembereiche mit dem [Commodore-Handbuch](https://www.two-mag.com/cpc/ACME/_BONUS/8_BITS/COMMODORE%5BUSA%5D/1984_COMMODORE_PLUS-4%28264_range_prototype%29/Commodore_Plus4_Programmers_reference_guide%5BENG%5D.pdf) bleibt bis zur Auswertung des Downloads offen.

## Ergebnisse

- ACME 0.97: Build erfolgreich. PRG-Nutzlast 158 Bytes, `$1001–$109E`; Entry `$100D` / SYS 4109; Dateigröße 160 Bytes einschließlich Ladeadresse.
- Assembler prüft Programmende, Bildschirm-/Attributüberschneidung und vierstellige SYS-Adresse; ein zu großes Programm bricht den Build ab.
- VICE 3.10: Optionen über lokale `-help` geprüft. Startprotokoll bestätigt RAM-Injektion ab `$1001`, Programmstart und Autostart-Abschluss. CoreAudio öffnet die MacBook-Lautsprecher mit 48000 Hz.
- Historischer Stand von Schritt 1: Sichtprüfung und Q waren offen; die damalige Startdemo erzeugte keinen Ton. Schritt 2 bestätigt Q-Rückkehr per VICE-Monitor; Schritt 3 korrigiert die PETSCII-Anzeige und bestätigt sie per Screenshot. Aktuelle Ergebnisse und verbleibende Hörprüfung siehe [engine.md](engine.md).

## Menü-Tastatursteuerung

Gegengeprüft am installierten Commodore-KERNAL `318004-05`: `$DB11–$DC2B`
scannt die Tastatur; `$C6` enthält den Matrixindex (`$40`: keine Taste),
`$0543` die Modifier, `$0540` das Wiederholungsflag. Bit 6 sperrt die
KERNAL-Wiederholung aller Tasten. Die Demo schreibt nur dieses Flag,
liest den Scanstatus für gehaltene Cursortasten und ruft STOP `$FFE1`
frameweise auf. CPU-Menütests verwenden kontrollierte Scanwerte und einen
STOP-Stub; sie ersetzen keine Prüfung tatsächlich gehaltener Host-Tasten.
VICE prüft reale ROM-Nutzung, Navigation während Loops und die Rückgabe
der gesicherten Wiederholungseinstellung beim Exit.
